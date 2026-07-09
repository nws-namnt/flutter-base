import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_logger.dart';
import 'setting_state.dart';

/// Cubit for the [SettingPage].
///
/// Owns and emits [SettingState]. Extend with logic for theme switching,
/// language selection, and other user preferences.
class SettingCubit extends Cubit<SettingState> {
  /// Creates [SettingCubit] with the default [SettingState].
  SettingCubit() : super(const SettingState());

  bool notifyScroll(ScrollNotification scrollNotification) {
    final scrollInfo = scrollNotification.metrics.toString();

    switch(scrollNotification) {
      case ScrollStartNotification _:
      case ScrollUpdateNotification _:
      case OverscrollNotification _:
      case ScrollEndNotification _:
        devLog(scrollInfo);
        break;
    }
    return true;
  }
}
