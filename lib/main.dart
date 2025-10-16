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

// ✅ add: to print base URL at startup
import 'package:Akarat/services/api_service.dart';

// ✅ add: global keys
final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> _smKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Create ONE instance and initialize it before runApp
  final profileProvider = ProfileImageProvider();
  await profileProvider.initialize();

  // ✅ Log the effective base URL once at startup (super helpful for your case)
  ApiService.debugPrintBaseUrl();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoriteProvider()..loadFavorites()),
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

      // ✅ global keys
      navigatorKey: _navKey,
      scaffoldMessengerKey: _smKey,

      home: const Home(),

      // Keep simple static routes
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => RegisterScreen(),
        '/my_accounts': (context) => My_Account(),
        '/home': (context) => const Home(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/new-projects': (context) => const New_Projects(),
      },

      // ✅ Safely hydrate routes that expect arguments (verify-otp, reset-password)
      onGenerateRoute: (settings) {
        if (settings.name == '/verify-otp') {
          // We expect a Map<String, dynamic> but handle null gracefully
          final args = (settings.arguments is Map)
              ? settings.arguments as Map
              : const <String, dynamic>{};

          return MaterialPageRoute(
            builder: (_) => const OtpVerificationScreen(), // screen will read ModalRoute args
            settings: RouteSettings(name: settings.name, arguments: args),
          );
        }

        if (settings.name == '/reset-password') {
          final args = (settings.arguments is Map)
              ? settings.arguments as Map
              : const <String, dynamic>{};

          final email = (args['email'] ?? '').toString();
          final token = (args['token'] ?? '').toString();

          return MaterialPageRoute(
            builder: (_) => (email.isEmpty || token.isEmpty)
                ? const Scaffold(
              body: Center(child: Text('Missing arguments for reset password.')),
            )
                : ResetPasswordScreen(email: email, token: token),
            settings: RouteSettings(name: settings.name, arguments: args),
          );
        }

        return null; // fall back to `routes:` map
      },

      // Optional: friendly fallback
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Unknown route')),
        ),
      ),
    );
  }
}
