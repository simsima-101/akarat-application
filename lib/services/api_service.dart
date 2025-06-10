import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

import '../model/agencypropertiesmodel.dart';
import '../screen/secure_storage.dart';

class ApiService {
  // Make sure baseUrl has NO trailing slash
  static const String baseUrl = "https://akarat.com/api";

  // Headers for requests without auth
  static Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  // Headers for requests with auth token
  static Map<String, String> authHeaders(String token) => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=UTF-8',
    'Authorization': 'Bearer $token',
  };

  // Helper to build full URL safely (avoid double slashes)
  static Uri _buildUri(String endpoint, [Map<String, String>? queryParams]) {
    // Remove trailing slash from baseUrl if any, and starting slash from endpoint
    final cleanBaseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    Uri uri = Uri.parse('$cleanBaseUrl/$cleanEndpoint');

    if (queryParams != null) {
      uri = uri.replace(queryParameters: queryParams);
    }

    return uri;
  }

  // Generic POST request (no auth)
  static Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body) async {
    final url = _buildUri(endpoint);
    print('POST Request to: $url');
    print('Headers: $defaultHeaders');
    print('Body: $body');

    try {
      final response = await http.post(
        url,
        headers: defaultHeaders,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response;
    } catch (e) {
      print('Error during POST request: $e');
      rethrow;
    }
  }

  // Generic POST request with auth token
  static Future<http.Response> postRequestAuth(String endpoint, String token, Map<String, dynamic> body) async {
    final url = _buildUri(endpoint);
    final headers = authHeaders(token);
    print('POST Request (Auth) to: $url');
    print('Headers: $headers');
    print('Body: $body');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response;
    } catch (e) {
      print('Error during POST request (Auth): $e');
      rethrow;
    }
  }

  // Generic GET request (no auth)
  static Future<http.Response> getRequest(String endpoint, [Map<String, String>? queryParams]) async {
    final url = _buildUri(endpoint, queryParams);
    print('GET Request to: $url');
    print('Headers: $defaultHeaders');

    try {
      final response = await http.get(url, headers: defaultHeaders);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response;
    } catch (e) {
      print('Error during GET request: $e');
      rethrow;
    }
  }

  // Generic GET request with auth
  static Future<http.Response> getRequestAuth(String endpoint, String token, [Map<String, String>? queryParams]) async {
    final url = _buildUri(endpoint, queryParams);
    final headers = authHeaders(token);
    print('GET Request (Auth) to: $url');
    print('Headers: $headers');

    try {
      final response = await http.get(url, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return response;
    } catch (e) {
      print('Error during GET request (Auth): $e');
      rethrow;
    }
  }

  // ========== Specific API Calls ==========

  // Register new user
  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await postRequest('/register', {
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
    });

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }


  // Login user
  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await postRequest('/login', {
      "email": email,
      "password": password,
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Logout user
  static Future<void> logoutUser(String token) async {
    final response = await Dio().post(
      'https://akarat.com/api/logout',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    if (response.statusCode == 200) {
      print('Logout successful');
    } else {
      throw Exception('Logout failed');
    }
  }

  // Get saved properties
  static Future<List<Property>> getSavedProperties(String token) async {
    final response = await getRequestAuth('/saved-property-list', token);
    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Check and extract the nested list based on your API response
      final List<dynamic> propertyList = decoded['data'] != null && decoded['data']['data'] != null
          ? decoded['data']['data']
          : [];
      return propertyList.map((item) => Property.fromJson(item)).toList();
    } else {
      throw Exception('Failed to get saved properties');
    }
  }

  // Toggle saved property (add/remove)
  static Future<bool> toggleSavedProperty(String token, int propertyId) async {
    final response = await postRequestAuth(
      '/toggle-saved-property',
      token,
      {"property_id": propertyId},
    );
    return response.statusCode == 200;
  }

  // Get agent list (with pagination)
  static Future<List<dynamic>> getAgents({int page = 1}) async {
    final response = await getRequest('/agents', {"page": page.toString()});
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get agents');
    }
  }

  // Get agent details
  static Future<Map<String, dynamic>> getAgentDetails(int id) async {
    final response = await getRequest('/agent/$id');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get agent details');
    }
  }

  // Get featured properties
  static Future<List<dynamic>> getFeaturedProperties({int page = 1}) async {
    final response = await getRequest(
      '/featured-properties',
      {"page": page.toString()},
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get featured properties');
    }
  }

  // Get filtered properties using filters
  static Future<List<dynamic>> getFilteredProperties(Map<String, String> filters) async {
    final response = await getRequest('/filters', filters);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get filtered properties');
    }
  }

  // Contact form submission
  static Future<bool> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String subject,
    required String message,
  }) async {
    final response = await postRequest('/contact', {
      "name": name,
      "email": email,
      "phone": phone,
      "subject": subject,
      "message": message,
    });

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // Forgot Password - send reset link
  static Future<bool> forgotPassword(String email) async {
    final response = await postRequest('/forgot-password', {"email": email});

    // API returns 200 if email exists and email sent, but may always return 200 for security.
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Forgot password failed: ${response.body}');
      return false;
    }
  }

// Reset Password - set new password
  static Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await postRequest('/reset-password', {
      "email": email,
      "token": token,
      "password": password,
      "password_confirmation": passwordConfirmation,
    });

    if (response.statusCode == 200) {
      // Optionally parse response for a success flag/message
      final data = jsonDecode(response.body);
      if (data['success'] == true || data['status'] == 'success') {
        return true;
      } else {
        print('Reset password response indicates failure: ${response.body}');
        return false;
      }
    } else {
      print('Reset password failed with status ${response.statusCode}: ${response.body}');
      return false;
    }
  }

}


