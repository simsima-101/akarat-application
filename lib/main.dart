import 'dart:developer' as developer;

// Providers
import 'package:Akarat/providers/favorite_provider.dart';
import 'package:Akarat/providers/filter_provider.dart';
import 'package:Akarat/providers/location_picker_provider.dart';
import 'package:Akarat/providers/profile_image_provider.dart';
import 'package:Akarat/providers/search_amenities_provider.dart';
import 'package:Akarat/providers/email_enquiry_provider.dart';

// Screens
import 'package:Akarat/screen/splash_screen.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/login.dart';
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/forgot_password.dart';
import 'package:Akarat/screen/new_projects.dart';
import 'package:Akarat/screen/otp_verification.dart';
import 'package:Akarat/screen/reset_password.dart';

// Services
import 'package:Akarat/services/session.dart';

// Other imports
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
    developer.log(".env loaded successfully");
  } catch (e) {
    developer.log("Warning: .env file not found - using dart-define values");
  }

  // Initialize Firebase
  await _initFirebase();

  // Restore session from secure storage
  await Session().restore();

  // Initialize profile image provider
  final profileProvider = ProfileImageProvider();
  await profileProvider.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<FavoriteProvider>(
          lazy: false,
          create: (_) {
            final provider = FavoriteProvider();
            provider.loadFavorites();
            return provider;
          },
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
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp();
    developer.log("Firebase initialized successfully");
  } catch (e) {
    developer.log("Firebase initialization failed: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akarat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFFE01E26),
        fontFamily: 'Tajawal',
      ),
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: const SplashScreen(),
      routes: {
        '/login': (_) => const Login(),
        '/register': (_) => const RegisterScreen(),
        '/my-account': (_) => const My_Account(),
        '/my_accounts': (_) => const My_Account(),
        '/home': (_) => const Home(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/new-projects': (_) => New_Projects(),
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
          final args = settings.arguments is Map
              ? Map<String, dynamic>.from(settings.arguments as Map)
              : <String, dynamic>{};

          final email = args['email']?.toString() ?? '';
          final token = args['token']?.toString() ?? '';

          return MaterialPageRoute(
            builder: (_) => (email.isEmpty || token.isEmpty)
                ? const Scaffold(body: Center(child: Text('Invalid reset link')))
                : ResetPasswordScreen(email: email, token: token),
            settings: settings,
          );
        }

        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}