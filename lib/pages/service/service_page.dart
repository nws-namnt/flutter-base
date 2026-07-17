import 'package:flutter/material.dart';
import 'package:flutter_base/common/app_extension.dart';
import 'package:flutter_base/pages/widgets/action_widget.dart';
import 'package:flutter_base/pages/widgets/flow_fab_menu_widget.dart';
import 'package:flutter_base/utils/app_utils.dart';
import 'package:flutter_base/utils/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../common/app_colors.dart';
import '../../generated/app_assets.dart';
import '../../models/flow_fab_menu.dart';
import '../widgets/cached_image_widget.dart';
import '../widgets/hero_image_widget.dart';
import 'service_cubit.dart';
import 'service_state.dart';

/// The Service tab screen, hosted inside the navigation shell at [Routers.service].
///
/// Instantiates and owns its [ServiceCubit]; the cubit is closed in [dispose].
class ServicePage extends StatefulWidget {
  /// Creates a [ServicePage].
  const ServicePage({super.key});

  @override
  State<ServicePage> createState() => _ServicePageState();
}

class _ServicePageState extends State<ServicePage> {
  late final ServiceCubit _cubit;

  // Drives the red color-filter opacity applied to the third hero image via
  // the Slider below.
  final _colorFilter = ValueNotifier<double>(0.5);

  @override
  void initState() {
    super.initState();
    _cubit = ServiceCubit();
  }

  @override
  void dispose() {
    _colorFilter.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ServiceCubit, ServiceState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.blue,
            floatingActionButton: FlowFabMenuWidget(
              items: [
                FlowFabMenu(
                  icon: Icons.message,
                  tooltip: 'Message',
                  onPressed: () => context.showSnackBar(message: 'Message sent'),
                ),
                FlowFabMenu(
                  icon: Icons.charging_station,
                  tooltip: 'Notify',
                  onPressed: () => context.showNotify(),
                ),
                FlowFabMenu(
                  icon: Icons.chair,
                  tooltip: 'Banner',
                  onPressed: () => context.showM3Banner(
                    message: 'Message sent',
                    actions: [
                      ActionWidget(
                        style: ActionStyle.material,
                        materialType: ActionMaterial.text,
                        onAction: () => context.hideM3Banner(),
                        label: 'Dismiss',
                      ),
                    ],
                  ),
                ),
                FlowFabMenu(
                  icon: Icons.info_outline,
                  tooltip: 'Info',
                  onPressed: () => showToast('Info tapped'),
                ),
              ],
            ),
            body: Column(
              children: [
                HeroImageWidget(
                  heroTag: '1',
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: FadeInImage.assetNetwork(
                      placeholder: R.imagesIcArticleNotFound,
                      image: 'https://iawildlife.org/wp-content/uploads/2021/02/1-Winter-Fox.jpg',
                    ),
                  ),
                ).equalExpand,
                const Divider(),
                const HeroImageWidget(
                  heroTag: '2',
                  preview: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: CachedImageWidget(
                      fit: BoxFit.contain,
                      imageUrl: 'https://iawildlife.org/wp-content/uploads/2021/02/1-Winter-Fox.jpg',
                    ),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1 / 1,
                    child: CachedImageWidget(
                      fit: BoxFit.cover,
                      width: 200,
                      imageUrl: 'https://iawildlife.org/wp-content/uploads/2021/02/1-Winter-Fox.jpg',
                    ),
                  ),
                ).equalExpand,
                const Divider(),
                Stack(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            HeroImageWidget(
                              heroTag: '3',
                              child: AspectRatio(
                                aspectRatio: 1 / 1,
                                child: ValueListenableBuilder(
                                    valueListenable: _colorFilter,
                                    builder: (context, opacity, child) {
                                      return ColorFiltered(
                                        colorFilter: ColorFilter.mode(Colors.red.withValues(alpha: opacity), BlendMode.srcIn),
                                        child: Image.asset(R.imagesIcArticleNotFound),
                                      );
                                    }
                                ),
                              ),
                            ).expanded,
                            ValueListenableBuilder(
                              valueListenable: _colorFilter,
                              builder: (context, opacity, child) {
                                return AnimatedPhysicalModel(
                                  onEnd: () {},
                                  color: Colors.red.withValues(alpha: opacity),
                                  shadowColor: AppColors.premiumBlack.withValues(alpha: 1 - opacity),
                                  clipBehavior: .none,
                                  elevation: 8,
                                  borderRadius: .circular(50),
                                  animateColor: true,
                                  animateShadowColor: true,
                                  shape: .circle,
                                  curve: Curves.linear,
                                  duration: 300.milliseconds,
                                  child: const SizedBox(
                                    width: 100,
                                    height: 100,
                                    child: Icon(Icons.android_rounded),
                                  ),
                                );
                              }
                            )
                          ],
                        ).expanded,
                        const VerticalDivider(),
                        ValueListenableBuilder(
                            valueListenable: _colorFilter,
                            builder: (context, opacity, child) {
                              return RotatedBox(
                                quarterTurns: 3,
                                child: Slider(
                                  value: opacity,
                                  onChanged: (value) {
                                    _colorFilter.value = value;
                                  },
                                  min: 0.0,
                                  max: 1.0,
                                ),
                              );
                            }
                        ),
                      ],
                    ),
                    // Vertical strip built by rotating a horizontal ListView.
                    // The SizedBox width is required: it bounds the rotated
                    // scrollable so layout resolves before the semantics pass
                    // (otherwise the new semantics engine asserts on dirty
                    // parent data).
                    Positioned(
                      top: 0,
                      left: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: 30,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: ListView.separated(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            scrollDirection: .horizontal,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10.0),
                                border: Border.all(color: AppColors.techBlack, width: .5),
                              ),
                              alignment: .center,
                              child: Text('Item ${index + 1}'),
                            ),
                            itemCount: 20,
                            separatorBuilder: (context, index) => const Gap(4.0),
                          ),
                        ),
                      ),
                    )
                  ],
                ).equalExpand,
              ],
            ).symPad(
              horizontal: 0,
              vertical: 15.0,
            ),
          );
        },
      ),
    );
  }
}
