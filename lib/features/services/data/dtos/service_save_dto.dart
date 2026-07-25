/// Body for create/update (backend `ServiceSaveDto`).
class ServiceSaveDto {
  final String name;
  final double price;
  final String? description;
  final bool? isActive;

  const ServiceSaveDto({
    required this.name,
    required this.price,
    this.description,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'description': description,
        if (isActive != null) 'isActive': isActive,
      };
}
