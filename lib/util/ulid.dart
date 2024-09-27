import 'package:ulid/ulid.dart';

class ULID {
  static String generate() {
    return Ulid().toCanonical();
  }
}
