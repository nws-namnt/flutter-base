import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_detail_cubit.dart';
import 'home_detail_state.dart';

/// Detail screen opened from a tapped item on [HomePage] via the Material
/// "container transform" animation (see [OpenContainerWrapper]).
///
/// Instantiates and owns its [HomeDetailCubit]; the cubit is closed in
/// [dispose].
class HomeDetailPage extends StatefulWidget {
  /// Creates a [HomeDetailPage] for the tapped [item].
  const HomeDetailPage({super.key, required this.item});

  /// The label of the [HomePage] list/grid item that was tapped to open
  /// this page.
  final String item;

  @override
  State<HomeDetailPage> createState() => _HomeDetailPageState();
}

class _HomeDetailPageState extends State<HomeDetailPage> {
  late final HomeDetailCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = HomeDetailCubit()..initialize(widget.item);
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
      child: Scaffold(
        appBar: AppBar(title: Text(widget.item)),
        body: BlocBuilder<HomeDetailCubit, HomeDetailState>(
          builder: (context, state) {
            return switch (state) {
              HomeDetailInitial() ||
              HomeDetailLoading() => const Center(child: CircularProgressIndicator()),
              HomeDetailSuccess(:final mess) => Center(
                child: Text(mess ?? ''),
              ),
              HomeDetailError(:final errMess) => Center(
                child: Text(errMess ?? 'Something went wrong'),
              ),
            };
          },
        ),
      ),
    );
  }
}
