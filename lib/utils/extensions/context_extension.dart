import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// Builds a [MarkdownStyleSheet] derived from the current M3 [ColorScheme]
/// and [TextTheme]. Call inside [build] so it picks up light/dark changes.
extension ContextExtension on BuildContext {
  MarkdownStyleSheet get m3MarkdownStyle {
    final scheme = Theme.of(this).colorScheme;
    final text = Theme.of(this).textTheme;

    final body = text.bodyMedium?.copyWith(color: scheme.onSurface);
    final muted = text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);

    return MarkdownStyleSheet(
      // ── Body ────────────────────────────────────────────────────────────────
      p: body,
      pPadding: const EdgeInsets.only(bottom: 8),

      // ── Headings ─────────────────────────────────────────────────────────────
      h1: text.headlineMedium?.copyWith(color: scheme.onSurface),
      h1Padding: const EdgeInsets.only(top: 8, bottom: 12),
      h2: text.titleLarge?.copyWith(color: scheme.onSurface),
      h2Padding: const EdgeInsets.only(top: 8, bottom: 8),
      h3: text.titleMedium?.copyWith(color: scheme.onSurface, fontWeight: FontWeight.w600),
      h3Padding: const EdgeInsets.only(top: 4, bottom: 4),

      // ── Inline code ──────────────────────────────────────────────────────────
      code: text.bodySmall?.copyWith(
        color: scheme.primary,
        backgroundColor: scheme.surfaceContainerHighest,
        fontFamily: 'monospace',
      ),

      // ── Code block ───────────────────────────────────────────────────────────
      codeblockPadding: const EdgeInsets.all(12),
      codeblockDecoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: scheme.outlineVariant),
      ),

      // ── Blockquote ───────────────────────────────────────────────────────────
      blockquote: muted,
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      blockquoteDecoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(4),
        border: Border(
          left: BorderSide(color: scheme.primary, width: 4),
        ),
      ),

      // ── Horizontal rule ──────────────────────────────────────────────────────
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: scheme.outlineVariant, width: 1),
        ),
      ),

      // ── Links ────────────────────────────────────────────────────────────────
      a: text.bodyMedium?.copyWith(
        color: scheme.primary,
        decoration: TextDecoration.underline,
        decorationColor: scheme.primary,
      ),

      // ── Lists ────────────────────────────────────────────────────────────────
      listBullet: body,
      listIndent: 20,

      // ── Table ────────────────────────────────────────────────────────────────
      tableHead: text.bodyMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      tableBody: body,
      tableBorder: TableBorder.all(color: scheme.outlineVariant),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      tableColumnWidth: const FlexColumnWidth(),

      // ── Emphasis / Strong ────────────────────────────────────────────────────
      em: body?.copyWith(fontStyle: FontStyle.italic),
      strong: body?.copyWith(fontWeight: FontWeight.w700),

      // ── Scaffold background ──────────────────────────────────────────────────
      // Makes the Markdown widget's own background transparent so Scaffold's
      // surface color shows through correctly.
      blockSpacing: 8,
    );
  }
}
