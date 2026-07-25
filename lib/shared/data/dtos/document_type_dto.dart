import '../../domain/entities/document_type.dart';

class DocumentTypeDto {
  final String code;
  final String name;

  const DocumentTypeDto({required this.code, required this.name});

  factory DocumentTypeDto.fromJson(Map<String, dynamic> json) {
    return DocumentTypeDto(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  DocumentType toEntity() => DocumentType(code: code, name: name);
}
