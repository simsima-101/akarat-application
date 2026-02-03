// lib/src/features/property/data/repositories/property_repository.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // for WidgetsBinding (language fallback)

import '../../../../core/services/api_service.dart';
import '../models/project_model.dart';       // ProjectResponseModel
import '../models/fdetailmodel.dart';      // Featured_DetailModel

class PropertyRepository {
  final http.Client client;

  PropertyRepository({http.Client? client}) : client = client ?? http.Client();

  /// Fetches a paginated list of properties with optional sorting.
  Future<ProjectResponseModel> fetchProperties({
    required String endpoint,
    int page = 1,
    String? sortBy,
    Map<String, String>? extraHeaders,
  }) async {
    try {
      // Build query parameters
      final query = <String, String>{
        'page': page.toString(),
      };
      if (sortBy != null && sortBy.trim().isNotEmpty) {
        query['sort_by'] = sortBy.trim();
      }

      if (kDebugMode) {
        debugPrint('→ Fetching properties from endpoint: $endpoint');
        debugPrint('   Query: $query');
      }

      // Use ApiService.get (compatibility helper we added)
      final response = await ApiService.get(
        endpoint,
        query: query,
        headers: extraHeaders,
      ).timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint('← Response: ${response.statusCode}');
        final preview = response.body.length > 300
            ? '${response.body.substring(0, 300)}...'
            : response.body;
        debugPrint('   Body preview: $preview');
      }

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        return ProjectResponseModel.fromJson(jsonMap);
      } else {
        throw HttpException(
          'Failed to fetch properties: ${response.statusCode} - ${response.body}',
          uri: response.request?.url,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}', uri: e.uri);
    } on TimeoutException {
      throw TimeoutException('Properties request timed out after 20 seconds');
    } catch (e) {
      throw Exception('Unexpected error fetching properties: $e');
    }
  }

  /// Fetches detailed information for a single property by its ID.
  Future<Featured_DetailModel> fetchPropertyDetail(
      String propertyId, {
        Map<String, String>? extraHeaders,
      }) async {
    try {
      final uri = ApiService.buildUri('properties/$propertyId');

      if (kDebugMode) {
        debugPrint('→ Fetching property detail: $uri');
      }

      // ────────────────────────────────────────────────
      // Determine current language for Accept-Language header
      // ────────────────────────────────────────────────
      String langCode = 'en'; // fallback

      try {
        final locale = WidgetsBinding.instance.platformDispatcher.locale;
        langCode = locale.languageCode.toLowerCase().trim();
      } catch (e) {
        debugPrint('Warning: Could not read locale → fallback to en');
      }

      String acceptLanguage;
      switch (langCode) {
        case 'ar':
          acceptLanguage = 'ar';
          break;
        case 'tr':
          acceptLanguage = 'tr';
          break;
        default:
          acceptLanguage = 'en';
      }

      if (kDebugMode) {
        debugPrint('→ Property detail request → Accept-Language: $acceptLanguage');
        debugPrint('→ Detected language code: $langCode');
      }

      // Use ApiService.get (compatibility helper)
      final response = await ApiService.get(
        'properties/$propertyId',
        headers: {
          ...?extraHeaders,
          'Accept-Language': acceptLanguage,
        },
      ).timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        debugPrint('← Response: ${response.statusCode}');
        final preview = response.body.length > 300
            ? '${response.body.substring(0, 300)}...'
            : response.body;
        debugPrint('   Body preview: $preview');
      }

      if (response.statusCode == 200) {
        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        return Featured_DetailModel.fromJson(jsonMap);
      } else {
        throw HttpException(
          'Failed to fetch property detail: ${response.statusCode} - ${response.body}',
          uri: response.request?.url,
          statusCode: response.statusCode,
        );
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}', uri: e.uri);
    } on TimeoutException {
      throw TimeoutException('Property detail request timed out after 30 seconds');
    } catch (e) {
      throw Exception('Unexpected error fetching property detail: $e');
    }
  }
}

// ────────────────────────────────────────────────
// Custom exceptions (keep them – very useful)
// ────────────────────────────────────────────────
class HttpException implements Exception {
  final String message;
  final Uri? uri;
  final int? statusCode;

  HttpException(this.message, {this.uri, this.statusCode});

  @override
  String toString() => 'HttpException: $message (status: $statusCode, url: $uri)';
}

class NetworkException implements Exception {
  final String message;
  final Uri? uri;

  NetworkException(this.message, {this.uri});

  @override
  String toString() => 'NetworkException: $message (url: $uri)';
}