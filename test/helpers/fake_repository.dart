import 'package:hoora_task/src/models/service.dart';
import 'package:hoora_task/src/repositories/service_repository.dart';

class FakeRepository extends ServiceRepository {
  FakeRepository();

  @override
  Future<List<Service>> fetchServices({int page = 1, int pageSize = 20}) async {
    final start = (page - 1) * pageSize + 1;
    return List.generate(pageSize, (i) {
      final id = start + i;
      return Service(id: id, name: 'Service $id', description: 'Desc $id');
    });
  }
}
