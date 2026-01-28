import 'package:Akarat/src/screen/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/widgets/property_card.dart'; // ← Your reusable card
import '../core/utils/secure_storage.dart';
import '../features/property/data/models/project_model.dart';
import '../features/property/presentation/bloc/new_projects_bloc.dart';
import '../utils/fav_logout.dart';
import 'ContactFormScreen.dart';
import 'login.dart';
import 'my_account.dart';

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
    if (input.startsWith('0') && input.length == 10)
      return '+971${input.substring(1)}';
    if (input.length == 9) return '+971$input';
    return input;
  }

  String whatsAppNumber(String input) {
    input = input.replaceAll(RegExp(r'[^\d]'), '');
    if (input.startsWith('971')) return input;
    if (input.startsWith('00971')) return input.substring(2);
    if (input.startsWith('+971')) return input.substring(1);
    if (input.startsWith('0') && input.length == 10)
      return '971${input.substring(1)}';
    if (input.length == 9) return '971$input';
    return input;
  }
  //
  // Future<bool> markAsContacted(BuildContext context, int propertyId,
  //     {required String contactType}) async {
  //   if (propertyId <= 0) return false;
  //
  //   await SessionManager().restore();
  //   final token = SessionManager().token ?? await SecureStorage.getToken();
  //   if (token == null || token.isEmpty) return false;
  //
  //   try {
  //     final response = await http.post(
  //       ApiService.buildUri('property-contact'),
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode(
  //           {"property_id": propertyId, "contact_type": contactType}),
  //     );
  //     return response.statusCode == 200 || response.statusCode == 201;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NewProjectsBloc()..add(LoadNewProjects())),
        // FavoriteBloc is already provided globally in main.dart or higher
        // If not, add it here too: BlocProvider(create: (_) => FavoriteBloc()..add(LoadFavorites())),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.red),
          title: const Text(
            "New Projects",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        bottomNavigationBar: SafeArea(child: _buildBottomNavBar(context)),
        body: BlocBuilder<NewProjectsBloc, NewProjectsState>(
          builder: (context, state) {
            if (state.status == NewProjectsStatus.initial ||
                state.status == NewProjectsStatus.loading) {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
                itemCount: 6,
                itemBuilder: (_, __) => const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: ShimmerCard(),
                ),
              );
            }

            if (state.status == NewProjectsStatus.error) {
              return Center(
                child: Text(
                  state.errorMessage ?? "Failed to load projects.",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red),
                ),
              );
            }

            if (state.projects.isEmpty) {
              return const Center(
                child: Text(
                  "No properties found.",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: (scrollInfo) {
                if (scrollInfo.metrics.pixels >=
                        scrollInfo.metrics.maxScrollExtent - 100 &&
                    state.hasMore &&
                    state.status != NewProjectsStatus.loadingMore) {
                  context.read<NewProjectsBloc>().add(LoadMoreNewProjects());
                }
                return false;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 20, left: 20, right: 20),
                    child: Text(
                      "Latest Projects in Dubai",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(
                        top: 12, left: 20, right: 20, bottom: 20),
                    child: Text(
                      "Find off-plan development and everything you need to know to invest in UAE's real estate market",
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 8), // ← main change here
                      // or try: horizontal: 6   ← very common modern value
                      //         horizontal: 8   ← safer / more conservative
                      itemCount: state.projects.length +
                          (state.status == NewProjectsStatus.loadingMore
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        if (index == state.projects.length) {
                          return const Padding(
                            padding: EdgeInsets.all(20),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final item = state.projects[index];

                        return PropertyCard(item: item.toProperty());
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))
        ],
      ),
      child: Row(
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
            onPressed: () async {
              final token = await SecureStorage.getToken();
              if (token == null || token.isEmpty) {
                // Show login dialog
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Login Required"),
                    content: const Text("Please login to access favorites."),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel")),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginDemo()));
                        },
                        child: const Text("Login"),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const Fav_Logout()));
              }
            },
            icon: const Icon(Icons.favorite_border_outlined,
                color: Colors.red, size: 30),
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () => showHomeContactDialog(context),
          ),
          IconButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const My_Account())),
            icon:
                const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
          ),
        ],
      ),
    );
  }
}
