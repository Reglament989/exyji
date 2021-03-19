import 'package:hive/hive.dart';

part 'secureStore.g.dart';

@HiveType(typeId: 2)
class SecureStore extends HiveObject {
  @HiveField(0)
  String publicKeyRsa;

  @HiveField(1)
  String privateKeyRsa;

  @override
  String toString() {
    return 'Public X25519 - $publicKeyRsa\nPublicRsaPss - $privateKeyRsa';
  }
}
