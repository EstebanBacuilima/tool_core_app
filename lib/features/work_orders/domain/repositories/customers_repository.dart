import '../../../../core/models/paged_result.dart';
import '../../../../shared/domain/entities/customer.dart';
import '../../../../shared/domain/entities/document_type.dart';
import '../../../../shared/domain/entities/vehicle.dart';

abstract class CustomersRepository {
  /// `GET /customers?search=` — paginated.
  Future<PagedResult<Customer>> search(String query, {int page = 1});

  /// `GET /vehicles?search=` — paginated; matches plate or owner data.
  Future<PagedResult<Vehicle>> searchVehicles(String query, {int page = 1});

  /// `GET /customers/{customerCode}/vehicles`
  Future<List<Vehicle>> getVehicles(String customerCode);

  /// `GET /document-types` — catalog for the identification field.
  Future<List<DocumentType>> getDocumentTypes();

  /// `POST /customers`.
  Future<Customer> createCustomer({
    required String firstName,
    String? lastName,
    String? documentTypeCode,
    String? identificationNumber,
    String? phone,
  });

  /// `POST /customers/{customerCode}/vehicles`
  Future<Vehicle> createVehicle({
    required String customerCode,
    required String plate,
    required String brand,
    required String model,
    int? year,
    String? color,
    int? mileage,
  });
}
