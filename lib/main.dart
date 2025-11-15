// lib/main.dart


// Providers
import 'package:Akarat/providers/favorite_provider.dart';
import 'package:Akarat/providers/filter_provider.dart';
import 'package:Akarat/providers/location_picker_provider.dart';
import 'package:Akarat/providers/profile_image_provider.dart';
import 'package:Akarat/providers/search_amenities_provider.dart';
import 'package:Akarat/screen/forgot_password.dart';
import 'package:Akarat/screen/home.dart'; // wraps HomeDemo inside
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/new_projects.dart';
import 'package:Akarat/screen/otp_verification.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/reset_password.dart';
// Screens
import 'package:Akarat/screen/splash_screen.dart';
// Services / Utils
import 'package:Akarat/services/api_service.dart';
import 'package:Akarat/services/session.dart';
// Firebase
import 'package:firebase_core/firebase_core.dart';
// Dart / Flutter
import 'package:flutter/material.dart';
// Env (for API_BASE_URL, etc.)
import 'package:flutter_dotenv/flutter_dotenv.dart';
// State management

// Dart / Flutter
import 'package:flutter/material.dart';

// Env (for API_BASE_URL, etc.)
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';

// State management
import 'package:provider/provider.dart';

// Screens
import 'package:Akarat/screen/splash_screen.dart';
import 'package:Akarat/screen/home.dart'; // wraps HomeDemo inside
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/forgot_password.dart';
import 'package:Akarat/screen/new_projects.dart';
import 'package:Akarat/screen/otp_verification.dart';
import 'package:Akarat/screen/reset_password.dart';

// Providers
import 'package:Akarat/providers/favorite_provider.dart';
import 'package:Akarat/providers/search_amenities_provider.dart';
import 'package:Akarat/providers/profile_image_provider.dart';
import 'package:Akarat/providers/location_picker_provider.dart';

// Services / Utils
import 'package:Akarat/services/api_service.dart';
import 'package:Akarat/services/session.dart';


// -------------------------------------------------------
// Global keys
// -------------------------------------------------------
final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> _smKey =
GlobalKey<ScaffoldMessengerState>();

// -------------------------------------------------------
// Entry point
// -------------------------------------------------------
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Load environment variables (safe if .env is missing; you may use --dart-define instead)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // It's fine if .env isn't present on device / CI
  }

  // 2) Initialize Firebase (required for Google Sign-In, FCM, etc.)
  await _initFirebase();

  // 3) Hydrate Session from SecureStorage so UI knows login state immediately
  await Session().hydrate();

  // 4) Optional: log effective base URL once at startup
  ApiService.debugPrintBaseUrl();

  // 5) Initialize providers that need async setup before runApp
  final profileProvider = ProfileImageProvider();
  await profileProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoriteProvider>(
          lazy: false,
          create: (_) {
            final p = FavoriteProvider();
            p.loadFavorites(); // fire-and-forget
            return p;
          },
        ),
        ChangeNotifierProvider.value(value: profileProvider),
        ChangeNotifierProvider(create: (_) => SearchAmenitiesProvider()),
        ChangeNotifierProvider(create: (_) => LocationPickerProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// -------------------------------------------------------
// Firebase init with graceful fallback
// -------------------------------------------------------
Future<void> _initFirebase() async {
  try {
    // Prefer this if you have firebase_options.dart:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Otherwise rely on native config files (GoogleService-Info.plist / google-services.json)
    await Firebase.initializeApp();
  } catch (e) {
    // Don't crash; log and allow app to continue (non-Firebase features still work)
    // ignore: avoid_print
    print('⚠️ Firebase initialization failed: $e');
  }
}

// -------------------------------------------------------
// App
// -------------------------------------------------------
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Global keys
      navigatorKey: navKey,
      scaffoldMessengerKey: _smKey,

      // Start on splash; it decides where to go next
      home: const SplashScreen(),

      // Static routes (no arguments)
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const RegisterScreen(),
        // Keep both spellings for safety; prefer '/my-account'
        '/my-account': (context) => const My_Account(),
        '/my_accounts': (context) => const My_Account(),
        '/home': (context) => const Home(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/new-projects': (context) => New_Projects(),
      },

      // Routes that may expect arguments
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';

        if (name == '/verify-otp') {
          // Push with (optional) args:
          // Navigator.pushNamed(context, '/verify-otp', arguments: {'email': 'x@y.com'});
          final raw = settings.arguments;
          final Map<String, dynamic> args =

              (raw is Map) ? Map<String, dynamic>.from(raw) : const {};




          return MaterialPageRoute(
            builder: (_) =>
            const OtpVerificationScreen(), // reads args via ModalRoute

            settings: RouteSettings(name: name, arguments: args),
          );
        }

        if (name == '/reset-password') {
          final raw = settings.arguments;
          final Map<String, dynamic> args =
          (raw is Map) ? Map<String, dynamic>.from(raw) : const {};
          final email = (args['email'] ?? '').toString();
          final token = (args['token'] ?? '').toString();

          return MaterialPageRoute(
            builder: (_) => (email.isEmpty || token.isEmpty)
                ? const Scaffold(
              body: Center(
                child: Text('Missing arguments for reset password.'),
              ),
            )
                : ResetPasswordScreen(email: email, token: token),
            settings: RouteSettings(name: name, arguments: args),
          );
        }

        // Fall back to default
        return null;
      },

      // Friendly fallback if an unknown route is hit
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Unknown route')),
        ),
      ),
    );
  }
}
