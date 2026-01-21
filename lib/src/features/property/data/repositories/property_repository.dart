// lib/src/features/property/data/repositories/property_repository.dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/services/api_service.dart';
import '../models/project_model.dart';

class PropertyRepository {
  final http.Client client; // or your ApiService if it has client

  PropertyRepository({http.Client? client}) : client = client ?? http.Client();

  Future<ProjectResponseModel> fetchProperties({
    required String endpoint,
    required int page,
    String? sortBy,
  }) async {
    final query = {'page': page.toString()};
    if (sortBy != null && sortBy.isNotEmpty) {
      query['sort_by'] = sortBy;
    }

    final uri = ApiService.buildUri(endpoint, query: query);

    final response = await client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed: ${response.statusCode} – ${response.body}');
    }

    return ProjectResponseModel.fromJson(jsonDecode(response.body));
  }
}