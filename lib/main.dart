// Core utilities
import 'package:Akarat/src/core/constants/constants.dart' as ApiService;
import 'package:Akarat/src/core/localization/language_controller.dart';
import 'package:Akarat/src/core/utils/session_manager.dart';

// Blocs
import 'package:Akarat/src/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:Akarat/src/features/filter/presentation/bloc/filter_bloc.dart';
import 'package:Akarat/src/features/filter/repo/filter_repo.dart';
import 'package:Akarat/src/features/property/data/repositories/property_repository.dart';
import 'package:Akarat/src/features/property/presentation/bloc/enquiry_bloc.dart';
import 'package:Akarat/src/features/property/presentation/bloc/favorite_bloc.dart';
import 'package:Akarat/src/features/property/presentation/bloc/favorite_event.dart';

import 'package:Akarat/src/features/property/presentation/bloc/properties_bloc.dart';

// Providers
import 'package:Akarat/src/providers/favorite_provider.dart';
import 'package:Akarat/src/providers/filter_provider.dart';
import 'package:Akarat/src/providers/location_picker_provider.dart';
import 'package:Akarat/src/providers/search_amenities_provider.dart';

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

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("📬 Background message: ${message.notification?.title ?? 'No title'}");
}

// Bloc observer
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  await _initializeRemoteConfig();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final session = SessionManager();
  await session.restore();
  await session.refreshProfileFromServer().catchError((e) {
    debugPrint('Session refresh failed: $e');
  });

  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }
}

Future<void> _initializeRemoteConfig() async {
  final rc = FirebaseRemoteConfig.instance;

  try {
    await rc.setDefaults(const {
      'api_base_url': 'https://api.fallback.example.com',
    });

    await rc.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 12),
      ),
    );

    await rc.fetchAndActivate();
    debugPrint('API Base: ${ApiService.baseUrl}');
  } catch (e) {
    debugPrint('Remote Config failed: $e');
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Tiny helper widget to run initial language sync AFTER providers are available
class _InitialLanguageSync extends StatefulWidget {
  const _InitialLanguageSync();

  @override
  State<_InitialLanguageSync> createState() => __InitialLanguageSyncState();
}

class __InitialLanguageSyncState extends State<_InitialLanguageSync> {
  @override
  void initState() {
    super.initState();
    // Wait until first frame → providers & context are ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LanguageController.instance.refreshFromDeviceIfNeeded();
      debugPrint('Initial language sync completed (post-frame)');
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ──────────────────────────────────────────────────────────────────────────────
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _localNotifications = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotifications();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    super.didChangeLocales(locales);
    if (locales == null || locales.isEmpty) return;

    LanguageController.instance.refreshFromDeviceIfNeeded();
    debugPrint('System locales changed → refreshed language');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      LanguageController.instance.refreshFromDeviceIfNeeded();
      debugPrint('App resumed → checked device language');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────────────────────
  Future<void> _setupNotifications() async {
    await FirebaseMessaging.instance.requestPermission(alert: true, sound: true);

    FirebaseMessaging.onMessage.listen(_showLocalNotification);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotifications.initialize(initSettings);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    if (notif == null) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'alerts',
        'Alerts',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      notif.title,
      notif.body,
      details,
    );
  }

  // ──────────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => AmenitiesProvider()),
        ChangeNotifierProvider(create: (_) => LocationPickerProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(
          create: (_) => LanguageController.instance,
        ),
      ],
      child: Builder(
        builder: (context) {
          final lang = context.watch<LanguageController>();

          return MultiRepositoryProvider(
            providers: [
              RepositoryProvider(create: (_) => PropertyRepository()),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => AuthBloc()..add(AppStarted())),
                BlocProvider(create: (_) => FavoriteBloc()..add(const LoadFavorites())),
                BlocProvider(
                  create: (context) => FilterBloc(
                    context.read<FilterRepository>(),   // ← pass it here
                  ),
                ),
                BlocProvider(create: (_) => EnquiryBloc()),
                BlocProvider(
                  create: (context) => PropertiesBloc(
                    repository: context.read<PropertyRepository>(),
                  )..add(const LoadProperties(endpoint: 'properties')),
                ),
              ],
              child: BlocListener<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthUnauthenticated) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                          (_) => false,
                    );
                  }
                },
                child: MaterialApp(
                  title: 'Akarat',
                  debugShowCheckedModeBanner: false,
                  navigatorKey: navigatorKey,
                  scaffoldMessengerKey: scaffoldMessengerKey,

                  locale: lang.locale,

                  supportedLocales: const [
                    Locale('en'),
                    Locale('ar'),
                    Locale('tr'),
                  ],
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                    CountryLocalizations.delegate,
                  ],

                  builder: (context, child) {
                    return Directionality(
                      textDirection: lang.languageCode == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: Stack(
                        children: [
                          child!,
                          const _InitialLanguageSync(),
                        ],
                      ),
                    );
                  },

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
                    '/forgot-password': (_) => const ForgotPasswordScreen(),
                    '/new-projects': (_) => const NewProjectsScreen(),
                  },

                  onGenerateRoute: (settings) {
                    if (settings.name == '/verify-otp') {
                      return MaterialPageRoute(
                        builder: (_) => const OtpVerificationScreen(),
                      );
                    }

                    if (settings.name == '/reset-password') {
                      final args = settings.arguments as Map<String, dynamic>? ?? {};
                      return MaterialPageRoute(
                        builder: (_) => ResetPasswordScreen(
                          email: args['email'] ?? '',
                          token: args['token'] ?? '',
                        ),
                      );
                    }

                    return null;
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}