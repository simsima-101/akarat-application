import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:Akarat/providers/email_enquiry_provider.dart';
import 'package:Akarat/providers/favorite_provider.dart';
import 'package:Akarat/providers/filter_provider.dart';
import 'package:Akarat/providers/location_picker_provider.dart';
import 'package:Akarat/providers/profile_image_provider.dart';
import 'package:Akarat/providers/search_amenities_provider.dart';

import 'package:Akarat/screen/forgot_password.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/new_projects.dart';
import 'package:Akarat/screen/otp_verification.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/reset_password.dart';
import 'package:Akarat/screen/splash_screen.dart';

import 'package:Akarat/services/session.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

// Your QA API
String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://akarat.com/api';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 1. Load .env file (you already have - .env in assets)
    await dotenv.load(fileName: ".env");
    developer.log("API_BASE_URL loaded: $apiBaseUrl");

    // 2. Firebase initialization — THIS IS THE 100% CORRECT WAY FOR iOS
    await Firebase.initializeApp(
      // This automatically reads GoogleService-Info.plist on iOS (and falls back on Android)
      options: FirebaseOptions(
        apiKey: "AIzaSyAXaA_SQY4HCI1mHqjo3eFhG7d9sKUeBS8",           // From your plist
        appId: "1:370139668712:ios:4b40488a7a407f2a7295d",           // GOOGLE_APP_ID from plist
        messagingSenderId: "370139668712",                          // GCM_SENDER_ID
        projectId: "akarat-fd6f4",                                  // PROJECT_ID
        iosBundleId: "com.akarat.io",                               // BUNDLE_ID
      ),
    );
    developer.log("Firebase initialized successfully");

    // 3. Restore session
    await Session().restore();
    await Session().refreshProfileFromServer();

    // 4. Initialize profile provider
    final profileProvider = ProfileImageProvider();
    await profileProvider.initialize();

    // 5. Run app
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<FavoriteProvider>(
            create: (_) {
              final p = FavoriteProvider();
              p.loadFavorites();
              return p;
            },
            lazy: false,
          ),
          ChangeNotifierProvider.value(value: profileProvider),
          ChangeNotifierProvider(create: (_) => SearchAmenitiesProvider()),
          ChangeNotifierProvider(create: (_) => LocationPickerProvider()),
          ChangeNotifierProvider(create: (_) => FilterProvider()),
          ChangeNotifierProvider(create: (_) => EmailEnquiryProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stack) {
    developer.log("FATAL ERROR IN main(): $e", stackTrace: stack);
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: Center(
            child: Text(
              "App crashed:\n$e\n\nCheck Xcode console",
              style: const TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akarat',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE01E26),
        fontFamily: 'Tajawal',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const Login(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const Home(),
        '/my-account': (_) => const My_Account(),
        '/my_accounts': (_) => const My_Account(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/new-projects': (_) => const New_Projects(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/verify-otp') {
          final args = settings.arguments is Map
              ? Map<String, dynamic>.from(settings.arguments as Map)
              : <String, dynamic>{};
          return MaterialPageRoute(
            builder: (_) => const OtpVerificationScreen(),
            settings: RouteSettings(name: settings.name, arguments: args),
          );
        }

        if (settings.name == '/reset-password') {
          final args = settings.arguments as Map<String, dynamic>? ?? {};
          final email = args['email']?.toString() ?? '';
          final token = args['token']?.toString() ?? '';
          if (email.isEmpty || token.isEmpty) {
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Invalid password reset link')),
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(email: email, token: token),
            settings: settings,
          );
        }
        return null;
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Page Not Found')),
        ),
      ),
    );
  }
}