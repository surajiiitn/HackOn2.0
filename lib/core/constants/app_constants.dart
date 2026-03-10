class AppConstants {
  AppConstants._();

  static const String appName = 'Suraksha AI';
  static const String appTagline = 'Enterprise-grade safety at your fingertips';
  static const String countryCode = '+91';
  static const String encryptionNote = 'Protected by End-to-End Encryption';

  // Route paths
  static const String authPath = '/auth';
  static const String dashboardPath = '/dashboard';
  static const String safeMapPath = '/safe-map';
  static const String audioListenerPath = '/audio-listener';
  static const String privacyHubPath = '/privacy-hub';
  static const String settingsPath = '/settings';

  // Offline defaults
  static const String offlineMapsSize = '320MB';
  static const int defaultFakeCallDelay = 30;
  static const int otpLength = 6;
  static const int otpResendSeconds = 45;
}
