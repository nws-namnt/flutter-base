import 'package:flutter/material.dart';
import 'package:flutter_base/pages/widgets/action_widget.dart';
import 'package:flutter_base/pages/widgets/flow_fab_menu_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../generated/app_assets.dart';
import '../../models/flow_fab_menu.dart';
import '../../utils/extensions/context_extension.dart';
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

  @override
  void initState() {
    super.initState();
    _cubit = ServiceCubit();
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
                  onPressed: () => context.showSnackBar(message: 'Info tapped'),
                ),
              ],
            ),
            body: ListView(
              children: [
                ActionWidget(
                  style: ActionStyle.material,
                  materialType: ActionMaterial.icon,
                  iconVariant: ActionIconVariant.filledTonal,
                  icon: Icons.message,
                  onAction: () => context.showSnackBar(message: 'Message sent'),
                ),
                ActionWidget(
                  style: ActionStyle.material,
                  materialType: ActionMaterial.icon,
                  iconVariant: ActionIconVariant.filledTonal,
                  icon: Icons.charging_station,
                  onAction: () => context.showNotify(),
                ),
                ActionWidget(
                  style: ActionStyle.material,
                  materialType: ActionMaterial.icon,
                  iconVariant: ActionIconVariant.filledTonal,
                  icon: Icons.chair,
                  onAction: () => context.showM3Banner(
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
                FadeInImage.assetNetwork(
                  placeholder: R.imagesIcArticleNotFound,
                  image: 'https://iawildlife.org/wp-content/uploads/2021/02/1-Winter-Fox.jpg',
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
