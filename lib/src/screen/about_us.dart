import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../core/utils/secure_storage.dart';
import '../features/property/data/datasources/favorite_remote_datasource.dart';
import '../screen/home.dart';
import '../utils/fav_logout.dart';
import '../utils/shared_preference_manager.dart';
import 'ContactFormScreen.dart';
import 'login.dart';
import 'my_account.dart';

class About_Us extends StatefulWidget {
  const About_Us({super.key});

  @override
  State<About_Us> createState() => _About_UsState();
}

class _About_UsState extends State<About_Us> {
  String token = '';

  bool isDataRead = false;
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref();
    setState(() {
      isDataRead = true;
    });
  }

  @override
  void initState() {
    readData();
    super.initState();
  }

  int? selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;

    final List<ExploreModel> exploreList = [
      ExploreModel(
        title: l.aboutUs_explore_verified_title,
        des: l.aboutUs_explore_verified_desc,
        assetIcon: 'assets/images/verified_icon.png',
        iconPadding: 5,
        color: Colors.green,
      ),
      ExploreModel(
        title: l.aboutUs_explore_smart_location_title,
        des: l.aboutUs_explore_smart_location_desc,
        assetIcon: "assets/images/smart_location_icon.png",
        iconPadding: 8,
        color: Colors.yellow,
      ),
      ExploreModel(
        title: l.aboutUs_explore_agent_dashboard_title,
        des: l.aboutUs_explore_agent_dashboard_desc,
        assetIcon: 'assets/images/dashboard_icon.png',
        iconPadding: 11,
        color: Colors.blue,
      ),
    ];

    List<ServiceModel> serviceList = [
      ServiceModel(
          title: l.aboutUs_service_buyers_renters_title,
          des: l.aboutUs_service_buyers_renters_desc,
          assetIcon: "assets/images/service_1.png"),
      ServiceModel(
          title: l.aboutUs_service_agents_agencies_title,
          des: l.aboutUs_service_agents_agencies_desc,
          assetIcon: "assets/images/service_2.png"),
      ServiceModel(
          title: l.aboutUs_service_developers_title,
          des: l.aboutUs_service_developers_desc,
          assetIcon: "assets/images/servce_3.png"),
      ServiceModel(
          title: l.aboutUs_service_investors_title,
          des: l.aboutUs_service_investors_desc,
          assetIcon: "assets/images/service_4.png"),
      ServiceModel(
          title: l.aboutUs_service_providers_title,
          des: l.aboutUs_service_providers_desc,
          assetIcon: "assets/images/service_5.png"),
    ];

    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(
          child: buildMyNavBar(context),
        ),
        appBar: AppBar(
          title: Text(l.aboutUs,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: const IconThemeData(color: Colors.red),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Hero Title
                    Text(
                      l.aboutUs_hero_title,
                      style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      l.aboutUs_hero_subtitle,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red.shade700),
                    ),
                    const SizedBox(height: 30),

                    // Main Paragraphs
                    Text(
                      l.aboutUs_intro_paragraph_1,
                      style: TextStyle(
                          fontSize: 16, height: 1.7, color: Colors.grey[800]),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l.aboutUs_intro_paragraph_2,
                      style: TextStyle(
                          fontSize: 16, height: 1.7, color: Colors.grey[800]),
                    ),

                    // YOUR IMAGE HERE — exactly after the text
                    const SizedBox(height: 24),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/images/about_main.png", // ← Your image
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Get Started Button
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const Home())),
                        icon: const Icon(Icons.arrow_forward, size: 20),
                        label: Text(l.aboutUs_get_started_button,
                            style: const TextStyle(fontSize: 16)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 11),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // What We Offer
                    Center(
                      child: Column(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "${l.aboutUs_features_heading_part1} ",
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: l.aboutUs_features_heading_part2,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(l.aboutUs_features_subtitle,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600]),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ),

                    const SizedBox(height: 27),

                    // Features Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      // childAspectRatio: 1.35,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      children: [
                        _featureCard(
                            l.aboutUs_feature_verified_listings_title,
                            l.aboutUs_feature_verified_listings_desc,
                            'assets/images/verified_icon.png',
                            Colors.green,
                            5),
                        _featureCard(
                            l.aboutUs_feature_smart_filters_title,
                            l.aboutUs_feature_smart_filters_desc,
                            'assets/images/filters_icon.png',
                            Colors.purple,
                            9),
                        _featureCard(
                            l.aboutUs_feature_agent_dashboard_title,
                            l.aboutUs_feature_agent_dashboard_desc,
                            'assets/images/dashboard_icon.png',
                            Colors.blue,
                            11),
                        _featureCard(
                            l.aboutUs_feature_offplan_projects_title,
                            l.aboutUs_feature_offplan_projects_desc,
                            'assets/images/offplan_projects.png',
                            Colors.orange,
                            9),
                        _featureCard(
                            l.aboutUs_feature_web_app_access_title,
                            l.aboutUs_feature_web_app_access_desc,
                            'assets/images/web_access_icon.png',
                            Colors.teal,
                            10),
                        _featureCard(
                            l.aboutUs_feature_growth_tools_title,
                            l.aboutUs_feature_growth_tools_desc,
                            'assets/images/growth_icon.png',
                            Colors.red,
                            6),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Our Audience
                    Center(
                      child: Column(
                        children: [
                          Text(l.aboutUs_audience_heading,
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(l.aboutUs_audience_subtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.grey[600])),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                    Column(
                      spacing: 14,
                      children: [
                        _pill(l.aboutUs_audience_pill_investors),
                        _pill(l.aboutUs_audience_pill_agents),
                        _pill(l.aboutUs_audience_pill_relocation),
                        _pill(l.aboutUs_audience_pill_developers),
                        _pill(l.aboutUs_audience_pill_buyers),
                      ],
                    ),

                    const SizedBox(height: 60),

                    Center(
                      child: Container(
                        child: Image.asset(
                          "assets/images/map_about_us.png", // ← Your image
                          width: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Our Story
                    Column(
                      children: [
                        Text(l.aboutUs_story_heading,
                            style: TextStyle(
                                fontSize: 22,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(l.aboutUs_story_main_title,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(l.aboutUs_story_paragraph_1,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                color: Colors.grey[800]),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(l.aboutUs_story_paragraph_2,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                color: Colors.grey[800]),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _bigNumber(
                              l.aboutUs_story_stat_clients_number,
                              l.aboutUs_story_stat_clients_label,
                            ),
                            const SizedBox(width: 50),
                            _bigNumber(l.aboutUs_story_stat_offices_number,
                                l.aboutUs_story_stat_offices_label),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Explore the Top Features of Akarat
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${l.aboutUs_explore_heading_part1} ",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: l.aboutUs_hero_brand_name,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: exploreList.length,
                      itemBuilder: (context, index) {
                        final exploreModel = exploreList[index];
                        return _buildExploreContainer(
                          exploreModel.title,
                          exploreModel.des,
                          exploreModel.assetIcon,
                          exploreModel.color,
                          exploreModel.iconPadding,
                          context,
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    Center(
                      child: Column(
                        children: [
                          Text(l.aboutUs_services_heading,
                              // textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Text(
                            l.aboutUs_services_whoWeServe_title,
                            style: TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l.aboutUs_services_intro,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                height: 1.7,
                                color: Colors.grey[800]),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: serviceList.length,
                            itemBuilder: (context, index) {
                              final serviceModel = serviceList[index];
                              return ServiceCard(
                                isActive: selectedIndex == index,
                                title: serviceModel.title,
                                desc: serviceModel.des,
                                icon: serviceModel.assetIcon,
                                onTap: () {
                                  setState(() {
                                    if (selectedIndex == index) {
                                      // If user taps the already selected card → unselect it
                                      selectedIndex = null;
                                    } else {
                                      // Otherwise select the tapped one
                                      selectedIndex = index;
                                    }
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 20, bottom: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFF252525), // Dark background
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialCircle(
                          "assets/images/facebook.png",
                          12,
                          () async {
                            await launchUrlSafe(
                                "https://www.facebook.com/people/Akarat/61575089527710/");
                          },
                        ),
                        const SizedBox(width: 18),
                        _socialCircle(
                          "assets/images/instagram.png",
                          11,
                          () async {
                            await launchUrlSafe(
                                "https://www.instagram.com/akarat.uae/");
                          },
                        ),
                        const SizedBox(width: 18),
                        _socialCircle(
                          "assets/images/linkedin.png",
                          14,
                          () async {
                            await launchUrlSafe(
                                "https://www.linkedin.com/company/akarat-uae/");
                          },
                        ),
                        const SizedBox(width: 18),
                        _socialCircle(
                          "assets/images/youtube.png",
                          10,
                          () async {
                            await launchUrlSafe(
                                "https://www.youtube.com/@akaratuae");
                          },
                        ),
                      ],
                    ),
                    Gap(12),
                    SelectionArea(
                      child: Text(
                        l.aboutUs_footer_email,
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> launchUrlSafe(String url) async {
    final Uri uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // opens in browser/app
      );

      if (!launched) {
        throw Exception('Could not launch $url');
      }
    } else {
      throw Exception('Invalid URL: $url');
    }
  }

  Widget _socialCircle(
      String icon, double iconPadding, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 43,
        height: 43,
        padding: EdgeInsets.all(iconPadding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF424242), // Circle background like image
        ),
        child: Image.asset(icon),
      ),
    );
  }

  // Reusable Widgets
  Widget _featureCard(
      String title, String desc, String icon, Color color, double iconPadding) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 12, top: 15),
      decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(iconPadding),
              child: Image.asset(icon),
            ),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(desc,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300)),
        child: Text(text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _bigNumber(String number, String label) {
    return Column(
      children: [
        Text(number,
            style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.red)),
        Text(label,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
            textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildExploreContainer(
    String title,
    String desc,
    String icon,
    Color color,
    double iconPadding,
    BuildContext ctx,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 18),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 0),
                color: Colors.grey.shade300,
                blurRadius: 1,
                spreadRadius: 1)
          ],
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Padding(
              padding: EdgeInsets.all(iconPadding),
              child: Image.asset(icon),
            ),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const Home())),
            label:
                Text(AppLocalizations.of(context)!.aboutUs_start_project_button,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    )),
            iconAlignment: IconAlignment.end,
            icon: const Icon(
              Icons.arrow_forward,
              size: 20,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    final l = AppLocalizations.of(context)!;

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    backgroundColor: Colors.white,
                    title: Text(l.aboutUs_login_dialog_title,
                        style: const TextStyle(color: Colors.black)),
                    content: Text(l.aboutUs_login_dialog_message,
                        style: const TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          l.aboutUs_login_dialog_cancel,
                          style: const TextStyle(color: Colors.red),
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
                        child: Text(
                          l.aboutUs_login_dialog_login,
                          style: const TextStyle(color: Colors.red),
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
}

class ExploreModel {
  final String title;
  final String des;
  final String assetIcon;
  final double iconPadding;
  final Color color;

  ExploreModel(
      {required this.title,
      required this.des,
      required this.assetIcon,
      required this.iconPadding,
      required this.color});
}

class ServiceModel {
  final String title;
  final String des;
  final String assetIcon;

  ServiceModel({
    required this.title,
    required this.des,
    required this.assetIcon,
  });
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String desc;
  final String icon;
  final bool isActive;
  final VoidCallback onTap;

  const ServiceCard({
    required this.title,
    required this.desc,
    required this.icon,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(top: 20),
        height: isActive ? 170 : 150,
        transform: Matrix4.identity()..scale(isActive ? 1.03 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              offset: Offset(0, 0),
              color: Colors.grey.shade300,
              blurRadius: 3,
              spreadRadius: 1,
            )
          ],
          image: DecorationImage(
            image: AssetImage(icon),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.black.withOpacity(0.60)
                    : Colors.black.withOpacity(0.20),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            AnimatedAlign(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              alignment: isActive ? Alignment.center : Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(isActive ? 1 : 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity: isActive ? 1 : 0,
                      child: Text(
                        desc,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.95),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
