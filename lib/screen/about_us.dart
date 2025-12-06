import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/home.dart';
import '../screen/my_account.dart';
import '../secure_storage.dart';
import '../services/favorite_service.dart';
import '../utils/fav_logout.dart';
import '../utils/shared_preference_manager.dart';
import 'login.dart';

class About_Us extends StatefulWidget {
  const About_Us({super.key});

  @override
  State<About_Us> createState() => _About_UsState();
}

class _About_UsState extends State<About_Us> {
  String token = '';
  SharedPreferencesManager prefManager = SharedPreferencesManager();

  void readData() async {
    token = await prefManager.readStringFromPref();
    setState(() {});
  }

  @override
  void initState() {
    readData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("About Us", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.red),
        ),
        bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Hero Title
              const Text(
                "About Akarat",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                "Built for Trust. Designed for the Future.",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.red.shade700),
              ),
              const SizedBox(height: 30),

              // Main Paragraphs
              Text(
                "Akarat is not just a real estate platform — it's a smarter way to connect people with properties in the UAE.",
                style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Text(
                "We bring together verified listings, powerful tech, and a user-first approach to help everyone succeed with confidence.",
                style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey[800]),
              ),

              // YOUR IMAGE HERE — exactly after the text
              const SizedBox(height: 30),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
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
                  onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home())),
                  icon: const Icon(Icons.arrow_forward, size: 20),
                  label: const Text("Get Started", style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // What We Offer
              Center(
                child: Column(
                  children: [
                    const Text("What We Offer", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Smart tools and verified listings tailored for real estate success.",
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]), textAlign: TextAlign.center),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Features Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.35,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _featureCard("Verified Listings", "100% verified properties to build trust and transparency.", Icons.verified, Colors.green),
                  _featureCard("Smart Filters", "Advanced location & lifestyle filters to refine your search.", Icons.tune, Colors.purple),
                  _featureCard("Agent Dashboard", "Track listing views, leads, and marketing performance.", Icons.dashboard, Colors.blue),
                  _featureCard("Off-plan Projects", "Showcase upcoming developments with dedicated visibility.", Icons.construction, Colors.orange),
                  _featureCard("Web & App Access", "Seamless browsing experience online and via mobile.", Icons.language, Colors.teal),
                  _featureCard("Growth Tools", "Marketing and data insights to boost your brand and reach.", Icons.trending_up, Colors.red),
                ],
              ),

              const SizedBox(height: 60),

              // Our Audience
              Center(
                child: Column(
                  children: [
                    const Text("Our Audience", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("We proudly serve the full real estate ecosystem", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Wrap(
                spacing: 12,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _pill("Home Buyers & Tenants"),
                  _pill("Agents & Agencies"),
                  _pill("Developers & Brokers"),
                  _pill("Property Investors"),
                  _pill("Relocation Services"),
                ],
              ),

              const SizedBox(height: 60),

              // Our Story
              Column(
                children: [
                  Text("Our Story", style: TextStyle(fontSize: 18, color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Text("We started Akarat with one goal", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text("To remove the frustration from property search and marketing by delivering real listings, real tools, and real results.",
                      style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey[800]), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Text("What began as a mission to bring clarity and trust to the real estate market has grown into a fully-featured platform trusted across the UAE.",
                      style: TextStyle(fontSize: 16, height: 1.7, color: Colors.grey[800]), textAlign: TextAlign.center),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _bigNumber("600 +", "International clients"),
                      const SizedBox(width: 50),
                      _bigNumber("40 +", "Offices around the world"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Dark Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(20)),
                child: Column(
                  children: [
                    const Text("Akarat", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text("Westburry Office Tower, Floor 23, Office No. 2303,\nBusiness Bay, Dubai, UAE",
                        style: TextStyle(color: Colors.grey[400], fontSize: 14), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    const Text("+971 52 620 7779", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text("info@akarat.com", style: TextStyle(color: Colors.grey[400])),
                    const SizedBox(height: 24),
                    const Text("BUY, SELL, RENT\nALL IS HERE",
                        style: TextStyle(color: Colors.red, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _storeButton("Download on the\nApp Store"),
                        const SizedBox(width: 16),
                        _storeButton("GET IT ON\nGoogle Play"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable Widgets
  Widget _featureCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          CircleAvatar(radius: 30, backgroundColor: color.withOpacity(0.1), child: Icon(icon, size: 36, color: color)),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade300)),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _bigNumber(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _storeButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.white30), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home())), icon: const Icon(Icons.home_outlined, size: 30)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: Colors.red, size: 30)),
          IconButton(onPressed: () async {
            final Uri email = Uri(scheme: 'mailto', path: 'info@akarat.com');
            if (await canLaunchUrl(email)) launchUrl(email);
          }, icon: const Icon(Icons.email_outlined, color: Colors.red, size: 30)),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const My_Account())), icon: const Icon(Icons.menu, size: 30)),
        ],
      ),
    );
  }
}