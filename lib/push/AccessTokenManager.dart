import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

import '../data/DataHandler.dart';
import '../storage/SharedPrefs.dart';

class AccessTokenManager {
  Future<String> getAccessToken() async {
    // If the token exists and hasn't expired, return it
    DateTime? storedExpiry = SharedPrefs().getExpiry();
    if (storedExpiry != null && DateTime.now().toUtc().isBefore(storedExpiry)) {
      String? token = SharedPrefs().getString('access_token');
      if (token != null) {
        return token;
      }
    }

    // Your logic to obtain a new access token
    final serviceAccountJson = DataHandler()
        .getAppConfigData<Map<String, dynamic>>(
            AppConfigType.serviceAccountJson);

    List<String>? _scopes =
        DataHandler().getAppConfigData<List<String>>(AppConfigType.scopes);
    _scopes ?? <String>[];
    List<String> scopes = _scopes!.map((scope) => scope.toString()).toList();

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
    await SharedPrefs().setString('access_token', credentials.accessToken.data);
    await SharedPrefs().setExpiry(credentials.accessToken.expiry);

    // Return the access token
    return credentials.accessToken.data;
  }
}
