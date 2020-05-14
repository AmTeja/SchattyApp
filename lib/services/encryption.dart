import 'package:pointycastle/api.dart' as crypto;
import 'package:rsa_encrypt/rsa_encrypt.dart';

crypto.AsymmetricKeyPair keyPair;
Future<crypto.AsymmetricKeyPair> futureKeyPair;

class Encryption {
  Future <crypto.AsymmetricKeyPair<crypto.PublicKey,
      crypto.PrivateKey>> getKeyPair() {
    var helper = RsaKeyHelper();
    return helper.computeRSAKeyPair(helper.getSecureRandom());
  }
}