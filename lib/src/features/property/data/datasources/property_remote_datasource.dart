import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/api_service.dart';
import '../models/featuredmodel.dart' as featured;   // ← adjust if you use different model

abstract class PropertyRemoteDataSource {
  Future<featured.FeaturedResponseModel> getProperties({
    required String sortBy,
    required int page,
  });
}

class PropertyRemoteDataSourceImpl implements PropertyRemoteDataSource {
  final http.Client client;

  PropertyRemoteDataSourceImpl({required this.client});

  @override
  Future<featured.FeaturedResponseModel> getProperties({
    required String sortBy,
    required int page,
  }) async {
    final uri = ApiService.buildUri(
      'properties',
      query: {
        'page': page.toString(),
        'sort_by': sortBy,
      },
    );

    final response = await client.get(uri);

    if (response.statusCode == 200) {
      return featured.FeaturedResponseModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception(
        'Failed to load properties: ${response.statusCode} – ${response.body}',
      );
    }
  }
}