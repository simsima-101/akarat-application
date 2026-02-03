// features/alerts/bloc/create_alert_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/constants/constants.dart' as ApiService;
import '../../../../core/utils/secure_storage.dart';
import '../../../../screen/CreateAlertScreen.dart';
import '../../../../screen/login.dart';
import '../../../../screen/saved_alert_screen.dart';
import '../../data/models/property_type_model.dart';

import 'create_alert_state.dart';


class CreateAlertCubit extends Cubit<CreateAlertState> {
  CreateAlertCubit({
    required String initialPurpose,
    required String initialPropertyType,
  }) : super(CreateAlertState(
    purpose: initialPurpose.trim(),
    propertyType: _normalizePropertyType(initialPropertyType),
    timePeriod: 'Daily',
    alertName: _generateDefaultName(initialPurpose, initialPropertyType),
  )) {
    loadPropertyTypes();
  }

  static String _normalizePropertyType(String raw) {
    final lower = raw.trim().toLowerCase();
    const anyMarkers = {'', 'all', 'any', 'all residential'};
    return anyMarkers.contains(lower) ? '' : raw.trim();
  }

  static String _generateDefaultName(String purpose, String type) {
    final labelType = type.trim().isEmpty ? 'Any' : type.trim();
    return '$purpose • $labelType';
  }

  Future<void> loadPropertyTypes() async {
    emit(state.copyWith(status: CreateAlertStatus.loadingPropertyTypes));

    try {
      final uri = Uri.parse('${ApiService.baseUrl}/property-types');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final model = PropertyTypeModel.fromJson(data);
        emit(state.copyWith(
          status: CreateAlertStatus.loaded,
          propertyTypeModel: model,
        ));
      } else {
        emit(state.copyWith(
          status: CreateAlertStatus.error,
          errorMessage: 'Failed to load property types (HTTP ${response.statusCode})',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CreateAlertStatus.error,
        errorMessage: 'Network error: $e',
      ));
    }
  }

  void updateTimePeriod(String? newValue) {
    if (newValue == null) return;
    emit(state.copyWith(timePeriod: newValue));
  }

  void updatePropertyType(String? newValue) {
    if (newValue == null) return;
    final labelType = newValue.isEmpty ? 'Any' : newValue;
    emit(state.copyWith(
      propertyType: newValue,
      alertName: '${state.purpose} • $labelType',
    ));
  }

  void updateAlertName(String newName) {
    emit(state.copyWith(alertName: newName.trim()));
  }

  Future<void> submit({
    required GlobalKey<FormState> formKey,
    required bool isFromSavedAlerts,
    required BuildContext context,
  }) async {
    if (!formKey.currentState!.validate()) return;

    emit(state.copyWith(status: CreateAlertStatus.submitting, isSubmitting: true));

    final token = await _requireAuth(context);
    if (token == null) {
      emit(state.copyWith(
        status: CreateAlertStatus.error,
        errorMessage: 'Authentication required',
        isSubmitting: false,
      ));
      return;
    }

    try {
      final purposeServerKey = _canonPurpose(state.purpose) +
          '|' +
          (state.propertyType.isEmpty ? 'any' : _mapTypeForApi(state.propertyType));

      String alertName = state.alertName.trim();
      if (alertName.isEmpty) {
        final labelType = state.propertyType.isEmpty ? 'Any' : state.propertyType;
        alertName = '${state.purpose} • $labelType';
      }

      alertName = await _uniqueName(alertName, token);

      final payload = {
        'alert_name': alertName,
        'time_period': _mapTimePeriodForApi(state.timePeriod),
        'purpose': purposeServerKey,
        if (state.propertyType.isNotEmpty) 'property_type': _mapTypeForApi(state.propertyType),
      };

      debugPrint('→ Creating alert: $payload');

      final url = Uri.parse('${ApiService.baseUrl}/alerts');
      final res = await http.post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'X-Requested-With': 'XMLHttpRequest',
        },
        body: jsonEncode(payload),
      );

      if (res.statusCode == 409 || res.statusCode == 422) {
        final newName = await _uniqueName('$alertName • 2', token);
        final retryPayload = Map.from(payload)..['alert_name'] = newName;
        await http.post(url, headers: res.request!.headers, body: jsonEncode(retryPayload));
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        emit(state.copyWith(status: CreateAlertStatus.success, isSubmitting: false));

        if (isFromSavedAlerts) {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SavedAlertsScreen(token: token)),
          );
        } else {
          Navigator.pop(context);
        }
      } else {
        String msg = 'Failed to save alert';
        try {
          final body = jsonDecode(res.body);
          if (body is Map) {
            if (body['errors'] is Map) {
              msg = (body['errors'] as Map).values.map((v) => v.toString()).join('\n');
            } else if (body['message'] != null) {
              msg = body['message'];
            }
          }
        } catch (_) {}
        emit(state.copyWith(
          status: CreateAlertStatus.error,
          errorMessage: msg,
          isSubmitting: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: CreateAlertStatus.error,
        errorMessage: 'Network error: $e',
        isSubmitting: false,
      ));
    }
  }

  // Auth & navigation helpers
  Future<String?> _requireAuth(BuildContext context) async {
    final token = await readToken();
    if (token == null || token.isEmpty) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
      return await readToken();
    }
    return token;
  }

  Future<String> _uniqueName(String base, String token) async {
    try {
      final res = await http.get(
        Uri.parse('${ApiService.baseUrl}/saved-searches'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      );

      if (res.statusCode < 200 || res.statusCode >= 300) return base;

      final body = jsonDecode(res.body);
      List<dynamic> list = body is List
          ? body
          : (body['data'] is List ? body['data'] : body['saved_searches'] ?? []);

      final existing = list
          .map((e) => (e['alert_name'] ?? e['name'] ?? '').toString().trim().toLowerCase())
          .toSet();

      if (!existing.contains(base.trim().toLowerCase())) return base;

      for (int i = 2; i <= 50; i++) {
        final candidate = '$base ($i)';
        if (!existing.contains(candidate.toLowerCase())) return candidate;
      }
      return '${base}_${DateTime.now().millisecondsSinceEpoch}';
    } catch (_) {
      return base;
    }
  }

  String _mapTimePeriodForApi(String period) {
    final lower = period.trim().toLowerCase();
    switch (lower) {
      case 'hourly':
        return 'hourly';
      case 'daily':
        return 'daily';
      case 'weekly':
        return 'weekly';
      case 'monthly':
        return 'monthly';
      default:
        return 'daily';
    }
  }

  String _mapTypeForApi(String t) {
    final s = t.trim().toLowerCase();
    if (s.isEmpty || s == 'all residential' || s == 'any' || s == 'all') return '';
    if (s.startsWith('office')) return 'office';
    if (s.startsWith('commercial')) return 'commercial';
    if (s.startsWith('apart')) return 'apartment';
    if (s.startsWith('villa')) return 'villa';
    if (s.startsWith('studio')) return 'studio';
    return s.replaceAll(' ', '_');
  }

  String _canonPurpose(String p) {
    var s = p.trim().toLowerCase().replaceAll(RegExp(r'[_\s-]+'), ' ');
    if (s.contains('rent')) return 'rent';
    if (s.contains('buy') || s.contains('sale')) return 'buy';
    if (s.contains('new')) return 'new projects';
    if (s.contains('commercial')) return 'commercial';
    return s;
  }
}