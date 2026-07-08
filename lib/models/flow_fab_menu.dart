import 'package:flutter/material.dart';

class FlowFabMenu {
  /// Creates a [FlowFabMenu].
  const FlowFabMenu({
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  /// Icon shown on the mini [FloatingActionButton].
  final IconData icon;

  /// Called after the menu collapses back into the toggle button.
  final VoidCallback onPressed;

  /// Optional tooltip for the mini button.
  final String? tooltip;
}