/// Inventory movement types (backend `InventoryMovementTypes`):
/// entry adds, exit subtracts, adjustment sets the absolute value.
enum MovementType {
  entry('entry'),
  exit('exit'),
  adjustment('adjustment');

  final String value;

  const MovementType(this.value);
}
