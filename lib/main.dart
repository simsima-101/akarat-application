import 'package:Akarat/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Screens
import 'package:Akarat/screen/login.dart';                 // NOTE: elsewhere you sometimes use LoginDemo
import 'package:Akarat/screen/register_screen.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/home.dart';                  // contains HomeDemo
import 'package:Akarat/screen/forgot_password.dart';
import 'package:Akarat/screen/otp_verification.dart';
import 'package:Akarat/screen/reset_password.dart';
import 'package:Akarat/screen/new_projects.dart';

// Providers
import 'package:Akarat/providers/favorite_provider.dart';
import 'providers/profile_image_provider.dart';

// Utils
import 'package:Akarat/services/api_service.dart';



// Global keys
final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> _smKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log effective base URL once at startup
  ApiService.debugPrintBaseUrl();

  // Create ONE instance of ProfileImageProvider and init before runApp
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Global keys
      navigatorKey: _navKey,
      scaffoldMessengerKey: _smKey,

      // 🚀 Start with animated splash (routes to HomeDemo afterward)
      home: const SplashScreen(),

      // Simple static routes
      routes: {
        '/login': (context) => const Login(),                 // NOTE: if you use LoginDemo elsewhere, align names
        '/register': (context) => const RegisterScreen(),
        '/my_accounts': (context) => const My_Account(),
        '/home': (context) => const Home(),                   // wraps HomeDemo inside
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/new-projects': (context) => const New_Projects(),
      },

      // Routes that expect arguments
      onGenerateRoute: (settings) {
        final name = settings.name ?? '';

        if (name == '/verify-otp') {
          // Expect a Map but handle anything gracefully
          final raw = settings.arguments;
          final Map<String, dynamic> args =
          (raw is Map) ? Map<String, dynamic>.from(raw) : const {};

          return MaterialPageRoute(
            builder: (_) => const OtpVerificationScreen(), // reads args via ModalRoute
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

        // Fall back to routes: map (or return an "unknown" page if you prefer)
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
