/// VAPID Key Generator for WebPush
///
/// Generates ECDSA P-256 key pairs for WebPush VAPID authentication.
/// Run with: dart run bin/generate_vapid_keys.dart
///
/// Output can be copied directly to config/development.yaml or
/// set as environment variables for production.
///
/// For detailed documentation on VAPID key management, key rotation,
/// security best practices, and troubleshooting, see:
/// docs/VAPID_KEYS.md
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

void main() {
  print('Generating VAPID keys for WebPush...\n');

  final keyPair = generateVapidKeyPair();

  print('Add these to your configuration:\n');
  print('vapid:');
  print("  subject: 'mailto:admin@yourdomain.com'");
  print("  publicKey: '${keyPair.publicKey}'");
  print("  privateKey: '${keyPair.privateKey}'");
  print('');
  print('Or set as environment variables:');
  print('  export VAPID_SUBJECT="mailto:admin@yourdomain.com"');
  print('  export VAPID_PUBLIC_KEY="${keyPair.publicKey}"');
  print('  export VAPID_PRIVATE_KEY="${keyPair.privateKey}"');
  print('');
  print('Public key for client apps (safe to share):');
  print('  ${keyPair.publicKey}');
}

/// Generated VAPID key pair
class VapidKeyPair {
  final String publicKey;
  final String privateKey;

  VapidKeyPair({required this.publicKey, required this.privateKey});
}

/// Generate a new VAPID key pair using ECDSA P-256
VapidKeyPair generateVapidKeyPair() {
  // Initialize secure random
  final secureRandom = FortunaRandom();
  final seedSource = Random.secure();
  final seeds = List<int>.generate(32, (_) => seedSource.nextInt(256));
  secureRandom.seed(KeyParameter(Uint8List.fromList(seeds)));

  // Generate EC key pair on P-256 curve
  final keyParams = ECKeyGeneratorParameters(ECCurve_prime256v1());
  final keyGenerator = ECKeyGenerator()
    ..init(ParametersWithRandom(keyParams, secureRandom));

  final pair = keyGenerator.generateKeyPair();
  final publicKey = pair.publicKey as ECPublicKey;
  final privateKey = pair.privateKey as ECPrivateKey;

  // Encode public key as uncompressed point (65 bytes: 0x04 + X + Y)
  final x = _bigIntToBytes(publicKey.Q!.x!.toBigInteger()!, 32);
  final y = _bigIntToBytes(publicKey.Q!.y!.toBigInteger()!, 32);
  final publicKeyBytes = Uint8List(65);
  publicKeyBytes[0] = 0x04; // Uncompressed point indicator
  publicKeyBytes.setRange(1, 33, x);
  publicKeyBytes.setRange(33, 65, y);

  // Encode private key as raw scalar (32 bytes)
  final privateKeyBytes = _bigIntToBytes(privateKey.d!, 32);

  // Base64url encode (no padding) for WebPush compatibility
  final publicKeyBase64 = base64UrlEncode(publicKeyBytes).replaceAll('=', '');
  final privateKeyBase64 =
      base64UrlEncode(privateKeyBytes).replaceAll('=', '');

  return VapidKeyPair(publicKey: publicKeyBase64, privateKey: privateKeyBase64);
}

/// Convert BigInt to fixed-length byte array (big-endian)
Uint8List _bigIntToBytes(BigInt value, int length) {
  final result = Uint8List(length);
  var temp = value;
  for (var i = length - 1; i >= 0; i--) {
    result[i] = (temp & BigInt.from(0xff)).toInt();
    temp = temp >> 8;
  }
  return result;
}
