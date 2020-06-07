import 'package:pointycastle/api.dart' as crypto;
import 'package:rsa_encrypt/rsa_encrypt.dart';

class EncryptionService {
  Future<crypto.AsymmetricKeyPair> futureKeyPair;
  crypto.AsymmetricKeyPair keyPair;

  var helper = RsaKeyHelper();

  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>>
      getKeyPair() {
    return helper.computeRSAKeyPair(helper.getSecureRandom());
  }

  getPublicKeyInPlain(crypto.AsymmetricKeyPair keyPair) async {
    return helper.encodePublicKeyToPemPKCS1(keyPair.publicKey);
  }

  getPrivatekeyInPlain(crypto.AsymmetricKeyPair keyPair) async {
    return helper.encodePrivateKeyToPemPKCS1(keyPair.privateKey);
  }
}
