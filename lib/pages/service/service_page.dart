import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          return const Scaffold(
            backgroundColor: Colors.blue,
            body: Center(child: Text('Service')),
          );
        },
      ),
    );
  }
}
