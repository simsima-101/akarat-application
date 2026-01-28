import 'dart:convert';

import '../../../core/services/api_service.dart';
import '../../property/data/models/amenities_model.dart';
import '../../property/data/models/property_type_model.dart';
import '../data/model/filtermodel.dart';

class FilterRepository {
  Future<List<Amenities>> fetchAmenities() async {
    try {
      //   final uri = ApiService.buildUri('amenities');
      //   final response = await http.get(uri).timeout(const Duration(seconds: 30));

      final response = await ApiService.get(
        'amenities',
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as List;
        return jsonData.map((e) => Amenities.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load amenities: ${response.statusCode}');
      }
    } catch (e) {
      rethrow; // Let BLoC handle the exception
    }
  }

  Future<PropertyTypeModel?> fetchPropertyTypes(String purpose) async {
    try {
      // final uri = ApiService.buildUri('property-types/$purpose');
      // final response = await http.get(uri).timeout(const Duration(seconds: 30));

      final response = await ApiService.get(
        'property-types/$purpose',
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return PropertyTypeModel.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to load property types: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<FilterResponseModel> fetchFilteredProperties({
    required Map<String, dynamic> queryParams,
    bool loadMore = false,
  }) async {
    try {
      // final uri = Uri.https('akarat.com', '/api/filters', queryParams);
      //
      // final response = await http.get(uri);

      final response = await ApiService.get(
        'api/filters',
        query: queryParams,
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return FilterResponseModel.fromJson(json);
      } else {
        throw Exception('Filter API failed: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
