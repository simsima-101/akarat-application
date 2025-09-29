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


const String kApiBase = 'akarat.com';

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
  /// Agents tab pagination/state
  int agentsPage = 1;
  bool isAgentsLoading = false;
  bool agentsHasMore = true;

  /// Agencies tab pagination/state
  int agenciesPage = 1;
  bool isAgencyLoading = false; // keep using this name for agencies
  bool agenciesHasMore = true;

  /// Separate scroll controllers (one per tab)
  final ScrollController _agentScroll = ScrollController();
  final ScrollController _agencyScroll = ScrollController();

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
  final List<Map<String, String>> serviceOptions = [
    {'label': 'Residential For Sale', 'value': 'residential-for-sale'},
    {'label': 'Residential For Rent',  'value': 'residential-for-rent'},
    {'label': 'Commercial For Sale',   'value': 'commercial-for-sale'},
    {'label': 'Commercial For Rent',   'value': 'commercial-for-rent'},
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
    // Agents scroll listener
    _agentScroll.addListener(() {
      if (_agentScroll.position.pixels >=
          _agentScroll.position.maxScrollExtent - 120 &&
          !isAgentsLoading &&
          agentsHasMore) {
        agentfetch(loadMore: true);
      }
    });

// Agencies scroll listener
    _agencyScroll.addListener(() {
      if (_agencyScroll.position.pixels >=
          _agencyScroll.position.maxScrollExtent - 120 &&
          !isAgencyLoading &&
          agenciesHasMore) {
        agencyfetch(loadMore: true);
      }
    });


    // Load for dropdowns or similar
    languageFuture = fetchLanguageData();
    nationalityFuture = fetchNationalities();
  }


  @override
  void dispose() {
    _agentScroll.dispose();
    _agencyScroll.dispose();
    _agentSearchController.dispose();
    _agencySearchController.dispose();
    locationController.dispose();
    super.dispose();
  }



  Future<void> agentfetch({bool loadMore = false}) async {
    if (isAgentsLoading) return;
    setState(() => isAgentsLoading = true);

    final requestedPage = (loadMore ? agentsPage : 1);

    // Build qp WITHOUT empty values
    final qp = <String, String>{
      'page': requestedPage.toString(),
      'per_page': '10',
      if (locationController.text.trim().isNotEmpty)
        'search': locationController.text.trim(),
      if (selectedService != null && serviceValueToId[selectedService!] != null)
        'service_needed': serviceValueToId[selectedService!]!,
      if (selectedLanguage?.trim().isNotEmpty == true)
        'language': selectedLanguage!.trim(),
      if (selectedNationality?.trim().isNotEmpty == true)
        'nationality': selectedNationality!.trim(),
    };

    final uri = Uri.https(kApiBase, '/api/agents', qp);
    debugPrint('🌐 [Agents] GET $uri (loadMore=$loadMore, requestedPage=$requestedPage)');

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint("❌ [Agents] ${response.statusCode} ${response.body}");
        return;
      }

      final jsonData = json.decode(response.body);
      // final model = PaginatedAgentsModel.fromJson(jsonData);
      // final agentData = model.data;
      //
      // final fetched = (agentData?.data ?? <AgentsModel>[]);
      // final currentFromMeta = agentData?.meta?.currentPage; // make sure your model maps current_page -> currentPage
      // final lastFromMeta = agentData?.meta?.lastPage;
      //
      // // De-dupe by id
      // final seenIds = agentsmodel.map((a) => a.id).whereType<int>().toSet();
      // final newOnes = fetched.where((a) => a.id != null && !seenIds.contains(a.id)).toList();
      //
      // setState(() {
      //   if (loadMore) {
      //     agentsmodel.addAll(newOnes);
      //   } else {
      //     agentsmodel = fetched; // fresh load replaces
      //   }
      //
      //   // Prefer meta when valid, else fallback to requestedPage
      //   final current = (currentFromMeta is int && currentFromMeta > 0)
      //       ? currentFromMeta
      //       : requestedPage;
      //   final last = (lastFromMeta is int && lastFromMeta > 0) ? lastFromMeta : current;
      //
      //   // If backend didn’t give meta, stop when nothing new arrives
      //   agentsHasMore = (current < last) || (currentFromMeta == null && newOnes.isNotEmpty);
      //   agentsPage = current + 1;
      // });


      final model = PaginatedAgentsModel.fromJson(jsonData);
      final agentData = model.data;

      final List<AgentsModel> fetched = (agentData?.data ?? <AgentsModel>[]);
      final int? currentFromMeta = agentData?.meta?.currentPage;
      final int? lastFromMeta = agentData?.meta?.lastPage;

