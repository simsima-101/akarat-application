import 'package:Akarat/src/core/utils/secure_storage.dart';
import 'package:Akarat/src/features/property/data/models/featuredmodel.dart' as featured;
import 'package:Akarat/src/features/property/data/models/property_model.dart';
import 'package:Akarat/src/features/property/presentation/bloc/properties_bloc.dart';

import 'package:Akarat/src/screen/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../common/widgets/property_card.dart';
import '../features/property/data/models/project_model.dart';
import '../features/property/presentation/bloc/filter_bloc.dart';
import '../utils/fav_logout.dart';
import 'ContactFormScreen.dart';
import 'filter.dart' as filter;
import 'location_picker_screen.dart';
import 'login.dart';
import 'my_account.dart';
import 'new_projects.dart';

extension AppLocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this)!;
}

extension FeaturedDataToProperty on featured.Data {
  Property toProperty() {
    return Property(
      id: id?.toString() ?? '0',
      title: title ?? 'No title',
      price: price ?? 'Price on request',
      location: location ?? address ?? 'Dubai, UAE',
      bedrooms: bedrooms ?? 0,
      bathrooms: bathrooms ?? 0,
      squareFeet: squareFeet ?? displaySize ?? 'N/A',
      description: 'Beautiful property listed on Akarat.',
      image: media?.isNotEmpty == true ? media!.first.originalUrl ?? '' : '',
      media: media ?? [],
      agent: agentName ?? 'Agent',
      agentImage: agentImage,
      phoneNumber: phoneNumber,
      whatsapp: whatsapp,
      postedOn: postedOn,
      agencyLogo: agencyLogo,
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeDemo(),
    );
  }
}

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _FixedHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_FixedHeaderDelegate oldDelegate) {
    return minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight ||
        child != oldDelegate.child;
  }
}

class HomeDemo extends StatelessWidget {
  const HomeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    String selectedSort = "Newest";  // ← add this line here

    final scrollController = ScrollController();

