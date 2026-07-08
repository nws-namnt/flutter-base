import 'package:flutter/widgets.dart';

/// A reusable [EmptyWidget] instance — prefer this over `const EmptyWidget()`.
const empty = EmptyWidget();

/// A widget that renders nothing and creates no [RenderObject].
///
/// APIs sometimes force you to return a widget when you really want to
/// render nothing (e.g. a builder callback that can't return null). The
/// common workaround, `const SizedBox()`, still creates a [RenderObject],
/// which lives in the render tree and costs layout/paint even though it
/// paints nothing. [EmptyWidget] avoids that: it only creates an [Element]
/// and does nothing during build.
///
/// Usage: prefer the top-level [empty] constant instead of constructing
/// this directly.
///
/// Note:
/// - Do not use inside widgets that take a list of children (e.g. [Row],
///   [Column], [ListView]). Omit the widget from the list instead —
///   using [EmptyWidget] there can produce unexpected results.
/// - A debug assertion fires if [EmptyWidget] is mounted directly under a
///   [MultiChildRenderObjectElement] to guard against that exact misuse.
class EmptyWidget extends Widget {
  /// Creates an [EmptyWidget].
  const EmptyWidget({super.key});

  @override
  Element createElement() => _EmptyElement(this);
}

class _EmptyElement extends Element {
  _EmptyElement(EmptyWidget super.widget);

  @override
  void mount(Element? parent, dynamic newSlot) {
    assert(parent is! MultiChildRenderObjectElement, """
        You are using EmptyWidget under a MultiChildRenderObjectElement.
        This suggests a possibility that the EmptyWidget is not needed or is being used improperly.
        Make sure it can't be replaced with an inline conditional or
        omission of the target widget from a list.
        """);

    super.mount(parent, newSlot);
  }

  @override
  bool get debugDoingBuild => false;

  @override
  void performRebuild() {
    super.performRebuild();
  }
}