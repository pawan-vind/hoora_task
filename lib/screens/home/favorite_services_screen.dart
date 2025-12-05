import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:hoora_task/src/models/service.dart';
import 'package:hoora_task/src/bloc/services/services_bloc.dart';
import 'package:hoora_task/core/color/appcolors.dart';

class FavoriteServicesScreen extends StatelessWidget {
  const FavoriteServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,

          shape: const Border(bottom: BorderSide(color: Colors.transparent)),
          automaticallyImplyLeading: false,
          toolbarHeight: 64,
          title: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildTabBar(context),
            ),
          ),
        ),
        body: SafeArea(
          child: const TabBarView(
            children: [
              _ServicesTab(allServices: true),
              _ServicesTab(allServices: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        indicator: BoxDecoration(
          color: AppColors.hooraYellow,
          borderRadius: BorderRadius.circular(6),
        ),
        dividerColor: AppColors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 12,
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        labelColor: AppColors.onSecondary,
        unselectedLabelColor: Theme.of(
          context,
        ).textTheme.bodyLarge?.color?.withOpacity(0.9),
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        physics: const BouncingScrollPhysics(),
        tabs: const [
          Tab(text: 'All Services'),
          Tab(text: 'Favorites'),
        ],
      ),
    );
  }
}

class _ServicesTab extends StatefulWidget {
  final bool allServices;
  const _ServicesTab({required this.allServices});

  @override
  State<_ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<_ServicesTab> {
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
          return _buildShimmerList(context);
        }
        if (state.error != null && state.services.isEmpty) {
          return Center(child: Text('Error: ${state.error}'));
        }

        final services = state.services.cast<Service>();
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

              return _ServiceCard(
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

  Widget _buildShimmerList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 6,
      separatorBuilder: (context, index)  => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Theme.of(context).dividerColor.withOpacity(0.08),
          highlightColor: Theme.of(context).dividerColor.withOpacity(0.02),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            height: 88,
            child: Row(
              children: [
                Container(width: 6),
                const SizedBox(width: 12),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 12,
                          width: MediaQuery.of(context).size.width * 0.5,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Service service;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _ServiceCard({
    required this.service,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700);
    final subtitleStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.75),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Theme.of(context).cardColor,
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {},
          child: Row(
            children: [
              // left accent
              Container(
                width: 6,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.hooraYellow,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),

              // content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // avatar
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.hooraYellow.withOpacity(
                          0.14,
                        ),
                        child: Text(
                          service.name.isNotEmpty
                              ? service.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: AppColors.hooraBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Main text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name, style: titleStyle),
                            const SizedBox(height: 6),
                            Text(
                              service.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: subtitleStyle,
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color: isFavorite
                                  ? AppColors.hooraYellow.withOpacity(0.14)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: onToggleFavorite,
                              iconSize: 18,
                              splashRadius: 20,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite
                                    ? AppColors.hooraYellow
                                    : Theme.of(context).iconTheme.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
