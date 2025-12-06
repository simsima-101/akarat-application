import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:flutter/material.dart';

import '../secure_storage.dart';
import '../services/favorite_service.dart';
import '../utils/fav_logout.dart';
import 'ContactFormScreen.dart';
import 'login.dart';

class Privacy extends StatefulWidget {
  const Privacy({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _PrivacyState();
}

class _PrivacyState extends State<Privacy> {
  int pageIndex = 0;

  final ScrollController _scrollController = ScrollController();
//
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
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(
          child: buildMyNavBar(context),
        ),
        appBar: AppBar(
          title: const Text("Privacy Policy",
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Image.asset(
                            "assets/images/app_icon.png",
                            height: 22,
                            alignment: Alignment.center,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Image.asset(
                            "assets/images/logo-text.png",
                            height: 22,
                            alignment: Alignment.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Align(
                  //   alignment: AlignmentGeometry.center,
                  //   child: Text(
                  //     "Your Privacy is our Priority",
                  //     style: TextStyle(
                  //       fontWeight: FontWeight.bold,
                  //       fontSize: 19,
                  //       letterSpacing: 0.5,
                  //     ),
                  //     textAlign: TextAlign.center,
                  //   ),
                  // ),
                  const SizedBox(height: 6),
                  Text(
                    "Introduction",
                    style: TextStyle(
                        fontSize: 18,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    """Protecting your privacy is a priority for Akarat. We are committed to safeguarding your Personal Data and being transparent about how it is collected, used, and disclosed in connection with your use of our website and mobile applications (the “Platform”).
                    \nThis Privacy Policy explains how Akarat collects, processes, and manages your Personal Data when you access or use the Platform, and outlines your rights and the legal protections available to you.
                    \nBy accessing or using the Platform, you acknowledge and agree to the collection, use, and transfer of your Personal Data in accordance with this Privacy Policy.
                    """,
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 13),
                  Text(
                    "This Privacy Policy covers the following sections:",
                    style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLink("About our company and contact information",
                          aboutKey),
                      _buildLink("Types of information we collect", typesKey),
                      _buildLink("Legal Basis for Processing Your Information",
                          legalKey),
                      _buildLink("How We Share Your Information", shareKey),
                      _buildLink("Data Security Measures", securityKey),
                      _buildLink(
                          "Your Rights Regarding Your Information", rightsKey),
                      _buildLink("Marketing and Promotional Communications",
                          marketingKey),
                      _buildLink("Information About Minors", minorsKey),
                      _buildLink("Links to Third-Party", thirdPartyKey),
                      _buildLink("Policy Updates and Revisions", updatesKey),
                    ],
                  ),
                  Text(
                    "\nWe may revise this Privacy Policy periodically. The latest version will always be available on this page."
                    "\n\nIf this Policy is published in different languages and any discrepancies arise, the English version shall prevail.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),
                  // const SizedBox(height: 6),
                  // Text(
                  //   "2.Usage Data: We may also collect information on how our website is accessed "
                  //   "and used. This data may include your IP address, browser type, pages visited, "
                  //   "and the time and date of your visit.How We Use Your Information",
                  //   style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                  // ),
                  const SizedBox(height: 25),
                  _buildTitle(
                    aboutKey,
                    "Who We Are & How to Contact Us?",
                  ),

                  const SizedBox(height: 12),

                  Text("Who are we?",
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Text(
                    "The Platform is operated by EMLAK BULUCU, a company registered in the United Arab Emirates, with its registered address at Westburry Office Tower, Floor 23, Office No. 2303, Business Bay, Dubai, UAE (“Akarat”, “we”, “us”, “our”).",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 26),

                  Text("How to contact us?",
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Text(
                    "You may contact us via email at info@akarat.com for any inquiries related to this Privacy Policy.",
                    style: TextStyle(
                      fontSize: 15.5,
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(height: 14),
                  _buildTitle(
                    typesKey,
                    "Informations We Collect & How We Use It",
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "The categories of Personal Data we collect directly from you are outlined below.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    "“Personal Data” refers to any information that identifies you or can reasonably be used to identify you. This does not include anonymised or aggregated data that cannot be linked back to you. Property listing details—such as photos, prices, descriptions, and amenities—are not considered Personal Data, as they relate to properties and do not identify individuals.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "The types of Personal Data we may collect include:",
                    style: TextStyle(
                        fontSize: 15.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 13),

                  Text(
                    "   → User Information\n"
                    "   → Agency Informatio\n"
                    "   → Agent Information\n"
                    "   → Property Creation Information\n"
                    "   → Chat Data\n"
                    "   → Technical Data\n"
                    "   → Marketing Data",
                    style: TextStyle(
                        fontSize: 15.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 18),
                  Text(
                    "→ User Information (for Registration and Login)",
                    style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "When you register on Akarat.com, we collect certain personal information to create and manage your account, verify your identity, and personalize your experience on the Platform.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 14),
                  Text(
                    "Account and Identity Details We Collect:",
                    style: TextStyle(
                        fontSize: 15.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "• Full Name (First and Last Name)\n"
                    "• Email Address\n"
                    "• Mobile Number (including country code)\n"
                    "• WhatsApp Number\n"
                    "• Password and login credentials\n"
                    "• Google Sign-In details (if you choose “Continue with Google”)\n"
                    "• Verification codes or OTPs used for account setup, login, or security checks",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 23),

// → Agency Information
                  Text(
                    "→ Agency Information",
                    style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "• Agency Name and Emirate\n"
                    "• National ID and property location\n"
                    "• Registered license number of Agency\n"
                    "• Registered logo of Agency\n"
                    "• Registered company license document\n"
                    "• Registered office registration number",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    "We collect Agency data to verify the legitimacy of the business and ensure compliance with licensing requirements. This information allows us to create and display a verified Agency profile on Akarat.com, facilitate transparent communication between users and registered Agencies, and efficiently manage property listings and the agents associated with each Agency.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    "Akarat may publicly display:",
                    style: TextStyle(
                        fontSize: 15.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "• Agency name, logo, ORN, and contact information\n"
                    "• Office address and linked Agents\n"
                    "• Publicly listed properties (views, listings)\n\n"
                    "Sensitive registration or licensing documents remain strictly confidential.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 20),

// → Agent Information
                  Text(
                    "→ Agent Information",
                    style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "• Agent name and Emirate\n"
                    "• Registered Agent License Number\n"
                    "• Agent National ID\n"
                    "• Agent profile photo\n"
                    "• Mobile phone number and WhatsApp number\n"
                    "• Nationality",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 15),

                  Text(
                    "We collect Agent data to verify their professional identity and authorization under RERA/DLD guidelines, to display verified Agent profiles on Akarat.com, and to facilitate communication between Agents and potential clients. Only limited information is displayed publicly, such as the Agent’s name, profile photo, linked Agency name and logo, and active property listings.\n\n"
                    "Sensitive documents, including copies of Emirates IDs, are never shared publicly.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 20),

// → Property Creation Information
                  Text(
                    "→ Property Creation Information",
                    style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "When you list or manage a property on Akarat.com, we collect specific details to ensure your listing is complete, accurate, and compliant.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "Information Collected:",
                    style: TextStyle(
                        fontSize: 15.5,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "• Emirate and Trakheesi license details\n"
                    "• Property Title and Description\n"
                    "• Property type (e.g., apartment, villa, office, land)\n"
                    "• Location and map coordinates\n"
                    "• Payment details and rental period\n"
                    "• Area size, number of bedrooms and bathrooms\n"
                    "• Amenities and furnishing details\n"
                    "• Availability status of property\n"
                    "• All project-related details\n"
                    "• Uploaded media (Photos, Floor Plans, YouTube Link)",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 17),

                  Text(
                    "A Trakheesi license is a mandatory permit issued by the Dubai Land Department (DLD) through RERA, regulating all real estate advertising in Dubai. It ensures that property advertisements are legitimate, traceable, and compliant.\n\n"
                    "We collect property listing information to publish and display your listings to potential buyers or tenants, verify authenticity, improve search accuracy, and ensure advertising compliance in the UAE.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 25),

// → Chat Data
                  Text(
                    "→ Chat Data",
                    style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "Chat Data refers to the messages you exchange through the Platform. This includes any text sent or received. We use this data to facilitate communication between users and Agents, respond to inquiries, provide support, maintain a record of interactions, and improve our services.\n\n"
                    "Chat Data is confidential and securely stored in accordance with this Privacy Policy.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 25),

// → Technical Data
                  Text(
                    "→ Technical Data",
                    style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "• IP Address\n"
                    "• Login Data\n"
                    "• Browser type and version\n"
                    "• Operating system and platform\n"
                    "• Device information\n"
                    "• Time zone settings",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "We collect technical data to understand how users interact with our Platform, diagnose issues, improve performance and functionality, enhance security, and optimize user experience. This data may also be used for analytics, fraud detection, and regulatory compliance.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 25),

// → Marketing Data
                  Text(
                    "→ Marketing Data",
                    style: TextStyle(
                        fontSize: 17,
                        letterSpacing: 0.3,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "We may collect information about your marketing preferences, including whether you wish to receive new property alerts, account status updates, enquiry notifications, or promotional messages. This helps us send relevant and useful content while ensuring you only receive communications in your preferred manner.\n\n"
                    "You may update or withdraw your marketing preferences at any time through your account settings or by contacting us.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 25),

                  Text(
                      "What happens if you refuse to provide necessary Personal Data?",
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 12),
                  Text(
                    "You are not required to provide Personal Data to us. However, if certain data is necessary to access the Platform or comply with legal requirements, and you do not provide it, we may be unable to grant access. For example, we require your email address to register your account on Akarat.com.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 10),

// Legal Basis for Processing
                  _buildTitle(
                    legalKey,
                    "Legal Basis for Processing",
                  ),

                  Text(
                    "Under applicable privacy laws, we must ensure that each purpose for which we use your Personal Data is supported by a valid legal basis. In most cases, we rely on one of the following:",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "• Contractual Necessity – When processing your Personal Data is required to fulfil our contract with you (for example, enabling your access to the Platform).\n\n"
                    "• Compliance with Law – When we must process your Personal Data to meet legal or regulatory requirements.\n\n"
                    "• Consent – When you have provided clear permission for us to process your Personal Data for a specific purpose.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 10),

// Who Do We Share Your Information With?
                  _buildTitle(
                    shareKey,
                    "Who Do We Share Your Information With?",
                  ),

                  Text(
                    "We require all parties who receive your Personal Data to apply appropriate security measures to protect it, in line with our policies and applicable data protection obligations. We do not allow any third-party service providers who process Personal Data on our behalf to use it for their own purposes. They are only permitted to handle your Personal Data for the specific purposes we define and strictly in accordance with our instructions.\n\n"
                    "We may also need to share certain Personal Data with other users of the Platform when you choose to engage in transactions with them. For example, if you express interest in a property listed by an Agent, relevant representatives of that Agent may require access to your Personal Data.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 10),

// How We Keep Your Data Secure
                  _buildTitle(
                    securityKey,
                    "How We Keep Your Data Secure",
                  ),

                  Text(
                    "We have implemented suitable security measures to protect your Personal Data from accidental loss, alteration, unauthorized access, or misuse.\n\n"
                    "Access to your Personal Data is restricted to employees and authorized personnel who require it for legitimate business purposes. All individuals with such access are bound by confidentiality obligations.\n\n"
                    "We also maintain robust procedures to detect, manage, and respond to any actual or suspected Personal Data breaches. In such cases, we take immediate steps to minimize potential impact on your privacy and cooperate with relevant regulatory authorities as required.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 10),

                  // Your Rights
                  _buildTitle(
                    rightsKey,
                    "Your Rights",
                  ),

                  Text(
                    "Depending on the applicable data protection laws and where your Personal Data is under our control, you may have the right to:",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "• Access — Request a copy of the Personal Data we hold about you.\n"
                    "• Correction — Ask us to update or amend inaccurate or incomplete information.\n"
                    "• Erasure — Request deletion of your Personal Data where it is no longer needed for its original purpose.\n"
                    "• Restrict Processing — Ask us to temporarily or permanently stop processing all or part of your data.\n"
                    "• Objection — Object to processing based on our legitimate interests or for direct marketing.\n"
                    "• Data Portability — Request a structured, machine-readable copy of your Personal Data.\n"
                    "• Withdrawal of Consent — Withdraw consent where processing is based on your permission.\n\n"
                    "If you want to exercise any of these rights, please contact us.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 10),

// Marketing Communications
                  _buildTitle(
                    marketingKey,
                    "Marketing Communications",
                  ),

                  Text(
                    "We may collect and store your preferences regarding the marketing communications you wish to receive from us, including property alerts, account updates, enquiry responses, and promotional messages. This helps us tailor communication to your interests.\n\n"
                    "You may opt out at any time by clicking the “Unsubscribe” link in any marketing email or by contacting us at info@akarat.com. Opting out will not affect your ability to use the Platform.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 10),

// Our Privacy for Minors
                  _buildTitle(
                    minorsKey,
                    "Our Privacy for Minors",
                  ),

                  Text(
                    "This Platform is not intended for use by anyone under 18. We do not knowingly collect data from minors or verify user age. If you believe a minor is using the Platform, please notify us at info@akarat.com so we can remove any associated Personal Data and prevent further access.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 10),

// Third-Party Links
                  _buildTitle(
                    thirdPartyKey,
                    "Third-Party Links",
                  ),

                  Text(
                    "The Platform may contain links to third-party websites or services. Akarat is not responsible for the content, availability, or privacy practices of external sites. When you leave our Platform, we encourage you to review the privacy policies of each website you visit.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 10),

// Changes to the Privacy Policy
                  _buildTitle(
                    updatesKey,
                    "Changes to the Privacy Policy",
                  ),

                  Text(
                    "We may update this Privacy Policy at any time, with or without prior notice. When updates occur, we will revise this page and may notify you directly in certain cases (for example, by email). All changes become effective immediately once posted.",
                    style: TextStyle(fontSize: 15.5, letterSpacing: 0.3),
                  ),

                  const SizedBox(height: 40),
                ])));
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
                text: "• ", // the bullet
                style: TextStyle(
                    color: Colors.black, // bullet color
                    fontSize: 21,
                    height: 0.9),
              ),
              TextSpan(
                text: title, // your title
                style: TextStyle(
                    color: Colors.blue, // title color
                    fontSize: 15.5,
                    letterSpacing: 0.3),
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
      child: Text(heading,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
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
            padding: const EdgeInsets.only(
                right: 20.0), // consistent spacing from right edge
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => My_Account()));
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
