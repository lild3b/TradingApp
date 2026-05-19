import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/trade.dart';
import '../../repositories/trade_repository.dart';
import '../../repositories/export_repository.dart';
import 'package:intl/intl.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class TradeEvent extends Equatable {
  const TradeEvent();
  @override
  List<Object?> get props => [];
}

class LoadTrades extends TradeEvent {
  const LoadTrades(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class LoadTradesByDate extends TradeEvent {
  const LoadTradesByDate({required this.userId, required this.date});
  final String userId;
  final DateTime date;
  @override
  List<Object?> get props => [userId, date];
}

class AddTrade extends TradeEvent {
  const AddTrade(this.trade);
  final Trade trade;
  @override
  List<Object?> get props => [trade];
}

class UpdateTrade extends TradeEvent {
  const UpdateTrade(this.trade);
  final Trade trade;
  @override
  List<Object?> get props => [trade];
}

class DeleteTrade extends TradeEvent {
  const DeleteTrade(this.tradeId);
  final String tradeId;
  @override
  List<Object?> get props => [tradeId];
}

class ExportTrades extends TradeEvent {
  const ExportTrades(this.userId);
  final String userId;
  @override
  List<Object?> get props => [userId];
}

class ExportSingleTrade extends TradeEvent {
  const ExportSingleTrade(this.tradeId);
  final String tradeId;
  @override
  List<Object?> get props => [tradeId];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class TradeState extends Equatable {
  const TradeState();
  @override
  List<Object?> get props => [];
}

class TradesLoading extends TradeState {
  const TradesLoading();
}

class TradeOperationInProgress extends TradeState {
  const TradeOperationInProgress();
}

class TradesLoaded extends TradeState {
  const TradesLoaded(this.trades);
  final List<Trade> trades;
  @override
  List<Object?> get props => [trades];
}

class TradeOperationSuccess extends TradeState {
  const TradeOperationSuccess({required this.trades, this.message = ''});
  final List<Trade> trades;
  final String message;
  @override
  List<Object?> get props => [trades, message];
}

class TradeOperationError extends TradeState {
  const TradeOperationError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class TradeExporting extends TradeState {
  const TradeExporting();
}

class TradeExported extends TradeState {
  const TradeExported(this.filePath);
  final String filePath;
  @override
  List<Object?> get props => [filePath];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class TradeBloc extends Bloc<TradeEvent, TradeState> {
  TradeBloc({
    required TradeRepository tradeRepository,
    required ExportRepository exportRepository,
  })  : _tradeRepo = tradeRepository,
        _exportRepo = exportRepository,
        super(const TradesLoading()) {
    on<LoadTrades>(_onLoadTrades);
    on<LoadTradesByDate>(_onLoadTradesByDate);
    on<AddTrade>(_onAddTrade);
    on<UpdateTrade>(_onUpdateTrade);
    on<DeleteTrade>(_onDeleteTrade);
    on<ExportTrades>(_onExportTrades);
    on<ExportSingleTrade>(_onExportSingleTrade);
  }

  final TradeRepository _tradeRepo;
  final ExportRepository _exportRepo;

  Future<void> _onLoadTrades(LoadTrades event, Emitter<TradeState> emit) async {
    emit(const TradesLoading());
    try {
      final trades = await _tradeRepo.getTradesByUser(event.userId);
      emit(TradesLoaded(trades));
    } catch (e) {
      emit(TradeOperationError(e.toString()));
    }
  }

  Future<void> _onLoadTradesByDate(
      LoadTradesByDate event, Emitter<TradeState> emit) async {
    emit(const TradesLoading());
    try {
      final trades = await _tradeRepo.getTradesByDate(event.userId, event.date);
      emit(TradesLoaded(trades));
    } catch (e) {
      emit(TradeOperationError(e.toString()));
    }
  }

  Future<void> _onAddTrade(AddTrade event, Emitter<TradeState> emit) async {
    emit(const TradeOperationInProgress());
    try {
      await _tradeRepo.insertTrade(event.trade);
      final trades = await _tradeRepo.getTradesByUser(event.trade.userId);
      emit(TradeOperationSuccess(
          trades: trades, message: 'Trade added successfully'));
    } catch (e) {
      emit(TradeOperationError(e.toString()));
    }
  }

  Future<void> _onUpdateTrade(
      UpdateTrade event, Emitter<TradeState> emit) async {
    emit(const TradeOperationInProgress());
    try {
      await _tradeRepo.updateTrade(event.trade);
      final trades = await _tradeRepo.getTradesByUser(event.trade.userId);
      emit(TradeOperationSuccess(
          trades: trades, message: 'Trade updated successfully'));
    } catch (e) {
      emit(TradeOperationError(e.toString()));
    }
  }

  Future<void> _onDeleteTrade(
      DeleteTrade event, Emitter<TradeState> emit) async {
    final current = state;
    List<Trade> trades = [];
    if (current is TradesLoaded) trades = current.trades;
    if (current is TradeOperationSuccess) trades = current.trades;

    emit(const TradeOperationInProgress());
    try {
      await _tradeRepo.deleteTrade(event.tradeId);
      final updatedTrades = trades.where((t) => t.id != event.tradeId).toList();
      emit(TradeOperationSuccess(
          trades: updatedTrades, message: 'Trade deleted'));
    } catch (e) {
      emit(TradeOperationError(e.toString()));
    }
  }

  Future<void> _onExportTrades(
      ExportTrades event, Emitter<TradeState> emit) async {
    emit(const TradeExporting());
    try {
      final trades = await _tradeRepo.getTradesByUser(event.userId);
      final filename =
          'trades_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
      final path = await _exportRepo.exportTrades(trades, filename);
      emit(TradeExported(path));
    } catch (e) {
      emit(TradeOperationError(e.toString()));
    }
  }

  Future<void> _onExportSingleTrade(
      ExportSingleTrade event, Emitter<TradeState> emit) async {
    emit(const TradeExporting());
    try {
      final trade = await _tradeRepo.getTradeById(event.tradeId);
      if (trade == null) {
        emit(const TradeOperationError('Trade not found'));
        return;
      }
      final filename = 'trade_${trade.id.substring(0, 8)}.csv';
      final path = await _exportRepo.exportTrades([trade], filename);
      emit(TradeExported(path));
    } catch (e) {
      emit(TradeOperationError(e.toString()));
    }
  }
}
