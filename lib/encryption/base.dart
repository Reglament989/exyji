import 'package:cryptography/cryptography.dart';

Future<void> main() async {
  final algorithm = Ed25519();

  // Generate a key pair
  final keyPair = await algorithm.newKeyPair();

  // Sign a message
  final message = <int>[1,2,3];
  final signature = await algorithm.sign(
    message,
    keyPair: keyPair,
  );
  print('Signature bytes: ${signature.bytes}');
  print('Public key: ${sign}');

  // Anyone can verify the signature
  final isSignatureCorrect = await algorithm.verify(
    message,
    signature: signature,
  );
}