import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../core/constants/constants.dart' as ApiService;
import '../core/utils/secure_storage.dart';
import '../features/property/data/datasources/favorite_remote_datasource.dart';
import '../features/property/data/models/saved_alert_model.dart';
import '../utils/fav_logout.dart';
import 'CreateAlertScreen.dart';
import 'home.dart';
import 'login.dart';
import 'my_account.dart';

// ──────────────────────────────────────────────────────────────
//  STATE
// ──────────────────────────────────────────────────────────────

enum SavedAlertsStatus {
  initial,
  loading,
  success,
  error,
  deleting,
  deleteSuccess,
  deleteError,
}

class SavedAlertsState {
  final SavedAlertsStatus status;
  final List<SavedAlert> alerts;
  final int currentPage;
  final int pageSize;
  final String? errorMessage;
  final bool isDeletingAll;

  const SavedAlertsState({
    this.status = SavedAlertsStatus.initial,
    this.alerts = const [],
    this.currentPage = 1,
    this.pageSize = 4,
    this.errorMessage,
    this.isDeletingAll = false,
  });

  int get totalPages => alerts.isEmpty ? 1 : ((alerts.length - 1) ~/ pageSize) + 1;

  List<SavedAlert> get pageItems {
    if (alerts.isEmpty) return const [];
    final start = (currentPage - 1) * pageSize;
    final end = (currentPage * pageSize).clamp(0, alerts.length);
    if (start >= alerts.length) return const [];
    return alerts.sublist(start, end);
  }

  bool get isLastPage => currentPage >= totalPages;

  SavedAlertsState copyWith({
    SavedAlertsStatus? status,
    List<SavedAlert>? alerts,
    int? currentPage,
    String? errorMessage,
    bool? isDeletingAll,
  }) {
    return SavedAlertsState(
      status: status ?? this.status,
      alerts: alerts ?? this.alerts,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize,
      errorMessage: errorMessage ?? this.errorMessage,
      isDeletingAll: isDeletingAll ?? this.isDeletingAll,
    );
  }
}

// ──────────────────────────────────────────────────────────────
//  CUBIT
// ──────────────────────────────────────────────────────────────

class SavedAlertsCubit extends Cubit<SavedAlertsState> {
  SavedAlertsCubit() : super(const SavedAlertsState());

  String? _token;

  Future<void> initialize({String? token}) async {
    _token = token ?? await readToken();
    await loadAlerts();
  }

