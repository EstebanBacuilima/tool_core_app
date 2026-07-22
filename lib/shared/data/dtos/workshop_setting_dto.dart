import '../../domain/entities/workshop_setting.dart';

class WorkshopSettingDto {
  final double laborHourlyRate;
  final double partsMarkupPercent;
  final double taxRatePercent;
  final String currencyCode;

  const WorkshopSettingDto({
    required this.laborHourlyRate,
    required this.partsMarkupPercent,
    required this.taxRatePercent,
    required this.currencyCode,
  });

  factory WorkshopSettingDto.fromJson(Map<String, dynamic> json) {
    return WorkshopSettingDto(
      laborHourlyRate: (json['laborHourlyRate'] as num? ?? 0).toDouble(),
      partsMarkupPercent: (json['partsMarkupPercent'] as num? ?? 0).toDouble(),
      taxRatePercent: (json['taxRatePercent'] as num? ?? 0).toDouble(),
      currencyCode: json['currencyCode'] as String? ?? '',
    );
  }

  WorkshopSetting toEntity() => WorkshopSetting(
        laborHourlyRate: laborHourlyRate,
        partsMarkupPercent: partsMarkupPercent,
        taxRatePercent: taxRatePercent,
        currencyCode: currencyCode,
      );
}
