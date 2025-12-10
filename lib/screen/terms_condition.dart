import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../secure_storage.dart';
import '../services/favorite_service.dart';
import '../utils/fav_logout.dart';
import 'ContactFormScreen.dart';
import 'home.dart';
import 'login.dart';
import 'my_account.dart';
import 'register_screen.dart';

class TermsCondition extends StatefulWidget {
  const TermsCondition({super.key});

  @override
  State<TermsCondition> createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: buildMyNavBar(context),
      ),
      appBar: AppBar(
        title: const Text(
          "Terms & Conditions",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                  Image.asset("assets/images/app_icon.png", height: 26),
                  const SizedBox(width: 8),
                  Image.asset("assets/images/logo-text.png", height: 26),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Introduction",
              style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 11),

            // Introduction
            const Text(
              "Welcome to Akarat (the “Platform”). These Terms & Conditions (“Terms”) serve as a legally binding agreement between Akarat and any individual or entity who accesses, uses, or interacts with our website, mobile application, digital solutions, or any related tools and functionalities (collectively, the “Services”). These Terms apply to all categories of users, including visitors, registered members, advertisers, licensed agents, developers, and any other parties accessing or utilizing the Platform.\n\n"
              "By using or accessing any component of the Platform, you acknowledge that you have read, understood, and agreed to comply with these Terms, together with our Privacy Policy. If you disagree with any provision contained herein, you must immediately discontinue use of the Platform and all associated Services.",
              style: TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 30),

            // 1. Who We Are
            const Text(
              "1. Who We Are",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "The Platform is owned and operated by EMLAK BULUCU PORTAL LLC, a legally registered entity in the United Arab Emirates (UAE).",
              style: TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Registered Office: Westburry Office Tower, Floor 23, Office No. 2303, Business Bay, Dubai, UAE\n"
              "Email: info@akarat.com",
              style: TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "References to “we,” “us,” or “our” refer to Akarat as the Platform operator.",
              style: TextStyle(
                fontSize: 15.5,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 30),

            // 2. Definitions
            const Text(
              "2. Definitions",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),

            // Table-like layout using Rows
            _buildDefinitionRow("Advertiser:",
                "Any individual, business, or organization that posts property listings on the Platform to promote, market, or sell properties."),
            _buildDefinitionRow("Agent:",
                "A licensed real estate professional, broker, or agency authorized to list or market properties."),
            _buildDefinitionRow("Content:",
                "All materials uploaded or submitted to the Platform, including text, images, videos, documents, graphics, and other media."),
            _buildDefinitionRow("Listing:",
                "Any property advertisement, promotional entry, or post published on the Platform, including all related details and media."),
            _buildDefinitionRow("User / You:",
                "Any person, company, or entity who accesses, navigates, or interacts with the Platform or its Services."),
            _buildDefinitionRow("Services:",
                "The complete range of features, tools, functionalities, and solutions offered by Akarat through the Platform."),

            const SizedBox(height: 30),

            // 3. Acceptance of Terms
            const Text(
              "3. Acceptance of Terms",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "By accessing or using the Platform, you expressly acknowledge that you have read, understood, and agreed to be bound by these Terms. Your use of the Platform signifies your acceptance of all obligations outlined herein.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "You may not use the Platform if any of the following apply:",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            const Text(
              "• You are under the age of 18 years.\n"
              "• Your jurisdiction prohibits access to digital property marketplaces.\n"
              "• You do not meet the eligibility or legal requirements to list, advertise, or interact with property listings.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Akarat reserves the right to modify, amend, or update these Terms at any time without prior notice. Updates become effective immediately upon publication. Continued use of the Platform after such changes constitutes acceptance of the revised Terms.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 4. Scope of Use
            const Text(
              "4. Scope of Use",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Users must utilize the Platform professionally, ethically, and in accordance with all applicable laws. You are strictly prohibited from:",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            const Text(
              "• Uploading unlawful, misleading, fraudulent, or copyrighted material without permission.\n"
              "• Scraping, mining, copying, or extracting Platform data for commercial use.\n"
              "• Posting inaccurate, duplicate, or non-existent property listings.\n"
              "• Using automated tools, bots, or scripts to access or interact with the Platform.\n"
              "• Attempting to harm, disable, overburden, or interfere with Platform security or operations.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 14),
            const Text(
              "Misuse may result in immediate suspension, account termination, content removal, or legal action.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 5. Account Registration
            const Text(
              "5. Account Registration",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Certain Services require user registration. You must provide accurate, complete, and up-to-date information. Users are responsible for:",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            const Text(
              "• Protecting login credentials\n"
              "• Preventing unauthorized access\n"
              "• All activity performed under their account",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Akarat is not liable for losses resulting from negligence or unauthorized access.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),
            // 6. Advertiser & Agent Obligations
            const Text(
              "6. Advertiser & Agent Obligations",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Advertisers and Agents must comply with all relevant UAE real estate regulations, including licensing and advertising requirements set by authorities such as the DLD (Dubai Land Department).",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "All property listings must:",
              style: TextStyle(
                  fontSize: 15.5,
                  letterSpacing: 0.3,
                  height: 1.6,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Be accurate, truthful, and currently available.\n"
              "• Contain updated information, images, specifications, and pricing.\n"
              "• Be backed by valid authorization, ownership documents, or listing agreements.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Akarat reserves full rights to:",
              style: TextStyle(
                  fontSize: 15.5,
                  letterSpacing: 0.3,
                  height: 1.6,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Review and approve listings before publication.\n"
              "• Edit or remove content that violates guidelines.\n"
              "• Suspend accounts engaged in dishonest or unethical practices.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Agents must hold a valid DLD license or equivalent certification depending on the emirate.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 7. User-Generated Content
            const Text(
              "7. User-Generated Content",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "By uploading content, you grant Akarat a global, non-exclusive, royalty-free license to store, publish, reproduce, modify, or use the content for Platform-related purposes.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "You affirm that:",
              style: TextStyle(
                  fontSize: 15.5,
                  letterSpacing: 0.3,
                  height: 1.6,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              "• You own the content or possess legal usage rights.\n"
              "• Your content does not violate intellectual property laws.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 8. Intellectual Property
            const Text(
              "8. Intellectual Property",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "All intellectual property rights in the Platform, including but not limited to trademarks, service marks, logos, graphics, text, images, audiovisual material, software, design elements, and other content, are the exclusive property of Akarat or its licensors.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Users are strictly prohibited from:",
              style: TextStyle(
                  fontSize: 15.5,
                  letterSpacing: 0.3,
                  height: 1.6,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Copying, reproducing, or distributing any Platform content without prior written consent.\n"
              "• Modifying, creating derivative works, or commercially exploiting the Platform or its content.\n"
              "• Using intellectual property in any way that infringes on the rights of Akarat or third-party licensors.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Any unauthorized use of the Platform’s intellectual property may result in civil or criminal liability under the applicable laws of the United Arab Emirates.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),
            // 9. Disclaimer & Limitation of Liability
            const Text(
              "9. Disclaimer & Limitation of Liability",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "The Platform and its Services are provided on an “as-is” and “as-available” basis. Akarat makes no warranties, whether express or implied, regarding the availability, accuracy, completeness, reliability, or fitness for purpose of any content, listings, or Services offered through the Platform.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Users acknowledge and agree that Akarat is not liable for:",
              style: TextStyle(
                  fontSize: 15.5,
                  letterSpacing: 0.3,
                  height: 1.6,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Text(
              "• Errors, omissions, or outdated information in property listings or user-generated content.\n"
              "• Indirect, incidental, consequential, punitive, or special damages, including lost profits, lost opportunities, or business interruptions.\n"
              "• Misconduct, misrepresentation, negligence, or any actions taken by advertisers, agents, users, or third-party entities.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Users access and use the Platform entirely at their own risk. The total aggregate liability of Akarat, whether in contract, tort, or otherwise, shall not exceed the fees, if any, paid by the user for the relevant Services.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 10. Suspension or Termination
            const Text(
              "10. Suspension or Termination",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Akarat reserves the right, at its sole discretion, to suspend, restrict, or terminate a user’s account and access to the Platform, in whole or in part, without prior notice, if:",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            const Text(
              "• The user violates any provision of these Terms or applicable law.\n"
              "• Fraudulent, abusive, or unethical activity is detected.\n"
              "• Security of the Platform or other users is threatened.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "Upon suspension or termination, access to all Services, content, and user data will be immediately revoked. Users remain liable for all obligations and actions performed under their account prior to termination.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 11. Data Protection & Privacy
            const Text(
              "11. Data Protection & Privacy",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "All personal and non-personal data collected through the Platform are processed in accordance with Akarat’s Privacy Policy. Key practices include:",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 12),
            const Text(
              "• Collection of data only for operational, legal, or service-related purposes.\n"
              "• Secure storage of data and restriction of access to authorized personnel only.\n"
              "• Use of personal data solely for improving Services, processing transactions, or complying with legal obligations.\n"
              "• User rights to access, correct, or request deletion of personal information, subject to applicable UAE laws.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 16),
            const Text(
              "By using the Platform, users consent to the collection, processing, and storage of data as described in the Privacy Policy.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),
            const Text(
              "12. Third-Party Links",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "The Platform may contain links to third-party websites, applications, or services. Akarat does not control, endorse, or guarantee the accuracy, content, privacy, or security of third-party sites.\n\n"
              "Users acknowledge that access to external websites or resources is at their own risk. Akarat disclaims all liability for any damages or losses incurred as a result of using such third-party services.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 13. Governing Law & Jurisdiction
            const Text(
              "13. Governing Law & Jurisdiction",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "These Terms shall be governed by and construed in accordance with the laws of the United Arab Emirates. Any dispute, controversy, or claim arising out of or in connection with these Terms, or the use of the Platform, shall be subject to the exclusive jurisdiction of the competent courts in Dubai.\n\n"
              "Users expressly submit to the jurisdiction of such courts and waive any objection to venue or inconvenient forum.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 14. Language
            const Text(
              "14. Language",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "These Terms are provided in both English and Arabic for convenience. In the event of any conflict or inconsistency between the English and Arabic versions, the English version shall prevail for all legal purposes, interpretation, and enforcement.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 15. Updates to These Terms
            const Text(
              "15. Updates to These Terms",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Akarat reserves the right to amend, revise, or update these Terms at any time to reflect changes in:\n\n"
              "• Legal or regulatory requirements.\n"
              "• Operational, technical, or security improvements.\n"
              "• New features, functionalities, or Services offered through the Platform.\n\n"
              "Updated Terms become effective immediately upon publication on the Platform. Users are encouraged to periodically review the Terms. Continued use of the Platform constitutes acceptance of any modifications or updates.",
              style: TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
            ),
            const SizedBox(height: 30),

            // 16. Contact Us
            const Text(
              "16. Contact Us",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SelectionArea(
              child: const Text(
                "For assistance, inquiries, or complaints:\n\n"
                "✉ info@akarat.com\n\n"
                "📍 Westburry Office Tower, Floor 23, Office 2303, Business Bay, Dubai, UAE",
                style:
                    TextStyle(fontSize: 15.5, letterSpacing: 0.3, height: 1.6),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => Home())),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                    backgroundColor: Colors.white, // white container
                    title: const Text("Login Required",
                        style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.",
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
                // ✅ Logged in – go to favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Fav_Logout()),
                ).then((_) async {
                  // 🔁 Re-sync when coming back
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
            padding: const EdgeInsets.only(
                right: 20.0), // consistent spacing from right edge
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => My_Account()));
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
            Gap(8),
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
