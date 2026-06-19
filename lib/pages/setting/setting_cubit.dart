import 'package:flutter_bloc/flutter_bloc.dart';

import 'setting_state.dart';

/// Cubit for the [SettingPage].
///
/// Owns and emits [SettingState]. Extend with logic for theme switching,
/// language selection, and other user preferences.
class SettingCubit extends Cubit<SettingState> {
  /// Creates [SettingCubit] with the default [SettingState].
  SettingCubit() : super(const SettingState());
}
