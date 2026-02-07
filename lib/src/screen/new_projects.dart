import 'dart:async';
import 'dart:convert';

import 'package:Akarat/src/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../l10n/app_localizations.dart';
import '../core/services/api_service.dart';
import '../core/utils/secure_storage.dart';
import '../core/utils/session_manager.dart';
import '../extensions/localization_extension.dart'; // ← your context.l10n extension
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/localization/presentation/bloc/localization_cubit.dart';
import '../features/localization/presentation/bloc/localization_state.dart';
import '../features/property/data/models/project_model.dart';
import '../features/property/presentation/bloc/favorite_bloc.dart';
import '../features/property/presentation/bloc/favorite_event.dart';
import '../features/property/presentation/bloc/new_projects_bloc.dart';
import '../common/widgets/property_card.dart';
import '../utils/fav_logout.dart';
import 'ContactFormScreen.dart';
import 'featured_detail.dart';
import 'home.dart';
import 'login.dart';
import 'my_account.dart';
import 'new_project_detail.dart';

class NewProjectsScreen extends StatelessWidget {
  const NewProjectsScreen({super.key});

  int _safePropertyId(dynamic id) {
    if (id == null) return 0;
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  String phoneCallNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (input.startsWith('+971')) return input;
    if (input.startsWith('00971')) return '+971${input.substring(5)}';
    if (input.startsWith('971')) return '+971${input.substring(3)}';
    if (input.startsWith('0') && input.length == 10) return '+971${input.substring(1)}';
    if (input.length == 9) return '+971$input';
    return input;
  }

  String whatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10) return '971${input.substring(1)}';
    if (input.length == 9) return '971$input';
    return input;
  }

  Future<bool> markAsContacted(
      BuildContext context,
      int propertyId, {
        required String contactType,
      }) async {
    if (propertyId <= 0) return false;

    await SessionManager().restore();
    final token = SessionManager().token ?? await SecureStorage.getToken();
    if (token == null || token.isEmpty) return false;

    try {
      final langCode = context.read<LocalizationCubit>().state.language.toLowerCase();
      final acceptLanguage = switch (langCode) {
        'ar' => 'ar',
        'tr' => 'tr',
        _ => 'en',
      };

      debugPrint('→ NewProjects markAsContacted → Accept-Language: $acceptLanguage');

      final response = await http.post(
        ApiService.buildUri('property-contact'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept-Language': acceptLanguage,
        },
        body: jsonEncode({
          "property_id": propertyId,
          "contact_type": contactType,
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error marking as contacted (NewProjects): $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => NewProjectsBloc(
            localizationCubit: context.read<LocalizationCubit>(),
          )..add(LoadNewProjects()),
        ),
      ],
      child: BlocBuilder<LocalizationCubit, LocalizationState>(
        builder: (context, locState) {
          final isArabic = locState.language == 'ar';

          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 1,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Colors.red),
                title: Builder(
                  builder: (innerContext) {
                    return Text(
                      innerContext.l10n.newProjectsTitle,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Tajawal',
                        fontSize: 18,
                      ),
                    );
                  },
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              body: BlocBuilder<NewProjectsBloc, NewProjectsState>(
                builder: (context, state) {
                  if (state.status == NewProjectsStatus.initial ||
                      state.status == NewProjectsStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Latest Projects title
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Builder(
                          builder: (innerContext) {
                            return Text(
                              innerContext.l10n.latestProjectsTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            );
                          },
                        ),
                      ),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Builder(
                          builder: (innerContext) {
                            return Text(
                              innerContext.l10n.newProjectsSubtitle,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            );
                          },
                        ),
                      ),

                      Expanded(
                        child: ListView.builder(
                          itemCount: state.projects.length,
                          itemBuilder: (context, index) {
                            final item = state.projects[index];
                            return PropertyCard(item: item.toProperty());
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              bottomNavigationBar: _buildBottomNavBar(context),
            ),
          );
        },
      ),
    );
  }
}

// Bottom navigation bar (unchanged)
Widget _buildBottomNavBar(BuildContext context) {
  return Container(
    height: 60,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
    ),
    child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isLoggedIn = authState is AuthAuthenticated;

        final bool isOnFavorites = ModalRoute.of(context)?.settings.name == '/favorites' ||
            (ModalRoute.of(context)?.isCurrent == true &&
                ModalRoute.of(context)?.settings.arguments is Fav_Logout);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset("assets/images/home.png", height: 28),
              ),
            ),
            IconButton(
              enableFeedback: false,
              onPressed: () {
                if (isLoggedIn) {
                  if (!isOnFavorites) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const Fav_Logout(),
                        settings: const RouteSettings(name: '/favorites'),
                      ),
                    ).then((_) {
                      context.read<FavoriteBloc>().add(const LoadFavorites());
                    });
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Login Required", style: TextStyle(color: Colors.black)),
                      content: const Text("Please login to access favorites.", style: TextStyle(color: Colors.black)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginDemo()),
                            );
                          },
                          child: const Text("Login", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
              icon: Icon(
                (isLoggedIn && isOnFavorites) ? Icons.favorite : Icons.favorite_border_outlined,
                color: Colors.red,
                size: 30,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
              onPressed: () => showHomeContactDialog(context),
            ),
            IconButton(
              enableFeedback: false,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const My_Account()),
              ),
              icon: const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ],
        );
      },
    ),
  );
}