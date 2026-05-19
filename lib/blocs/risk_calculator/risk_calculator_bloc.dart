import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/risk_calculation.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class RiskCalculatorEvent extends Equatable {
  const RiskCalculatorEvent();
  @override
  List<Object?> get props => [];
}

class UpdateRiskBalance extends RiskCalculatorEvent {
  const UpdateRiskBalance(this.balance);
  final double balance;
  @override
  List<Object?> get props => [balance];
}

class UpdateRiskPercent extends RiskCalculatorEvent {
  const UpdateRiskPercent(this.percent);
  final double percent;
  @override
  List<Object?> get props => [percent];
}

class UpdateEntryPrice extends RiskCalculatorEvent {
  const UpdateEntryPrice(this.price);
  final double price;
  @override
  List<Object?> get props => [price];
}

class UpdateStopLossPrice extends RiskCalculatorEvent {
  const UpdateStopLossPrice(this.price);
  final double price;
  @override
  List<Object?> get props => [price];
}

class UpdateRewardRatio extends RiskCalculatorEvent {
  const UpdateRewardRatio(this.ratio);
  final double ratio;
  @override
  List<Object?> get props => [ratio];
}

class UpdatePositionDirection extends RiskCalculatorEvent {
  const UpdatePositionDirection(this.isLong);
  final bool isLong;
  @override
  List<Object?> get props => [isLong];
}

class ResetCalculator extends RiskCalculatorEvent {
  const ResetCalculator();
}

// ─── States ───────────────────────────────────────────────────────────────────

class RiskCalculatorState extends Equatable {
  const RiskCalculatorState(this.calculation);
  final RiskCalculation calculation;
  @override
  List<Object?> get props => [calculation];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class RiskCalculatorBloc
    extends Bloc<RiskCalculatorEvent, RiskCalculatorState> {
  RiskCalculatorBloc()
      : super(const RiskCalculatorState(RiskCalculation.initial)) {
    on<UpdateRiskBalance>(_onBalance);
    on<UpdateRiskPercent>(_onRiskPercent);
    on<UpdateEntryPrice>(_onEntryPrice);
    on<UpdateStopLossPrice>(_onStopLoss);
    on<UpdateRewardRatio>(_onRewardRatio);
    on<UpdatePositionDirection>(_onDirection);
    on<ResetCalculator>(_onReset);
  }

  void _onBalance(UpdateRiskBalance e, Emitter<RiskCalculatorState> emit) =>
      emit(RiskCalculatorState(state.calculation.copyWith(balance: e.balance)));

  void _onRiskPercent(UpdateRiskPercent e, Emitter<RiskCalculatorState> emit) =>
      emit(RiskCalculatorState(state.calculation.copyWith(riskPercent: e.percent)));

  void _onEntryPrice(UpdateEntryPrice e, Emitter<RiskCalculatorState> emit) =>
      emit(RiskCalculatorState(state.calculation.copyWith(entryPrice: e.price)));

  void _onStopLoss(UpdateStopLossPrice e, Emitter<RiskCalculatorState> emit) =>
      emit(RiskCalculatorState(state.calculation.copyWith(stopLossPrice: e.price)));

  void _onRewardRatio(UpdateRewardRatio e, Emitter<RiskCalculatorState> emit) =>
      emit(RiskCalculatorState(state.calculation.copyWith(rewardRatio: e.ratio)));

  void _onDirection(UpdatePositionDirection e, Emitter<RiskCalculatorState> emit) =>
      emit(RiskCalculatorState(state.calculation.copyWith(isLong: e.isLong)));

  void _onReset(ResetCalculator e, Emitter<RiskCalculatorState> emit) =>
      emit(const RiskCalculatorState(RiskCalculation.initial));
}
