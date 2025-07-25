import 'dart:convert';

import 'package:Akarat/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Akarat/model/propertymodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/new_projects.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/shared_preference_manager.dart';
import 'htmlEpandableText.dart';
import 'my_account.dart';
import 'package:Akarat/utils/property_type_image_mapper.dart';


class Property_Detail extends StatefulWidget {
  Property_Detail({super.key, required this.data});
  final String data;

  @override
  State<Property_Detail> createState() => _Property_DetailState();
}

class _Property_DetailState extends State<Property_Detail> {

  int pageIndex = 0;

  String token = '';
  String email = '';
  String result = '';
  bool isDataRead = false;
  // Create an object of SharedPreferencesManager class
  SharedPreferencesManager prefManager = SharedPreferencesManager();
  // Method to read data from shared preferences
  void readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();
    setState(() {
      isDataRead = true;
    });
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
   // super.initState();
    fetchProducts(widget.data);
  }

  ProjectDetailModel? projectDetailModel;

  Future<void> fetchProducts(String data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'project_detail_$data';
    final cacheTimeKey = 'project_detail_time_$data';
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastFetched = prefs.getInt(cacheTimeKey) ?? 0;


    // Use cached data if less than 6 hours old
    if (now - lastFetched < Duration(hours: 6).inMilliseconds) {
      final cachedData = prefs.getString(cacheKey);
      if (cachedData != null) {
        final Map<String, dynamic> jsonData = json.decode(cachedData);
        final cachedModel = ProjectDetailModel.fromJson(jsonData);
        setState(() {
          projectDetailModel = cachedModel;
        });
        debugPrint("✅ Loaded project from cache");
        return;
      }
    }

    // Fetch from API if no cache or cache is old
    final url = Uri.parse('https://akarat.com/api/new-projects/$data');
    try {
      final response = await http.get(url);
      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        final parsedModel = ProjectDetailModel.fromJson(jsonData);

        // Save to cache
        await prefs.setString(cacheKey, json.encode(jsonData));
        await prefs.setInt(cacheTimeKey, now);

        if (mounted) {
          setState(() {
            projectDetailModel = parsedModel;
          });
        }

        debugPrint("✅ Project title: ${projectDetailModel?.data?.title ?? 'No title'}");
      } else {
        debugPrint("❌ Failed to fetch project. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Exception occurred: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    if (projectDetailModel == null) {
      return Scaffold(
          body: ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const ShimmerCard(),) // Show loading state
      );
    }
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(30.0),
          child: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.red),
              onPressed: () => Navigator.of(context).pop(),
            ),
            centerTitle: true,
            backgroundColor: Color(0xFFFFFFFF),
            iconTheme: const IconThemeData(color: Colors.red),
            // elevation: 1,
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
                children: <Widget>[
                  Container(
                    height: screenSize.height * 0.55,
                    margin: const EdgeInsets.all(0),
                    child:  ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: const ScrollPhysics(),
                      itemCount: projectDetailModel?.data?.media?.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        final imageUrl = projectDetailModel!.data!.media![index].originalUrl.toString();

                        return GestureDetector(
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: "ImagePreview",
                              transitionDuration: const Duration(milliseconds: 300),
                              pageBuilder: (context, animation, secondaryAnimation) {
                                PageController controller = PageController(initialPage: index);
                                return Scaffold(
                                  backgroundColor: Colors.black,
                                  body: SafeArea(
                                    child: Stack(
                                      children: [
                                        PageView.builder(
                                          controller: controller,
                                          itemCount: projectDetailModel?.data?.media?.length ?? 0,
                                          itemBuilder: (context, pageIndex) {
                                            final previewUrl = projectDetailModel!.data!.media![pageIndex].originalUrl.toString();
                                            return InteractiveViewer(
                                              child: CachedNetworkImage(
                                                imageUrl: previewUrl,
                                                fit: BoxFit.contain,
                                              ),
                                            );
                                          },
                                        ),
                                        Positioned(
                                          top: 20,
                                          right: 20,
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                            onPressed: () {
                                              Navigator.of(context).pop(); // closes the full screen
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 25,),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Text(
                            projectDetailModel!.data!.title.toString(),
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      const SizedBox(), // or remove this if not needed
                    ],
                  ),
                  const SizedBox(height: 5,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Launch price",
                              style: TextStyle(
                                letterSpacing: 0.5,
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            const SizedBox(width: 10,),
                            Text(
                              'AED ${projectDetailModel!.data!.price}',
                              style: const TextStyle(
                                letterSpacing: 0.5,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              ' /${projectDetailModel!.data!.paymentPeriod}',
                              style: const TextStyle(
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: HtmlExpandableText(
                      htmlContent: projectDetailModel!.data!.description.toString().replaceAll('\r\n', '<br>'),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Container(
                      height: screenSize.height * 0.13,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.3,
                              0.3,
                            ),
                            blurRadius: 0.3,
                            spreadRadius: 0.3,
                          ), //BoxShadow
                          BoxShadow(
                            color: Colors.white,
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SOBHA logo text block
                          Container(
                            width: screenSize.width * 0.3,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  "SOBHA",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "REALITY",
                                  style: TextStyle(
                                    fontSize: 8,
                                    letterSpacing: 0.5,
                                    height: 0.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),

                          // Developer details block
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    "Developer",
                                    style: TextStyle(fontSize: 14, letterSpacing: 0.5),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Sobha Realty",
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Text(
                                  //   "View Developer Details",
                                  //   style: TextStyle(
                                  //     fontSize: 11,
                                  //     color: Colors.blue,
                                  //     letterSpacing: 0.5,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                   Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 15,),
                            const Text(
                              "Key Information",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text("")
                          ],
                        ),
                        const SizedBox(height: 10,),
                        _infoItem("Delivery date", projectDetailModel!.data!.deliveryDate.toString()),
                        _infoItem("Property Type", projectDetailModel!.data!.propertyType.toString()),
                        _infoItem("Payment Plan", projectDetailModel!.data!.paymentPlan.toString()),
                        _infoItem("Government Fee", "${projectDetailModel!.data!.governmentFee}%"),
                      ],
                    ),
                  const SizedBox(height: 10,),
                  Row(
                    children: [
                      const SizedBox(width: 15,),
                      Text("Payment Plan",style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,),),
                      Text("")
                    ],
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.3,
                              0.3,
                            ),
                            blurRadius: 0.3,
                            spreadRadius: 0.3,
                          ), //BoxShadow
                          BoxShadow(
                            color: Color(0xFFEEEEEE),
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${projectDetailModel!.data!.downPayment}%',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Down Payment",
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.3,
                              0.3,
                            ),
                            blurRadius: 0.3,
                            spreadRadius: 0.3,
                          ), //BoxShadow
                          BoxShadow(
                            color: Color(0xFFEEEEEE),
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${projectDetailModel!.data!.duringConstruction}%',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "During Construction",
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            offset: const Offset(
                              0.3,
                              0.3,
                            ),
                            blurRadius: 0.3,
                            spreadRadius: 0.3,
                          ), //BoxShadow
                          BoxShadow(
                            color: Color(0xFFEEEEEE),
                            offset: const Offset(0.0, 0.0),
                            blurRadius: 0.0,
                            spreadRadius: 0.0,
                          ), //BoxShadow
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${projectDetailModel!.data!.onHandover}%',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "On Handover",
                              style: TextStyle(
                                fontSize: 13,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
                    child: Row(
                      children: const [
                        Text(
                          "Project Timeline",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: const Offset(0.3, 0.3),
                          blurRadius: 2,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Project Announcement",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          projectDetailModel!.data!.projectAnnouncement.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Text(
                          "Construction Started",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          projectDetailModel!.data!.constructionStarted.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 15),

                        const Text(
                          "Expected Completion",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          projectDetailModel!.data!.expectedCompletion.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 10,),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 0, left: 15, right: 15),
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text(
                  //       "Units from Developer",
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.bold,
                  //         fontSize: 18,
                  //         letterSpacing: 0.5,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 5, left: 15, right: 15),
                  //   child: Align(
                  //     alignment: Alignment.centerLeft,
                  //     child: Text(
                  //       "Apartments",
                  //       style: TextStyle(
                  //         fontSize: 14,
                  //         letterSpacing: 0.5,
                  //         color: Colors.grey[700],
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(height: 10,),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  //   child: Column(
                  //     children: [
                  //       _unitRow("3 beds"),
                  //       const SizedBox(height: 15),
                  //       _unitRow("4 beds"),
                  //     ],
                  //   ),
                  // ),
                  const SizedBox(height: 10,),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "About the Project",
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: HtmlExpandableText(
                            htmlContent: projectDetailModel!.data!.description.toString().replaceAll('\r\n', '<br>'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  )
                ]
            )
        )
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // ✅ distributes space correctly
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () async {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Image.asset("assets/images/home.png", height: 25),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0), // consistent spacing from right edge
            child: IconButton(
              enableFeedback: false,
              onPressed: () {
                setState(() {
                  if (token == '') {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                  } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                  }
                });
              },
              icon: pageIndex == 3
                  ? const Icon(Icons.dehaze, color: Colors.red, size: 35)
                  : const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),

    );
  }
}
Widget _unitRow(String title) {
  return Row(
    children: [
      Expanded(
        flex: 2,
        child: Container(
          height: 40,
          decoration: _cardBoxDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.black)),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.red, size: 15),
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        flex: 1,
        child: Container(
          height: 40,
          decoration: _cardBoxDecoration(),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.call, color: Colors.red, size: 15),
              SizedBox(width: 5),
              Text("Call?", style: TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
    ],
  );
}

BoxDecoration _cardBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withOpacity(0.4),
        offset: const Offset(0.3, 0.3),
        blurRadius: 1,
        spreadRadius: 0.3,
      ),
      const BoxShadow(
        color: Colors.white,
        offset: Offset(0.0, 0.0),
        blurRadius: 0.0,
        spreadRadius: 0.0,
      ),
    ],
  );
}
Widget _infoItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: 15,),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            Text("")
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            const SizedBox(width: 15,),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

