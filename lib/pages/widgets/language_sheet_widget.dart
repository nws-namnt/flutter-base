import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/app.dart';
import '../../common/app_enums.dart' show AppLanguage;

/// Bottom sheet listing every [AppLanguage], with a checkmark on the option
/// matching the current [AppState.locale].
///
/// Tapping an option calls [AppCubit.setLocale] and pops the sheet via the
/// root navigator.
class LanguageBottomSheet extends StatelessWidget {
  /// Creates a [LanguageBottomSheet].
  const LanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        final currentCode = state.locale.languageCode;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                  child: Text(
                    'Select Language',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const Divider(height: 1),

                // Language list
                ...AppLanguage.values.map((opt) {
                  final selected = opt.locale.languageCode == currentCode;

                  return ListTile(
                    leading: Text(
                      opt.flag,
                      style: const TextStyle(fontSize: 26),
                    ),
                    title: Text(
                      opt.label,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    trailing: selected
                        ? Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    )
                        : null,
                    onTap: () {
                      context.read<AppCubit>().setLocale(opt.locale);
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}