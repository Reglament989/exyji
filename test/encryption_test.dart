import 'dart:convert';

import 'package:exyji/encryption/base.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Encryption", () {
    test("Generate key values", () async {
      final List<List<List<int>>> keys = await generateKeyPairs();
      expect(keys.first.first, isNotNull);
      expect(keys.last.last, isNotNull);
    });
    test("Signature", () async {
      final List<List<List<int>>> keys = await generateKeyPairs();
      final signature = await signObject(
          privateSeed: keys.first.first,
          message: utf8.encode("Hello its a test"));
      final ifSignVerifyed = await verifySign(
          message: utf8.encode("Hello its a test"),
          rawSignature: signature.bytes,
          publicKey: keys.first.last);
      expect(ifSignVerifyed, true);
    });

    test("AesGcm", () async {
      final encryptedBlock = await encryptBlock(
          key: "Secret key", message: utf8.encode("gcm test"));
      final decryptedSource = await decryptBlock(
          encryptedMessage: encryptedBlock, key: "Secret key");
      expect(utf8.decode(decryptedSource), "gcm test");
    });
  });
}
