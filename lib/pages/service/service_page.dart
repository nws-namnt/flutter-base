import 'package:flutter/material.dart';
import 'package:flutter_base/pages/widgets/action_widget.dart';
import 'package:flutter_base/pages/widgets/flow_fab_menu_widget.dart';
import 'package:flutter_base/utils/app_utils.dart';
import 'package:flutter_base/utils/extensions/extensions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                HeroImageWidget(
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
                ).equalExpand,
                const Divider(),
                ValueListenableBuilder(
                  valueListenable: _colorFilter,
                  builder: (context, opacity, child) {
                    return Slider(
                      value: opacity,
                      onChanged: (value) {
                        _colorFilter.value = value;
                      },
                      min: 0.0,
                      max: 1.0,
                    );
                  }
                )
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
