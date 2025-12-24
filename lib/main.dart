import 'package:Akarat/src/core/utils/session_manager.dart';
import 'package:Akarat/src/features/property/presentation/bloc/favorite_bloc.dart';
import 'package:Akarat/src/features/property/presentation/bloc/favorite_event.dart';
import 'package:Akarat/src/features/property/presentation/bloc/filter_bloc.dart'; // ← NEW: FilterBloc
import 'package:Akarat/src/features/property/presentation/bloc/properties_bloc.dart'; // ← Optional: if you have it
import 'package:Akarat/src/features/property/presentation/bloc/new_projects_bloc.dart'; // ← Optional: if you have it

import 'package:Akarat/src/screen/forgot_password.dart';
import 'package:Akarat/src/screen/home.dart';
import 'package:Akarat/src/screen/login.dart';
import 'package:Akarat/src/screen/my_account.dart';
import 'package:Akarat/src/screen/new_projects.dart';
import 'package:Akarat/src/screen/otp_verification.dart';
import 'package:Akarat/src/screen/register_screen.dart';
import 'package:Akarat/src/screen/reset_password.dart';
import 'package:Akarat/src/screen/splash_screen.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';

// Auth Bloc
import 'src/features/auth/presentation/bloc/auth_bloc.dart';

String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'https://akarat.com/api';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

// Bloc Observer for debugging
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('Bloc Change: ${bloc.runtimeType} $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('Bloc Error: ${bloc.runtimeType} $error');
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  await SessionManager().restore();
  await SessionManager().refreshProfileFromServer();

  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Auth Bloc
        BlocProvider(
          create: (context) => AuthBloc()..add(AppStarted()),
        ),

        // Favorite Bloc
        BlocProvider(
          create: (context) => FavoriteBloc()..add(LoadFavorites()),
        ),

        // Filter Bloc — NEWLY ADDED
        BlocProvider(
          create: (context) => FilterBloc(),
        ),

        // Optional: Add other Blocs here when ready
        // BlocProvider(create: (context) => PropertiesBloc()),
        // BlocProvider(create: (context) => NewProjectsBloc()),
      ],
      child: MaterialApp(
        title: 'Akarat',
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        scaffoldMessengerKey: scaffoldMessengerKey,
        localizationsDelegates: const [
          CountryLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
        ],
        locale: const Locale('en'),
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFFE01E26),
          fontFamily: 'Tajawal',
          scaffoldBackgroundColor: Colors.white,
        ),
        home: const SplashScreen(),
        routes: {
          '/login': (_) => const Login(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const Home(),
          '/my-account': (_) => const My_Account(),
          '/my_accounts': (_) => const My_Account(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/new-projects': (_) => const NewProjectsScreen(),
        },
        onGenerateRoute: (settings) {
          // OTP Verification Route
          if (settings.name == '/verify-otp') {
            final Map<String, dynamic> args = settings.arguments is Map
                ? Map<String, dynamic>.from(settings.arguments as Map)
                : <String, dynamic>{};

            return MaterialPageRoute(
              builder: (_) => const OtpVerificationScreen(),
              settings: RouteSettings(
                name: settings.name,
                arguments: args,
              ),
            );
          }

          // Reset Password Route
          if (settings.name == '/reset-password') {
            final Map<String, dynamic>? routeArgs =
            settings.arguments as Map<String, dynamic>?;

            final args = routeArgs ?? {};
            final email = args['email']?.toString().trim() ?? '';
            final token = args['token']?.toString().trim() ?? '';

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
      ),
    );
  }
}