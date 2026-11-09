// lib/features/admin_web/shared/data/auth_repository.dart
// Auth repository: interface, mock, and http implementations.
// Selected at runtime via AppConfig.useMock dart-define flag.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/entities/auth_entity.dart';
import '../../../../../../app_config.dart';
import 'api_client.dart';
import 'api_exception.dart';
import 'token_storage.dart';

// ─── Interface ───────────────────────────────────────────────────────────────

abstract class AuthRepository {
  Future<CurrentUser> login({
    required String email,
    required String password,
  });

  Future<CurrentUser?> getMe();

  Future<void> logout();

  Future<bool> isLoggedIn();
}

// ─── Mock ────────────────────────────────────────────────────────────────────

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._storage);

  final TokenStorage _storage;

  static const _accounts = <String, _MockAccount>{
    'bagas@panenara.id': _MockAccount(
      password: 'admin123',
      id: 'sa-001',
      name: 'Bagas Pratama',
      role: AppRole.superAdmin,
    ),
    'rina@panenara.id': _MockAccount(
      password: 'admin123',
      id: 'ad-001',
      name: 'Rina Wulandari',
      role: AppRole.admin,
    ),
  };

  CurrentUser? _user;

  @override
  Future<CurrentUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final acct = _accounts[email.toLowerCase()];
    if (acct == null || acct.password != password) {
      throw const ApiException(
        code: 'INVALID_CREDENTIALS',
        message: 'Email atau kata sandi tidak valid.',
        statusCode: 401,
      );
    }
    _user = CurrentUser(
      id: acct.id,
      name: acct.name,
      email: email,
      role: acct.role,
    );
    try {
      await _storage.saveTokens(
        accessToken: 'mock.${acct.id}',
        refreshToken: 'mock-refresh.${acct.id}',
      );
    } catch (_) {
      // Ignore secure storage errors in mock on web platforms
    }
    return _user!;
  }

  @override
  Future<CurrentUser?> getMe() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_user != null) return _user;
    try {
      final token = await _storage.getAccessToken();
      if (token == null || !token.startsWith('mock.')) return null;
      final id = token.substring(5);
      for (final e in _accounts.entries) {
        if (e.value.id == id) {
          _user = CurrentUser(
            id: e.value.id,
            name: e.value.name,
            email: e.key,
            role: e.value.role,
          );
          return _user;
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Future<void> logout() async {
    _user = null;
    try {
      await _storage.clearTokens();
    } catch (_) {}
  }

  @override
  Future<bool> isLoggedIn() async {
    if (_user != null) return true;
    try {
      return (await _storage.getAccessToken()) != null;
    } catch (_) {
      return false;
    }
  }
}

class _MockAccount {
  const _MockAccount({
    required this.password,
    required this.id,
    required this.name,
    required this.role,
  });

  final String password;
  final String id;
  final String name;
  final AppRole role;
}

// ─── HTTP ────────────────────────────────────────────────────────────────────

class HttpAuthRepository implements AuthRepository {
  HttpAuthRepository(this._client, this._storage);

  final ApiClient _client;
  final TokenStorage _storage;

  @override
  Future<CurrentUser> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data!['data'] as Map<String, dynamic>;
    await _storage.saveTokens(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
    return _parseUser(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<CurrentUser?> getMe() async {
    try {
      final res = await _client.dio.get<Map<String, dynamic>>('/auth/me');
      return _parseUser(res.data!['data'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post<void>('/auth/logout');
    } finally {
      await _storage.clearTokens();
    }
  }

  @override
  Future<bool> isLoggedIn() async =>
      (await _storage.getAccessToken()) != null;

  CurrentUser _parseUser(Map<String, dynamic> d) => CurrentUser(
        id: d['id'] as String,
        name: d['name'] as String,
        email: d['email'] as String,
        role: AppRole.fromString(d['role'] as String),
      );
}

// ─── Providers ───────────────────────────────────────────────────────────────

final _secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(_secureStorageProvider));
});

final _mockAuthRepo = MockAuthRepository(
  TokenStorage(const FlutterSecureStorage()),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  if (AppConfig.useMock) return _mockAuthRepo;
  return HttpAuthRepository(ApiClient.instance, storage);
});

/// Streams the current logged-in user. null means not logged in.
final currentUserProvider = FutureProvider<CurrentUser?>((ref) {
  return ref.watch(authRepositoryProvider).getMe();
});
