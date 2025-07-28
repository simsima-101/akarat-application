import 'dart:convert';

import 'package:Akarat/model/agencymodel.dart';
import 'package:Akarat/model/agentsmodel.dart';
import 'package:Akarat/screen/home.dart';
import 'package:Akarat/screen/my_account.dart';
import 'package:Akarat/screen/profile_login.dart';
import 'package:Akarat/screen/shimmer.dart';
import 'package:Akarat/utils/agencyCardScreen.dart';
import 'package:Akarat/utils/agentcardscreen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/language.dart';
import '../model/nationality.dart';
import '../secure_storage.dart';
import '../utils/fav_logout.dart';
import '../utils/shared_preference_manager.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
  List<Agency> agencyList = [];
  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
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
    // {'label': 'Services needed', 'value': ''},
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


  final Map<String, String> serviceValueToId = {
    'residential-for-sale': '1',
    'residential-for-rent': '2',
    'commercial-for-sale': '3',
    'commercial-for-rent': '4',
  };


  late Future<Language> languageFuture;




  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Initial fetch
    agentfetch();
    agencyfetch();

    // Async call for other setup
    Future.microtask(() {
      readData();
    });

    // Scroll pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !isLoading &&
          hasMore) {
        agentfetch(loadMore: true);
        agencyfetch(loadMore: true); // <-- Combine here
      }
    });

    // Load for dropdowns or similar
    languageFuture = fetchLanguageData();
    nationalityFuture = fetchNationalities();
  }



  Future<void> agentfetch({bool loadMore = false}) async {
    if (isLoading) return;

    setState(() => isLoading = true);

    final queryParams = {
      'search': locationController.text,
      'language': selectedLanguage ?? '',
      'page': currentPage.toString(),
    };

    if (selectedService != null && serviceValueToId[selectedService!] != null) {
      queryParams['service_needed'] = serviceValueToId[selectedService!]!;
    }

    if (selectedNationality?.isNotEmpty == true) {
      queryParams['nationality'] = selectedNationality!;
    }


    if (selectedNationality?.isNotEmpty == true) {
      queryParams['nationality'] = selectedNationality!;
    }

    final uri = Uri.https('akarat.com', '/api/agents', queryParams);
    final cacheKey = 'agent_cache_${uri.query}';
    final cacheTimeKey = 'agent_cache_time_${uri.query}';






    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final model = PaginatedAgentsModel.fromJson(jsonData);
        final agentData = model.data;


        setState(() {
          if (loadMore) {
            agentsmodel.addAll(agentData?.data ?? []);
          } else {
            agentsmodel = agentData?.data ?? [];
          }
          currentPage++;
          hasMore = (agentData?.meta?.currentPage ?? 1) < (agentData?.meta?.lastPage ?? 1);
        });


      } else {
        debugPrint("❌ Agent API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Exception in agentfetch: $e");
    }

    setState(() => isLoading = false);
  }



  bool isAgencyLoading = false;

  Future<void> agencyfetch({bool loadMore = false}) async {
    if (isAgencyLoading) return;

    setState(() => isAgencyLoading = true);

    final queryParams = {
      'search': locationController.text,
      'page': currentPage.toString(),
    };

    if (selectedAgencyService != null &&
        serviceValueToId[selectedAgencyService!] != null) {
      queryParams['service_needed'] = serviceValueToId[selectedAgencyService!]!;
    }

    final uri = Uri.https('akarat.com', '/api/companies', queryParams);


    // ✅ Fetch from API
    try {
      final response = await http.get(uri);
      debugPrint("📨 Response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['data'] is List) {
          final List<dynamic> agencyJsonList = jsonData['data'];
          setState(() {
            if (loadMore) {
              agencyList.addAll(
                  agencyJsonList.map((e) => Agency.fromJson(e)).toList());
            } else {
              agencyList =
                  agencyJsonList.map((e) => Agency.fromJson(e)).toList();
            }
            hasMore = false;
          });
        } else {
          final model = PaginatedAgencyModel.fromJson(jsonData);
          final fetchedAgencies = model.data;

          setState(() {
            if (loadMore) {
              agencyList.addAll(fetchedAgencies?.data ?? []);
            } else {
              agencyList = fetchedAgencies?.data ?? [];
            }

            currentPage++;
            hasMore = (fetchedAgencies?.meta?.currentPage ?? 1) <
                (fetchedAgencies?.meta?.lastPage ?? 1);
          });
        }

        // ✅ Cache if not loadMore

      } else {
        debugPrint("❌ Agency API Error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("🚨 Exception in agencyfetch: $e");
    }

    setState(() => isAgencyLoading = false);
  }


  /*    if (!loadMore && now - lastFetched < Duration(hours: 6).inMilliseconds) {
        final cachedData = prefs.getString(cacheKey);


        if (cachedData != null) {
          final model = await compute(decodeAgencyData, cachedData);
          final fetchedAgencies = model.data?.data ?? [];

          setState(() {
            agencyList = fetchedAgencies;
            currentPage = model.data?.meta?.currentPage ?? 1;
            hasMore = (model.data?.meta?.currentPage ?? 1) < (model.data?.meta?.lastPage ?? 1);
            isLoading = false;
          });
          debugPrint("✅ Loaded agency data from cache");
          return;
        }
      }

      try {
        final response = await http.get(uri);
        if (response.statusCode == 200) {
          final model = await compute(decodeAgencyData, response.body);
          final fetchedAgencies = model.data?.data ?? [];

          setState(() {
            if (loadMore) {
              agencyList.addAll(fetchedAgencies);
            } else {
              agencyList = fetchedAgencies;
            }
            currentPage++;
            hasMore = (model.data?.meta?.currentPage ?? 1) < (model.data?.meta?.lastPage ?? 1);
            isLoading = false;
          });

          if (!loadMore) {
            await prefs.setString(cacheKey, response.body);
            await prefs.setInt(cacheTimeKey, now);
            debugPrint("📦 Cached agency data");
          }
        } else {
          debugPrint("❌ API Error: ${response.statusCode}");
        }
      } catch (e) {
        debugPrint("🚨 Exception in agencyfetch: $e");
        setState(() => isLoading = false);
      }
    }*/



  Future<Nationality> fetchNationalities() async {


    // If no cache or cache is expired, fetch from API
    final response = await http.get(Uri.parse('https://akarat.com/api/agents/nationalities'));

    if (response.statusCode == 200) {
      final responseBody = response.body;

      // Save to cache


      return Nationality.fromJson(json.decode(responseBody));
    } else {
      throw Exception('Failed to load nationalities');
    }
  }

  Future<Language> fetchLanguageData() async {


    // Otherwise, fetch from API
    final response = await http.get(Uri.parse('https://akarat.com/api/agents/languages'));

    if (response.statusCode == 200) {
      final responseBody = response.body;




      return Language.fromJson(json.decode(responseBody));
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
              "Find My Agent",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
              )
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () async {
              setState(() {
                if(token == ''){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> My_Account()));
                }
              });
            },
          ),
          actions: [
            TextButton.icon(
              onPressed: () async {
                // Reset all filters
                setState(() {
                  _agentSearchController.clear();
                  _agencySearchController.clear();
                  locationController.clear();
                  selectedService = null;
                  selectedAgencyService = null;
                  selectedLanguage = null;
                  selectedNationality = null;
                  agentsmodel.clear();
                  agencyList.clear();
                  currentPage = 1;
                  hasMore = true;
                });
                // Reload data
                await agentfetch();
                await agencyfetch();
              },
              icon: const Icon(Icons.refresh, color: Colors.red, size: 20),
              label: const Text(
                'Reset',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.symmetric(vertical: 15,horizontal: 12),
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
                                // buildSearchBarComingSoon(),

                                const SizedBox(height: 10),

                                // Services Dropdown
                                SafeArea(
                                  child: Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                          isExpanded: true,
                                          decoration: _dropdownDecoration("Services needed"), // just hint
                                          dropdownColor: Colors.white,
                                          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          value: selectedService,
                                          items: [
                                            // Add grey header item
                                            const DropdownMenuItem<String>(
                                              value: null,
                                              enabled: false,
                                              child: Text(
                                                "Services needed", // this is the header inside dropdown
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            // Now your real options
                                            ...serviceOptions.map((option) {
                                              return DropdownMenuItem<String>(
                                                value: option['value'],
                                                child: Text(option['label']!),
                                              );
                                            }).toList(),
                                          ],
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                selectedService = value;
                                                currentPage = 1;
                                                agentsmodel.clear();
                                                hasMore = true;
                                              });
                                              agentfetch();
                                            }
                                          }

                                      ),
                                    ],
                                  ),
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
                                      final language = ["Language"];
                                      language.addAll(
                                          snapshot.data?.languages
                                              ?.where((lang) => lang.trim().isNotEmpty && lang.trim().length > 1)
                                              .toSet()
                                              .toList() ?? []
                                      );

                                      return DropdownButtonFormField<String>(
                                        isExpanded: true,
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



                                    setState(() {
                                      currentPage = 1;
                                      agentsmodel.clear();
                                      hasMore = true;
                                    });
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

                                if (agentsmodel.isEmpty && !isLoading) ...[
                                  const SizedBox(height: 15),
                                  Center(
                                    child: Text(
                                      "No Results",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:  EdgeInsets.symmetric(vertical: 0,horizontal: 15),
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
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text("Explore agents with a proven track record of high response rates and authentic listings."),
                          ),
                          SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [


                                // ... your widgets above the list (like search bar, filters, titles, etc.) ...

                                // Example header widgets:
                                // Padding(
                                //   padding: EdgeInsets.symmetric(horizontal: 15.0),
                                //   child: Text("Explore agents with a proven track record of high response rates and authentic listings."),
                                // ),
                                const SizedBox(height: 10),


                                // The agent list - this is the important part!
                                ListView.builder(
                                  controller: _scrollController, // 🚀 Use controller for pagination!
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  itemCount: agentsmodel.length + (hasMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index < agentsmodel.length) {
                                      // Add fallback image handling inside your Agentcardscreen
                                      return Agentcardscreen(agentsModel: agentsmodel[index]);
                                    } else {
                                      // Show loader when loading more
                                      return const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    }
                                  },
                                ),

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [




                          Container(
                            padding: const EdgeInsets.all(15),
                            margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
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
                                // buildSearchBarComingSoon(),

                                const SizedBox(height: 10),
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
                                    items: serviceOptions.map((option) {
                                      return DropdownMenuItem<String>(
                                        alignment: Alignment.bottomLeft,
                                        value: option['value'],
                                        child: Text(
                                          option['label']!,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          selectedAgencyService = value;
                                          currentPage = 1;
                                          agencyList.clear();
                                          hasMore = true;
                                        });
                                        agencyfetch();
                                      }
                                    }

                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    print("Searching with:");
                                    print("Location: ${locationController.text}");
                                    print("Service: $selectedService");
                                    agencyfetch();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize: const Size.fromHeight(45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text("Find", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),

                                if (agencyList.isEmpty && !isAgencyLoading) ...[
                                  const SizedBox(height: 15),
                                  Center(
                                    child: Text(
                                      "No Results",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],

                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: const Text("Featured Agencies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: const Text("Explore agencies with a proven track record of high response rates and authentic listings."),
                          ),
                          // The important change is here!
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: agencyList.length + (hasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < agencyList.length) {
                                return Agencycardscreen(agencyModel: agencyList[index]);
                              } else {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
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




  // Widget buildSearchBarComingSoon() {
  //   // return Container(
  //   //   // Use full available width (or keep fixed 400 if you prefer)
  //   //   width: double.infinity,
  //   //   height: 50,
  //   //   padding: const EdgeInsets.symmetric(horizontal: 12),
  //   //   decoration: BoxDecoration(
  //   //     color: Colors.white,                                // active background
  //   //     borderRadius: BorderRadius.circular(10.0),
  //   //     boxShadow: [
  //   //       BoxShadow(
  //   //         color: Colors.grey.withOpacity(0.5),
  //   //         offset: Offset(0, 0),
  //   //         blurRadius: 4.0,
  //   //         spreadRadius: 1.0,
  //   //       ),
  //   //       BoxShadow(
  //   //         color: Colors.white.withOpacity(0.8),
  //   //         offset: Offset(0, 0),
  //   //         blurRadius: 2.0,
  //   //         spreadRadius: 0.0,
  //   //       ),
  //   //     ],
  //   //   ),
  //   //   child: Row(
  //   //     children: [
  //   //       const Icon(Icons.search, color: Colors.red),      // active icon color
  //   //       const SizedBox(width: 8),
  //   //       Expanded(
  //   //         child: TextField(
  //   //           controller: _searchController,
  //   //           decoration: InputDecoration(
  //   //             hintText: "Search for a locality, area or city",
  //   //             hintStyle: TextStyle(
  //   //               color: Colors.grey.shade600,
  //   //               fontSize: 13,
  //   //               fontWeight: FontWeight.w500,
  //   //             ),
  //   //             border: InputBorder.none,
  //   //           ),
  //   //           onChanged: (value) {
  //   //             // TODO: your search logic here
  //   //           },
  //   //         ),
  //   //       ),
  //   //       const SizedBox(width: 8),
  //   //       GestureDetector(
  //   //         onTap: () {
  //   //           // TODO: voice input logic
  //   //         },
  //   //
  //   //       ),
  //   //     ],
  //   //   ),
  //   // );
  // }


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


          IconButton(
            enableFeedback: false,
            onPressed: () async {
              final token = await SecureStorage.getToken();

              if (token == null || token.isEmpty) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white, // white container
                    title: const Text("Login Required", style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.", style: TextStyle(color: Colors.black)),
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
                            MaterialPageRoute(builder: (_) => const LoginDemo()),
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
              }
              else {
                // ✅ Logged in – go to favorites
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Fav_Logout()),
                );
              }
            },
            icon: pageIndex == 2
                ? const Icon(Icons.favorite, color: Colors.red, size: 30)
                : const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
          ),

          IconButton(
            tooltip: "Email",
            icon: const Icon(Icons.email_outlined, color: Colors.red,
            size: 28),
            onPressed: () async {
              final Uri emailUri = Uri.parse(
                'mailto:info@akarat.com?subject=Property%20Inquiry&body=Hi,%20I%20saw%20your%20agent%20profile%20on%20Akarat.',
              );

              if (await canLaunchUrl(emailUri)) {
                await launchUrl(emailUri);
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Email not available'),
                    content: const Text('No email app is configured on this device. Please add a mail account first.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                );
              }
            },
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
