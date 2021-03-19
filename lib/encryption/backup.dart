// import 'dart:convert';
//
// import 'package:cryptography/cryptography.dart';
// import 'package:fl_andro_x/hivedb/secureStore.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
//
// final sha256 = Sha256();
//
// final x25519Algorithm = Cryptography.instance.x25519();
// final ed25519Algorithm = Ed25519();
// final aesAlgorithm = AesGcm.with256bits();
//
// Future<String> encryptBackupKey({key, password}) async {
//   final secretKeyofBackup =
//       (await sha256.hash(utf8.encode(password))).bytes.getRange(0, 32).toList();
//
//   debugPrint(secretKeyofBackup.toString());
//
//   debugPrint('SecretKey maked from password');
//
//   final nonce = aesAlgorithm.newNonce();
//
//   final encryptedKeys = await aesAlgorithm.encrypt(key,
//       secretKey: SecretKey(secretKeyofBackup), nonce: nonce);
//
//   final stringBackup = base64.encode(encryptedKeys.concatenation());
//   return stringBackup;
// }
//
// Future decryptBackupKey({source, password, type}) async {
//   final secretKeyofBackup =
//       (await sha256.hash(utf8.encode(password))).bytes.getRange(0, 32).toList();
//
//   final secretBox = SecretBox.fromConcatenation(base64.decode(source),
//       nonceLength: 12, macLength: 16);
//
//   final decrypted = await aesAlgorithm.decrypt(secretBox,
//       secretKey: SecretKey(secretKeyofBackup));
//
//   var secureStore = Hive.box<SecureStore>('SecureStore').get('store');
//
//   if (secureStore == null) {
//     secureStore = new SecureStore();
//     Hive.box<SecureStore>('SecureStore').put('store', secureStore);
//   }
//
//   if (type == 'privateX25519Key') {
//     final SimpleKeyPair keyPair =
//         await x25519Algorithm.newKeyPairFromSeed(decrypted);
//     secureStore.privateX25519Key = decrypted;
//     secureStore.pubX25519Key = (await keyPair.extractPublicKey()).bytes;
//     await secureStore.save();
//   } else if (type == 'privateEd25519Key') {
//     final SimpleKeyPair keyPair =
//         await ed25519Algorithm.newKeyPairFromSeed(decrypted);
//     secureStore.privateEd25519Key = decrypted;
//     secureStore.pubEd25519Key = (await keyPair.extractPublicKey()).bytes;
//     await secureStore.save();
//   }
// }
