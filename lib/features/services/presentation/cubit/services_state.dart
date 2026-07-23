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

  const ServicesLoaded(this.services);

  @override
  List<Object?> get props => [services];
}

class ServicesFailure extends ServicesState {
  final String code;

  const ServicesFailure(this.code);

  @override
  List<Object?> get props => [code];
}
