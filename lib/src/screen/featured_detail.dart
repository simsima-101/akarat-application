// lib/screen/featured_detail.dart

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../features/property/data/repositories/property_repository.dart';
import '../features/property/presentation/bloc/detail_bloc.dart';
import 'about_agent.dart';
import 'full_map_screen.dart';
import 'htmlEpandableText.dart';

class Featured_Detail extends StatefulWidget {
  final String data;

  const Featured_Detail({super.key, required this.data});

  @override
  State<Featured_Detail> createState() => _FeaturedDetailState();
}

class _FeaturedDetailState extends State<Featured_Detail> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<DetailBloc>(
      create: (context) => DetailBloc(
        repository: PropertyRepository(),
      )..add(LoadPropertyDetail(widget.data)), // ← note widget.data
      child: BlocBuilder<DetailBloc, DetailState>(
        builder: (context, state) {
          if (state.status == DetailStatus.loading || state.detail == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.status == DetailStatus.error) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 20),
                      const Text(
                        "Unable to load property",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.errorMessage ??
                            "Please check your connection and try again.",
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<DetailBloc>()
                            .add(LoadPropertyDetail(widget.data)),
                        icon: const Icon(Icons.refresh),
                        label: const Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final Size screenSize = MediaQuery.sizeOf(context);

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(30.0),
              child: AppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.red),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                backgroundColor: const Color(0xFFFFFFFF),
                iconTheme: const IconThemeData(color: Colors.red),
              ),
            ),

            // ──────────────────────────────────────────────
            // Pull-to-refresh (very useful after language change)
            // ──────────────────────────────────────────────
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<DetailBloc>().add(LoadPropertyDetail(widget.data));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Images + full preview dialog
                    Container(
                      height: screenSize.height * 0.55,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: state.imageUrls.length,
                        itemBuilder: (context, index) {
                          final imageUrl = state.imageUrls[index];
                          return GestureDetector(
                            onTap: () {
                              showGeneralDialog(
                                context: context,
                                barrierDismissible: true,
                                barrierLabel: "ImagePreview",
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) {
                                  final controller =
                                      PageController(initialPage: index);
                                  return Scaffold(
                                    backgroundColor: Colors.black,
                                    body: SafeArea(
                                      child: Stack(
                                        children: [
                                          PageView.builder(
                                            controller: controller,
                                            itemCount: state.imageUrls.length,
                                            itemBuilder: (context, pageIndex) {
                                              final previewUrl =
                                                  state.imageUrls[pageIndex];
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
                                              icon: const Icon(Icons.close,
                                                  color: Colors.white,
                                                  size: 30),
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 200,
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ──────────────────────────────────────────────
                    // The rest of your UI stays exactly the same
                    // (address, price, beds/baths, title, location, description,
                    //  property details, building info, project info, map,
                    //  amenities, agent, regulatory, recommended)
                    // ──────────────────────────────────────────────

                    const SizedBox(height: 25),

                    // Address
                    if (state.resolvedAddress != null &&
                        state.resolvedAddress!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("📍 ", style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                state.resolvedAddress!,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Price section
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 15),
                      child: Row(
                        children: [
                          Text(
                            state.displayPrice ?? '0', // ← changed
                            style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                          const Text("  AED",
                              style:
                                  TextStyle(fontSize: 19, letterSpacing: 0.5)),
                          Text(
                            state.paymentPeriodText != null
                                ? "/${state.paymentPeriodText}"
                                : "", // ← changed
                            style: const TextStyle(
                                fontSize: 16, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),

// Beds / Baths / Size
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (state.bedsText != null) ...[
                            Image.asset("assets/images/bed.png", height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Text(
                                state.bedsText!,
                                style: const TextStyle(
                                    fontSize: 14, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                          if (state.bathsText != null) ...[
                            if (state.bedsText != null)
                              const SizedBox(width: 15),
                            Image.asset("assets/images/bath.png", height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Text(
                                state.bathsText!,
                                style: const TextStyle(
                                    fontSize: 14, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                          if (state.displaySizeSqft != null &&
                              state.displaySizeSqft!.isNotEmpty) ...[
                            if (state.bedsText != null ||
                                state.bathsText != null)
                              const SizedBox(width: 15),
                            Image.asset("assets/images/messure.png",
                                height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 3.0),
                              child: Text(
                                state.displaySizeSqft!,
                                style: const TextStyle(
                                    fontSize: 14, letterSpacing: 0.5),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

// Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        state.title ?? '',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

// Location
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 15),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 18, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            state.locationName ?? '',
                            style: const TextStyle(
                                letterSpacing: 0.5, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Description – Always visible with Read more / Read less toggle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Description",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 8),

                          // Main content container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: state.isLoadingFullDescription
                                ? const Center(
                                    child: CircularProgressIndicator())
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      HtmlExpandableText(
                                        htmlContent:
                                            (state.fullDescription ?? '')
                                                .replaceAll('\r\n', '<br>')
                                                .replaceAll('\n', '<br>'),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Property Details section (using state getters)
                    _buildPropertyDetailsSection(state),

                    // Building Information
                    _buildBuildingInformationSection(state),

                    const SizedBox(height: 5),

                    // Project Information section
                    // Project Information section
                    if (state.hasProjectInfo) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Project Information",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  if (state.completionPercentage != null)
                                    _buildProjectInfoRow("Completion",
                                        "${state.completionPercentage}%"),

                                  if (state.governmentFee != null)
                                    _buildProjectInfoRow("Government Fee",
                                        "${state.governmentFee}%"),

                                  if (state.deliveryYear != null)
                                    _buildProjectInfoRow(
                                        "Delivery Year", state.deliveryYear!),

                                  // Use paymentPeriodText (already formatted)
                                  if (state.paymentPeriodText != null &&
                                      state.paymentPeriodText!.isNotEmpty)
                                    _buildProjectInfoRow("Payment Period",
                                        state.paymentPeriodText!.toUpperCase()),

                                  if (state.projectAnnouncementDate != null)
                                    _buildProjectInfoRow(
                                        "Project Announcement",
                                        _formatDate(
                                            state.projectAnnouncementDate!)),

                                  if (state.constructionStartDate != null)
                                    _buildProjectInfoRow(
                                        "Construction Started",
                                        _formatDate(
                                            state.constructionStartDate!)),

                                  if (state.expectedCompletionDate != null)
                                    _buildProjectInfoRow(
                                        "Expected Completion",
                                        _formatDate(
                                            state.expectedCompletionDate!)),

                                  if (state.salesStartDate != null)
                                    _buildProjectInfoRow("Sales Started",
                                        _formatDate(state.salesStartDate!)),

                                  // Payment Plan – now using state.paymentPlan (correct name)
                                  if (state.paymentPlan != null &&
                                      state.paymentPlan!.isNotEmpty)
                                    Builder(
                                      builder: (_) {
                                        final plan = state.paymentPlan!;
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Divider(
                                                height: 28, thickness: 1),
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Payment Plan",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.3,
                                                  color: Colors.grey[900],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                    child: _planBox(
                                                        "${plan['down_payment'] ?? '--'}%",
                                                        "Down Payment")),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                    child: _planBox(
                                                        "${plan['during_construction'] ?? '--'}%",
                                                        "During Construction")),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                    child: _planBox(
                                                        "${plan['on_handover'] ?? '--'}%",
                                                        "On Handover")),
                                              ],
                                            ),
                                          ],
                                        );
                                      },
                                    ),

                                  // DLD Verified Project / Developer
                                  if (state.officialProjectName != null ||
                                      state.officialDeveloperName != null ||
                                      state.dldAgencyName != null) ...[
                                    if (state.officialProjectName != null)
                                      _buildProjectInfoRow(
                                          "Project", state.officialProjectName!,
                                          isBold: true),
                                    if (state.officialDeveloperName != null)
                                      _buildProjectInfoRow("Developer",
                                          state.officialDeveloperName!,
                                          isBold: true),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 15),

                    // Location & Nearby Map
                    _buildLocationAndNearbySection(context, state),

                    const SizedBox(height: 15),

                    // Amenities – Bloc managed
                    _buildAmenitiesSection(context, state),

                    const SizedBox(height: 10),

                    // Provided by (Agent)
                    _buildAgentSection(context, state),

                    const SizedBox(height: 5),

                    // Regulatory Information + QR
                    _buildRegulatorySection(context, state),

                    const SizedBox(height: 5),

                    // Recommended Properties
                    _buildRecommendedSection(state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────
  // Helper Widgets (almost identical to original)
  // ──────────────────────────────────────────────

  Widget _buildProjectInfoRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? Colors.black87 : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(BuildContext context, DetailState state) {
    final amenities = state.amenities;

    if (amenities == null || amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    const int initialCount = 6;
    final bool showButton = amenities.length > initialCount;

    final displayedAmenities = state.showAllAmenities
        ? amenities
        : amenities.take(initialCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Amenities",
            style: TextStyle(
                fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 5),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 360;

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedAmenities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 1 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: isSmallScreen ? 4.5 : 5,
              ),
              itemBuilder: (context, index) {
                final amenity = displayedAmenities[index];
                final iconUrl = amenity.icon?.trim();

                return Row(
                  children: [
                    if (iconUrl != null && iconUrl.isNotEmpty)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Image.network(
                          iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image, size: 18),
                        ),
                      )
                    else
                      const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        amenity.getTitle(
                            Localizations.localeOf(context).languageCode),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign:
                            Localizations.localeOf(context).languageCode == 'ar'
                                ? TextAlign.right
                                : TextAlign.left,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
        if (showButton)
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 10),
            child: Center(
              child: GestureDetector(
                onTap: () => context.read<DetailBloc>().add(ToggleAmenities()),
                child: Text(
                  state.showAllAmenities ? "Show less" : "Show more",
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPropertyDetailsSection(DetailState state) {
    final rows = <Widget>[];

    void addRow(String label, String? value) {
      final cleaned = _cleanStr(value);
      if (cleaned == null || cleaned.isEmpty) return;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 11.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  cleaned,
                  style: const TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── All values now come from state (pre-computed in Bloc) ──
    addRow('Property ID', state.propertyId);
    addRow('Property Type', state.propertyType);
    addRow('Size', state.displaySizeSqft);
    addRow('Listed On', state.listedOn);
    addRow('Category', state.categoryText);
    addRow('Price', state.formattedPriceWithPeriod);
    addRow('Address', state.resolvedAddress);

    if (rows.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Property Details",
            style: TextStyle(
                fontSize: 16, letterSpacing: 0.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rows,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingInformationSection(DetailState state) {
    // If none of the building fields exist → hide the whole section
    if (!state.hasBuildingInfo) {
      return const SizedBox.shrink();
    }

    Widget row(String label, String? value) {
      final cleaned = value?.trim();
      if (cleaned == null || cleaned.isEmpty) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Expanded(
              child: Text(
                cleaned,
                style: const TextStyle(
                  fontSize: 13.8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          const Text(
            "Building Information",
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                row("Building Name", state.buildingName),
                row("Total Parking Space", state.totalParking),
                row("Building Area", state.buildingArea),
                row("Year of Completion", state.yearOfCompletion),
                row("Elevators", state.elevators),
                row("Total Floors", state.totalFloors),
                row("Swimming Pools", state.swimmingPools),
                row("Retail Centers", state.retailCenters),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAndNearbySection(
      BuildContext context, DetailState state) {
    final lat = state.latitude ?? 25.0657;
    final lng = state.longitude ?? 55.2030;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Text("Location & nearby",
              style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.3, 0.3),
                  blurRadius: 0.3,
                  spreadRadius: 0.3),
              BoxShadow(
                  color: Colors.white,
                  offset: Offset(0, 0),
                  blurRadius: 0,
                  spreadRadius: 0),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: LatLng(lat, lng), zoom: 12),
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Card(
                      color: Colors.white,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.resolvedAddress ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  side: const BorderSide(
                                      color: Colors.grey, width: 0.4),
                                  elevation: 1,
                                  backgroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyGoogleMapWidget(
                                          latitude: lat, longitude: lng),
                                    ),
                                  );
                                },
                                child: const Text("View on map",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgentSection(BuildContext context, DetailState state) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Provided by",
              style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Column(
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, blurRadius: 0.1),
                    BoxShadow(color: Colors.white)
                  ],
                ),
                child: CachedNetworkImage(
                  imageUrl:
                      state.agentImageUrl ?? 'https://via.placeholder.com/100',
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  state.agentName ?? 'Agent',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  final agentId = state.agentId ?? '';
                  if (agentId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AboutAgent(data: agentId, initialTabIndex: 0),
                      ),
                    );
                  }
                },
                child: Container(
                  height: 35,
                  width: screenWidth * 0.5,
                  margin: const EdgeInsets.only(left: 15, right: 10, top: 15),
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(color: Colors.red, blurRadius: 0.5),
                      BoxShadow(color: Colors.white)
                    ],
                  ),
                  child: const Text(
                    "See Agent Details",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        letterSpacing: 0.5,
                        fontSize: 13,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegulatorySection(BuildContext context, DetailState state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 18, right: 14, top: 20, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.5, 0.5),
            blurRadius: 1,
            spreadRadius: 0.3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + DLD Verified badge
          Row(
            children: [
              const Text(
                "Regulatory Information",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              if (state.dldPermitNumber != null || state.dldAgencyName != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "DLD Verified",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // All regulatory rows – only show if value exists
          _buildInfoRowIfNotNull("DLD Permit Number", state.dldPermitNumber),
          _buildInfoRowIfNotNull("Zone", state.zoneName),
          _buildInfoRowIfNotNull("DED", state.ded),
          _buildInfoRowIfNotNull("RERA", state.rera),
          _buildInfoRowIfNotNull("BRN", state.brn),
          _buildInfoRowIfNotNull("Registered Agency", state.dldAgencyName),

          const SizedBox(height: 16),

          // QR Code – only show if base64 exists
          if (state.hasQrCode) ...[
            const Text(
              "RERA QR Code",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  base64Decode(state.qrCodeBase64!),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.qr_code, size: 80),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

// Helper method – only builds row if value is non-null and non-empty
  Widget _buildInfoRowIfNotNull(String label, String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: _buildInfoRow(label, cleaned),
    );
  }

  // Helper: clean string (same logic as old _cleanStr)
  String? _cleanStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  Widget _buildRecommendedSection(DetailState state) {
    // Use the pre-computed list from Bloc state
    if (state.recommendedProperties.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 17),
          child: Row(
            children: const [
              Text(
                "Recommended Properties",
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        Gap(8),
        SizedBox(
          height: 260,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.recommendedProperties.length,
            itemBuilder: (context, index) {
              final rec = state.recommendedProperties[index];

              return Container(
                width: 300,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Card(
                  color: Colors.white,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Featured_Detail(data: rec.id),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: rec.imageUrl,
                            height: 130,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: Colors.grey[300],
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              height: 130,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  size: 50),
                            ),
                          ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Price (pre-formatted in Bloc)
                              Text(
                                'AED ${rec.displayPrice}',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Beds / Baths / Size (all pre-computed)
                              SizedBox(
                                height: 30,
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  child: Row(
                                    children: [
                                      if (rec.beds > 0) ...[
                                        _buildFeatureItem(
                                          Icons.king_bed_outlined,
                                          '${rec.beds} bed${rec.beds > 1 ? 's' : ''}',
                                        ),
                                        const SizedBox(width: 16),
                                      ],
                                      if (rec.baths > 0) ...[
                                        _buildFeatureItem(
                                          Icons.bathtub_outlined,
                                          '${rec.baths} bath${rec.baths > 1 ? 's' : ''}',
                                        ),
                                        const SizedBox(width: 16),
                                      ],
                                      if (rec.displaySize.isNotEmpty) ...[
                                        _buildFeatureItem(
                                          Icons.square_foot,
                                          rec.displaySize,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Location (pre-cleaned in Bloc)
                              Text(
                                rec.location,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  // Reusable small helpers (kept from original)
  // ──────────────────────────────────────────────

  Widget _planBox(String value, String label) {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: 0.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12.8,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: Colors.redAccent),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  String _formatPrice(String? price) {
    if (price == null || price == 'null') return '0';
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    final number = double.tryParse(cleaned);
    if (number == null) return price;
    return NumberFormat('#,##0').format(number);
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final cleaned = date.split(' ').first;
      final parsed = DateTime.parse(cleaned);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (e) {
      return date;
    }
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130,
              child: Text("$title:",
                  style: const TextStyle(fontSize: 13, letterSpacing: 0.5))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontSize: 13, letterSpacing: 0.5))),
        ],
      ),
    );
  }
}
