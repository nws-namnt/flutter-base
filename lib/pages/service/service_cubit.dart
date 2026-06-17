import 'package:flutter_bloc/flutter_bloc.dart';

import 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit() : super(const ServiceState());
}
