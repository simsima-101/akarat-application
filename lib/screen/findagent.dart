import 'dart:convert';

import 'package:Akarat/model/agencymodel.dart';
import 'package:Akarat/model/agentsmodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:Akarat/utils/agencyCardScreen.dart';
import 'package:Akarat/utils/agentcardscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/language.dart';
import '../model/nationality.dart';
import '../utils/shared_preference_manager.dart';

void main(){
  runApp(const FindAgent());

}

class FindAgent extends StatelessWidget {
  const FindAgent({Key ? key}) : super (key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FindAgentDemo(),
    );
  }
}
class FindAgentDemo extends StatefulWidget {
  @override
  _FindAgentDemoState createState() => _FindAgentDemoState();
}
class _FindAgentDemoState extends State<FindAgentDemo> {
  List<AgentsModel> agentsmodel = [];
  List<AgencyModel> agentcymodel = [];
  final TextEditingController _agentSearchController = TextEditingController();
  final TextEditingController _agencySearchController = TextEditingController();
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

  String? selectedService;
  String? selectedAgencyService;
  String? selectedLanguage;
  String? selectedNationality;
  late Future<Nationality> nationalityFuture;

  final TextEditingController locationController = TextEditingController();

  // final List<String> services = ["Residential For Sale", "Residential For Rent", "Commercial For Sale","Commercial For Rent"];
  final serviceOptions = [
    {'label': 'Services needed', 'value': ''},
    {'label': 'Residential For Sale', 'value': 'residential-for-sale'},
    {'label': 'Residential For Rent', 'value': 'residential-for-rent'},
    {'label': 'Commercial For Sale', 'value': 'commercial-for-sale'},
    {'label': 'Commercial For Rent', 'value': 'commercial-for-rent'},
  ];
  final services = [
    {'label': 'Services needed', 'value': ''},
    {'label': 'Residential For Sale', 'value': 'residential-for-sale'},
    {'label': 'Residential For Rent', 'value': 'residential-for-rent'},
    {'label': 'Commercial For Sale', 'value': 'commercial-for-sale'},
    {'label': 'Commercial For Rent', 'value': 'commercial-for-rent'},
  ];// final List<String> agencyservices = ["Residential For Sale", "Residential For Rent", "Commercial For Sale","Commercial For Rent"];
 // final List<String> languages = ["English", "Arabic", "Hindi"];
 // final List<String> nationalities = ["Indian", "Emirati", "Pakistani"];
  late Future<Language> languageFuture;
  @override
  void initState() {
    super.initState();
    agentfetch();
    agencyfetch();
    languageFuture = fetchLanguageData();
    nationalityFuture = fetchNationalities();
    readData();
  }


