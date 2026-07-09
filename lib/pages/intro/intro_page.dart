import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../common/app_colors.dart';
import '../../common/app_dimensions.dart';
import '../../models/intro_entity.dart';
import '../../routing/routers.dart';
import '../../storage/app_preference.dart';
import 'intro_cubit.dart';
import 'intro_state.dart';

/// Onboarding carousel shown before the app shell, at [Routers.intro].
///
/// Each [IntroEntity]'s image/color fills the entire screen edge-to-edge —
/// including the area behind Skip and the bottom action row. Those controls
/// float on top as an overlay instead of sitting in their own opaque strip,
/// so the slide's color/image always covers the whole screen.
///
/// Action layout:
/// - Skip — persistent overlay button, top-right corner, shown on every slide.
/// - Bottom row: Previous (left, hidden on the first slide) and, on the
///   right, either Next (first/middle slides) or "Let's explore" (last slide).
///
/// Skip and "Let's explore" both persist [AppPreference.setSeenIntro] before
/// leaving, so [SplashCubit] sends future launches straight to [Routers.home].
class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late final IntroCubit _cubit;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _cubit = IntroCubit();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _cubit.close();
    super.dispose();
  }

  // Drives the PageController from Next/Previous button taps. Swipes go the
  // other direction — PageView.onPageChanged -> IntroCubit.onPageChanged.
  void _animateToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Skip and Explore both mark onboarding as seen, then exit to Home. Kept
  // as separate callbacks — they represent different user intents (bail out
  // early vs. finish reading) and may diverge later (e.g. separate analytics
  // events).
  Future<void> _onSkip() async {
    await AppPreference.instance.setCompleteIntro(true);
    if (!mounted) return;
    context.go(Routers.home.routerPath);
  }

  Future<void> _onExplore() async {
    await AppPreference.instance.setCompleteIntro(true);
    if (!mounted) return;
    context.go(Routers.home.routerPath);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocConsumer<IntroCubit, IntroState>(
        listenWhen: (previous, current) =>
            previous.currentIndex != current.currentIndex,
        listener: (context, state) => _animateToPage(state.currentIndex),
        builder: (context, state) {
          final currentItem = state.items[state.currentIndex];

          return Scaffold(
            body: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: state.items.length,
                  onPageChanged: _cubit.onPageChanged,
                  itemBuilder: (context, index) => _IntroCover(item: state.items[index]),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.spacing),
                          child: TextButton(
                            onPressed: _onSkip,
                            style: TextButton.styleFrom(foregroundColor: Colors.white),
                            child: const Text('Skip'),
                          ),
                        ),
                      ),
                      const Spacer(),
                      _IntroContent(item: currentItem),
                      _IntroActions(
                        isFirstPage: state.isFirstPage,
                        isLastPage: state.isLastPage,
                        onNext: _cubit.next,
                        onPrevious: _cubit.previous,
                        onExplore: _onExplore,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Full-bleed background for one [IntroEntity] — an image or solid color
/// filling its entire [PageView] cell.
class _IntroCover extends StatelessWidget {
  const _IntroCover({required this.item});

  final IntroEntity item;

  @override
  Widget build(BuildContext context) {
    return switch (item.type) {
      IntroItemType.image => Image.asset(item.imagePath!, fit: BoxFit.cover),
      IntroItemType.color => ColoredBox(color: item.color ?? AppColors.pureWhite),
    };
  }
}

/// Title + description for the currently visible slide, rendered in white
/// so it stays legible over an arbitrary background color/image.
class _IntroContent extends StatelessWidget {
  const _IntroContent({required this.item});

  final IntroEntity item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.padding * 1.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: textTheme.headlineSmall?.copyWith(color: Colors.white),
          ),
          const Gap(AppDimensions.spacing * 4),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
          const Gap(AppDimensions.spacing * 4),
        ],
      ),
    );
  }
}

/// Bottom action row — Previous (left) and Next / "Let's explore" (right),
/// shown or hidden per slide position. Skip lives outside this row, as a
/// persistent overlay button (see [IntroPage] doc comment).
class _IntroActions extends StatelessWidget {
  const _IntroActions({
    required this.isFirstPage,
    required this.isLastPage,
    required this.onNext,
    required this.onPrevious,
    required this.onExplore,
  });

  final bool isFirstPage;
  final bool isLastPage;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.padding,
        vertical: AppDimensions.padding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          isFirstPage
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: onPrevious,
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: const Text('Previous'),
                ),
          isLastPage
              ? FilledButton(onPressed: onExplore, child: const Text("Let's explore"))
              : FilledButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}
