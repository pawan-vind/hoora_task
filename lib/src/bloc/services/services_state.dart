part of 'services_bloc.dart';

class ServicesState {
  final List<dynamic> services;
  final Set<int> favorites;
  final bool loading;
  final bool loadingMore;
  final int page;
  final bool hasReachedEnd;
  final String? error;

  const ServicesState._({
    required this.services,
    required this.favorites,
    required this.loading,
    required this.loadingMore,
    required this.page,
    required this.hasReachedEnd,
    this.error,
  });

  const ServicesState.initial()
    : this._(
        services: const [],
        favorites: const {},
        loading: false,
        loadingMore: false,
        page: 0,
        hasReachedEnd: false,
      );

  ServicesState copyWith({
    List<dynamic>? services,
    Set<int>? favorites,
    bool? loading,
    bool? loadingMore,
    int? page,
    bool? hasReachedEnd,
    String? error,
  }) {
    return ServicesState._(
      services: services ?? this.services,
      favorites: favorites ?? this.favorites,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      page: page ?? this.page,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      error: error,
    );
  }
}
