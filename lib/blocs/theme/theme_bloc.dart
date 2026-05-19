import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ToggleTheme extends ThemeEvent {
  const ToggleTheme();
}

class SetTheme extends ThemeEvent {
  const SetTheme(this.themeMode);
  final ThemeMode themeMode;
  @override
  List<Object?> get props => [themeMode];
}

// ─── State ────────────────────────────────────────────────────────────────────

class ThemeState extends Equatable {
  const ThemeState(this.themeMode);
  final ThemeMode themeMode;
  @override
  List<Object?> get props => [themeMode];
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.system)) {
    on<ToggleTheme>(_onToggle);
    on<SetTheme>(_onSet);
  }

  void _onToggle(ToggleTheme event, Emitter<ThemeState> emit) {
    final next = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    emit(ThemeState(next));
  }

  void _onSet(SetTheme event, Emitter<ThemeState> emit) {
    emit(ThemeState(event.themeMode));
  }
}
