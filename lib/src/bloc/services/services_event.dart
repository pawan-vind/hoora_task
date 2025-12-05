part of 'services_bloc.dart';

abstract class ServicesEvent {}

class FetchServices extends ServicesEvent {
  final int pageSize;
  FetchServices({this.pageSize = 20});
}

class FetchNextPage extends ServicesEvent {
  final int pageSize;
  FetchNextPage({this.pageSize = 20});
}

class ToggleFavorite extends ServicesEvent {
  final int id;
  ToggleFavorite(this.id);
}

class LoadFavorites extends ServicesEvent {}