    // Infinite scroll: dispatch LoadMoreProperties when near bottom
    scrollController.addListener(() {
      const threshold = 200.0;
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - threshold) {
        final bloc = context.read<PropertiesBloc>();
        if (bloc.state.hasMore &&
            bloc.state.status != PropertiesStatus.loadingMore &&
            bloc.state.status != PropertiesStatus.loading) {
          bloc.add(LoadMoreProperties());
        }
      }
    });

    return WillPopScope(
      onWillPop: () async {
        return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'No',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Yes',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        )) ??
            false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: SafeArea(child: buildMyNavBar(context)),
        body: Column(
          children: [
            // FIXED HEADER: Logo + Search Bar
            Container(
              color: Colors.white,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  const SizedBox(height: 5),

                  // Logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 40,
                        width: 40,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/app_icon.png'),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 10),
                        height: 80,
                        width: 120,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo-text.png'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Container(
                      width: double.infinity,
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red.shade200),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              height: 45,
                              child: Row(
                                children: [
                                  const Icon(Icons.search, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      focusNode: FocusNode(),
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        hintText: "Search for a locality, area or city",
                                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                        border: InputBorder.none,
                                      ),
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                          const FilterSetInitialHomeCategory(0),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => filter.Filter(data: "Rent"),
                                          ),
                                        );
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (_) => const FractionallySizedBox(
                                            heightFactor: 0.95,
                                            child: LocationPickerScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // BLoC-powered property list
            Expanded(
              child: BlocBuilder<PropertiesBloc, PropertiesState>(
                builder: (context, state) {
                  // 1. Loading / Initial state
                  if (state.status == PropertiesStatus.loading ||
                      state.status == PropertiesStatus.initial) {
                    return const Center(child: ShimmerCard());
                  }

                  // 2. Error state
                  if (state.status == PropertiesStatus.error) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.errorMessage ?? "Unknown error"}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<PropertiesBloc>().add(
                                const LoadProperties(endpoint: 'properties'),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  // 3. Loaded / Loading more
                  final items = state.properties;
                  final hasMore = state.hasMore;

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PropertiesBloc>().add(RefreshProperties());
                    },
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8),
                      itemCount: items.length + (hasMore ? 1 : 0) + 1,
                      itemBuilder: (context, index) {
                        // Header (index 0) – categories, banner, sort
                        if (index == 0) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Location Suggestions (keep as is; later move to separate bloc)
                              // ... paste your location suggestions code here if you still want it ...

                              // Category Row 1
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                          const FilterSetInitialHomeCategory(0),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => filter.Filter(data: "Rent"),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.29,
                                          height: MediaQuery.of(context).size.height * 0.11,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                offset: const Offset(7, 7),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                offset: const Offset(-4, -4),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset("assets/images/ak-rent-red.png", height: 35),
                                              const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                  "Property For Rent",
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Buy
                                    GestureDetector(
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                          FilterSetInitialHomeCategory(1),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => filter.Filter(data: "Buy"),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.29,
                                          height: MediaQuery.of(context).size.height * 0.11,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                offset: const Offset(7, 7),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                offset: const Offset(-4, -4),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset("assets/images/ak-sale.png", height: 35),
                                              const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                  "Property For Sale",
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Off-Plan
                                    GestureDetector(
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                          FilterSetInitialHomeCategory(2),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => filter.Filter(data: "Buy", optionType: 'offplan'),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.height * 0.11,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                offset: const Offset(7, 7),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                offset: const Offset(-4, -4),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset("assets/images/ak-off-plan.png", height: 35),
                                              const Padding(
                                                padding: EdgeInsets.only(top: 5),
                                                child: Text(
                                                  "Off-Plan-Properties",
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, height: 1.2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Category Row 2 (Commercial, Villas, Apartment)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Row(
                                  children: [
                                    // Commercial
                                    GestureDetector(
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                          FilterSetInitialHomeCategory(3),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => filter.Filter(data: "Rent", propertyType: 1),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.29,
                                          height: MediaQuery.of(context).size.height * 0.11,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                offset: const Offset(7, 7),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                offset: const Offset(-4, -4),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset("assets/images/commercial_new.png", height: 35),
                                              const Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Text(
                                                  "Commercial",
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Villas
                                    GestureDetector(
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                          const FilterSetInitialHomeCategory(4),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => filter.Filter(
                                              data: "Rent",
                                              propertyType: 0,
                                              propertyCategoryType: 'Villa',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.height * 0.11,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                offset: const Offset(7, 7),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                offset: const Offset(-4, -4),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset("assets/images/villa-new.png", height: 35),
                                              const Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Text(
                                                  "Villas",
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Apartment
                                    GestureDetector(
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                          FilterSetInitialHomeCategory(5),
                                        );
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => filter.Filter(
                                              data: "Rent",
                                              propertyType: 0,
                                              propertyCategoryType: 'Apartment',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Container(
                                          width: MediaQuery.of(context).size.width * 0.3,
                                          height: MediaQuery.of(context).size.height * 0.11,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.8),
                                                offset: const Offset(7, 7),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                              BoxShadow(
                                                color: Colors.white.withOpacity(0.8),
                                                offset: const Offset(-4, -4),
                                                blurRadius: 8,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Image.asset("assets/images/apartment.png", height: 35),
                                              const Padding(
                                                padding: EdgeInsets.all(5),
                                                child: Text(
                                                  "Apartment",
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, height: 1.2),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Banner - New Projects
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                                child: GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => NewProjectsScreen()),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          offset: const Offset(4, 4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.8),
                                          offset: const Offset(-4, -4),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "New Projects",
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 19,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  "Discover more about the UAE real estate market",
                                                  style: TextStyle(color: Colors.black87, fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Image.asset(
                                                'assets/images/banner1.jpg',
                                                fit: BoxFit.cover,
                                                height: double.infinity,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Properties Count + Sort
                              Container(
                                margin: const EdgeInsets.only(top: 20, left: 5, right: 15),
                                height: MediaQuery.of(context).size.height * 0.05,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Text(
                                        "${state.totalProperties ?? items.length} Properties",
                                        style: const TextStyle(color: Colors.black, fontSize: 15),
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      elevation: 0,
                                      onSelected: (value) {
                                        final sortMap = {
                                          "Featured": "featured",
                                          "Newest": "newest",
                                          "Price (low)": "price_asc",
                                          "Price (high)": "price_desc",
                                        };
                                        final sortKey = sortMap[value]!;
                                        context.read<PropertiesBloc>().add(
                                          ChangeSort(sortBy: sortKey),
                                        );
                                        scrollController.jumpTo(0);
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      offset: const Offset(0, 35),
                                      color: Colors.white,
                                      itemBuilder: (context) {
                                        const sortOptions = [
                                          "Featured",
                                          "Newest",
                                          "Price (low)",
                                          "Price (high)",
                                        ];
                                        return sortOptions.map((option) {
                                          return PopupMenuItem<String>(
                                            value: option,
                                            child: Text(option),
                                          );
                                        }).toList();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.red),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.asset("assets/images/filter.png", height: 16, width: 16),
                                            const SizedBox(width: 6),
                                            Text(selectedSort),
                                            const Icon(Icons.arrow_drop_down, size: 18),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          );
                        }

                        // Property cards
                        final itemIndex = index - 1;
                        if (itemIndex < items.length) {
                          final dataItem = items[itemIndex];
                          final property = dataItem.toProperty();
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                            child: PropertyCard(item: property),
                          );
                        }

                        // Bottom loading indicator
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
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
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
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
                    backgroundColor: Colors.white,
                    title: const Text("Login Required", style: TextStyle(color: Colors.black)),
                    content: const Text("Please login to access favorites.", style: TextStyle(color: Colors.black)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginDemo()),
                          );
                        },
                        child: const Text("Login", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Fav_Logout()),
                ).then((_) async {
                  // Optional: reload favorites if needed
                });
              }
            },
            icon: const Icon(Icons.favorite_border_outlined, color: Colors.red, size: 30),
          ),

          IconButton(
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
              icon: const Icon(Icons.dehaze_outlined, color: Colors.red, size: 35),
            ),
          ),
        ],
      ),
    );
  }
}