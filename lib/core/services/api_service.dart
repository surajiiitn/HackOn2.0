import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrlFromEnv =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');
  static String? _accessToken;
  static String? _refreshToken;

  static String get baseUrl {
    if (_baseUrlFromEnv.isNotEmpty) return _baseUrlFromEnv;
    if (kIsWeb) {
      final webUri = Uri.base;
      final host = webUri.host.isNotEmpty ? webUri.host : 'localhost';
      final scheme = webUri.scheme == 'https' ? 'https' : 'http';
      return '$scheme://$host:8000/api/v1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Android emulator maps host loopback to 10.0.2.2
        return 'http://10.0.2.2:8000/api/v1';
      case TargetPlatform.iOS:
        return 'http://127.0.0.1:8000/api/v1';
      default:
        return 'http://localhost:8000/api/v1';
    }
  }

  static Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  static Future<void> saveTokens(String access, String refresh) async {
    _accessToken = access;
    _refreshToken = refresh;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  static Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  static bool get isAuthenticated => _accessToken != null;

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  static Future<http.Response> _requestWithAutoRefresh(
      Future<http.Response> Function() request) async {
    var response = await request();
    if (response.statusCode != 401 || _refreshToken == null) {
      return response;
    }

    final refreshed = await _tryRefreshToken();
    if (!refreshed) {
      await clearTokens();
      return response;
    }

    response = await request();
    if (response.statusCode == 401) {
      await clearTokens();
    }
    return response;
  }

  static Future<Map<String, dynamic>> _handleResponse(
      http.Response response) async {
    if (response.statusCode == 401) {
      await clearTokens();
      throw ApiException('Session expired. Please login again.', 401);
    }

    dynamic decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = <String, dynamic>{};
      }
    }
    final body = decoded is Map<String, dynamic>
        ? decoded
        : <String, dynamic>{'data': decoded};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    throw ApiException(_extractErrorMessage(body), response.statusCode);
  }

  static String _extractErrorMessage(Map<String, dynamic> body) {
    final direct = body['detail'] ?? body['message'] ?? body['error'];
    if (direct != null) return direct.toString();

    if (body.isEmpty) return 'Request failed';
    final firstValue = body.values.first;
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    return firstValue.toString();
  }

  static Future<bool> _tryRefreshToken() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _refreshToken}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await saveTokens(
          data['access'] as String,
          data['refresh'] as String? ?? _refreshToken!,
        );
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Auth ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber}),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String phoneNumber, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber, 'code': code}),
    );
    final data = await _handleResponse(response);
    if (data.containsKey('access')) {
      await saveTokens(
        data['access'] as String,
        data['refresh'] as String,
      );
    }
    return data;
  }

  // ── User Profile ────────────────────────────────────────────

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await _requestWithAutoRefresh(
      () => http.get(
        Uri.parse('$baseUrl/users/profile/'),
        headers: _headers,
      ),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data) async {
    final response = await _requestWithAutoRefresh(
      () => http.patch(
        Uri.parse('$baseUrl/users/profile/'),
        headers: _headers,
        body: jsonEncode(data),
      ),
    );
    return _handleResponse(response);
  }

  // ── Emergency Contacts ──────────────────────────────────────

  static Future<Map<String, dynamic>> listContacts() async {
    final response = await _requestWithAutoRefresh(
      () => http.get(
        Uri.parse('$baseUrl/users/contacts/'),
        headers: _headers,
      ),
    );
    final data = await _handleResponse(response);
    return data;
  }

  static Future<Map<String, dynamic>> addContact(
      Map<String, dynamic> contact) async {
    final response = await _requestWithAutoRefresh(
      () => http.post(
        Uri.parse('$baseUrl/users/contacts/'),
        headers: _headers,
        body: jsonEncode(contact),
      ),
    );
    return _handleResponse(response);
  }

  static Future<void> deleteContact(String id) async {
    final response = await _requestWithAutoRefresh(
      () => http.delete(
        Uri.parse('$baseUrl/users/contacts/$id/'),
        headers: _headers,
      ),
    );
    if (response.statusCode != 204) {
      await _handleResponse(response);
    }
  }

  // ── SOS ─────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> triggerSos({
    required double latitude,
    required double longitude,
    String triggerType = 'manual_sos',
  }) async {
    final response = await _requestWithAutoRefresh(
      () => http.post(
        Uri.parse('$baseUrl/sos/trigger/'),
        headers: _headers,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'trigger_type': triggerType,
        }),
      ),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> cancelSos(String eventId) async {
    final response = await _requestWithAutoRefresh(
      () => http.post(
        Uri.parse('$baseUrl/sos/$eventId/cancel/'),
        headers: _headers,
      ),
    );
    return _handleResponse(response);
  }

  // ── Hazards ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> dropHazardPin({
    required double latitude,
    required double longitude,
    required String hazardType,
    String description = '',
  }) async {
    final response = await _requestWithAutoRefresh(
      () => http.post(
        Uri.parse('$baseUrl/hazards/drop-pin/'),
        headers: _headers,
        body: jsonEncode({
          'latitude': latitude,
          'longitude': longitude,
          'hazard_type': hazardType,
          'description': description,
        }),
      ),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> listHazards({
    double? lat,
    double? lng,
    double? radius,
  }) async {
    final params = <String, String>{};
    if (lat != null) params['lat'] = lat.toString();
    if (lng != null) params['lng'] = lng.toString();
    if (radius != null) params['radius'] = radius.toString();
    final uri =
        Uri.parse('$baseUrl/hazards/list/').replace(queryParameters: params);
    final response =
        await _requestWithAutoRefresh(() => http.get(uri, headers: _headers));
    return _handleResponse(response);
  }

  // ── Safe Routes ─────────────────────────────────────────────

  static Future<Map<String, dynamic>> getSafePath({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final response = await _requestWithAutoRefresh(
      () => http.post(
        Uri.parse('$baseUrl/routes/safe-path/'),
        headers: _headers,
        body: jsonEncode({
          'start_lat': startLat,
          'start_lng': startLng,
          'end_lat': endLat,
          'end_lng': endLng,
        }),
      ),
    );
    return _handleResponse(response);
  }

  // ── Privacy / OSINT ─────────────────────────────────────────

  static Future<Map<String, dynamic>> startPrivacyScan() async {
    final response = await _requestWithAutoRefresh(
      () => http.post(
        Uri.parse('$baseUrl/privacy/scan/start/'),
        headers: _headers,
      ),
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getScanStatus({String? scanId}) async {
    final params = <String, String>{};
    if (scanId != null) params['scan_id'] = scanId;
    final uri = Uri.parse('$baseUrl/privacy/scan/status/')
        .replace(queryParameters: params.isEmpty ? null : params);
    final response =
        await _requestWithAutoRefresh(() => http.get(uri, headers: _headers));
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> generateNotice(String url) async {
    final response = await _requestWithAutoRefresh(
      () => http.post(
        Uri.parse('$baseUrl/privacy/generate-notice/'),
        headers: _headers,
        body: jsonEncode({'flagged_url': url}),
      ),
    );
    return _handleResponse(response);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}
