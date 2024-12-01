import 'package:ulid/ulid.dart';

class UlidHandler {
  UlidHandler._();
  // static final instance = ULID._();

  static String generate() {
    return Ulid().toCanonical();
  }
}
