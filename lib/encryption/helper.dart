import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

SecretBox getBoxFromConcat(Uint8List data) {
  return SecretBox(data.sublist(12, data.length - 16),
      nonce: data.sublist(0, 12), mac: Mac(data.sublist(data.length - 16)));
}