// ✅ De-dupe by String key (works for int or string IDs)
      final seenAgentKeys = agentsmodel
          .map((a) => a.id == null ? null : a.id.toString())
          .whereType<String>()
          .toSet();

      final newAgentOnes = fetched
          .where((a) => a.id != null && !seenAgentKeys.contains(a.id.toString()))
          .toList();

      setState(() {
        if (loadMore) {
          agentsmodel.addAll(newAgentOnes);
        } else {
          agentsmodel = fetched; // first page replace
        }

        // ✅ Has more?
        if (currentFromMeta != null && lastFromMeta != null) {
          agentsHasMore = currentFromMeta < lastFromMeta;
        } else {
          // No meta → stop if no new items came
          agentsHasMore = newAgentOnes.isNotEmpty && fetched.isNotEmpty;
        }

        // ✅ Only advance page if there’s more
        if (agentsHasMore) {
          agentsPage = (currentFromMeta ?? requestedPage) + 1;
        }
      });

// Optional hard stop: if loadMore and nothing new, stop.
      if (loadMore && newAgentOnes.isEmpty) {
        setState(() => agentsHasMore = false);
      }


      debugPrint('✅ [Agents] got ${fetched.length} (added ${newAgentOnes.length}) '
          'current=${currentFromMeta ?? requestedPage} next=$agentsPage hasMore=$agentsHasMore');


    } catch (e) {
      debugPrint("🚨 [Agents] $e");
    } finally {
      if (mounted) setState(() => isAgentsLoading = false);
    }
  }







  Future<void> agencyfetch({bool loadMore = false}) async {
    if (isAgencyLoading) return;
    setState(() => isAgencyLoading = true);

    final requestedPage = (loadMore ? agenciesPage : 1);

    final qp = <String, String>{
      'page': requestedPage.toString(),
      'per_page': '10',
      if (locationController.text.trim().isNotEmpty)
        'search': locationController.text.trim(),
      if (selectedAgencyService != null &&
          serviceValueToId[selectedAgencyService!] != null)
        'service_needed': serviceValueToId[selectedAgencyService!]!,
    };

    final uri = Uri.https(kApiBase, '/api/companies', qp);
    debugPrint('🌐 [Companies] GET $uri (loadMore=$loadMore, requestedPage=$requestedPage)');

    try {
      final response = await http.get(uri, headers: {'Accept': 'application/json'});
      debugPrint('📨 [Companies] Status: ${response.statusCode}');
      if (response.statusCode != 200) {
        debugPrint('❌ [Companies] Body: ${response.body}');
        return;
      }

      final jsonData = json.decode(response.body);

      List<dynamic> items = const [];
      int? currentFromMeta;
      int? lastFromMeta;

      // Handle both shapes: data:[...] OR data:{data:[...], meta:{...}}
      if (jsonData is Map<String, dynamic>) {
        final dataField = jsonData['data'];
        if (dataField is List) {
          items = dataField;
        } else if (dataField is Map<String, dynamic>) {
          if (dataField['data'] is List) items = dataField['data'] as List;
          final meta = dataField['meta'];
          if (meta is Map<String, dynamic>) {
            currentFromMeta = (meta['current_page'] ?? meta['currentPage']) as int?;
            lastFromMeta = (meta['last_page'] ?? meta['lastPage']) as int?;
          }
        } else if (jsonData['companies'] is List) {
          items = jsonData['companies'] as List;
        }
      }

      final fetched = items
          .map((e) => Agency.fromJson(e as Map<String, dynamic>))
          .toList();

// ✅ De-dupe by String key
      final seenAgencyKeys = agencyList
          .map((a) => a.id == null ? null : a.id.toString())
          .whereType<String>()
          .toSet();

      final newAgencyOnes = fetched
          .where((a) => a.id != null && !seenAgencyKeys.contains(a.id.toString()))
          .toList();

      setState(() {
        if (loadMore) {
          agencyList.addAll(newAgencyOnes);
        } else {
          agencyList = fetched;
        }

        // ✅ Has more?
        if (currentFromMeta != null && lastFromMeta != null) {
          agenciesHasMore = currentFromMeta < lastFromMeta;
        } else {
          // No meta → stop if no new items came
          agenciesHasMore = newAgencyOnes.isNotEmpty && fetched.isNotEmpty;
        }

        // ✅ Only advance page if there’s more
        if (agenciesHasMore) {
          agenciesPage = (currentFromMeta ?? requestedPage) + 1;
        }
      });

// Optional hard stop when backend repeats a page
      if (loadMore && newAgencyOnes.isEmpty) {
        setState(() => agenciesHasMore = false);
      }


      // final fetched = items
      //     .map((e) => Agency.fromJson(e as Map<String, dynamic>))
      //     .toList();
      //
      // // De-dupe by id
      // final seen = agencyList.map((a) => a.id).whereType<int>().toSet();
      // final newOnes = fetched.where((a) => a.id != null && !seen.contains(a.id)).toList();
      //
      // setState(() {
      //   if (loadMore) {
      //     agencyList.addAll(newOnes);
      //   } else {
      //     agencyList = fetched;
      //   }
      //
      //   final current = (currentFromMeta != null && currentFromMeta! > 0)
      //       ? currentFromMeta!
      //       : requestedPage;
      //   final last = (lastFromMeta != null && lastFromMeta! > 0)
      //       ? lastFromMeta!
      //       : current;
      //
      //   agenciesHasMore = (current < last) || (currentFromMeta == null && newOnes.isNotEmpty);
      //   agenciesPage = current + 1;
      // });

      debugPrint('✅ [Companies] got ${fetched.length} (added ${newAgencyOnes.length}) '
          'current=${currentFromMeta ?? requestedPage} next=$agenciesPage hasMore=$agenciesHasMore');


    } catch (e) {
      debugPrint('🚨 [Companies] $e');
    } finally {
      if (mounted) setState(() => isAgencyLoading = false);
    }
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
                setState(() {
                  _agentSearchController.clear();
                  _agencySearchController.clear();
                  locationController.clear();
                  selectedService = null;
                  selectedAgencyService = null;
                  selectedLanguage = null;
                  selectedNationality = null;

                  // Agents
                  agentsmodel.clear();
                  agentsPage = 1;
                  agentsHasMore = true;
                  isAgentsLoading = false;

                  // Agencies
                  agencyList.clear();
                  agenciesPage = 1;
                  agenciesHasMore = true;
                  isAgencyLoading = false;
                });
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
                      controller: _agentScroll, // 👈 per-tab scroll controller
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
                                const SizedBox(height: 10),

                                // Services Dropdown
                                SafeArea(
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
                                        items: const [
                                          DropdownMenuItem<String>(
                                            value: null,
                                            enabled: false,
                                            child: Text(
                                              "Services needed",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ].followedBy(
                                          serviceOptions.map((option) => DropdownMenuItem<String>(
                                            value: option['value'],
                                            child: Text(option['label']!),
                                          )),
                                        ).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedService = value;              // ✅ correct
                                              // reset ONLY agents state
                                              agentsmodel.clear();
                                              agentsPage = 1;
                                              agentsHasMore = true;
                                              isAgentsLoading = false;
                                            });
                                            agentfetch();                           // ✅ correct
                                          }



                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // Language
                                FutureBuilder<Language>(
                                  future: languageFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        decoration: _dropdownDecoration("Language"),
                                        dropdownColor: Colors.white,
                                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blueAccent),
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black),
                                        value: selectedLanguage,
                                        items: const [
                                          DropdownMenuItem<String>(
                                            value: null,
                                            child: Text("None", style: TextStyle(color: Colors.grey)),
                                          ),
                                        ],
                                        onChanged: (value) => setState(() => selectedLanguage = value),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    } else {
                                      final List<String> languageList = snapshot.data?.languages
                                          ?.where((lang) => lang.trim().isNotEmpty && lang.trim().length > 1)
                                          .toSet()
                                          .toList() ??
                                          [];
                                      return GestureDetector(
                                        onTap: () async {
                                          final result = await showDialog<String>(
                                            context: context,
                                            builder: (context) {
                                              String searchText = '';
                                              List<String> filteredList = ["None", ...languageList];
                                              return StatefulBuilder(
                                                builder: (context, setState) => AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  title: const Text("Select Language"),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        decoration: const InputDecoration(
                                                          hintText: "Search...",
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            searchText = value;
                                                            filteredList = ["None", ...languageList]
                                                                .where((lang) => lang.toLowerCase().contains(searchText.toLowerCase()))
                                                                .toList();
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(height: 10),
                                                      SizedBox(
                                                        height: 400,
                                                        width: double.maxFinite,
                                                        child: ListView.builder(
                                                          itemCount: filteredList.length,
                                                          itemBuilder: (context, index) => ListTile(
                                                            title: Text(filteredList[index]),
                                                            onTap: () => Navigator.pop(context, filteredList[index]),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          if (result != null) {
                                            setState(() {
                                              selectedLanguage = (result == "None") ? null : result;
                                            });
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: _dropdownDecoration("Language"),
                                          child: Text(
                                            selectedLanguage?.isNotEmpty == true ? selectedLanguage! : "Select Language",
                                            style: TextStyle(
                                              color: selectedLanguage?.isNotEmpty == true ? Colors.black : Colors.grey,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 10),

                                // Nationality
                                FutureBuilder<Nationality>(
                                  future: nationalityFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return DropdownButtonFormField<String>(
                                        decoration: _dropdownDecoration("Nationality"),
                                        items: const [
                                          DropdownMenuItem(value: null, child: Text("Loading...")),
                                        ],
                                        onChanged: null,
                                      );
                                    } else if (snapshot.hasError) {
                                      return Text("Error: ${snapshot.error}");
                                    } else {
                                      final List<String> nationalityList =
                                          snapshot.data?.nationalities?.toSet().toList() ?? [];
                                      return GestureDetector(
                                        onTap: () async {
                                          final result = await showDialog<String>(
                                            context: context,
                                            builder: (context) {
                                              String searchText = '';
                                              List<String> filteredList = ["None", ...nationalityList];
                                              return StatefulBuilder(
                                                builder: (context, setState) => AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                  title: const Text("Select Nationality"),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextField(
                                                        decoration: const InputDecoration(
                                                          hintText: "Search...",
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                                                        ),
                                                        onChanged: (value) {
                                                          setState(() {
                                                            searchText = value;
                                                            filteredList = ["None", ...nationalityList]
                                                                .where((nat) => nat.toLowerCase().contains(searchText.toLowerCase()))
                                                                .toList();
                                                          });
                                                        },
                                                      ),
                                                      const SizedBox(height: 10),
                                                      SizedBox(
                                                        height: 400,
                                                        width: double.maxFinite,
                                                        child: ListView.builder(
                                                          itemCount: filteredList.length,
                                                          itemBuilder: (context, index) => ListTile(
                                                            title: Text(filteredList[index]),
                                                            onTap: () => Navigator.pop(context, filteredList[index]),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                          if (result != null) {
                                            setState(() {
                                              selectedNationality = (result == "None") ? null : result;
                                            });
                                          }
                                        },
                                        child: InputDecorator(
                                          decoration: _dropdownDecoration("Nationality"),
                                          child: Text(
                                            selectedNationality?.isNotEmpty == true ? selectedNationality! : "Select Nationality",
                                            style: TextStyle(
                                              color: selectedNationality?.isNotEmpty == true ? Colors.black : Colors.grey,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Search Button
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      agentsPage = 1;
                                      agentsHasMore = true;
                                      isAgentsLoading = false;
                                      agentsmodel.clear();
                                    });

                                    debugPrint("Searching with:");
                                    debugPrint("Location: ${locationController.text}");
                                    debugPrint("Service: $selectedService");
                                    debugPrint("Language: $selectedLanguage");
                                    debugPrint("Nationality: $selectedNationality");

                                    agentfetch();
                                  },

                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    minimumSize: const Size.fromHeight(45),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  child: const Text("Search", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ),

                                if (agentsmodel.isEmpty && !isAgentsLoading) ...[
                                  const SizedBox(height: 15),
                                  const Center(
                                    child: Text(
                                      "No Results",
                                      style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Prime Agent badge
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                            child: Container(
                              width: screenSize.width * 0.28,
                              height: 35,
                              padding: const EdgeInsets.only(top: 2, left: 5, right: 1),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                  BoxShadow(
                                    color: Colors.blueAccent.withOpacity(0.8),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 1),
                                    child: Icon(Icons.check_circle, color: Colors.white, size: 17),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(left: 1, right: 3),
                                    child: Text(
                                      "Prime Agent",
                                      style: TextStyle(letterSpacing: 0.5, color: Colors.white, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Description
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text("Explore agents with a proven track record of high response rates and authentic listings."),
                          ),

                          const SizedBox(height: 10),

                          // ✅ The agent list — no extra SingleChildScrollView, no controller here
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            itemCount: agentsmodel.length + (agentsHasMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < agentsmodel.length) {
                                return Agentcardscreen(agentsModel: agentsmodel[index]);
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
                    ),

                    // --- Agencies tab (REPLACE your SingleChildScrollView with this) ---
                    CustomScrollView(
                      controller: _agencyScroll,
                      slivers: [
                        // Filters box
                        SliverToBoxAdapter(child: _agencyFiltersBox(context)),

                        // Spacing & headings
                        const SliverToBoxAdapter(child: SizedBox(height: 20)),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              "Featured Agencies",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Text(
                              "Explore agencies with a proven track record of high response rates and authentic listings.",
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),

                        // Agencies list
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              if (index < agencyList.length) {
                                return Agencycardscreen(agencyModel: agencyList[index]);
                              }
                              if (agenciesHasMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(child: CircularProgressIndicator()),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            childCount: agencyList.length + (agenciesHasMore ? 1 : 0),
                          ),
                        ),

                        // Empty state (shows only when no results and not loading)
                        if (agencyList.isEmpty && !isAgencyLoading)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  "No Results",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
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


  Widget _agencyFiltersBox(BuildContext context) {
    return Container(
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
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: _dropdownDecoration("Services needed"),
            dropdownColor: Colors.white,
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.blueAccent,
            ),
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
                  selectedAgencyService = value;     // agencies filter
                  agencyList.clear();
                  agenciesPage = 1;
                  agenciesHasMore = true;
                  isAgencyLoading = false;
                });
                agencyfetch();                        // call agencies API
              }
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                agencyList.clear();
                agenciesPage = 1;
                agenciesHasMore = true;
                isAgencyLoading = false;
              });
              debugPrint("Searching agencies with:");
              debugPrint("Location: ${locationController.text}");
              debugPrint("Service: $selectedAgencyService");
              agencyfetch();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size.fromHeight(45),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Find",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
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
          icon: const Icon(Icons.email_outlined, color: Colors.red, size: 28),
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
                  backgroundColor: Colors.white, // White dialog container
                  title: const Text(
                    'Email not available',
                    style: TextStyle(color: Colors.black), // Title in black
                  ),
                  content: const Text(
                    'No email app is configured on this device. Please add a mail account first.',
                    style: TextStyle(color: Colors.black), // Content in black
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.red), // Red "OK" text
                      ),
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
