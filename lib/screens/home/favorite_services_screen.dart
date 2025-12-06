import 'package:flutter/material.dart';
import 'package:hoora_task/core/color/appcolors.dart';
import 'package:hoora_task/screens/home/widgets/service_tabs.dart';

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
              ServicesTab(allServices: true),
              ServicesTab(allServices: false),
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
