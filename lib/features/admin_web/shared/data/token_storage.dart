// lib/features/admin_web/shared/data/token_storage.dart
// Wraps flutter_secure_storage.
//
// Web caveat: flutter_secure_storage on web stores data in localStorage.
// This means tokens are NOT encrypted at rest on web.
// For production, consider short-lived tokens (< 15 min) and httpOnly cookies
// managed server-side. Document this in BACKEND_HANDOFF.md.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _keyAccess = 'panenara_access_token';
  static const _keyRefresh = 'panenara_refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccess, value: accessToken),
      _storage.write(key: _keyRefresh, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _keyAccess);
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefresh);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _keyAccess),
      _storage.delete(key: _keyRefresh),
    ]);
  }
}
