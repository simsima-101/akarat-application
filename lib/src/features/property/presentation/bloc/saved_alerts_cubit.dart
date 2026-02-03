// features/saved_alerts/bloc/saved_alerts_cubit.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../../core/constants/constants.dart' as ApiService;
import '../../../../core/utils/secure_storage.dart';
import '../../../../screen/CreateAlertScreen.dart';
import '../../data/models/saved_alert_model.dart';
import 'saved_alerts_state.dart';

class SavedAlertsCubit extends Cubit<SavedAlertsState> {
  SavedAlertsCubit() : super(const SavedAlertsState());

  String? _token;

  Future<void> initialize({String? token}) async {
    _token = token ?? await readToken();
    debugPrint('→ Cubit initialized, token: ${_token != null ? "present" : "missing"}');
    await loadAlerts();
  }

  Future<void> loadAlerts() async {
    debugPrint('→ loadAlerts called');
    _safeEmit(state.copyWith(status: SavedAlertsStatus.loading));

    try {
      final newList = await _fetchAlerts();
      debugPrint('→ Fetched ${newList.length} alerts');
      _safeEmit(state.copyWith(
        status: SavedAlertsStatus.success,
        alerts: newList,
        currentPage: 1,
      ));
    } catch (e) {
      debugPrint('→ Load error: $e');
      _safeEmit(state.copyWith(
        status: SavedAlertsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> reloadAlerts({bool goToLastPage = false}) async {
    debugPrint('→ reloadAlerts called (goToLastPage: $goToLastPage)');
    try {
      final newList = await _fetchAlerts();
      debugPrint('→ Reload fetched ${newList.length} alerts');

      int newPage = state.currentPage;
      final oldLength = state.alerts.length;
      final newLength = newList.length;

      if (goToLastPage || newLength > oldLength) {
        newPage = newList.isEmpty ? 1 : ((newLength - 1) ~/ state.pageSize) + 1;
      } else if (newPage > ((newLength - 1) ~/ state.pageSize) + 1) {
        newPage = newLength == 0 ? 1 : ((newLength - 1) ~/ state.pageSize) + 1;
      }

      _safeEmit(state.copyWith(
        status: SavedAlertsStatus.success,
        alerts: newList,
        currentPage: newPage,
      ));
    } catch (e) {
      debugPrint('→ Reload error: $e');
      _safeEmit(state.copyWith(
        status: SavedAlertsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteAlert(SavedAlert alert) async {
    if (_token == null) return;

    debugPrint('→ Deleting alert ID: ${alert.id}');
    _safeEmit(state.copyWith(status: SavedAlertsStatus.deleting));

    try {
      bool success = await _tryDelete('${ApiService.baseUrl}/alerts/${alert.id}');
      if (!success) {
        success = await _tryDelete('${ApiService.baseUrl}/saved-searches/${alert.id}');
      }

      if (success) {
        final updated = List<SavedAlert>.from(state.alerts)
          ..removeWhere((a) => a.id == alert.id);

        int newPage = state.currentPage;
        final newPageItems = _getPageItems(updated, newPage);
        if (newPageItems.isEmpty && newPage > 1) {
          newPage--;
        }

        _safeEmit(state.copyWith(
          status: SavedAlertsStatus.deleteSuccess,
          alerts: updated,
          currentPage: newPage,
        ));
      } else {
        _safeEmit(state.copyWith(
          status: SavedAlertsStatus.deleteError,
          errorMessage: 'Failed to delete alert',
        ));
      }
    } catch (e) {
      debugPrint('→ Delete error: $e');
      _safeEmit(state.copyWith(
        status: SavedAlertsStatus.deleteError,
        errorMessage: 'Network error while deleting',
      ));
    }
  }

  Future<bool> _tryDelete(String endpoint) async {
    final url = Uri.parse(endpoint);
    final res = await http.delete(url, headers: _headers);
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  Future<void> deleteAllAlerts() async {
    if (_token == null || state.isDeletingAll) return;

    debugPrint('→ Deleting all alerts');
    _safeEmit(state.copyWith(
      status: SavedAlertsStatus.deleting,
      isDeletingAll: true,
    ));

    try {
      final url = Uri.parse('${ApiService.baseUrl}/alerts-deleteall');
      var res = await http.delete(url, headers: _headers);

      if (res.statusCode == 404 || res.statusCode == 405) {
        res = await http.post(url, headers: _headers);
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        _safeEmit(state.copyWith(
          status: SavedAlertsStatus.deleteSuccess,
          alerts: const [],
          currentPage: 1,
          isDeletingAll: false,
        ));
      } else {
        _safeEmit(state.copyWith(
          status: SavedAlertsStatus.deleteError,
          errorMessage: 'Failed to delete all (HTTP ${res.statusCode})',
          isDeletingAll: false,
        ));
      }
    } catch (e) {
      debugPrint('→ Delete all error: $e');
      _safeEmit(state.copyWith(
        status: SavedAlertsStatus.deleteError,
        errorMessage: e.toString(),
        isDeletingAll: false,
      ));
    }
  }

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $_token',
    'X-Requested-With': 'XMLHttpRequest',
  };

  Future<List<SavedAlert>> _fetchAlerts() async {
    if (_token == null || _token!.isEmpty) throw Exception('Not authenticated');

    debugPrint('→ Fetching saved alerts...');
    final url = Uri.parse('${ApiService.baseUrl}/saved-searches');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 401) throw Exception('401 - Unauthorized');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);
      List<dynamic> list = body is List ? body : (body['data'] ?? body['saved_searches'] ?? []);

      final result = list.map((e) => SavedAlert.fromJson(e as Map<String, dynamic>)).toList();
      debugPrint('→ Fetched ${result.length} alerts');
      return result;
    }

    final msg = (jsonDecode(res.body) as Map?)?['message'] ?? 'HTTP ${res.statusCode}';
    throw Exception(msg);
  }

  List<SavedAlert> _getPageItems(List<SavedAlert> list, int page) {
    final start = (page - 1) * state.pageSize;
    final end = (page * state.pageSize).clamp(0, list.length);
    if (start >= list.length) return const [];
    return list.sublist(start, end);
  }

  void changePage(int page) {
    final total = state.totalPages;
    final safePage = page.clamp(1, total);
    _safeEmit(state.copyWith(currentPage: safePage));
  }

  // Prevent redundant emits & log what actually changes
  void _safeEmit(SavedAlertsState newState) {
    if (newState == state) {
      debugPrint('→ Skipped emit (state identical)');
      return;
    }
    debugPrint('→ Emitting change → alerts: ${newState.alerts.length}, page: ${newState.currentPage}, '
        'status: ${newState.status}, deletingAll: ${newState.isDeletingAll}');
    emit(newState);
  }

  @override
  Future<void> close() {
    _token = null;
    return super.close();
  }
}