// Fixture: should trigger code-quality/swallowed-errors rule.
// ignore_for_file: unused_element, empty_catches, avoid_print

void bad() {
  try {
    throw Exception('boom');
  } catch (_) {}
}

void ok() {
  try {
    throw Exception('boom');
  } catch (e) {
    print('caught: $e');
  }
}
