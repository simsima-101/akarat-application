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

// Providers & Utils
import 'package:Akarat/providers/favorite_provider.dart';
import 'package:Akarat/secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final token = await SecureStorage.getToken();

  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoriteProvider(),
      child: MyApp(initialRoute: token == null ? '/login' : '/my_accounts'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => RegisterScreen(),
        '/my_accounts': (context) => My_Account(),
        '/home': (context) => const Home(),

        // Password Reset Flow Routes
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/verify-otp': (context) => const OtpVerificationScreen(),
        '/reset-password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          print('reset-password route args: $args');
          if (args == null || !args.containsKey('email') || !args.containsKey('token')) {
            return Scaffold(body: Center(child: Text('Missing arguments for reset password.')));
          }
          return ResetPasswordScreen(
            email: args['email'] ?? '',
            token: args['token'] ?? '',
          );
        },
      },
    );
  }
}