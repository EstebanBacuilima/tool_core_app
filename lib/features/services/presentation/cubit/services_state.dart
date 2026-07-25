import 'package:equatable/equatable.dart';

import '../../domain/entities/service.dart';

sealed class ServicesState extends Equatable {
  const ServicesState();

  @override
  List<Object?> get props => [];
}

class ServicesInitial extends ServicesState {
  const ServicesInitial();
}

class ServicesLoading extends ServicesState {
  const ServicesLoading();
}

class ServicesLoaded extends ServicesState {
  final List<Service> services;

  final String? togglingCode;
  final String? errorCode;

  const ServicesLoaded(this.services, {this.togglingCode, this.errorCode});

  ServicesLoaded copyWith({
    List<Service>? services,
    String? togglingCode,
    String? errorCode,
  }) {
    return ServicesLoaded(
      services ?? this.services,
      togglingCode: togglingCode,
      errorCode: errorCode,
    );
  }

  @override
  List<Object?> get props => [services, togglingCode, errorCode];
}

class ServicesFailure extends ServicesState {
  final String code;

  const ServicesFailure(this.code);

  @override
  List<Object?> get props => [code];
}
