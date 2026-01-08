import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/utils/secure_storage.dart';
import '../providers/main_bottom_nav_bar_provider.dart';
import 'ContactFormScreen.dart';
import 'login.dart';

class MainBottomNavBarScreen extends StatefulWidget {
  final ScreenEnum currentScreen;

  const MainBottomNavBarScreen(
      {super.key, this.currentScreen = ScreenEnum.homeScreen});

  @override
  State<MainBottomNavBarScreen> createState() => _MainBottomNavBarScreenState();
}

class _MainBottomNavBarScreenState extends State<MainBottomNavBarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<MainBottomNavBarProvider>()
          .setSelectedItemIndex(widget.currentScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MainBottomNavBarProvider>(
        builder: (context, mainBottomNavBarProvider, child) {
      final selectedIndex = mainBottomNavBarProvider.selectedBarItemIndex;
      final pageList = mainBottomNavBarProvider.pages;

      final page = (selectedIndex < pageList.length)
          ? pageList[selectedIndex]
          : pageList.first;

      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: page),
        resizeToAvoidBottomInset: false,
        extendBody: false,
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 50,
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // ✅ distributes space correctly
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    mainBottomNavBarProvider
                        .setSelectedItemIndex(ScreenEnum.homeScreen);
                    // Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Image.asset("assets/images/home.png", height: 26),
                  ),
                ),
                IconButton(
                  enableFeedback: false,
                  onPressed: () async {
                    final token = await SecureStorage.getToken();

                    if (token == null || token.isEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white, // white container
                          title: const Text("Login Required",
                              style: TextStyle(color: Colors.black)),
                          content: const Text(
                              "Please login to access favorites.",
                              style: TextStyle(color: Colors.black)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red), // red text
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const LoginDemo()),
                                );
                              },
                              child: const Text(
                                "Login",
                                style: TextStyle(color: Colors.red), // red text
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      mainBottomNavBarProvider
                          .setSelectedItemIndex(ScreenEnum.favoriteScreen);

                      // ✅ Logged in – go to favorites
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (_) => const Fav_Logout()),
                      // ).then((_) async {
                      // 🔁 Re-sync when coming back
                      // final updatedFavorites =
                      //     await FavoriteService.fetchApiFavorites(token);
                      // setState(() {
                      //   FavoriteService.loggedInFavorites = updatedFavorites;
                      // });
                      // });
                    }
                  },
                  icon: selectedIndex == 1
                      ? const Icon(Icons.favorite, color: Colors.red, size: 31)
                      : const Icon(Icons.favorite_border_outlined,
                          color: Colors.red, size: 31),
                ),
                IconButton(
                  tooltip: "Email",
                  icon: const Icon(Icons.email_outlined,
                      color: Colors.red, size: 30),
                  onPressed: () => showHomeContactDialog(context),
                ),
                IconButton(
                  enableFeedback: false,
                  onPressed: () {
                    mainBottomNavBarProvider
                        .setSelectedItemIndex(ScreenEnum.myAccountScreen);

                    // setState(() {
                    //   if (token == '') {
                    //                     Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                    // } else {
                    //   Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                    // }
                    // });
                  },
                  icon:
                      // selectedIndex == 3
                      //     ? const Icon(Icons.dehaze, color: Colors.red, size: 32)
                      //     :
                      const Icon(Icons.dehaze, color: Colors.red, size: 32),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
