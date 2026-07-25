import 'package:equatable/equatable.dart';

class DocumentType extends Equatable {
  final String code;
  final String name;

  const DocumentType({required this.code, required this.name});

  @override
  List<Object?> get props => [code, name];
}
