import 'package:Akarat/screen/findagent.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';
import 'my_account.dart';
import '../utils/fav_logout.dart';
import '../secure_storage.dart';
import '../services/favorite_service.dart';
import 'login.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static List<GlobalKey<NavigatorState>> navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  static Function(int)? changeTab;

  /// Push a page inside a tab
  static void pushInTab(int tabIndex, Widget page) {
    navigatorKeys[tabIndex].currentState?.push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// Switch to home and push a new page
  static void switchToHomeAndPush(Widget page) {
    final state = navigatorKeys[0].currentState;
    if (state != null) {
      state.popUntil((route) => route.isFirst);
      state.push(MaterialPageRoute(builder: (_) => page));
    }
    changeTab?.call(0);
  }

  /// Always go to the home tab and reset its stack
  static void goToHome() {
    changeTab?.call(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKeys[0].currentState?.popUntil((route) => route.isFirst);
    });
  }

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    MainScreen.changeTab = (index) {
      setState(() => pageIndex = index);
    };
  }

  void goToHomeAndReset() {
    if (pageIndex != 0) {
      // If not already on Home, switch to it first
      setState(() => pageIndex = 0);
    }

    // Ensure the frame rebuilds before popping
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = MainScreen.navigatorKeys[0].currentState;
      navState?.popUntil((route) => route.isFirst);
    });
  }



  List<Widget> _buildTabNavigators() {
    return [
      Navigator(
        key: MainScreen.navigatorKeys[0],
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const Home()),
      ),
      Navigator(
        key: MainScreen.navigatorKeys[1],
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const Fav_Logout()),
      ),
      Navigator(
        key: MainScreen.navigatorKeys[2],
        onGenerateRoute: (_) => MaterialPageRoute(builder: (_) => const My_Account()),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
        !await MainScreen.navigatorKeys[pageIndex].currentState!.maybePop();
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: IndexedStack(
          index: pageIndex,
          children: _buildTabNavigators(),
        ),
        bottomNavigationBar: buildMyNavBar(context),
      ),
    );
  }

  Widget buildMyNavBar(BuildContext context) {
    return Container(
      height: 75,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// HOME ICON
            GestureDetector(
              onTap: goToHomeAndReset,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Image.asset("assets/images/home.png", height: 25),
              ),
            ),





            /// FAVORITES ICON
            IconButton(
              enableFeedback: false,
              onPressed: () async {
                final token = await SecureStorage.getToken();
                if (token == null || token.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text("Login Required",
                          style: TextStyle(color: Colors.black)),
                      content: const Text(
                          "Please login to access favorites.",
                          style: TextStyle(color: Colors.black)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel",
                              style: TextStyle(color: Colors.red)),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const LoginDemo()));
                          },
                          child: const Text("Login",
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                } else {
                  setState(() => pageIndex = 1);
                  final favNav = MainScreen.navigatorKeys[1].currentState;
                  favNav?.popUntil((route) => route.isFirst);
                }
              },
              icon: pageIndex == 1
                  ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                  : const Icon(Icons.favorite_border_outlined,
                  color: Colors.red, size: 30),
            ),

            /// EMAIL ICON
            IconButton(
              tooltip: "Email",
              icon: const Icon(Icons.email_outlined,
                  color: Colors.red, size: 28),
              onPressed: () async {
                final Uri emailUri = Uri.parse(
                    'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.');
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: const Text('Email not available',
                          style: TextStyle(color: Colors.black)),
                      content: const Text(
                          'No email app is configured on this device. Please add a mail account first.',
                          style: TextStyle(color: Colors.black)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            /// ACCOUNT ICON
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: IconButton(
                enableFeedback: false,
                onPressed: () {
                  if (pageIndex != 2) {
                    setState(() => pageIndex = 2);
                  } else {
                    final navState = MainScreen.navigatorKeys[2].currentState;
                    navState?.popUntil((route) => route.isFirst);
                  }
                },
                icon: pageIndex == 2
                    ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                    : const Icon(Icons.dehaze_outlined,
                    color: Colors.red, size: 35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
