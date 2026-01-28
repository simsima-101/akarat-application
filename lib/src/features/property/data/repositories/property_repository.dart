// lib/src/features/property/data/repositories/property_repository.dart
import 'dart:convert';

import '../../../../core/services/api_service.dart';
import '../models/project_model.dart';

class PropertyRepository {
  PropertyRepository();

  /// Fetch properties with pagination and optional sorting
  Future<ProjectResponseModel> fetchProperties({
    required String endpoint,
    required int page,
    String? sortBy,
  }) async {
    try {
      // Build query parameters
      final query = {'page': page.toString()};
      if (sortBy != null && sortBy.isNotEmpty) {
        query['sort_by'] = sortBy;
      }

      // Use the new ApiService GET helper
      final response = await ApiService.get(endpoint, query: query);

      if (response.statusCode != 200) {
        throw Exception('Failed: ${response.statusCode} – ${response.body}');
      }

      // Decode and return model
      final data = jsonDecode(response.body);
      return ProjectResponseModel.fromJson(data);
    } catch (e) {
      // You can also wrap this in a custom exception if needed
      throw Exception('Error fetching properties: $e');
    }
  }
}
