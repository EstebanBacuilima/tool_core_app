import 'package:equatable/equatable.dart';

/// States of the create/edit service form (bottom sheet).
sealed class ServiceFormState extends Equatable {
  const ServiceFormState();

  @override
  List<Object?> get props => [];
}

class ServiceFormInitial extends ServiceFormState {
  const ServiceFormInitial();
}

class ServiceFormSaving extends ServiceFormState {
  const ServiceFormSaving();
}

class ServiceFormSuccess extends ServiceFormState {
  const ServiceFormSuccess();
}

class ServiceFormFailure extends ServiceFormState {
  final String code;

  const ServiceFormFailure(this.code);

  @override
  List<Object?> get props => [code];
}
