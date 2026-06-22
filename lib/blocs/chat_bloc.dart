import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../services/ai_trading_service.dart';

const _uuid = Uuid();

class ChatConversation extends Equatable {
  const ChatConversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime updatedAt;

  ChatConversation copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
  }) {
    return ChatConversation(
      id: id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages
            .map((m) => {
                  'id': m.id,
                  'content': m.content,
                  'isUser': m.isUser,
                  'timestamp': m.timestamp.toIso8601String(),
                })
            .toList(),
      };

  static ChatConversation fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'New chat',
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      messages: ((json['messages'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map((m) => ChatMessage(
                id: m['id'] as String?,
                content: m['content'] as String? ?? '',
                isUser: m['isUser'] as bool? ?? false,
                timestamp: DateTime.tryParse(m['timestamp'] as String? ?? '') ??
                    DateTime.now(),
              ))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, messages, updatedAt];
}

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializeChatEvent extends ChatEvent {}

class NewChatConversationEvent extends ChatEvent {
  NewChatConversationEvent({this.title});
  final String? title;

  @override
  List<Object?> get props => [title];
}

class SelectChatConversationEvent extends ChatEvent {
  SelectChatConversationEvent(this.conversationId);
  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class DeleteChatConversationEvent extends ChatEvent {
  DeleteChatConversationEvent(this.conversationId);
  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

class DeleteChatMessageEvent extends ChatEvent {
  DeleteChatMessageEvent(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class SendChatMessageEvent extends ChatEvent {
  SendChatMessageEvent(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class AnalyzeJournalEvent extends ChatEvent {
  AnalyzeJournalEvent({
    required this.journalContent,
    required this.userId,
  });

  final String journalContent;
  final String userId;

  @override
  List<Object?> get props => [journalContent, userId];
}

class AnalyzeJournalFileEvent extends ChatEvent {
  AnalyzeJournalFileEvent(this.filePath);
  final String filePath;

  @override
  List<Object?> get props => [filePath];
}

abstract class ChatState extends Equatable {
  const ChatState({
    this.conversations = const [],
    this.activeConversationId,
    this.messages = const [],
  });

  final List<ChatConversation> conversations;
  final String? activeConversationId;
  final List<ChatMessage> messages;

  @override
  List<Object?> get props => [conversations, activeConversationId, messages];
}

class ChatInitialState extends ChatState {
  const ChatInitialState();
}

class ChatLoadingState extends ChatState {
  const ChatLoadingState({
    required super.conversations,
    required super.activeConversationId,
    required super.messages,
  });
}

class ChatLoadedState extends ChatState {
  const ChatLoadedState({
    required super.conversations,
    required super.activeConversationId,
    required super.messages,
  });
}

class ChatErrorState extends ChatState {
  const ChatErrorState(
    this.error, {
    required super.conversations,
    required super.activeConversationId,
    required super.messages,
  });

  final String error;

  @override
  List<Object?> get props =>
      [error, conversations, activeConversationId, messages];
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({required AiTradingService aiService, String? profileId})
      : _aiService = aiService,
        super(const ChatInitialState()) {
    on<InitializeChatEvent>(_onInitialize);
    on<NewChatConversationEvent>(_onNewConversation);
    on<SelectChatConversationEvent>(_onSelectConversation);
    on<DeleteChatConversationEvent>(_onDeleteConversation);
    on<DeleteChatMessageEvent>(_onDeleteMessage);
    on<SendChatMessageEvent>(_onSendMessage);
    on<AnalyzeJournalEvent>(_onAnalyzeJournal);
    on<AnalyzeJournalFileEvent>(_onAnalyzeJournalFile);
  }

  final AiTradingService _aiService;
  final List<ChatConversation> _conversations = [];
  String? _activeConversationId;

  AiTradingService get aiService => _aiService;

  List<ChatMessage> get _messages => _activeConversation?.messages ?? [];

  ChatConversation? get _activeConversation {
    for (final conversation in _conversations) {
      if (conversation.id == _activeConversationId) return conversation;
    }
    return null;
  }

  Future<void> _onInitialize(
    InitializeChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (_conversations.isEmpty) {
      _createConversation(title: 'New chat');
    }
    _activeConversationId ??= _conversations.first.id;
    emit(_loadedState());
  }

  Future<void> _onNewConversation(
    NewChatConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    _createConversation(title: event.title ?? 'New chat');
    await _saveConversations();
    emit(_loadedState());
  }

  Future<void> _onSelectConversation(
    SelectChatConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (_conversations.any((c) => c.id == event.conversationId)) {
      _activeConversationId = event.conversationId;
      emit(_loadedState());
    }
  }

  Future<void> _onDeleteConversation(
    DeleteChatConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    _conversations.removeWhere((c) => c.id == event.conversationId);
    if (_conversations.isEmpty) {
      _createConversation(title: 'New chat');
    } else if (_activeConversationId == event.conversationId) {
      _activeConversationId = _conversations.first.id;
    }
    await _saveConversations();
    emit(_loadedState());
  }

  Future<void> _onDeleteMessage(
    DeleteChatMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final active = _activeConversation;
    if (active == null) return;

    _replaceActiveConversation(active.copyWith(
      messages: active.messages.where((m) => m.id != event.messageId).toList(),
      updatedAt: DateTime.now(),
    ));
    emit(_loadedState());
    unawaited(_saveConversations());
  }

  Future<void> _onSendMessage(
    SendChatMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.message.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _appendMessages([userMessage], titleSeed: text);
    await _saveConversations();
    emit(_loadingState());
    await Future<void>.delayed(const Duration(milliseconds: 80));

    try {
      final response = await _aiService.getTradingAdvice(
        text,
        conversationHistory: _messages,
      );
      _appendMessages([
        ChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ]);
      await _saveConversations();
      emit(_loadedState());
    } catch (e) {
      await _appendError(e);
      emit(_errorState(_formatError(e)));
    }
  }

  Future<void> _onAnalyzeJournal(
    AnalyzeJournalEvent event,
    Emitter<ChatState> emit,
  ) async {
    const prompt = 'Please analyze my trading journal';
    _appendMessages([
      ChatMessage(
        content: prompt,
        isUser: true,
        timestamp: DateTime.now(),
      )
    ], titleSeed: 'Journal analysis');
    emit(_loadingState());
    unawaited(_saveConversations());
    await Future<void>.delayed(const Duration(milliseconds: 80));

    try {
      final response = await _aiService.analyzeTradeJournal(
        event.journalContent,
        event.userId,
      );
      _appendMessages([
        ChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ]);
      emit(_loadedState());
      unawaited(_saveConversations());
    } catch (e) {
      await _appendError(e);
      emit(_errorState(_formatError(e)));
    }
  }

  Future<void> _onAnalyzeJournalFile(
    AnalyzeJournalFileEvent event,
    Emitter<ChatState> emit,
  ) async {
    const prompt = 'Analyzing my trading journal file...';
    _appendMessages([
      ChatMessage(
        content: prompt,
        isUser: true,
        timestamp: DateTime.now(),
      )
    ], titleSeed: 'Journal file analysis');
    emit(_loadingState());
    unawaited(_saveConversations());
    await Future<void>.delayed(const Duration(milliseconds: 80));

    try {
      final response =
          await _aiService.analyzeTradeJournalFromFile(event.filePath);
      _appendMessages([
        ChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ]);
      emit(_loadedState());
      unawaited(_saveConversations());
    } catch (e) {
      await _appendError(e);
      emit(_errorState(_formatError(e)));
    }
  }

  Future<void> _appendError(Object error) async {
    _appendMessages([
      ChatMessage(
        content: _formatError(error),
        isUser: false,
        timestamp: DateTime.now(),
      ),
    ]);
    unawaited(_saveConversations());
  }

  void _appendMessages(List<ChatMessage> messages, {String? titleSeed}) {
    var active = _activeConversation;
    active ??= _createConversation(title: 'New chat');

    final currentMessages = [...active.messages, ...messages];
    final shouldRetitle =
        active.title == 'New chat' && titleSeed != null && titleSeed.isNotEmpty;
    _replaceActiveConversation(active.copyWith(
      title: shouldRetitle ? _conversationTitle(titleSeed) : active.title,
      messages: currentMessages,
      updatedAt: DateTime.now(),
    ));
  }

  ChatConversation _createConversation({required String title}) {
    final conversation = ChatConversation(
      id: _uuid.v4(),
      title: title,
      messages: const [],
      updatedAt: DateTime.now(),
    );
    _conversations.insert(0, conversation);
    _activeConversationId = conversation.id;
    return conversation;
  }

  void _replaceActiveConversation(ChatConversation updated) {
    final index = _conversations.indexWhere((c) => c.id == updated.id);
    if (index == -1) return;
    _conversations[index] = updated;
    _conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> _saveConversations() async {
    return;
  }

  ChatLoadedState _loadedState() => ChatLoadedState(
        conversations: List.unmodifiable(_conversations),
        activeConversationId: _activeConversationId,
        messages: List.unmodifiable(_messages),
      );

  ChatLoadingState _loadingState() => ChatLoadingState(
        conversations: List.unmodifiable(_conversations),
        activeConversationId: _activeConversationId,
        messages: List.unmodifiable(_messages),
      );

  ChatErrorState _errorState(String error) => ChatErrorState(
        error,
        conversations: List.unmodifiable(_conversations),
        activeConversationId: _activeConversationId,
        messages: List.unmodifiable(_messages),
      );

  String _conversationTitle(String seed) {
    final compact = seed.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= 34) return compact;
    return '${compact.substring(0, 34)}...';
  }

  String _formatError(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  @override
  Future<void> close() {
    _aiService.dispose();
    return super.close();
  }
}
