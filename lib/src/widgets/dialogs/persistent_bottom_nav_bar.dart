import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:Akarat/src/core/utils/secure_storage.dart';
import 'package:Akarat/src/features/property/presentation/bloc/favorite_bloc.dart';
import 'package:Akarat/src/features/property/presentation/bloc/favorite_event.dart';

import 'package:Akarat/src/screen/login.dart';
import 'package:Akarat/src/screen/home.dart';

import '../../screen/ContactFormScreen.dart'; // for showHomeContactDialog if needed

class PersistentBottomNavBar extends StatelessWidget {
  final int currentIndex; // Used to highlight the active icon

  const PersistentBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
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
          // Home Icon
          GestureDetector(
            onTap: () {
              if (currentIndex != 0) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/home',
                      (route) => false,
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset(
                "assets/images/home.png",
                height: 25,
                color: currentIndex == 0 ? const Color(0xFFE01E26) : Colors.grey,
              ),
            ),
          ),

          // Favorites Icon – with full login check and dialog
          IconButton(
            enableFeedback: false,
            onPressed: () async {
              final token = await SecureStorage.getToken();

              if (token == null || token.isEmpty) {
                // FULLY FIXED showDialog – no more errors
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text(
                        "Login Required",
                        style: TextStyle(color: Colors.black),
                      ),
                      content: const Text(
                        "Please login to access favorites.",
                        style: TextStyle(color: Colors.black),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext); // Close dialog
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const Login()),
                            );
                          },
                          child: const Text(
                            "Login",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );
              } else {
                // User is logged in
                if (currentIndex != 1) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/favorites',
                        (route) => false,
                  );
                }
                // Refresh favorites list
                context.read<FavoriteBloc>().add(LoadFavorites());
              }
            },
            icon: currentIndex == 1
                ? const Icon(Icons.favorite, color: Color(0xFFE01E26), size: 30)
                : const Icon(Icons.favorite_border_outlined, color: Color(0xFFE01E26), size: 30),
          ),

          // Contact / Email Icon
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Color(0xFFE01E26), size: 28),
            onPressed: () {
              showHomeContactDialog(context);
            },
          ),

          // My Account Icon
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                if (currentIndex != 3) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/my-account',
                        (route) => false,
                  );
                }
              },
              child: Icon(
                currentIndex == 3 ? Icons.dehaze : Icons.dehaze_outlined,
                color: const Color(0xFFE01E26),
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}