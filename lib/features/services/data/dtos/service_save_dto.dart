/// Body for create/update (backend `ServiceSaveDto`).
class ServiceSaveDto {
  final String name;
  final double price;
  final String? description;

  const ServiceSaveDto({
    required this.name,
    required this.price,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'description': description,
      };
}
