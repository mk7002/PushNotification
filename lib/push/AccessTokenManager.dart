import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:pushapp/Singleton/app_provider.dart';

import '../data/DataHandler.dart';
import '../storage/SharedPrefs.dart';

class AccessTokenManager {
  Future<String> getAndroidAccessToken() async {
    // If the token exists and hasn't expired, return it
    DateTime? storedExpiry = await SharedPrefs().tokenExpiry();
    if (storedExpiry != null && DateTime.now().toUtc().isBefore(storedExpiry)) {
      String? token = await SharedPrefs().accessToken();
      if (token != null) {
        return token;
      }
    }

    // Your logic to obtain a new access token
    final serviceAccountJson =
        DataHandler().getAppConfigData<Map<String, dynamic>>();

    List<String> _scopes = DataHandler().getFirebaseScopes();
    List<String> scopes = _scopes.map((scope) => scope.toString()).toList();

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    // Obtain the access token
    auth.AccessCredentials credentials =
        await auth.obtainAccessCredentialsViaServiceAccount(
            auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
            scopes,
            client);

    // Close the HTTP client
    client.close();

    // Store the new access token and its expiry time

    await SharedPrefs().accessToken(data: credentials.accessToken.data);
    await SharedPrefs().tokenExpiry(expiry: credentials.accessToken.expiry);

    // Return the access token
    return credentials.accessToken.data;
  }

  Future<String?> generateJwtToken() async {
    try {
      final iosProvider = AppProvider().iosProvider;
      final privateKey = iosProvider.privateKeyContent;
      final teamId = iosProvider.teamId;
      final keyId = iosProvider.keyId;

      if (privateKey == null || teamId == null || keyId == null) {
        debugPrint(
            'Missing JWT configuration (private key, team ID, or key ID)');
        return null;
      }

      final jwt = JWT(
        {},
        issuer: teamId,
        header: {
          'alg': 'ES256',
          'kid': keyId,
        },
      );

      final token = jwt.sign(
        ECPrivateKey(privateKey), // ✅ Pass the PEM string directly
        algorithm: JWTAlgorithm.ES256,
        expiresIn: const Duration(minutes: 20),
      );

      return token;
    } catch (e, stack) {
      debugPrint('JWT generation error: $e\n$stack');
      return null;
    }
  }
}
