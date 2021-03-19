// import 'dart:convert';
//
// import 'package:cryptography/cryptography.dart';
// import 'package:fl_andro_x/hivedb/secureStore.dart';
// import 'package:hive/hive.dart';
//
// final x25519Algorithm = Cryptography.instance.x25519();
// final ed25519Algorithm = Ed25519();
// final aesAlgorithm = AesGcm.with256bits();
// final hkdfAlgorithm = Hkdf(hmac: Hmac(Sha256()), outputLength: 32);
//
// Future<Map> getKeyPairKeys() async {
//   final x25519KeyPair = await x25519Algorithm.newKeyPair();
//   final ed25519KeyPair = await ed25519Algorithm.newKeyPair();
//   final pubEd25519Key = await ed25519KeyPair.extractPublicKey();
//   final pubX25519KeyPair = await x25519KeyPair.extractPublicKey();
//   var secureBox = Hive.box<SecureStore>('SecureStore');
//   if (!secureBox.isOpen) {
//     await Hive.openBox<SecureStore>('SecureStore');
//   }
//   SecureStore store = SecureStore();
//   store.privateEd25519Key = await ed25519KeyPair.extractPrivateKeyBytes();
//   store.privateX25519Key = await x25519KeyPair.extractPrivateKeyBytes();
//   store.pubEd25519Key = pubEd25519Key.bytes;
//   store.pubX25519Key = pubX25519KeyPair.bytes;
//   secureBox.put('store', store);
//   Map returnable = Map.of({
//     'pubEd25519Key': pubEd25519Key.bytes,
//     'pubX25519Key': pubX25519KeyPair.bytes,
//     'privateEd25519Key': store.privateEd25519Key,
//     'privateX25519Key': store.privateX25519Key
//   });
//   return returnable;
// }
//
// Future<Map> encryptSecret(secretBytes, pubX25519) async {
//   var secureBox = Hive.box<SecureStore>('SecureStore');
//   final SimpleKeyPair keyPair = await x25519Algorithm
//       .newKeyPairFromSeed(secureBox.get('store').privateX25519Key);
//   final SimplePublicKey pubKeyX25519 = SimplePublicKey(
//       new List<int>.from(pubX25519.whereType<dynamic>()),
//       type: KeyPairType.x25519);
//   final SecretKey secretKeyOfSecret = await x25519Algorithm.sharedSecretKey(
//       keyPair: keyPair, remotePublicKey: pubKeyX25519);
//   final secretSalt = aesAlgorithm.newNonce();
//   final nonce = aesAlgorithm.newNonce();
//   final SecretKey secretKey = await hkdfAlgorithm.deriveKey(
//       secretKey: secretKeyOfSecret, nonce: secretSalt);
//   final secretBox = await aesAlgorithm.encrypt(secretBytes,
//       secretKey: secretKey, nonce: nonce);
//   return {
//     'encryptedSecret': secretBox.concatenation(),
//     'secretNonce': secretSalt
//   };
// }
//
// Future<List<int>> decryptSecret(encryptedSecret, pubX25519) async {
//   var secureBox = Hive.box<SecureStore>('SecureStore');
//   final SimpleKeyPair keyPair = await x25519Algorithm
//       .newKeyPairFromSeed(secureBox.get('store').privateX25519Key);
//   final SimplePublicKey pubKeyX25519 = SimplePublicKey(
//       new List<int>.from(pubX25519.whereType<dynamic>()),
//       type: KeyPairType.x25519);
//   final SecretKey secretKey = await x25519Algorithm.sharedSecretKey(
//       keyPair: keyPair, remotePublicKey: pubKeyX25519);
//   final keyOfEncryptedKey = await hkdfAlgorithm.deriveKey(
//       secretKey: secretKey,
//       nonce: new List<int>.from(
//           encryptedSecret['secretNonce'].whereType<dynamic>()));
//   final SecretBox secretBox = SecretBox.fromConcatenation(
//       new List<int>.from(
//           encryptedSecret['encryptedSecret'].whereType<dynamic>()),
//       nonceLength: 12,
//       macLength: 16);
//   final List<int> decryptedSecretKey =
//       await aesAlgorithm.decrypt(secretBox, secretKey: keyOfEncryptedKey);
//   return decryptedSecretKey;
// }
//
// Future<Map> encryptMessage(pubX25519, message) async {
//   final secretKey = await aesAlgorithm.newSecretKey();
//   final nonce = aesAlgorithm.newNonce();
//   final secretBox = await aesAlgorithm.encrypt(
//     utf8.encode(message),
//     secretKey: secretKey,
//     nonce: nonce,
//   );
//   // print('SECRET BOX VALUES');
//   // print(secretBox.mac.bytes.length);
//   // print(secretBox.nonce.length);
//   final ency = await encryptSecret(await secretKey.extractBytes(), pubX25519);
//
//   final SimpleKeyPair keyPair = await ed25519Algorithm.newKeyPairFromSeed(
//       Hive.box<SecureStore>('SecureStore').get('store').privateEd25519Key);
//   final sign =
//       await ed25519Algorithm.sign(secretBox.concatenation(), keyPair: keyPair);
//   return {
//     'encrypted': secretBox.concatenation(),
//     'secretKey': ency,
//     'signature': sign.bytes,
//   };
// }
//
// Future<String> decryptMessage(
//     encryptedDynamic, encryptedSecret, signature, pubX25519, pubEd25519) async {
//   final encrypted = new List<int>.from(encryptedDynamic.whereType<dynamic>());
//   final SimplePublicKey pubEd25519Key = SimplePublicKey(
//       new List<int>.from(pubEd25519.whereType<dynamic>()),
//       type: KeyPairType.ed25519);
//   final isSign = await ed25519Algorithm.verify(encrypted,
//       signature: Signature(new List<int>.from(signature.whereType<dynamic>()),
//           publicKey: pubEd25519Key));
//   if (isSign) {
//     final secretBox =
//         SecretBox.fromConcatenation(encrypted, nonceLength: 12, macLength: 16);
//     final secretKeyBytes = await decryptSecret(encryptedSecret, pubX25519);
//     final secretKey = await aesAlgorithm.newSecretKeyFromBytes(secretKeyBytes);
//     final decryptedMessage =
//         await aesAlgorithm.decrypt(secretBox, secretKey: secretKey);
//     return utf8.decode(decryptedMessage);
//   } else {
//     return 'Message corrupted';
//   }
// }
