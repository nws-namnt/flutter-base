import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit() : super(const AppState());

  void setThemeMode(ThemeMode mode) => emit(state.copyWith(themeMode: mode));

  void setLocale(Locale locale) => emit(state.copyWith(locale: locale));
}
