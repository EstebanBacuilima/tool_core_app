import '../../domain/entities/customer.dart';
import 'vehicle_dto.dart';

class CustomerDto {
  final String code;
  final String firstName;
  final String? lastName;
  final String? identificationNumber;
  final String? email;
  final String? phone;
  final String? address;
  final List<VehicleDto> vehicles;

  const CustomerDto({
    required this.code,
    required this.firstName,
    this.lastName,
    this.identificationNumber,
    this.email,
    this.phone,
    this.address,
    this.vehicles = const [],
  });

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return CustomerDto(
      code: json['code'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String?,
      identificationNumber: json['identificationNumber'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      vehicles: (json['vehicles'] as List<dynamic>? ?? const [])
          .map((e) => VehicleDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Customer toEntity() => Customer(
    code: code,
    firstName: firstName,
    lastName: lastName,
    identificationNumber: identificationNumber,
    email: email,
    phone: phone,
    address: address,
    vehicles: vehicles.map((v) => v.toEntity()).toList(),
  );
}
