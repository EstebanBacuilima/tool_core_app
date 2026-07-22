import 'package:equatable/equatable.dart';

class WorkshopSetting extends Equatable {
  final double laborHourlyRate;
  final double partsMarkupPercent;
  final double taxRatePercent;
  final String currencyCode;

  const WorkshopSetting({
    required this.laborHourlyRate,
    required this.partsMarkupPercent,
    required this.taxRatePercent,
    required this.currencyCode,
  });

  @override
  List<Object?> get props =>
      [laborHourlyRate, partsMarkupPercent, taxRatePercent, currencyCode];
}
