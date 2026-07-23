import 'package:equatable/equatable.dart';

/// States of the create/edit product form (bottom sheet).
sealed class ProductFormState extends Equatable {
  const ProductFormState();

  @override
  List<Object?> get props => [];
}

class ProductFormInitial extends ProductFormState {
  const ProductFormInitial();
}

class ProductFormSaving extends ProductFormState {
  const ProductFormSaving();
}

class ProductFormSuccess extends ProductFormState {
  const ProductFormSuccess();
}

class ProductFormFailure extends ProductFormState {
  final String code;

  const ProductFormFailure(this.code);

  @override
  List<Object?> get props => [code];
}
