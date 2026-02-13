import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../general/services/home_app_logo_manager_service.dart';
import '../../l10n/app_localizations.dart';
import '../core/utils/secure_storage.dart';
import '../features/localization/presentation/bloc/localization_cubit.dart';
import '../features/localization/presentation/bloc/localization_state.dart';
import '../features/property/data/datasources/favorite_remote_datasource.dart';
import '../utils/fav_logout.dart';
import 'ContactFormScreen.dart';
import 'home.dart';
import 'login.dart';
import 'my_account.dart';

class Privacy extends StatefulWidget {
  const Privacy({super.key});

  @override
  State<Privacy> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  int pageIndex = 0;

  final ScrollController _scrollController = ScrollController();

  // GlobalKeys for each section
  final aboutKey = GlobalKey();
  final typesKey = GlobalKey();
  final legalKey = GlobalKey();
  final shareKey = GlobalKey();
  final securityKey = GlobalKey();
  final rightsKey = GlobalKey();
  final marketingKey = GlobalKey();
  final minorsKey = GlobalKey();
  final thirdPartyKey = GlobalKey();
  final updatesKey = GlobalKey();

  void scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: buildMyNavBar(context),
      ),
      appBar: AppBar(
        title: Text(
          l10n.myAccountPrivacyAppBarTitle,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.red),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.all(3.0),
                  //   child: Image.asset(
                  //     "assets/images/app_icon.png",
                  //     height: 22,
                  //     alignment: Alignment.center,
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(3.0),
                  //   child: Image.asset(
                  //     "assets/images/logo-text.png",
                  //     height: 22,
                  //     alignment: Alignment.center,
                  //   ),
                  // ),

                  BlocBuilder<LocalizationCubit, LocalizationState>(
                    builder: (context, localizationState) {
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 30,
                        child: Image.asset(
                          HomeAppLogoManagerService.getHomeAppLogoBasedLocale(
                            localizationState.locale,
                          ),
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.myAccountPrivacyIntroductionTitle,
              style: const TextStyle(
                fontSize: 18,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 6),
            Text(
              l10n.myAccountPrivacyIntroductionContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 13),
            Text(
              l10n.myAccountPrivacySectionsIntro,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLink(l10n.myAccountPrivacySectionLinkAbout, aboutKey),
                _buildLink(l10n.myAccountPrivacySectionLinkTypes, typesKey),
                _buildLink(l10n.myAccountPrivacySectionLinkLegal, legalKey),
                _buildLink(l10n.myAccountPrivacySectionLinkShare, shareKey),
                _buildLink(
                    l10n.myAccountPrivacySectionLinkSecurity, securityKey),
                _buildLink(l10n.myAccountPrivacySectionLinkRights, rightsKey),
                _buildLink(
                    l10n.myAccountPrivacySectionLinkMarketing, marketingKey),
                _buildLink(l10n.myAccountPrivacySectionLinkMinors, minorsKey),
                _buildLink(
                    l10n.myAccountPrivacySectionLinkThirdParty, thirdPartyKey),
                _buildLink(l10n.myAccountPrivacySectionLinkUpdates, updatesKey),
              ],
            ),
            Text(
              "\n${l10n.myAccountPrivacyFooterNote}",
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 25),
            _buildTitle(aboutKey, l10n.myAccountPrivacySectionWhoWeAreTitle),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyWhoWeAreSubtitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountPrivacyWhoWeAreContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 26),
            Text(
              l10n.myAccountPrivacyContactSubtitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountPrivacyContactContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 14),
            _buildTitle(typesKey, l10n.myAccountPrivacySectionTypesTitle),
            const SizedBox(height: 6),
            Text(
              l10n.myAccountPrivacyTypesIntro,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.myAccountPrivacyPersonalDataDefinition,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.myAccountPrivacyTypesCollectedIntro,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 13),
            Text(
              l10n.myAccountPrivacyTypesList,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 18),
            Text(
              l10n.myAccountPrivacyUserInfoTitle,
              style: const TextStyle(
                fontSize: 16,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyUserInfoPurpose,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.myAccountPrivacyUserInfoCollectedTitle,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountPrivacyUserInfoCollectedList,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 23),
            Text(
              l10n.myAccountPrivacyAgencyInfoTitle,
              style: const TextStyle(
                fontSize: 17,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyAgencyInfoList,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.myAccountPrivacyAgencyPurpose,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.myAccountPrivacyAgencyPublicDisplayTitle,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountPrivacyAgencyPublicDisplayList,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.myAccountPrivacyAgentInfoTitle,
              style: const TextStyle(
                fontSize: 17,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyAgentInfoList,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 15),
            Text(
              l10n.myAccountPrivacyAgentPurpose,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.myAccountPrivacyPropertyInfoTitle,
              style: const TextStyle(
                fontSize: 17,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyPropertyPurpose,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyPropertyCollectedTitle,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.myAccountPrivacyPropertyCollectedList,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 17),
            Text(
              l10n.myAccountPrivacyTrakheesiNote,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 25),
            Text(
              l10n.myAccountPrivacyChatDataTitle,
              style: const TextStyle(
                fontSize: 17,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyChatDataContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 25),
            Text(
              l10n.myAccountPrivacyTechnicalDataTitle,
              style: const TextStyle(
                fontSize: 17,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyTechnicalDataList,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyTechnicalPurpose,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 25),
            Text(
              l10n.myAccountPrivacyMarketingDataTitle,
              style: const TextStyle(
                fontSize: 17,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyMarketingContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 25),
            Text(
              l10n.myAccountPrivacyRefusalTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyRefusalContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            _buildTitle(legalKey, l10n.myAccountPrivacySectionLegalTitle),
            Text(
              l10n.myAccountPrivacyLegalIntro,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyLegalBases,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            _buildTitle(shareKey, l10n.myAccountPrivacySectionShareTitle),
            Text(
              l10n.myAccountPrivacyShareContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            _buildTitle(securityKey, l10n.myAccountPrivacySectionSecurityTitle),
            Text(
              l10n.myAccountPrivacySecurityContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            _buildTitle(rightsKey, l10n.myAccountPrivacySectionRightsTitle),
            Text(
              l10n.myAccountPrivacyRightsIntro,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountPrivacyRightsList,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            _buildTitle(
                marketingKey, l10n.myAccountPrivacySectionMarketingTitle),
            Text(
              l10n.myAccountPrivacyMarketingContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            _buildTitle(minorsKey, l10n.myAccountPrivacySectionMinorsTitle),
            Text(
              l10n.myAccountPrivacyMinorsContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            _buildTitle(
                thirdPartyKey, l10n.myAccountPrivacySectionThirdPartyTitle),
            Text(
              l10n.myAccountPrivacyThirdPartyContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 10),
            _buildTitle(updatesKey, l10n.myAccountPrivacySectionUpdatesTitle),
            Text(
              l10n.myAccountPrivacyUpdatesContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLink(String title, GlobalKey key) {
    return GestureDetector(
      onTap: () => scrollToSection(key),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "• ",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 21,
                  height: 0.9,
                ),
              ),
              TextSpan(
                text: title,
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 15.5,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(GlobalKey key, String heading) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(top: 15, bottom: 10),
      child: Text(
        heading,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 50,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
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
                    backgroundColor: Colors.white,
                    title: const Text("Login Required",
                        style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.",
                        style: TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginDemo(),
                            ),
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Fav_Logout()),
                ).then((_) async {
                  final updatedFavorites =
                      await FavoriteService.fetchApiFavorites(token);
                  setState(() {
                    FavoriteService.loggedInFavorites = updatedFavorites;
                  });
                });
              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined,
                    color: Colors.red, size: 30),
          ),
          IconButton(
            tooltip: "Email",
            icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
            onPressed: () => showHomeContactDialog(context),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const My_Account()),
                );
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined,
                      color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}
