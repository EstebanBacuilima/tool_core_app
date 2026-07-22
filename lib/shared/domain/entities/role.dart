import 'package:equatable/equatable.dart';

class Role extends Equatable {
  final String code;
  final String name;
  final String? description;
  final String slug;

  const Role({
    required this.code,
    required this.name,
    this.description,
    required this.slug,
  });

  @override
  List<Object?> get props => [code, name, description, slug];
}
