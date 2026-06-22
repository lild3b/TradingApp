import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/chat_bloc.dart';
import '../blocs/user_profile/user_profile_bloc.dart';
import '../services/ai_trading_service.dart';
import '../services/secure_storage_service.dart';

class ChatModal extends StatefulWidget {
  const ChatModal({
    super.key,
    this.initialJournalContent,
    this.initialJournalUserId,
  });

  final String? initialJournalContent;
  final String? initialJournalUserId;

  @override
  State<ChatModal> createState() => _ChatModalState();
}

class _ChatModalState extends State<ChatModal> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  late ChatBloc _chatBloc;
  late GrokTradingService _grokService;
  String? _profileId;
  bool _apiConfigured = false;
  bool _loadingSavedConfig = true;
  bool _initialJournalAnalysisStarted = false;
  bool _showConversations = false;

  @override
  void initState() {
    super.initState();
    _grokService = GrokTradingService();

    String? profileId;
    try {
      final profileState = context.read<UserProfileBloc>().state;
      if (profileState is ProfileSelected) {
        profileId = profileState.selectedProfile.id;
      }
    } catch (_) {
      profileId = null;
    }

    _profileId = profileId;
    _chatBloc = ChatBloc(aiService: _grokService, profileId: profileId);
    _chatBloc.add(InitializeChatEvent());
    _loadSavedApiConfig();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  Future<void> _loadSavedApiConfig() async {
    final apiKey = await SecureStorageService.instance.read(
      SecureStorageService.groqApiKeyKey,
    );
    final model = await SecureStorageService.instance.read(
      SecureStorageService.groqModelNameKey,
    );

    if (!mounted) return;

    final hasSavedConfig = apiKey != null &&
        apiKey.trim().isNotEmpty &&
        model != null &&
        model.trim().isNotEmpty;
    if (hasSavedConfig) {
      _apiKeyController.text = apiKey.trim();
      _modelController.text = model.trim();
      _grokService.setGrokApiKey(apiKey);
      _grokService.setModel(model);
    }

    setState(() {
      _apiConfigured = hasSavedConfig;
      _loadingSavedConfig = false;
    });
    _startInitialJournalAnalysisIfReady();
  }

  Future<void> _configureApi() async {
    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim();

    if (apiKey.isNotEmpty && model.isNotEmpty) {
      await SecureStorageService.instance.write(
        SecureStorageService.groqApiKeyKey,
        apiKey,
      );
      await SecureStorageService.instance.write(
        SecureStorageService.groqModelNameKey,
        model,
      );
      _grokService.setGrokApiKey(apiKey);
      _grokService.setModel(model);
      if (!mounted) return;
      setState(() {
        _apiConfigured = true;
      });
      _startInitialJournalAnalysisIfReady();
    }
  }

  void _startInitialJournalAnalysisIfReady() {
    final journalContent = widget.initialJournalContent;
    if (_initialJournalAnalysisStarted ||
        !_apiConfigured ||
        journalContent == null ||
        journalContent.trim().isEmpty) {
      return;
    }

    _initialJournalAnalysisStarted = true;
    _chatBloc.add(NewChatConversationEvent(title: 'Journal analysis'));
    _chatBloc.add(AnalyzeJournalEvent(
      journalContent: journalContent,
      userId: widget.initialJournalUserId ?? _profileId ?? 'unknown',
    ));
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      _chatBloc.add(SendChatMessageEvent(_controller.text));
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return BlocProvider.value(
      value: _chatBloc,
      child: Dialog(
        child: SizedBox(
          width: size.width >= 1200
              ? 980
              : size.width >= 800
                  ? size.width * 0.82
                  : size.width * 0.94,
          height: size.height * 0.84,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: theme.dividerColor),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history_rounded),
                      tooltip: 'Conversations',
                      onPressed: () {
                        setState(() {
                          _showConversations = !_showConversations;
                        });
                      },
                    ),
                    Expanded(
                      child: Text('Groq Trading Assistant',
                          style: theme.textTheme.titleLarge),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_comment_outlined),
                      tooltip: 'New chat',
                      onPressed: () {
                        _chatBloc.add(NewChatConversationEvent());
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              if (_loadingSavedConfig)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (!_apiConfigured)
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Setup Groq API',
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Get your Groq API key from https://console.groq.com/',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: _modelController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Model Name',
                              hintText: 'Enter the model name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _apiKeyController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              labelText: 'Groq API Key',
                              hintText: 'Enter your Groq API key',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _apiKeyController.text.isNotEmpty &&
                                      _modelController.text.isNotEmpty
                                  ? _configureApi
                                  : null,
                              child: const Text('Configure'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Both API key and model are required',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _apiConfigured = true;
                                });
                                _startInitialJournalAnalysisIfReady();
                              },
                              child: const Text('Continue Without Setup'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      List<ChatMessage> messages = [];
                      final isLoading = state is ChatLoadingState;

                      if (state is ChatLoadedState) {
                        messages = state.messages;
                      } else if (state is ChatLoadingState) {
                        messages = state.messages;
                      } else if (state is ChatErrorState) {
                        messages = state.messages;
                      }

                      return Row(
                        children: [
                          if (_showConversations)
                            _ConversationList(
                              conversations: state.conversations,
                              activeConversationId: state.activeConversationId,
                              onSelect: (id) {
                                _chatBloc.add(SelectChatConversationEvent(id));
                              },
                              onDelete: (id) {
                                _chatBloc.add(DeleteChatConversationEvent(id));
                              },
                            ),
                          Expanded(
                            child: messages.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.chat_bubble_outline,
                                          size: 48,
                                          color: theme.hintColor,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Ask trading questions to Groq...',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                            color: theme.hintColor,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.all(12),
                                    itemCount:
                                        messages.length + (isLoading ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (isLoading &&
                                          index == messages.length) {
                                        return const _ChatLoadingTile();
                                      }

                                      final message = messages[index];
                                      return _ChatMessageTile(
                                        message: message,
                                        onDelete: () {
                                          _chatBloc.add(
                                            DeleteChatMessageEvent(message.id),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              if (_apiConfigured)
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.dividerColor)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      final isLoading = state is ChatLoadingState;
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              enabled: !isLoading,
                              decoration: InputDecoration(
                                hintText: 'Type a question...',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                isDense: true,
                              ),
                              maxLines: 1,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send_rounded),
                            onPressed: isLoading ? null : _sendMessage,
                            tooltip: 'Send',
                          ),
                        ],
                      );
                    },
                  ),
                )
              else if (!_loadingSavedConfig)
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: theme.dividerColor)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _apiKeyController.clear();
                          _modelController.clear();
                        });
                      },
                      child: const Text('Clear Setup Fields'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessageTile extends StatelessWidget {
  const _ChatMessageTile({
    required this.message,
    required this.onDelete,
  });

  final ChatMessage message;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isUser)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            tooltip: 'Delete message',
            onPressed: onDelete,
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            decoration: BoxDecoration(
              color: isUser
                  ? theme.colorScheme.primary
                  : theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isUser ? theme.colorScheme.onPrimary : null,
              ),
            ),
          ),
        ),
        if (!isUser)
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            tooltip: 'Delete message',
            onPressed: onDelete,
          ),
      ],
    );
  }
}

class _ChatLoadingTile extends StatelessWidget {
  const _ChatLoadingTile();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'AI is reading your journal...',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  const _ConversationList({
    required this.conversations,
    required this.activeConversationId,
    required this.onSelect,
    required this.onDelete,
  });

  final List<ChatConversation> conversations;
  final String? activeConversationId;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 220,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: conversations.isEmpty
          ? Center(
              child: Text(
                'No chats',
                style: theme.textTheme.bodySmall,
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final selected = conversation.id == activeConversationId;
                return ListTile(
                  dense: true,
                  selected: selected,
                  title: Text(
                    conversation.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    _conversationSubtitle(conversation),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onSelect(conversation.id),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    tooltip: 'Delete conversation',
                    onPressed: () => onDelete(conversation.id),
                  ),
                );
              },
            ),
    );
  }

  String _conversationSubtitle(ChatConversation conversation) {
    if (conversation.messages.isEmpty) return 'No messages';
    final latest = conversation.messages.last.content.trim();
    return latest.isEmpty ? 'Empty message' : latest;
  }
}
