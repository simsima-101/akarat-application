import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/forgot_password.dart';
import 'package:Akarat/screen/otp_verification.dart';
import 'package:Akarat/screen/reset_password.dart';
import 'package:Akarat/screen/new_projects.dart';

// Providers
import 'package:Akarat/providers/favorite_provider.dart';
import 'providers/profile_image_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Create ONE instance and initialize it before runApp
  final profileProvider = ProfileImageProvider();
  await profileProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()..loadFavorites()),

        // ✅ Use the SAME initialized instance (no second constructor call)
        ChangeNotifierProvider.value(value: profileProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const Home(), // or const New_Projects()
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => RegisterScreen(),
        '/my_accounts': (context) => My_Account(),
        '/home': (context) => const Home(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-otp': (context) => const OtpVerificationScreen(),
        '/reset-password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          if (args == null || !args.containsKey('email') || !args.containsKey('token')) {
            return const Scaffold(
              body: Center(child: Text('Missing arguments for reset password.')),
            );
          }
          return ResetPasswordScreen(
            email: args['email'] ?? '',
            token: args['token'] ?? '',
          );
        },
        '/new-projects': (context) => const New_Projects(),
      },
    );
  }
}
