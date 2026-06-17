import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../common/app_colors.dart';
import 'setting_cubit.dart';
import 'setting_state.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late final SettingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = SettingCubit();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<SettingCubit, SettingState>(
        builder: (context, state) {
          return const Scaffold(
            backgroundColor: AppColors.oldLace,
            body: Center(child: Text('Settings')),
          );
        },
      ),
    );
  }
}
