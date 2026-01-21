// Core utilities
import 'package:Akarat/src/core/constants/constants.dart' as ApiService;
import 'package:Akarat/src/core/utils/session_manager.dart';
// Blocs
import 'package:Akarat/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:Akarat/src/features/filter/presentation/bloc/filter_bloc.dart';
import 'package:Akarat/src/features/filter/repo/filter_repo.dart';
import 'package:Akarat/src/features/property/data/repositories/property_repository.dart';
import 'package:Akarat/src/features/property/presentation/bloc/enquiry_bloc.dart';
import 'package:Akarat/src/features/property/presentation/bloc/favorite_bloc.dart';
import 'package:Akarat/src/features/property/presentation/bloc/favorite_event.dart';
// Providers
import 'package:Akarat/src/features/property/presentation/bloc/properties_bloc.dart';
// Providers
import 'package:Akarat/src/providers/favorite_provider.dart';
import 'package:Akarat/src/providers/location_picker_provider.dart';
// Screens

// Screens
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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// Localization
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'l10n/app_localizations.dart';

// ──────────────────────────────────────────────────────────────────────────────
// Global keys
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Background message handler (must be top-level)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint(
      "📬 Background message: ${message.notification?.title ?? 'No title'}");
}

// Simple Bloc observer for development
class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    if (kDebugMode) debugPrint('🔄 ${bloc.runtimeType} → $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stack) {
    debugPrint('❌ ${bloc.runtimeType} error: $error');
    super.onError(bloc, error, stack);
  }
}

// ──────────────────────────────────────────────────────────────────────────────
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeAppServices();

  runApp(const MyApp());
}

Future<void> _initializeAppServices() async {
  // 1. Firebase Core
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Environment variables
  await dotenv.load(fileName: ".env");

  // 3. Remote Config – IMPORTANT: defaults FIRST!
  await _initializeRemoteConfig();

  // 4. Background messaging
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // 5. Session & profile restoration
  final session = SessionManager();
  await session.restore();
  await session.refreshProfileFromServer().catchError((e) {
    debugPrint('Session refresh failed on startup: $e');
  });

  // 6. Better bloc logging in debug
  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }
}

Future<void> _initializeRemoteConfig() async {
  final rc = FirebaseRemoteConfig.instance;

  try {
    // 1. Set defaults FIRST – this prevents the Null → int crash
    await rc.setDefaults(const {
      'api_base_url': 'https://api.fallback.example.com',
      'app_environment': 'production',
      'maintenance_mode': false,
      'force_update': false,
      'min_app_version': '1.0.0',
      'show_new_feature': false,
      // Add all keys your app might read with correct Dart types
    });

    // 2. Then configure settings
    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval:
            kDebugMode ? Duration.zero : const Duration(hours: 12),
      ),
    );

    // 3. Try to fetch fresh values
    final fetched = await rc.fetchAndActivate();
    debugPrint('Remote Config → fetched & activated: $fetched');

    // Useful debug info
    debugPrint('API Base (Remote Config): ${rc.getString('api_base_url')}');
    debugPrint('Effective API Base: ${ApiService.baseUrl}');

    debugPrint('Remote Config → fetched & activated: $fetched');
    debugPrint('API Base (Remote Config): ${rc.getString('api_base_url')}');
    debugPrint('Effective API Base: ${ApiService.baseUrl}');
  } catch (e) {
    debugPrint('Remote Config init failed (will use defaults/cache): $e');
    // Application should continue safely with cached/default values
  }
}

// ──────────────────────────────────────────────────────────────────────────────
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  Future<void> _setupNotifications() async {
    // Request permissions
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        '🔔 Notification permission: ${settings.authorizationStatus.name}');

    // Token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('🔄 FCM Token refreshed');
      // TODO: Send new token to backend
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('📩 Foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('🔔 Opened from background');
      _handleNotificationData(message.data);
    });

    // Launched from terminated
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null) {
      debugPrint('🔔 Launched from terminated via notification');
      _handleNotificationData(initial.data);
    }

    // Initialize local notifications
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null) {
          _handleLocalNotificationPayload(payload);
        }
      },
    );
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    final payload = data['payload']?.toString() ?? 'open_alerts';
    final alertId = data['alert_id']?.toString();

    if (payload == 'open_alerts' || alertId != null) {
      navigatorKey.currentState?.pushNamed(
        '/saved-alerts',
        arguments: {'alert_id': alertId, 'from_notification': true},
      );
    }
  }

  void _handleLocalNotificationPayload(String payload) {
    if (payload.startsWith('alert:')) {
      final alertId = payload.split(':')[1];
      navigatorKey.currentState?.pushNamed(
        '/saved-alerts',
        arguments: {'alert_id': alertId},
      );
    } else if (payload == 'open_alerts') {
      navigatorKey.currentState?.pushNamed('/saved-alerts');
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    String title = notif?.title ?? 'New Property Alert';
    String body = notif?.body ?? 'New properties matching your criteria';

    final data = message.data;
    if (data['custom_title'] != null) title = data['custom_title'];
    if (data['custom_body'] != null) body = data['custom_body'];

    final alertId = data['alert_id']?.toString();
    final id = DateTime.now().millisecondsSinceEpoch % 100000;

    const androidDetails = AndroidNotificationDetails(
      'property_alerts_channel',
      'Property Alerts',
      channelDescription: 'Notifications for saved property searches',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      color: Color(0xFFE01E26),
      icon: '@drawable/ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: alertId != null ? 'alert:$alertId' : 'open_alerts',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => LocationPickerProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
      ],
      child: MultiRepositoryProvider(
        providers: [
          // ─── NEW: Provide the repository once ────────────────────────
          RepositoryProvider<PropertyRepository>(
            create: (context) => PropertyRepository(),
          ),
          // ──────────────────────────────────────────────────────────────
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => AuthBloc()..add(AppStarted())),
            BlocProvider(
                create: (_) => FavoriteBloc()..add(const LoadFavorites())),
            BlocProvider(create: (_) => FilterBloc(FilterRepository())),
            BlocProvider(create: (_) => EnquiryBloc()),
            BlocProvider<PropertiesBloc>(
              create: (context) => PropertiesBloc(
                repository: context.read<PropertyRepository>(),
              )..add(const LoadProperties(endpoint: 'properties')), // auto-load
            ),
          ],
          child: MaterialApp(
            title: 'Akarat',
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            scaffoldMessengerKey: scaffoldMessengerKey,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              CountryLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
              Locale('tr'),
            ],
            localeResolutionCallback: (locale, supported) {
              if (locale == null) return const Locale('en');
              for (final loc in supported) {
                if (loc.languageCode == locale.languageCode) return locale;
              }
              return const Locale('en');
            },
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
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              '/new-projects': (_) => const NewProjectsScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == '/verify-otp') {
                return MaterialPageRoute(
                  builder: (_) => const OtpVerificationScreen(),
                  settings: settings,
                );
              }

              if (settings.name == '/reset-password') {
                final args = settings.arguments as Map<String, dynamic>? ?? {};
                final email = (args['email'] as String?)?.trim() ?? '';
                final token = (args['token'] as String?)?.trim() ?? '';

                if (email.isEmpty || token.isEmpty) {
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Invalid reset link')),
                    ),
                  );
                }

                return MaterialPageRoute(
                  builder: (_) =>
                      ResetPasswordScreen(email: email, token: token),
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
        ),
      ),
    );
  }
}