  Future<void> loadAlerts() async {
    emit(state.copyWith(status: SavedAlertsStatus.loading));

    try {
      final list = await _fetchAlerts();
      emit(state.copyWith(
        status: SavedAlertsStatus.success,
        alerts: list,
        currentPage: 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SavedAlertsStatus.error,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }

  Future<void> reloadAlerts({bool goToLastPage = false}) async {
    try {
      final newList = await _fetchAlerts();

      int newPage = state.currentPage;
      if (goToLastPage || newList.length > state.alerts.length) {
        newPage = newList.isEmpty ? 1 : ((newList.length - 1) ~/ state.pageSize) + 1;
      } else if (newPage > ((newList.length - 1) ~/ state.pageSize) + 1) {
        newPage = newList.isEmpty ? 1 : ((newList.length - 1) ~/ state.pageSize) + 1;
      }

      emit(state.copyWith(
        status: SavedAlertsStatus.success,
        alerts: newList,
        currentPage: newPage,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SavedAlertsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> deleteAlert(SavedAlert alert) async {
    if (_token == null) return;

    emit(state.copyWith(status: SavedAlertsStatus.deleting));

    bool success = false;

    try {
      success = await _tryDelete('${ApiService.baseUrl}/alerts/${alert.id}');
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

        emit(state.copyWith(
          status: SavedAlertsStatus.deleteSuccess,
          alerts: updated,
          currentPage: newPage,
        ));
      } else {
        emit(state.copyWith(
          status: SavedAlertsStatus.deleteError,
          errorMessage: 'Failed to delete alert',
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: SavedAlertsStatus.deleteError,
        errorMessage: 'Network error',
      ));
    }
  }

  Future<bool> _tryDelete(String urlStr) async {
    final url = Uri.parse(urlStr);
    final res = await http.delete(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $_token',
        'X-Requested-With': 'XMLHttpRequest',
      },
    );
    return res.statusCode >= 200 && res.statusCode < 300;
  }

  Future<void> deleteAllAlerts() async {
    if (_token == null || state.isDeletingAll) return;

    emit(state.copyWith(isDeletingAll: true, status: SavedAlertsStatus.deleting));

    try {
      final url = Uri.parse('${ApiService.baseUrl}/alerts-deleteall');
      var res = await http.delete(url, headers: _headers);

      if (res.statusCode == 405 || res.statusCode == 404) {
        res = await http.post(url, headers: _headers);
      }

      if (res.statusCode >= 200 && res.statusCode < 300) {
        emit(state.copyWith(
          status: SavedAlertsStatus.deleteSuccess,
          alerts: const [],
          currentPage: 1,
          isDeletingAll: false,
        ));
      } else {
        emit(state.copyWith(
          status: SavedAlertsStatus.deleteError,
          errorMessage: 'Failed to delete all (HTTP ${res.statusCode})',
          isDeletingAll: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
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
    if (_token == null || _token!.isEmpty) {
      throw Exception('Not authenticated');
    }

    debugPrint('→ Fetching saved alerts...');
    final url = Uri.parse('${ApiService.baseUrl}/saved-searches');
    final res = await http.get(url, headers: _headers);

    if (res.statusCode == 401) {
      throw Exception('401 - Unauthorized');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = jsonDecode(res.body);

      List<dynamic> rawItems = [];

      // Safe nested parsing (most common pattern in your API)
      if (body is Map<String, dynamic>) {
        final dataLevel1 = body['data'];
        if (dataLevel1 is Map<String, dynamic>) {
          // This is your real list: data.data
          rawItems = dataLevel1['data'] as List<dynamic>? ?? [];
        }
        // Fallback if API changes to direct list
        else if (dataLevel1 is List<dynamic>) {
          rawItems = dataLevel1;
        }

        // Extra fallback for other possible keys
        else if (body['saved_searches'] is List<dynamic>) {
          rawItems = body['saved_searches'] as List<dynamic>;
        }
      }
      // Very rare: root is list
      else if (body is List<dynamic>) {
        rawItems = body;
      }

      debugPrint('→ Parsed ${rawItems.length} raw items');

      // Convert to model (safe cast)
      return rawItems.map((item) {
        if (item is Map<String, dynamic>) {
          return SavedAlert.fromJson(item);
        }
        throw Exception('Invalid item format: expected Map, got ${item.runtimeType}');
      }).toList();
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
    emit(state.copyWith(currentPage: safePage));
  }
}

// ──────────────────────────────────────────────────────────────
//  SCREEN
// ──────────────────────────────────────────────────────────────

class SavedAlertsScreen extends StatelessWidget {
  final String? token;
  const SavedAlertsScreen({super.key, this.token});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SavedAlertsCubit()..initialize(token: token),
      child: const _SavedAlertsView(),
    );
  }
}

class _SavedAlertsView extends StatelessWidget {
  const _SavedAlertsView();

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: _buildNavBar(context),
        ),
      ),
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.red),
        actions: [
          BlocBuilder<SavedAlertsCubit, SavedAlertsState>(
            buildWhen: (p, c) => p.alerts.length != c.alerts.length,
            builder: (context, state) {
              if (state.alerts.isEmpty) return const SizedBox.shrink();
              return Row(
                children: [
                  IconButton(
                    tooltip: l10n.howToRemoveSavedAlerts,
                    icon: Icon(Icons.info_outline, color: Colors.grey[600]),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(
                            l10n.howToRemoveTitle,
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                          ),
                          content: Text(
                            l10n.howToRemoveMessage,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                l10n.gotIt,
                                style: const TextStyle(color: Colors.red, fontSize: 17, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Gap(5),
                  TextButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: Colors.white,
                          title: Text(l10n.clearAllTitle),
                          content: Text(l10n.clearAllConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text("Clear", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true && context.mounted) {
                        context.read<SavedAlertsCubit>().deleteAllAlerts();
                      }
                    },
                    child: Text(l10n.clearAll, style: const TextStyle(color: Colors.red, fontSize: 15)),
                  ),
                  const Gap(10),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<SavedAlertsCubit, SavedAlertsState>(
        listener: (context, state) {
          if (state.status == SavedAlertsStatus.deleteSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.alerts.isEmpty ? l10n.allAlertsDeleted : l10n.alertDeleted),
                duration: const Duration(milliseconds: 1500),
              ),
            );
          }
          if (state.status == SavedAlertsStatus.deleteError || state.status == SavedAlertsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? l10n.errorOccurred)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == SavedAlertsStatus.loading && state.alerts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == SavedAlertsStatus.error && state.alerts.isEmpty) {
            return _ErrorView(
              message: state.errorMessage ?? 'Failed to load alerts',
              onRetry: () => context.read<SavedAlertsCubit>().loadAlerts(),
            );
          }

          final cubit = context.read<SavedAlertsCubit>();

          return Column(
            children: [
              if (state.alerts.isNotEmpty || state.status != SavedAlertsStatus.loading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.savedAlerts,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black, height: 1.1),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '(${state.alerts.length})',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFFF4D4D), height: 1.2),
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.manageYourSavedPropertyAlerts,
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.2),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: state.alerts.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.youHaventSavedAnyAlertsYet,
                        style: const TextStyle(color: Colors.black54, fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const Gap(24),
                      SizedBox(
                        width: 150,
                        child: CreateAlertButton(
                          disabled: false,
                          onTap: () => _onCreateAlert(context, cubit),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: state.pageItems.length,
                  itemBuilder: (context, index) {
                    final alert = state.pageItems[index];
                    return Dismissible(
                      key: Key(alert.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white, size: 30),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: Colors.white,
                            title: Text(l10n.deleteAlertTitle),
                            content: Text(l10n.deleteAlertConfirm),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(l10n.cancel, style: const TextStyle(color: Colors.red)),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        ) ??
                            false;
                      },
                      onDismissed: (_) => cubit.deleteAlert(alert),
                      child: SavedAlertCard(
                        title: alert.alertName ?? l10n.unnamedAlert,           // ← localized fallback (good)
                        frequency: alert.timePeriod ?? l10n.daily,             // ← also better to localize
                        created: _relativeTime(alert.createdAt, l10n),         // ← FIXED: pass l10n
                      ),
                    );
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              if (state.totalPages > 1)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: state.currentPage > 1 ? () => cubit.changePage(state.currentPage - 1) : null,
                      ),
                      Text('Page ${state.currentPage} of ${state.totalPages}'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: !state.isLastPage ? () => cubit.changePage(state.currentPage + 1) : null,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }


  String _formatFrequency(String? raw, AppLocalizations l10n) {
    if (raw == null || raw.isEmpty) return l10n.daily;

    final lower = raw.trim().toLowerCase();
    switch (lower) {
      case 'hourly':
        return l10n.hourly;
      case 'daily':
        return l10n.daily;
      case 'weekly':
        return l10n.weekly;
      case 'monthly':
        return l10n.monthly;
      default:
        return raw; // fallback to raw value if unknown
    }
  }

  Future<void> _onCreateAlert(BuildContext context, SavedAlertsCubit cubit) async {

    final l10n = AppLocalizations.of(context)!;
    final isLoggedIn = await _isUserLoggedIn();
    if (!isLoggedIn) {
      // Show your beautiful login required dialog
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            height: 70,
            margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -14,
                  right: -10,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(ctx).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 12,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.loginRequiredToCreateAlerts,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pushNamed('/login');
                        },
                        child: Text(
                          l10n.login,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                            decorationThickness: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateAlertScreen(
          initialPurpose: l10n.purposeRent,
          initialPropertyType: l10n.propertyTypeAny,
          isFromSavedAlerts: true,
        ),
      ),
    );

    if (saved == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.alertCreated),
          duration: const Duration(milliseconds: 1200),
        ),
      );
      await cubit.reloadAlerts(goToLastPage: true);
    }
  }

  Future<bool> _isUserLoggedIn() async {
    final token = await readToken();
    return token != null && token.isNotEmpty;
  }

  String _relativeTime(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) {
      return l10n.justNow;
    }

    if (diff.inMinutes < 60) {
      return l10n.minutesAgo(diff.inMinutes);
    }

    if (diff.inHours < 24) {
      return l10n.hoursAgo(diff.inHours);
    }

    return l10n.daysAgo(diff.inDays);
  }

  // ────────────────────────────────────────────────
  // Bottom Navigation Bar (kept almost identical)
  // ────────────────────────────────────────────────
  Container _buildNavBar(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    const pageIndex = 2;

    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const Home())),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Image(image: AssetImage("assets/images/home.png"), height: 25),
            ),
          ),
          IconButton(
            enableFeedback: false,
            onPressed: () async {
              final token = await SecureStorage.getToken();
              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(l10n.loginRequired, style: const TextStyle(color: Colors.black)),
                    content: Text(l10n.pleaseLoginToAccessFavorites, style: const TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.cancel, style: const TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
                        },
                        child: Text(l10n.login, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const Fav_Logout())).then((_) async {
                  // Optional: refresh favorites if needed
                });
              }
            },
            icon: const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
          ),
          IconButton(
            tooltip: l10n.emailHint,
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () async {
              final Uri emailUri = Uri.parse(
                'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.',
              );
              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text(l10n.emailNotAvailable, style: const TextStyle(color: Colors.black)),
                    content: Text(
                      l10n.noEmailAppConfigured,
                      style: const TextStyle(color: Colors.black),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.ok, style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const My_Account()));
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}
String _formatFrequency(String? raw, AppLocalizations l10n) {
  if (raw == null || raw.isEmpty) return l10n.daily;

  final lower = raw.trim().toLowerCase();
  switch (lower) {
    case 'hourly':
      return l10n.hourly;
    case 'daily':
      return l10n.daily;
    case 'weekly':
      return l10n.weekly;
    case 'monthly':
      return l10n.monthly;
    default:
      return raw; // fallback – shows whatever the backend sent
  }
}
// ──────────────────────────────────────────────────────────────
//  SUPPORTING WIDGETS (unchanged)
// ──────────────────────────────────────────────────────────────

class SavedAlertCard extends StatelessWidget {
  final String title;
  final String? frequency;           // ← make it nullable to match model
  final String created;

  const SavedAlertCard({
    super.key,
    required this.title,
    this.frequency,                   // ← can be null
    required this.created,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // ← HERE: format the raw frequency using your helper
    final displayFrequency = _formatFrequency(frequency, l10n);



    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            color: Colors.grey.shade300,
            blurRadius: 3,
            spreadRadius: 3,
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.receiveUpdates,
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey, width: 0.6),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ← Use the localized version here
                Text(
                  displayFrequency,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            created,
            style: const TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class CreateAlertButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool disabled;

  const CreateAlertButton({super.key, this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    const gradient = LinearGradient(
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
      colors: [Color(0xFFFFA3A3), Color(0xFFFFFFFF)],
    );

    return AbsorbPointer(
      absorbing: disabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: disabled ? null : onTap,
          splashColor: disabled ? Colors.transparent : null,
          highlightColor: disabled ? Colors.transparent : null,
          child: Container(
            height: 41,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.red, width: 1),
              gradient: gradient,
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/bell-red.png',
                  height: 18,
                  width: 18,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.notifications_none, size: 18, color: Colors.black),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.createAlert,
                  style: const TextStyle(color: Colors.black, fontSize: 15, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    return Center(


      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('l10n.errorTitleWithMessage', textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryButton),
            ),
          ],
        ),
      ),
    );
  }
}