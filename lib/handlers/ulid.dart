import 'package:ulid/ulid.dart';

class ULID {
  ULID._();
  // static final instance = ULID._();

  static String generate() {
    return Ulid().toCanonical();
  }
}
