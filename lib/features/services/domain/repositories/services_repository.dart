import '../entities/service.dart';

abstract class ServicesRepository {
  Future<List<Service>> getAll();

  Future<Service> create({
    required String name,
    required double price,
    String? description,
  });

  Future<Service> update({
    required String code,
    required String name,
    required double price,
    String? description,
    bool? isActive,
  });
}
