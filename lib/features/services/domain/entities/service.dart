import 'package:equatable/equatable.dart';

/// Labor/service catalog item. Identified by [code].
class Service extends Equatable {
  final String code;
  final String name;
  final double price;
  final String? description;
  final bool isActive;

  const Service({
    required this.code,
    required this.name,
    required this.price,
    this.description,
    required this.isActive,
  });

  @override
  List<Object?> get props => [code, name, price, description, isActive];
}
