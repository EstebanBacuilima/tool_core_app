enum PaymentMethod {
  cash('cash'),
  transfer('transfer'),
  card('card'),
  other('other');

  final String value;

  const PaymentMethod(this.value);

  static PaymentMethod? fromValue(String? value) {
    for (final method in values) {
      if (method.value == value) return method;
    }
    return null;
  }
}
