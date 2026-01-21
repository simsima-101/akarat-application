import 'package:flutter/material.dart';

import '../features/find_agent/presentation/pages/findagent.dart';
import '../screen/home.dart';
import '../screen/my_account.dart';
import '../screen/privacy.dart';
import '../screen/support.dart';
import '../screen/terms_condition.dart';
import '../utils/fav_logout.dart';

enum ScreenEnum {
  homeScreen,
  favoriteScreen,
  emailScreen,
  myAccountScreen,
  findAgentScreen,
  aboutAgencyScreen,
  aboutUsScreen,
  supportScreen,
  privacyPolicyScreen,
  termsAndConditionScreen,
  newProjectScreen,
  fliterListScreen
}

class MainBottomNavBarProvider extends ChangeNotifier {
  int selectedBarItemIndex = 0;

  List<Widget> pages = <Widget>[
    Home(),
    Fav_Logout(),
    SizedBox(),
    My_Account(),
    FindAgentDemo(),
    // About_Agency(),
    SizedBox(),
    // About_Us(),
    Support(),
    Privacy(),
    TermsCondition(),
    // New_Projects(),
  ];

// Get index from enum
  void setSelectedItemIndex(ScreenEnum value) {
    final index = ScreenEnum.values.indexOf(value);
    selectedBarItemIndex = index;
    notifyListeners();
  }

// Get enum from index
//   ScreenEnum getScreenEnumFromIndex(int index) {
//   return ScreenEnum.values[index];
//   }
}
