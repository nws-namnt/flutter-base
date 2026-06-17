import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'service_cubit.dart';
import 'service_state.dart';

class ServicePage extends StatefulWidget {
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
