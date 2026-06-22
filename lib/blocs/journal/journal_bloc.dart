import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../models/trade.dart';
import '../../repositories/trade_repository.dart';
import '../../repositories/export_repository.dart';
import '../../services/secure_storage_service.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class JournalEvent extends Equatable {
  const JournalEvent();
  @override
  List<Object?> get props => [];
}

class LoadJournal extends JournalEvent {
  const LoadJournal(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class FilterJournal extends JournalEvent {
  const FilterJournal({
    this.market,
    this.positionType,
    this.rulesFollowed,
    this.startDate,
    this.endDate,
    this.tags,
  });
  final String? market;
  final PositionType? positionType;
  final RulesFollowed? rulesFollowed;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String>? tags;
  @override
  List<Object?> get props =>
      [market, positionType, rulesFollowed, startDate, endDate, tags];
}

class SortJournal extends JournalEvent {
  const SortJournal(this.sortBy, this.ascending);
  final String sortBy; // 'date', 'pnl', 'market'
  final bool ascending;
  @override
  List<Object?> get props => [sortBy, ascending];
}

class SearchJournal extends JournalEvent {
  const SearchJournal(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class ClearFilters extends JournalEvent {
  const ClearFilters();
}

class ExportJournal extends JournalEvent {
  const ExportJournal(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class AnalyzeJournal extends JournalEvent {
  const AnalyzeJournal(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class JournalState extends Equatable {
  const JournalState();
  @override
  List<Object?> get props => [];
}

class JournalLoading extends JournalState {
  const JournalLoading();
}

class JournalLoaded extends JournalState {
  const JournalLoaded({
    required this.allTrades,
    required this.filteredTrades,
    this.searchQuery = '',
    this.sortBy = 'date',
    this.ascending = false,
  });
  final List<Trade> allTrades;
  final List<Trade> filteredTrades;
  final String searchQuery;
  final String sortBy;
  final bool ascending;
  @override
  List<Object?> get props =>
      [allTrades, filteredTrades, searchQuery, sortBy, ascending];
}

class JournalExporting extends JournalState {
  const JournalExporting();
}

class JournalAnalyzing extends JournalState {
  const JournalAnalyzing();
}

class JournalExported extends JournalState {
  const JournalExported(this.filePath);
  final String filePath;
  @override
  List<Object?> get props => [filePath];
}

class JournalAnalyzed extends JournalState {
  const JournalAnalyzed({
    required this.journalContent,
    required this.userId,
  });

  final String journalContent;
  final String userId;

  @override
  List<Object?> get props => [journalContent, userId];
}

class JournalError extends JournalState {
  const JournalError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class JournalBloc extends Bloc<JournalEvent, JournalState> {
  JournalBloc({
    required TradeRepository tradeRepository,
    required ExportRepository exportRepository,
  })  : _tradeRepo = tradeRepository,
        _exportRepo = exportRepository,
        super(const JournalLoading()) {
    on<LoadJournal>(_onLoad);
    on<FilterJournal>(_onFilter);
    on<SortJournal>(_onSort);
    on<SearchJournal>(_onSearch);
    on<ClearFilters>(_onClearFilters);
    on<ExportJournal>(_onExport);
    on<AnalyzeJournal>(_onAnalyze);
  }

  final TradeRepository _tradeRepo;
  final ExportRepository _exportRepo;

  Future<void> _onLoad(LoadJournal event, Emitter<JournalState> emit) async {
    emit(const JournalLoading());
    try {
      final trades = await _tradeRepo.getTradesByUser(event.userId);
      emit(JournalLoaded(allTrades: trades, filteredTrades: trades));
    } catch (e) {
      emit(JournalError(e.toString()));
    }
  }

  void _onFilter(FilterJournal event, Emitter<JournalState> emit) {
    final current = state;
    if (current is! JournalLoaded) return;

    var filtered = current.allTrades.where((t) {
      if (event.market != null &&
          !t.market.toLowerCase().contains(event.market!.toLowerCase())) {
        return false;
      }
      if (event.positionType != null && t.positionType != event.positionType) {
        return false;
      }
      if (event.rulesFollowed != null &&
          t.rulesFollowed != event.rulesFollowed) {
        return false;
      }
      if (event.startDate != null &&
          t.dateTimeTaken.isBefore(event.startDate!)) {
        return false;
      }
      if (event.endDate != null && t.dateTimeTaken.isAfter(event.endDate!)) {
        return false;
      }
      if (event.tags != null && event.tags!.isNotEmpty) {
        if (!event.tags!.any((tag) => t.tags.contains(tag))) return false;
      }
      return true;
    }).toList();

    emit(JournalLoaded(
      allTrades: current.allTrades,
      filteredTrades: filtered,
      searchQuery: current.searchQuery,
      sortBy: current.sortBy,
      ascending: current.ascending,
    ));
  }

  void _onSort(SortJournal event, Emitter<JournalState> emit) {
    final current = state;
    if (current is! JournalLoaded) return;
    final sorted = List<Trade>.from(current.filteredTrades);
    sorted.sort((a, b) {
      int cmp;
      switch (event.sortBy) {
        case 'pnl':
          cmp = a.pnl.compareTo(b.pnl);
          break;
        case 'market':
          cmp = a.market.compareTo(b.market);
          break;
        default:
          cmp = a.dateTimeTaken.compareTo(b.dateTimeTaken);
      }
      return event.ascending ? cmp : -cmp;
    });
    emit(JournalLoaded(
      allTrades: current.allTrades,
      filteredTrades: sorted,
      searchQuery: current.searchQuery,
      sortBy: event.sortBy,
      ascending: event.ascending,
    ));
  }

  void _onSearch(SearchJournal event, Emitter<JournalState> emit) {
    final current = state;
    if (current is! JournalLoaded) return;
    final q = event.query.toLowerCase();
    final filtered = current.allTrades.where((t) {
      return t.market.toLowerCase().contains(q) ||
          t.entryStrategy.toLowerCase().contains(q) ||
          t.comments.toLowerCase().contains(q) ||
          t.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();
    emit(JournalLoaded(
      allTrades: current.allTrades,
      filteredTrades: filtered,
      searchQuery: event.query,
      sortBy: current.sortBy,
      ascending: current.ascending,
    ));
  }

  void _onClearFilters(ClearFilters event, Emitter<JournalState> emit) {
    final current = state;
    if (current is! JournalLoaded) return;
    emit(JournalLoaded(
      allTrades: current.allTrades,
      filteredTrades: current.allTrades,
    ));
  }

  Future<void> _onExport(
      ExportJournal event, Emitter<JournalState> emit) async {
    final current = state;
    final previousState = current is JournalLoaded ? current : null;
    emit(const JournalExporting());
    try {
      final trades = await _tradeRepo.getTradesByUser(event.userId);
      final filename =
          'journal_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      final directory = await SecureStorageService.instance
          .read(SecureStorageService.exportPathKey);
      final path = await _exportRepo.exportTrades(
        trades,
        filename,
        directory: directory,
      );
      emit(JournalExported(path));
      if (previousState != null) {
        emit(previousState);
      }
    } catch (e) {
      emit(JournalError(e.toString()));
      if (previousState != null) {
        emit(previousState);
      }
    }
  }

  Future<void> _onAnalyze(
      AnalyzeJournal event, Emitter<JournalState> emit) async {
    final current = state;
    final previousState = current is JournalLoaded ? current : null;
    emit(const JournalAnalyzing());

    try {
      final trades = await _tradeRepo.getTradesByUser(event.userId);
      if (trades.isEmpty) {
        throw Exception('Add trades before analyzing your journal.');
      }

      final analysisDataFeed = _buildAnalysisDataFeed(trades);
      emit(JournalAnalyzed(
        journalContent: analysisDataFeed,
        userId: event.userId,
      ));
      if (previousState != null) {
        emit(previousState);
      }
    } catch (e) {
      emit(JournalError(e.toString()));
      if (previousState != null) {
        emit(previousState);
      }
    }
  }

  String _buildAnalysisDataFeed(List<Trade> trades) {
    final buffer = StringBuffer()
      ..writeln(
        'Entry Strategy,Trade Comments,PnL,Tags,Rules Followed,Market,Risk Amount,Position Type',
      );

    for (final trade in trades) {
      buffer.writeln([
        _csvCell(_clipAnalysisText(trade.entryStrategy, 120)),
        _csvCell(_clipAnalysisText(trade.comments, 180)),
        trade.pnl.toStringAsFixed(2),
        _csvCell(trade.tags.take(6).join('|')),
        _rulesFollowedLabel(trade.rulesFollowed),
        _csvCell(trade.market),
        trade.riskAmount.toStringAsFixed(2),
        trade.positionType == PositionType.long ? 'Long' : 'Short',
      ].join(','));
    }

    return buffer.toString();
  }

  String _csvCell(String value) {
    final escaped = value.replaceAll('"', '""');
    return '"$escaped"';
  }

  String _clipAnalysisText(String value, int maxChars) {
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.length <= maxChars) return compact;
    return compact.substring(0, maxChars);
  }

  String _rulesFollowedLabel(RulesFollowed rulesFollowed) {
    switch (rulesFollowed) {
      case RulesFollowed.yes:
        return 'Yes';
      case RulesFollowed.partial:
        return 'Partial';
      case RulesFollowed.no:
        return 'No';
    }
  }
}
