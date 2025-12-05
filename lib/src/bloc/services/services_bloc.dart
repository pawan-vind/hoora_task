import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';

import '../../repositories/service_repository.dart';

part 'services_event.dart';
part 'services_state.dart';

class ServicesBloc extends Bloc<ServicesEvent, ServicesState> {
  final ServiceRepository repository;
  final Box<int> favoritesBox;

  ServicesBloc({required this.repository, required this.favoritesBox})
    : super(const ServicesState.initial()) {
    on<FetchServices>(_onFetch);
    on<FetchNextPage>(_onFetchNext);
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    add(LoadFavorites());
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<ServicesState> emit,
  ) async {
    final favs = favoritesBox.values.toSet();
    emit(state.copyWith(favorites: favs));
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<ServicesState> emit,
  ) async {
    final current = state.favorites;
    if (current.contains(event.id)) {
      final key = favoritesBox.keys.firstWhere(
        (k) => favoritesBox.get(k) == event.id,
        orElse: () => -1,
      );
      if (key != -1) await favoritesBox.delete(key);
      emit(state.copyWith(favorites: {...current}..remove(event.id)));
    } else {
      await favoritesBox.add(event.id);
      emit(state.copyWith(favorites: {...current}..add(event.id)));
    }
  }

  Future<void> _onFetch(
    FetchServices event,
    Emitter<ServicesState> emit,
  ) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        page: 0,
        hasReachedEnd: false,
        services: [],
      ),
    );
    await Future.delayed(const Duration(seconds: 1));
    try {
      final page = 1;
      final services = await repository.fetchServices(
        page: page,
        pageSize: event.pageSize,
      );
      final reachedEnd = services.length < event.pageSize;
      emit(
        state.copyWith(
          services: services,
          loading: false,
          page: page,
          hasReachedEnd: reachedEnd,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onFetchNext(
    FetchNextPage event,
    Emitter<ServicesState> emit,
  ) async {
    if (state.loading || state.loadingMore || state.hasReachedEnd) return;
    emit(state.copyWith(loadingMore: true));
    final nextPage = state.page + 1;
    await Future.delayed(const Duration(seconds: 1));
    try {
      final more = await repository.fetchServices(
        page: nextPage,
        pageSize: event.pageSize,
      );
      final reachedEnd = more.length < event.pageSize;
      final combined = [...state.services, ...more];
      emit(
        state.copyWith(
          services: combined,
          loadingMore: false,
          page: nextPage,
          hasReachedEnd: reachedEnd,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loadingMore: false, error: e.toString()));
    }
  }
}