  Future<void> agentfetch() async {
    final queryParams = {
      'search': locationController.text,
      'service_needed': selectedService ?? '',
      'language': selectedLanguage ?? '',
    };

    if (selectedNationality != null && selectedNationality!.isNotEmpty) {
      queryParams['nationality'] = selectedNationality!;
    }

    final uri = Uri.https('akarat.com', '/api/agents', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        agentsmodel = jsonData.map((data) => AgentsModel.fromJson(data)).toList();
      });
    } else {
      // Handle error
    }
  }

  Future<void> agencyfetch() async {
    final queryParams = {
      'search': locationController.text,
      'service_needed': selectedAgencyService ?? ''
    };
    final uri = Uri.https('akarat.com', '/api/companies', queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      List<dynamic> jsonData = json.decode(response.body);
      setState(() {
        agentcymodel = jsonData.map((data) => AgencyModel.fromJson(data)).toList();
      });
    } else {
      // Handle error
    }
  }

  Future<Nationality> fetchNationalities() async {
    final response = await http.get(Uri.parse('https://akarat.com/api/agents/nationalities'));

    if (response.statusCode == 200) {
      return Nationality.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load nationalities');
    }
  }

  Future<Language> fetchLanguageData() async {
    final response = await http.get(Uri.parse('https://akarat.com/api/agents/languages'));

    if (response.statusCode == 200) {
      return Language.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load languages');
    }
  }

  final TextEditingController _searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (nationalityFuture == null) {
      return const SizedBox(height: 50); // or a placeholder
    }
    Size screenSize = MediaQuery.sizeOf(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        bottomNavigationBar: SafeArea( child: buildMyNavBar(context),),
        backgroundColor: Colors.white, // Light grey background
        appBar: AppBar(
          title: const Text(
              "Find My Agent", style: TextStyle(color: Colors.black,
              fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => Home())), // ✅ Add close functionality
          ),
          centerTitle: true,
          backgroundColor: Color(0xFFFFFFFF),
          iconTheme: const IconThemeData(color: Colors.red),
          elevation: 1,
        ),
        body: SafeArea(
          child: Column(
            children: [
              /*Padding(
                padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                       // Navigator.of(context).pop();
                        setState(() {
                          if (token == '') {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Profile_Login()));
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => My_Account()));
                          }
                        });
                      },
                      child: Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.5, 0.5),
                              blurRadius: 1.0,
                              spreadRadius: 0.5,
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Icon(Icons.arrow_back, color: Colors.red),
                      ),
                    ),
                    SizedBox(width: 20),
                    Image.asset('assets/images/app_icon.png', height: 40),
                    SizedBox(width: 10),
                    Text("Find My Agent", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  ],
                ),
              ),*/
              Container(
                margin: const EdgeInsets.only(top: 20, left: 15, right: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: Offset(4, 4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      offset: Offset(-4, -4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorColor: Colors.transparent,
                  indicator: BoxDecoration(),
                  labelColor: Colors.lightBlueAccent,
                  unselectedLabelColor: Colors.grey,
                  tabs: [
                    Tab(child: Text('Agents', style: TextStyle(fontSize: 16))),
                    Tab(child: Text('Agency', style: TextStyle(fontSize: 16))),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildSearchBar(_agentSearchController, 'Search for a locality, area or city', Icons.search),
                                const SizedBox(height: 10),

                                // Services Dropdown
                                SafeArea(
                                 // child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          decoration: _dropdownDecoration("Services needed"),
                                          dropdownColor: Colors.white,
                                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          value: selectedService,
                                          items: services.map((option){
                                            return DropdownMenuItem<String>(
                                              value: option['value'],
                                              child: Text(
                                                option['label']!,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) => setState(() => selectedService = value!),
                                        ),
                                      ],
                                    ),
                                 // ),
                                ),

                                const SizedBox(height: 10),

                                // Language Dropdown
                                FutureBuilder<Language>(
                                  future: languageFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return DropdownButtonFormField<String>(
                                        decoration: _dropdownDecoration("Language"),
                                        items: [
                                          const DropdownMenuItem(
                                            value: '',
                                            child: Text('Loading...'),
                                          ),
                                        ],
                                        onChanged: null, // disables dropdown
                                      );// shows nothing
                                    } else if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    } else {
                                      final language = ["Language"]; // add default item
                                      language.addAll(snapshot.data?.languages?.toSet().toList() ?? []);
                                      return DropdownButtonFormField<String>(
                                        isExpanded: true, // ✅ Important to avoid overflow
                                        decoration: _dropdownDecoration("Language"),
                                        dropdownColor: Colors.white,
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                        value: language.contains(selectedLanguage) ? selectedLanguage : null,
                                        items: language.map((item) {
                                          if (item == "Language") {
                                            return DropdownMenuItem<String>(
                                              value: '',
                                              enabled: true,
                                              child: Text(
                                                item,
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                            );
                                          } else {
                                            return DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item),
                                            );
                                          }
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedLanguage = value!;
                                          });
                                        },
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 10),

                                FutureBuilder<Nationality>(
                                  future: nationalityFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return DropdownButtonFormField<String>(
                                        decoration: _dropdownDecoration("Nationality"),
                                        items: const [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text("Loading..."),
                                          )
                                        ],
                                        onChanged: null,
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    } else {
                                      final nationalities = ["Nationality"]; // add default item
                                      nationalities.addAll(snapshot.data?.nationalities?.toSet().toList() ?? []);

                                      // Prevent mismatch
                                      if (!nationalities.contains(selectedNationality)) {
                                        selectedNationality = null;
                                      }

                                      return DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        decoration: _dropdownDecoration("Nationality"),
                                        dropdownColor: Colors.white,
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                                        value: selectedNationality,
                                        items: nationalities.map((item) {
                                          if (item == "Nationality") {
                                            return DropdownMenuItem<String>(
                                              value: '',
                                              enabled: true,
                                              child: Text(
                                                item,
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                            );
                                          } else {
                                            return DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(item),
                                            );
                                          }
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            selectedNationality = value!;
                                          });
                                        },
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Search Button
                                ElevatedButton(
                                  onPressed: () {
                                    // Your search logic here
                                    print("Searching with:");
                                    print("Location: ${locationController.text}");
                                    print("Service: $selectedService");
                                    print("Language: $selectedLanguage");
                                    print("Nationality: $selectedNationality");

                                    agentfetch();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize: const Size.fromHeight(45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 10),
                          Padding(
                            padding:  EdgeInsets.only(left: 5.0, right: 5.0, top: 8, bottom: 8),
                            child: Container(
                              width: screenSize.width*0.28,
                              height: 35,
                              padding:  EdgeInsets.only(top: 2,left: 5,right: 1),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.8),
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Padding(padding: const EdgeInsets.only(left: 1),
                                      child:   Icon(Icons.check_circle,color: Colors.white,size: 17,)
                                  ),
                                  Padding(padding: const EdgeInsets.only(left: 1,right: 3),
                                      child:   Text("Prime Agent",style: TextStyle(
                                          letterSpacing: 0.5,color: Colors.white,fontSize: 12
                                      ),textAlign: TextAlign.center,)
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text("Explore agents with a proven track record of high response rates and authentic listings."),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: agentsmodel.length,
                            itemBuilder: (context, index) {
                              return Agentcardscreen(agentsModel: agentsmodel[index]);
                            },
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                buildSearchBar(_agentSearchController, 'Search for a locality, area or city', Icons.search),
                                const SizedBox(height: 10),
                                // Services Dropdown
                                SafeArea(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          decoration: _dropdownDecoration("Services needed"),
                                          dropdownColor: Colors.white,
                                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          value: selectedAgencyService,
                                          items: serviceOptions.map((option){
                                            return DropdownMenuItem<String>(
                                              alignment: Alignment.bottomLeft,
                                              value: option['value'],
                                              child: Text(
                                                option['label']!,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) => setState(() => selectedAgencyService = value!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Search Button
                                ElevatedButton(
                                  onPressed: () {
                                    // Your search logic here
                                    print("Searching with:");
                                    print("Location: ${locationController.text}");
                                    print("Service: $selectedAgencyService");

                                    agencyfetch();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize: const Size.fromHeight(45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Find", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),
                          Text("Featured Agencies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 10),
                          Text("Explore agencies with a proven track record of high response rates and authentic listings."),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: agentcymodel.length,
                            itemBuilder: (context, index) {
                              return Agencycardscreen(agencyModel: agentcymodel[index]);
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  InputDecoration _dropdownDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      //prefixIcon: Icon(Icons.language, color: Colors.blueAccent),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );

  }
  Widget buildSearchBar(TextEditingController controller, String hint, IconData icon) {
    return Container(
      width: 400,
      height: 50,
      padding: const EdgeInsets.only(top: 0, left: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.0,
            spreadRadius: 0.3,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(0.0, 0.0),
            blurRadius: 0.5,
            spreadRadius: 0.0,
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.search, color: Colors.red),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search for a locality, area or city",
                hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
              onTap: ()async{
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Home()));
              },
              child: Image.asset("assets/images/home.png",height: 22,)),
          Container(
              margin: const EdgeInsets.only(left: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: const Offset(
                      0.5,
                      0.5,
                    ),
                    blurRadius: 1.0,
                    spreadRadius: 0.5,
                  ), //BoxShadow
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ), //BoxShadow
                ],
              ),
              child: Icon(Icons.favorite_border,color: Colors.red,)
          ),

          Container(
              margin: const EdgeInsets.only(left: 1),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: const Offset(
                      0.5,
                      0.5,
                    ),
                    blurRadius: 1.0,
                    spreadRadius: 0.5,
                  ), //BoxShadow
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ), //BoxShadow
                ],
              ),
              child: Icon(Icons.add_location_rounded,color: Colors.red,)

          ),
          Container(
              margin: const EdgeInsets.only(left: 1,right: 40),
              height: 35,
              width: 35,
              padding: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: const Offset(
                      0.5,
                      0.5,
                    ),
                    blurRadius: 1.0,
                    spreadRadius: 0.5,
                  ), //BoxShadow
                  BoxShadow(
                    color: Colors.white,
                    offset: const Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ), //BoxShadow
                ],
              ),
              child: Icon(Icons.chat,color: Colors.red,)

          ),
          IconButton(
            enableFeedback: false,
            onPressed: () {

              setState(() {
                if(token == ''){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile_Login()));
                }
                else{
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));

                }
              });

            },
            icon: pageIndex == 3
                ? const Icon(
              Icons.dehaze,
              color: Colors.red,
              size: 35,
            )
                : const Icon(
              Icons.dehaze_outlined,
              color: Colors.red,
              size: 35,
            ),
          ),
        ],
      ),
    );
  }
}
