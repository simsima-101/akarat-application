import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:Akarat/screen/splash_screen.dart';
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

// Utils
import 'package:Akarat/services/api_service.dart';

// Firebase
import 'package:firebase_core/firebase_core.dart';
// If you used `flutterfire configure`, uncomment the next line and use the options in _initFirebase():
// import 'firebase_options.dart';

// Dotenv (for API_BASE_URL, etc.)
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Global keys
final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> _smKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Load environment variables first so ApiService / others can read them
  // Try to load .env if it exists, but don’t crash if it doesn’t.
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // No .env on device – that's fine when using --dart-define
  }


  // 2) Initialize Firebase (required for Google Sign-In)
  await _initFirebase();

  // 3) Optional: log effective base URL once at startup (reads from your ApiService)
  ApiService.debugPrintBaseUrl();

  // 4) Create ONE instance of ProfileImageProvider and init before runApp
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
        // Provide the already-created instance
        ChangeNotifierProvider.value(value: profileProvider),
      ],
      child: const MyApp(),
    ),
  );
}

/// Isolated Firebase init with graceful fallback if `firebase_options.dart` isn’t present.
Future<void> _initFirebase() async {
  try {
    // If you configured via `flutterfire configure`, prefer:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Otherwise, this uses native config files (GoogleService-Info.plist / google-services.json)
    await Firebase.initializeApp();
  } catch (e) {
    // Don’t crash the app; log so you can diagnose init issues.
    // ignore: avoid_print
    print('⚠️ Firebase initialization failed: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Global keys
      navigatorKey: _navKey,
      scaffoldMessengerKey: _smKey,

      // 🚀 Start with animated splash (route to Home/Login based on your logic)
      home: const SplashScreen(),

      // Static routes
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const RegisterScreen(),
        '/my_accounts': (context) => const My_Account(),
        '/home': (context) => const Home(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/new-projects': (context) => const New_Projects(),
      },

      // Routes that expect arguments
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';

        if (name == '/verify-otp') {
          final raw = settings.arguments;
          final Map<String, dynamic> args =
          (raw is Map) ? Map<String, dynamic>.from(raw) : const {};
          return MaterialPageRoute(
            builder: (_) => const OtpVerificationScreen(), // read args via ModalRoute.of(context)
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
              body: Center(child: Text('Missing arguments for reset password.')),
            )
                : ResetPasswordScreen(email: email, token: token),
            settings: RouteSettings(name: name, arguments: args),
          );
        }

        // Fall back to default routes map
        return null;
      },

      // Friendly fallback
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Unknown route')),
        ),
      ),
    );
  }
}
