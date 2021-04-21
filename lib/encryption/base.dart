import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:exyji/encryption/helper.dart';

Future<List<List<List<int>>>> generateKeyPairs() async {
  final algorithm = Ed25519();
  final algorithmX = Cryptography.instance.x25519();
  // Generate a key pair
  final keyPair = await algorithm.newKeyPair();

  final privateKey = await keyPair.extractPrivateKeyBytes();
  final publicKey = (await keyPair.extractPublicKey()).bytes;

  final keyPairX = await algorithmX.newKeyPair();

  final privateKeyX = await keyPairX.extractPrivateKeyBytes();
  final publicKeyX = (await keyPairX.extractPublicKey()).bytes;

  return [
    [privateKey, publicKey],
    [privateKeyX, publicKeyX]
  ];
}

Future<Signature> signObject(
    {required List<int> privateSeed, required List<int> message}) async {
  final algorithm = Ed25519();
  final keyPair = await algorithm.newKeyPairFromSeed(privateSeed);
  final signature = await algorithm.sign(message, keyPair: keyPair);
  return signature;
}

Future<bool> verifySign(
    {required List<int> rawSignature,
    required List<int> publicKey,
    required List<int> message}) async {
  final algorithm = Ed25519();
  final isVerified = await algorithm.verify(message,
      signature: Signature(rawSignature,
          publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519)));
  return isVerified;
}

Future excangeKeys() async {}

Future<List<int>> deriveKey({required String key}) async {
  final pbkdf2 = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 100000,
    bits: 128,
  );

  // Password we want to hash
  final secretKey = SecretKey(utf8.encode(key));

  // A random salt
  final nonce = <int>[];

  // Calculate a hash that can be stored in the database
  final newSecretKey = await pbkdf2.deriveKey(
    secretKey: secretKey,
    nonce: nonce,
  );
  final newSecretKeyBytes = await newSecretKey.extractBytes();
  print("Secret key - $newSecretKeyBytes");
  return newSecretKeyBytes;
}

Future<Uint8List> encryptBlock(
    {required String key, required List<int> message}) async {
  final algorithm = AesGcm.with128bits();
  final secretKey =
      await algorithm.newSecretKeyFromBytes(await deriveKey(key: key));
  final nonce = algorithm.newNonce();

  // Encrypt
  final secretBox = await algorithm.encrypt(
    message,
    secretKey: secretKey,
    nonce: nonce,
  );

  print("Lenght mac - ${secretBox.mac.bytes.length}");

  return secretBox.concatenation();
}

Future decryptBlock(
    {required String key, required Uint8List encryptedMessage}) async {
  final algorithm = AesGcm.with128bits();
  final secretKey =
      await algorithm.newSecretKeyFromBytes(await deriveKey(key: key));
  final SecretBox secretBox = getBoxFromConcat(encryptedMessage);
  final clearBlock = await algorithm.decrypt(
    secretBox,
    secretKey: secretKey,
  );
  return clearBlock;
}

void main(List<String> args) async {
  final keys = await generateKeyPairs();
  print("Keys generated of ${DateTime.now()}");
  final encryptedMessage = await encryptBlock(
      key: "Some key", message: utf8.encode("Hello what your nothing?"));
  final sign = await signObject(
      message: encryptedMessage, privateSeed: keys.first.first);
  final isVerified = await verifySign(
      message: encryptedMessage,
      publicKey: keys.first.last,
      rawSignature: sign.bytes);
  final decryptedMessage =
      await decryptBlock(encryptedMessage: encryptedMessage, key: "Some key");
  print("Decrypted");
  print(utf8.decode(decryptedMessage));
}
