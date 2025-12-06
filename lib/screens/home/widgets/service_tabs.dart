import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hoora_task/screens/home/widgets/service_card.dart';
import 'package:hoora_task/screens/shimmer/home_simmer.dart';
import 'package:hoora_task/src/bloc/services/services_bloc.dart';
import 'package:hoora_task/src/models/service_model.dart';

class ServicesTab extends StatefulWidget {
  final bool allServices;
  const ServicesTab({super.key, required this.allServices});

  @override
  State<ServicesTab> createState() => ServicesTabState();
}

class ServicesTabState extends State<ServicesTab> {
  final _scrollThreshold = 200.0;
  late final ScrollController _controller;

  void _onScroll() {
    if (!_controller.hasClients) return;
    final max = _controller.position.maxScrollExtent;
    final pos = _controller.position.pixels;
    if (max - pos <= _scrollThreshold) {
      context.read<ServicesBloc>().add(FetchNextPage(pageSize: 20));
    }
  }

  Future<void> _onRefresh() async {
    context.read<ServicesBloc>().add(FetchServices(pageSize: 20));
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.removeListener(_onScroll);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        if (state.loading && state.services.isEmpty) {
          return const BuildShimmerList();
        }
        if (state.error != null && state.services.isEmpty) {
          return Center(child: Text('Error: ${state.error}'));
        }

        final services = state.services.cast<ServiceModel>();
        final favorites = state.favorites;
        final list = widget.allServices
            ? services
            : services.where((s) => favorites.contains(s.id)).toList();

        if (list.isEmpty) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Center(
                  child: Column(
                    children: const [
                      Icon(Icons.star_border, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No items', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final itemCount = list.length + (state.loadingMore ? 1 : 0);

        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.separated(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: itemCount,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index >= list.length) {
                if (state.hasReachedEnd) return const SizedBox.shrink();
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              if (list.length >= 20 && index == list.length - 20) {
                if (!state.loadingMore && !state.hasReachedEnd) {
                  context.read<ServicesBloc>().add(FetchNextPage(pageSize: 20));
                }
              }

              final s = list[index];
              final isFav = favorites.contains(s.id);

              return ServiceCard(
                service: s,
                isFavorite: isFav,
                onToggleFavorite: () =>
                    context.read<ServicesBloc>().add(ToggleFavorite(s.id)),
              );
            },
          ),
        );
      },
    );
  }
}
