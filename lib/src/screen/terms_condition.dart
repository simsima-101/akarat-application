import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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

class TermsCondition extends StatefulWidget {
  const TermsCondition({super.key});

  @override
  State<TermsCondition> createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
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
          l10n.myAccountTermsAndConditionsAppBarTitle,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.red),
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
              l10n.myAccountTermsSectionIntroductionTitle,
              style:
                  const TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 11),
            Text(
              l10n.myAccountTermsSectionIntroductionContent,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 30),

            // 1. Who We Are
            Text(
              l10n.myAccountTermsSectionWhoWeAreTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsWhoWeAreCompany,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsWhoWeAreOffice,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsWhoWeArePronouns,
              style: const TextStyle(fontSize: 15.5, letterSpacing: 0.3),
            ),
            const SizedBox(height: 30),

            // 2. Definitions
            Text(
              l10n.myAccountTermsSectionDefinitionsTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),

            _buildDefinitionRow(
              l10n.myAccountTermsDefinitionAdvertiser.split(':')[0].trim() +
                  ':',
              l10n.myAccountTermsDefinitionAdvertiser.split(':')[1].trim(),
            ),
            _buildDefinitionRow(
              l10n.myAccountTermsDefinitionAgent.split(':')[0].trim() + ':',
              l10n.myAccountTermsDefinitionAgent.split(':')[1].trim(),
            ),
            _buildDefinitionRow(
              l10n.myAccountTermsDefinitionContent.split(':')[0].trim() + ':',
              l10n.myAccountTermsDefinitionContent.split(':')[1].trim(),
            ),
            _buildDefinitionRow(
              l10n.myAccountTermsDefinitionListing.split(':')[0].trim() + ':',
              l10n.myAccountTermsDefinitionListing.split(':')[1].trim(),
            ),
            _buildDefinitionRow(
              l10n.myAccountTermsDefinitionUser.split(':')[0].trim() + ':',
              l10n.myAccountTermsDefinitionUser.split(':')[1].trim(),
            ),
            _buildDefinitionRow(
              l10n.myAccountTermsDefinitionServices.split(':')[0].trim() + ':',
              l10n.myAccountTermsDefinitionServices.split(':')[1].trim(),
            ),

            const SizedBox(height: 30),

            // 3. Acceptance of Terms
            Text(
              l10n.myAccountTermsSectionAcceptanceTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsAcceptanceMain,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsAcceptanceNotAllowed,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsAcceptanceConditions,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsAcceptanceUpdates,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 4. Scope of Use
            Text(
              l10n.myAccountTermsSectionScopeTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsScopeIntro,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsScopeProhibited,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 14),
            Text(
              l10n.myAccountTermsScopeConsequence,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 5. Account Registration
            Text(
              l10n.myAccountTermsSectionRegistrationTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsRegistrationIntro,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsRegistrationDuties,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsRegistrationNoLiability,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 6. Advertiser & Agent Obligations
            Text(
              l10n.myAccountTermsSectionAdvertiserAgentTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsAdvertiserAgentCompliance,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsListingMust,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountTermsListingRequirements,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsAkaratRights,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountTermsAkaratRightsList,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsAgentLicense,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 7. User-Generated Content
            Text(
              l10n.myAccountTermsSectionUGCTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsUGCLicense,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsUGCAffirm,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountTermsUGCAffirmList,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 8. Intellectual Property
            Text(
              l10n.myAccountTermsSectionIPTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsIPOwnership,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsIPProhibited,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountTermsIPProhibitedList,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsIPConsequence,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 9. Disclaimer & Limitation of Liability
            Text(
              l10n.myAccountTermsSectionDisclaimerTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsDisclaimerBasis,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsNoLiabilityFor,
              style: const TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.myAccountTermsNoLiabilityList,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsUseAtOwnRisk,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 10. Suspension or Termination
            Text(
              l10n.myAccountTermsSectionSuspensionTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsSuspensionRight,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsSuspensionReasons,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsSuspensionEffect,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 11. Data Protection & Privacy
            Text(
              l10n.myAccountTermsSectionPrivacyTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsPrivacyProcessed,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.myAccountTermsPrivacyPractices,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsPrivacyConsent,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 12. Third-Party Links
            Text(
              l10n.myAccountTermsSectionThirdPartyTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsThirdPartyContent,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 13. Governing Law & Jurisdiction
            Text(
              l10n.myAccountTermsSectionGoverningLawTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsGoverningLawContent,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 14. Language
            Text(
              l10n.myAccountTermsSectionLanguageTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsLanguageContent,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 15. Updates to These Terms
            Text(
              l10n.myAccountTermsSectionUpdatesTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.myAccountTermsUpdatesIntro,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 0),
            Text(
              l10n.myAccountTermsUpdatesReasons,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 0),
            Text(
              l10n.myAccountTermsUpdatesEffect,
              style: const TextStyle(
                  fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 16. Contact Us
            Text(
              l10n.myAccountTermsSectionContactTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SelectionArea(
              child: Text(
                l10n.myAccountTermsContactContent,
                style: const TextStyle(
                    fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
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
            icon: const Icon(Icons.favorite_border_outlined,
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
              icon: const Icon(Icons.dehaze_outlined,
                  color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinitionRow(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFF5F5F5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const Gap(8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
