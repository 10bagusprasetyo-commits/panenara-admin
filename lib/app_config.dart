// lib/app_config.dart
// Reads compile-time constants set via --dart-define

class AppConfig {
  static const bool useMock =
      bool.fromEnvironment('USE_MOCK', defaultValue: true);

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const int connectTimeoutSeconds =
      int.fromEnvironment('CONNECT_TIMEOUT', defaultValue: 10);

  static const int receiveTimeoutSeconds =
      int.fromEnvironment('RECEIVE_TIMEOUT', defaultValue: 30);
}
