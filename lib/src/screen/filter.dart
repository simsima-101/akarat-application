import 'dart:async';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../features/property/presentation/bloc/filter_bloc.dart';
import '../providers/filter_provider.dart';
import '../providers/location_picker_provider.dart';
import 'filter_list.dart' hide Data;
import 'full_amenities_screen.dart';
import 'location_picker_screen.dart';

class Filter extends StatelessWidget {
  final dynamic data;
  final int? propertyType;
  final String? propertyCategoryType;
  final String? optionType;
  const Filter({
    super.key,
    required this.data,
    this.propertyType,
    this.propertyCategoryType,
    this.optionType,
  });

  @override
  Widget build(BuildContext context) {
    return FilterDemo(
      data: data,
      propertyType: propertyType,
      propertyCategoryType: propertyCategoryType,
      optionType: optionType,
    ); // ✅ No MaterialApp — just return the screen
  }
}

class FilterDemo extends StatefulWidget {
  final dynamic data;
  final int? propertyType;
  final String? propertyCategoryType;
  final String? optionType;

  const FilterDemo(
      {super.key,
      required this.data,
      this.optionType,
      this.propertyType,
      this.propertyCategoryType});

  @override
  _FilterDemoState createState() => _FilterDemoState();
}

class _FilterDemoState extends State<FilterDemo> {
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();

    // Apply incoming filters from Home screen categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<FilterBloc>();

      // Example: if coming from "Buy" with off-plan
      if (widget.data == "Buy") {
        if (widget.optionType == 'offplan') {
          // Buy + Off-Plan
          bloc.add(const SelectProduct(1)); // Buy
          bloc.add(const SelectCompletionStatus(1)); // Assuming index 1 = Off-Plan
        } else {
          bloc.add(const SelectProduct(1)); // Just Buy
        }
      } else if (widget.data == "Rent") {
        bloc.add(const SelectProduct(0)); // Rent
      }

      // Property Type (Commercial = 1)
      if (widget.propertyType == 1) {
        bloc.add(const SelectPropertyType(1));
      }

      // Property Category (Villa, Apartment, etc.)
      if (widget.propertyCategoryType != null) {
        bloc.add(SelectPropertyCategory(widget.propertyCategoryType));
      }

      bloc.add(const LoadAmenities());
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);



    return BlocBuilder<FilterBloc, FilterState>(
        builder: (context, state) {
          // Local constants
          const int rentIndex = 0;
          const int buyIndex = 1;

          final bool isNewProjects = state.selectedTab == 1;
          final bool isProperties = state.selectedTab == 0;
          final bool isOffPlan = state.selectedCompletionIndex ==
              1; // Adjust index if needed

          final bool showProductPills = isProperties;
          final bool showRentPaid = isProperties &&
              state.selectedProductIndex == rentIndex;
          final bool showHandoverBy = isNewProjects ||
              (isProperties && state.selectedProductIndex == buyIndex &&
                  isOffPlan);
          final bool isBuyMode = isProperties &&
              state.selectedProductIndex == buyIndex;

          return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: AppBar(
                  surfaceTintColor: const Color(0xFFF9F9F9),
                  backgroundColor: const Color(0xFFF9F9F9),
                  elevation: 0,
                  centerTitle: true,
                  title: const Text(
                    "Filters",
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  actions: [
                    Builder(
                      builder: (context) {
                        return TextButton(
                          onPressed: state.hasChanges
                              ? () {
                            context.read<FilterBloc>().add(const ResetFilter());
                          }
                              : null,
                          child: state.isLoading
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.red),
                            ),
                          )
                              : Text(
                            "Reset",
                            style: TextStyle(
                              color: state.hasChanges ? Colors.red : Colors
                                  .grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                body: Stack(
                  children: [
                    // Scrollable content
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          // Tab Switcher: Properties vs New Projects
                          Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFF5F4F9), Color(0xFFF5F4F9)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      context.read<FilterBloc>().add(
                                          const SwitchTab(0)),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 180,
                                    height: 45,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: state.selectedTab == 0
                                          ? const Color(0xFF3A7CED)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4),
                                        BoxShadow(
                                            color: Colors.white.withOpacity(
                                                0.8),
                                            offset: const Offset(-4, -4),
                                            blurRadius: 8,
                                            spreadRadius: 2),
                                      ],
                                    ),
                                    child: Text(
                                      "Properties",
                                      style: TextStyle(
                                        color: state.selectedTab == 0 ? Colors
                                            .white : Colors.black,
                                        letterSpacing: 0.5,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () =>
                                      context.read<FilterBloc>().add(
                                          const SwitchTab(1)),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    width: 180,
                                    height: 45,
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 5),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    decoration: BoxDecoration(
                                      color: state.selectedTab == 1
                                          ? const Color(0xFF3A7CED)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4),
                                        BoxShadow(
                                            color: Colors.white.withOpacity(
                                                0.8),
                                            offset: const Offset(-4, -4),
                                            blurRadius: 8,
                                            spreadRadius: 2),
                                      ],
                                    ),
                                    child: Text(
                                      "New Projects",
                                      style: TextStyle(
                                        color: state.selectedTab == 1 ? Colors
                                            .white : Colors.black,
                                        letterSpacing: 0.5,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Rent / Buy Pills
                          if (showProductPills)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: SizedBox(
                                  height: 60,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: ['Rent', 'Buy']
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      final int index = entry.key;
                                      final String label = entry.value;
                                      final bool isSelected = state
                                          .selectedProductIndex == index;

                                      return GestureDetector(
                                        onTap: () =>
                                            context.read<FilterBloc>().add(
                                                SelectProduct(index)),
                                        child: Container(
                                          width: 180,
                                          height: 34,
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 5),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          decoration: BoxDecoration(
                                            color: isSelected ? const Color(
                                                0xFFF5F4F9) : Colors.white,
                                            border: Border.all(color: isSelected
                                                ? Colors.black
                                                : Colors.transparent, width: 1),
                                            borderRadius: BorderRadius.circular(
                                                12),
                                            boxShadow: [
                                              BoxShadow(color: Colors.grey
                                                  .withOpacity(0.5),
                                                  offset: const Offset(0, 2),
                                                  blurRadius: 4),
                                              BoxShadow(color: Colors.white
                                                  .withOpacity(0.8),
                                                  offset: const Offset(-4, -4),
                                                  blurRadius: 8,
                                                  spreadRadius: 2),
                                            ],
                                          ),
                                          child: Text(label,
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 14)),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),
                          const Divider(height: 1, indent: 15, endIndent: 15),
                          const SizedBox(height: 20),

                          // Location Picker (simplified – you can expand with Bloc if needed)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Location", style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 13),
                                SizedBox(
                                  height: 48,
                                  child: TextFormField(
                                    readOnly: true,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        builder: (_) =>
                                        const FractionallySizedBox(
                                          heightFactor: 0.95,
                                          child: LocationPickerScreen(),
                                        ),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(
                                          Icons.place, color: Colors.redAccent,
                                          size: 26),
                                      hintText: 'Search locations',
                                      hintStyle: const TextStyle(
                                          color: Colors.black54, fontSize: 16),
                                      filled: true,
                                      fillColor: Colors.white,
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              5),
                                          borderSide: const BorderSide(
                                              color: Colors.grey)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              5),
                                          borderSide: const BorderSide(
                                              color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                              ],
                            ),
                          ),

                          const Divider(height: 1, indent: 15, endIndent: 15),
                          const SizedBox(height: 20),

                          // Property Type (Residential / Commercial)
                          const Padding(
                            padding: EdgeInsets.only(left: 18),
                            child: Text("Property Type", style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      context.read<FilterBloc>().add(
                                          const SelectPropertyType(0)),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: state.propertyType == 0
                                          ? const LinearGradient(colors: [
                                        Color(0xFFF5F4F9),
                                        Color(0xFFEFEFF3)
                                      ])
                                          : null,
                                      color: state.propertyType == 0
                                          ? null
                                          : Colors.white,
                                      border: Border.all(
                                          color: state.propertyType == 0
                                              ? Colors.black
                                              : const Color(0xFFE6E4EE)),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12,
                                            offset: Offset(0, 3),
                                            blurRadius: 6),
                                        BoxShadow(color: Colors.white,
                                            offset: Offset(-2, -2),
                                            blurRadius: 6,
                                            spreadRadius: 2),
                                      ],
                                    ),
                                    child: const Text('Residential',
                                        style: TextStyle(fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      context.read<FilterBloc>().add(
                                          const SelectPropertyType(1)),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      gradient: state.propertyType == 1
                                          ? const LinearGradient(colors: [
                                        Color(0xFFF5F4F9),
                                        Color(0xFFEFEFF3)
                                      ])
                                          : null,
                                      color: state.propertyType == 1
                                          ? null
                                          : Colors.white,
                                      border: Border.all(
                                          color: state.propertyType == 1
                                              ? Colors.black
                                              : const Color(0xFFE6E4EE)),
                                      borderRadius: BorderRadius.circular(14),
                                      boxShadow: const [
                                        BoxShadow(color: Colors.black12,
                                            offset: Offset(0, 3),
                                            blurRadius: 6),
                                        BoxShadow(color: Colors.white,
                                            offset: Offset(-2, -2),
                                            blurRadius: 6,
                                            spreadRadius: 2),
                                      ],
                                    ),
                                    child: const Text('Commercial',
                                        style: TextStyle(fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),

                          if (state.propertyType != null) ...[
                            const SizedBox(height: 10),
                            AnimatedOpacity(
                              opacity: state.isLoading ? 0.0 : 1.0,
                              // Assuming you have isLoading in state for this
                              duration: const Duration(milliseconds: 500),
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                height: screenSize.height * 0.125,
                                child: state.propertyTypeModel == null
                                    ? const Center(
                                    child: CupertinoActivityIndicator())
                                    : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: state.propertyTypeModel!.data
                                      ?.length ?? 0,
                                  itemBuilder: (context, index) {
                                    final item = state.propertyTypeModel!
                                        .data![index];
                                    final bool isSelected = state
                                        .propertyCategory == item.name;

                                    return GestureDetector(
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                          SelectPropertyCategory(item.name),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 5),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(
                                              0xFFEEEEEE) : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              8),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                  0.5),
                                              offset: const Offset(0, 2),
                                              blurRadius: 4,
                                            ),
                                            BoxShadow(
                                              color: Colors.white.withOpacity(
                                                  0.8),
                                              offset: const Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                  5.0),
                                              child: CachedNetworkImage(
                                                imageUrl: item.icon ?? '',
                                                height: 37,
                                                width: 37,
                                                placeholder: (context, url) =>
                                                const SizedBox(
                                                  width: 37,
                                                  height: 37,
                                                  child: CupertinoActivityIndicator(
                                                      radius: 12),
                                                ),
                                                errorWidget: (context, url,
                                                    error) =>
                                                const Icon(
                                                  Icons.broken_image,
                                                  size: 37,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(
                                                  5.0),
                                              child: Text(
                                                item.name ?? '',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  letterSpacing: 0.5,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                          // const Divider(height: 1,indent: 15,endIndent: 15,),
                          const SizedBox(height: 20),

                          // --- Completion Status ---
                          if (isBuyMode && state.selectedTab == 0) ...[
                            Padding(
                              padding: const EdgeInsets.only(right: 100),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Completion Status',
                                    style: TextStyle(fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 15),

                                  // Pills row (scrollable if needed)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: List.generate(
                                        state.completion.length,
                                        // assuming you have a list in state
                                            (i) {
                                          final bool isSelected = state
                                              .selectedCompletionIndex == i;

                                          return GestureDetector(
                                            onTap: () {
                                              context.read<FilterBloc>().add(
                                                  SelectCompletionStatus(i));
                                            },
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                  minHeight: 34),
                                              padding: const EdgeInsets
                                                  .symmetric(horizontal: 20),
                                              margin: const EdgeInsets.only(
                                                  right: 10),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: isSelected ? const Color(
                                                    0xFFF5F4F9) : Colors.white,
                                                border: Border.all(
                                                  color: isSelected ? Colors
                                                      .black : const Color(
                                                      0xFFE6E4EE),
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius
                                                    .circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey
                                                        .withOpacity(0.15),
                                                    offset: const Offset(0, 2),
                                                    blurRadius: 4,
                                                    spreadRadius: 0,
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    offset: const Offset(
                                                        -2, -2),
                                                    blurRadius: 6,
                                                    spreadRadius: 2,
                                                  ),
                                                ],
                                              ),
                                              child: Text(
                                                state.completion[i],
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  letterSpacing: 0.2,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          const Divider(
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                          const SizedBox(height: 20),
                          //text
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "Price range",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          Padding(
                              padding: const EdgeInsets.only(
                                  top: 0, left: 20, right: 10),
                              child: Row(spacing: 15, children: [
                                Container(
                                  width: screenSize.width * 0.38,
                                  height: 40,
                                  padding: const EdgeInsets.only(
                                      top: 8, left: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadiusDirectional
                                        .circular(6.0),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none),
                                      initialValue: state.minPrice
                                          .toStringAsFixed(0),
                                      // Use state value
                                      onChanged: (value) {
                                        final double? parsed = double.tryParse(
                                            value);
                                        if (parsed == null) return;

                                        final double newMin = parsed;
                                        final double currentMax = state
                                            .maxPrice;

                                        // Only update if new min is <= current max
                                        if (newMin <= currentMax) {
                                          context.read<FilterBloc>().add(
                                            UpdatePriceRange(
                                                newMin, currentMax),
                                          );
                                        }
                                      },
                                      // Optional: Sync slider when user finishes typing
                                      onEditingComplete: () {
                                        // Force slider to match if user typed a valid value
                                        final double? parsed = double.tryParse(
                                          state.minPrice.toStringAsFixed(0),
                                        );
                                        if (parsed != null) {
                                          context.read<FilterBloc>().add(
                                            UpdatePriceRange(
                                                parsed, state.maxPrice),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    "to",
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 15.0),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  width: screenSize.width * 0.38,
                                  height: 40,
                                  padding: const EdgeInsets.only(
                                      top: 8, left: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadiusDirectional
                                        .circular(6.0),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                          border: InputBorder.none),
                                      initialValue: state.maxPrice
                                          .toStringAsFixed(0),
                                      // Sync from state
                                      onChanged: (value) {
                                        final double? parsed = double.tryParse(
                                            value);
                                        if (parsed == null) return;

                                        final double newMax = parsed;
                                        final double currentMin = state
                                            .minPrice;

                                        // Only update if new max >= current min
                                        if (newMax >= currentMin) {
                                          context.read<FilterBloc>().add(
                                            UpdatePriceRange(
                                                currentMin, newMax),
                                          );
                                        }
                                      },
                                      // Optional: Ensure slider syncs when user presses "Done"
                                      onEditingComplete: () {
                                        final double? parsed = double.tryParse(
                                            state.maxPrice.toStringAsFixed(0));
                                        if (parsed != null) {
                                          context.read<FilterBloc>().add(
                                            UpdatePriceRange(
                                                state.minPrice, parsed),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ])),
                          const SizedBox(height: 20),
                          //rangeslider
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: SfRangeSelectorTheme(
                              data: SfRangeSelectorThemeData(
                                overlappingTooltipStrokeColor: Color(
                                    0x80E0E0E0),
                                tooltipBackgroundColor: Colors.black,
                                activeDividerStrokeWidth: 1,
                                activeDividerRadius: 2,
                                thumbStrokeWidth: 0.5,
                                // Change tooltip background color
                                tooltipTextStyle: TextStyle(
                                  color: Colors.white,
                                  // Change tooltip text color
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: SfRangeSelectorTheme(
                                data: SfRangeSelectorThemeData(
                                  overlappingTooltipStrokeColor: const Color(
                                      0x80E0E0E0),
                                  tooltipBackgroundColor: Colors.black,
                                  activeDividerStrokeWidth: 1,
                                  activeDividerRadius: 2,
                                  thumbStrokeWidth: 0.5,
                                  tooltipTextStyle: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: SfRangeSelector(
                                  min: 500,
                                  max: 300000,
                                  interval: 10000,
                                  activeColor: const Color(0xFF2575D4),
                                  inactiveColor: const Color(0x80F1EEEE),
                                  enableTooltip: true,
                                  shouldAlwaysShowTooltip: true,
                                  initialValues: SfRangeValues(
                                      state.minPrice, state.maxPrice),
                                  // Sync from state
                                  tooltipTextFormatterCallback: (actualValue,
                                      _) =>
                                  'AED ${actualValue.toInt()}',
                                  onChanged: (SfRangeValues newValues) {
                                    // Dispatch event to update Bloc state
                                    context.read<FilterBloc>().add(
                                      UpdatePriceRange(
                                        newValues.start as double,
                                        newValues.end as double,
                                      ),
                                    );
                                  },
                                  child: SizedBox(
                                    height: 60,
                                    width: double.infinity,
                                    child: SfCartesianChart(
                                      backgroundColor: Colors.transparent,
                                      plotAreaBorderColor: Colors.transparent,
                                      margin: const EdgeInsets.all(0),
                                      primaryXAxis: const NumericAxis(
                                        minimum: 500,
                                        maximum: 300000, // Match range max
                                        isVisible: false,
                                      ),
                                      primaryYAxis: const NumericAxis(
                                          isVisible: false),
                                      plotAreaBorderWidth: 0,
                                      plotAreaBackgroundColor: Colors
                                          .transparent,
                                      series: <ColumnSeries<ChartData, double>>[
                                        ColumnSeries<ChartData, double>(
                                          trackColor: Colors.transparent,
                                          dataSource: state.chartData,
                                          // Use chartData from state
                                          selectionBehavior: SelectionBehavior(
                                            unselectedOpacity: 0.0,
                                            selectedColor: Colors.transparent,
                                            selectedOpacity: 0.0,
                                            unselectedColor: Colors.transparent,
                                          ),
                                          xValueMapper: (ChartData data,
                                              _) => data.x,
                                          yValueMapper: (ChartData data,
                                              _) => data.y,
                                          pointColorMapper: (ChartData data,
                                              _) =>
                                          const Color.fromARGB(
                                              255, 37, 117, 212),
                                          dashArray: const <double>[5, 3],
                                          animationDuration: 0,
                                          borderWidth: 0,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                // child:  Text(_values.start.toStringAsFixed(2),
                                child: Text(
                                  "Bedrooms",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          //studio
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              height: 60,
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                scrollDirection: Axis.horizontal,
                                itemCount: state.bedroomList.length,
                                itemBuilder: (context, index) {
                                  final String bedroom = state
                                      .bedroomList[index];
                                  final bool isSelected = state.selectedBedrooms
                                      .contains(bedroom);

                                  return GestureDetector(
                                    onTap: () {
                                      context.read<FilterBloc>().add(
                                          ToggleBedroom(bedroom));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black87
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                                0.8),
                                            offset: const Offset(-4, -4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          if (isSelected) ...[
                                            const Icon(Icons.check, size: 18,
                                                color: Colors.green),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            bedroom,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                // child:  Text(bedroom,
                                child: Text(
                                  "Bathrooms",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: state.bathroomList.length,
                                itemBuilder: (context, index) {
                                  final String bathroom = state
                                      .bathroomList[index];
                                  final bool isSelected = state
                                      .selectedBathrooms.contains(bathroom);

                                  return GestureDetector(
                                    onTap: () {
                                      context.read<FilterBloc>().add(
                                          ToggleBathroom(bathroom));
                                    },
                                    child: Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black87
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(4, 4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                                0.8),
                                            offset: const Offset(-4, -4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment
                                            .center,
                                        children: [
                                          if (isSelected) ...[
                                            const Icon(Icons.check, size: 18,
                                                color: Colors.green),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            bathroom,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                          const SizedBox(height: 20),
                          //area
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  "Area/Size",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20),
                                child: Row(
                                  children: [
                                    // Minimum area input
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.only(left: 8),
                                        decoration: _inputBoxDecoration(),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          initialValue: state.minArea
                                              .toStringAsFixed(0),
                                          // Sync from Bloc state
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Min',
                                            hintStyle: TextStyle(
                                                color: Colors.grey),
                                          ),
                                          onChanged: (value) {
                                            final double? newMin = double
                                                .tryParse(value);
                                            if (newMin == null) return;

                                            // Only update if new min <= current max
                                            if (newMin <= state.maxArea) {
                                              context.read<FilterBloc>().add(
                                                UpdateAreaRange(
                                                    newMin, state.maxArea),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                          "to", style: TextStyle(fontSize: 15)),
                                    ),
                                    // Maximum area input
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        padding: const EdgeInsets.only(left: 8),
                                        decoration: _inputBoxDecoration(),
                                        child: TextFormField(
                                          keyboardType: TextInputType.number,
                                          initialValue: state.maxArea
                                              .toStringAsFixed(0),
                                          // Sync from Bloc state
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Max',
                                            hintStyle: TextStyle(
                                                color: Colors.grey),
                                          ),
                                          onChanged: (value) {
                                            final double? newMax = double
                                                .tryParse(value);
                                            if (newMax == null) return;

                                            // Only update if new max >= current min
                                            if (newMax >= state.minArea) {
                                              context.read<FilterBloc>().add(
                                                UpdateAreaRange(
                                                    state.minArea, newMax),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Slider
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5),
                                child: SfRangeSelectorTheme(
                                  data: SfRangeSelectorThemeData(
                                    tooltipBackgroundColor: Colors.black,
                                    tooltipTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  child: SfRangeSelectorTheme(
                                    data: SfRangeSelectorThemeData(
                                      tooltipBackgroundColor: Colors.black,
                                      tooltipTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    child: SfRangeSelector(
                                      min: 0,
                                      max: 10000,
                                      interval: 1000,
                                      enableTooltip: true,
                                      shouldAlwaysShowTooltip: true,
                                      activeColor: const Color(0xFF2575D4),
                                      inactiveColor: const Color(0x80F1EEEE),
                                      initialValues: SfRangeValues(
                                          state.minArea, state.maxArea),
                                      // Sync from state
                                      tooltipTextFormatterCallback: (
                                          actualValue, _) =>
                                      '${actualValue.toInt()} sqft',
                                      onChanged: (SfRangeValues newValues) {
                                        // Dispatch Bloc event directly
                                        context.read<FilterBloc>().add(
                                          UpdateAreaRange(
                                            newValues.start as double,
                                            newValues.end as double,
                                          ),
                                        );
                                      },
                                      child: SizedBox(
                                        height: 70,
                                        width: double.infinity,
                                        child: SfCartesianChart(
                                          plotAreaBorderColor: Colors
                                              .transparent,
                                          margin: const EdgeInsets.all(0),
                                          primaryXAxis: const NumericAxis(
                                            minimum: 0,
                                            maximum: 10000,
                                            isVisible: false,
                                          ),
                                          primaryYAxis: const NumericAxis(
                                              isVisible: false),
                                          plotAreaBorderWidth: 0,
                                          plotAreaBackgroundColor: Colors
                                              .transparent,
                                          series: <ColumnSeries<ChartDataArea,
                                              double>>[
                                            ColumnSeries<ChartDataArea, double>(
                                              dataSource: state.chartDataArea,
                                              // Use from state
                                              selectionBehavior: SelectionBehavior(
                                                unselectedOpacity: 0,
                                                selectedOpacity: 0,
                                                unselectedColor: Colors
                                                    .transparent,
                                              ),
                                              xValueMapper: (ChartDataArea data,
                                                  _) => data.x,
                                              yValueMapper: (ChartDataArea data,
                                                  _) => data.y,
                                              pointColorMapper: (
                                                  ChartDataArea data, _) =>
                                              const Color.fromARGB(
                                                  255, 37, 117, 212),
                                              dashArray: const <double>[5, 3],
                                              animationDuration: 0,
                                              borderWidth: 0,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                          const SizedBox(height: 20),
                          //furnished
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  "Furnished Type",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              height: 60,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: const ScrollPhysics(),
                                itemCount: state.furnishedTypes.length,
                                itemBuilder: (context, index) {
                                  final isSelected = state
                                      .selectedFurnishedIndex == index;

                                  return GestureDetector(
                                    onTap: () {
                                      context.read<FilterBloc>().add(
                                          SelectFurnishedType(index));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black87
                                              : Colors.grey.shade300,
                                          width: isSelected ? 2 : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            offset: const Offset(4, 4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                                0.8),
                                            offset: const Offset(-4, -4),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (isSelected) ...[
                                            const Icon(Icons.check, size: 18,
                                                color: Colors.green),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            state.furnishedTypes[index],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              letterSpacing: 0.5,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                          const SizedBox(height: 20),

                          // --- Completion Status ---
                          if (showHandoverBy) ...[
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Handover By',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 15),

                                  // ✅ Handover By chips (4 visible + scrollable)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      const double spacing = 10;
                                      final double chipWidth = (constraints
                                          .maxWidth - (spacing * 3)) /
                                          4; // 4 chips visible

                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: List.generate(
                                            state.handoverOptions.length,
                                                (i) {
                                              final bool isSelected = state
                                                  .selectedHandoverIndex == i;

                                              return Container(
                                                width: chipWidth,
                                                margin: EdgeInsets.only(
                                                  right: i ==
                                                      state.handoverOptions
                                                          .length - 1
                                                      ? 0
                                                      : spacing,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<FilterBloc>()
                                                        .add(SelectHandover(i));
                                                  },
                                                  child: Container(
                                                    constraints: const BoxConstraints(
                                                        minHeight: 34),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? const Color(
                                                          0xFFF5F4F9)
                                                          : Colors.white,
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? Colors.black
                                                            : const Color(
                                                            0xFFE6E4EE),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius
                                                          .circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                              0.15),
                                                          offset: const Offset(
                                                              0, 2),
                                                          blurRadius: 4,
                                                          spreadRadius: 0,
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                          offset: const Offset(
                                                              -2, -2),
                                                          blurRadius: 6,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      state.handoverOptions[i],
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        letterSpacing: 0.2,
                                                        color: Colors.black,
                                                      ),
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: 20,
                            ),

                            // % Completion (under Handover By)
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '% Completion',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 15),

                                  // 4 visible + scrollable, same as Handover By
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      const double spacing = 10;
                                      final double chipWidth = (constraints
                                          .maxWidth - (spacing * 3)) /
                                          4; // 4 chips visible at once

                                      return SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: List.generate(
                                            state.percentCompletionOptions
                                                .length,
                                                (i) {
                                              final bool isSelected = state
                                                  .selectedPercentCompletionIndex ==
                                                  i;

                                              return Container(
                                                width: chipWidth,
                                                margin: EdgeInsets.only(
                                                  right: i == state
                                                      .percentCompletionOptions
                                                      .length - 1 ? 0 : spacing,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    context
                                                        .read<FilterBloc>()
                                                        .add(
                                                        SelectPercentCompletion(
                                                            i));
                                                  },
                                                  child: Container(
                                                    constraints: const BoxConstraints(
                                                        minHeight: 34),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 8),
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? const Color(
                                                          0xFFF5F4F9)
                                                          : Colors.white,
                                                      border: Border.all(
                                                        color: isSelected
                                                            ? Colors.black
                                                            : const Color(
                                                            0xFFE6E4EE),
                                                        width: 1,
                                                      ),
                                                      borderRadius: BorderRadius
                                                          .circular(12),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                              0.15),
                                                          offset: const Offset(
                                                              0, 2),
                                                          blurRadius: 4,
                                                          spreadRadius: 0,
                                                        ),
                                                        BoxShadow(
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                          offset: const Offset(
                                                              -2, -2),
                                                          blurRadius: 6,
                                                          spreadRadius: 2,
                                                        ),
                                                      ],
                                                    ),
                                                    child: Text(
                                                      state
                                                          .percentCompletionOptions[i],
                                                      textAlign: TextAlign
                                                          .center,
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        letterSpacing: 0.2,
                                                        color: Colors.black,
                                                      ),
                                                      overflow: TextOverflow
                                                          .ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(
                              height: 15,
                            ),

                            const Divider(
                              height: 1,
                              indent: 15,
                              endIndent: 15,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                          ],

                          Padding(
                            padding: EdgeInsets.only(left: 15, right: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 5),
                                  child: Text(
                                    "Agent or Agency",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                const SizedBox(height: 13),
                                SizedBox(
                                  height: 48,
                                  width: double.infinity,
                                  child: TextFormField(
                                    // Use Bloc to get current value and update on change
                                    initialValue: state.agentOrAgencySearchText,
                                    onChanged: (value) {
                                      context.read<FilterBloc>().add(
                                          UpdateAgentOrAgencySearch(value));
                                    },
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    decoration: InputDecoration(
                                      labelStyle: const TextStyle(
                                          color: Colors.black),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets
                                          .symmetric(
                                          vertical: 10, horizontal: 8),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.red, width: 1),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.5),
                                      ),
                                      hintText: 'Search agent or agency by name',
                                      hintStyle: const TextStyle(
                                          color: Colors.black54,
                                          fontSize: 14.7),
                                    ),
                                    cursorColor: Colors.redAccent,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),

                          const Divider(
                            height: 1,
                            indent: 15,
                            endIndent: 15,
                          ),
                          SizedBox(
                            height: 8,
                          ),

                          // --- Amenities (always for Properties) ---
                          const SizedBox(height: 15),
                          Row(
                            children: const [
                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(
                                  "Amenities",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: state.isLoading && state.amenities.isEmpty
                                ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(30),
                                child: CircularProgressIndicator(),
                              ),
                            )
                                : state.amenities.isEmpty
                                ? const Center(
                              child: Text(
                                'No amenities available',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            )
                                : GridView.builder(
                              itemCount: state.amenities.length > 5
                                  ? 5
                                  : state.amenities.length,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 4,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemBuilder: (context, index) {
                                final amenity = state.amenities[index];
                                final bool isSelected = state
                                    .selectedAmenitiesIds
                                    .contains(amenity.id);

                                return GestureDetector(
                                  onTap: () {
                                    context.read<FilterBloc>().add(
                                      ToggleAmenity(amenity.id),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.black87
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 3,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Row(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl:
                                          amenity.icon ?? '',
                                          width: 18,
                                          height: 18,
                                          placeholder:
                                              (context, url) =>
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child:
                                            CircularProgressIndicator(
                                                strokeWidth: 2),
                                          ),
                                          errorWidget: (context, url,
                                              error) =>
                                          const Icon(
                                              Icons.broken_image,
                                              size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            amenity.title ?? '',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight:
                                              FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // "Show more amenities" button
                          if (state.amenities.length > 6)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: TextButton(
                                onPressed: () async {
                                  // Precache images for smoother experience in full screen
                                  await Future.wait(
                                    state.amenities.map((a) async {
                                      final url = a.icon;
                                      if (url != null && url.isNotEmpty) {
                                        try {
                                          final provider =
                                          CachedNetworkImageProvider(url);
                                          await precacheImage(provider, context);
                                        } catch (_) {}
                                      }
                                    }),
                                  );

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullAmenitiesScreen(
                                        allAmenities: state.amenities,
                                        selectedAmenitiesIds:
                                        state.selectedAmenitiesIds,
                                        onDone: (List<int> selectedIds) {
                                          context.read<FilterBloc>().add(
                                            UpdateSelectedAmenities(
                                                selectedIds),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Show more amenities",
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),

                          if (!isBuyMode) ...[
                            const SizedBox(height: 10),
                            const Divider(height: 1, indent: 15, endIndent: 15),
                            const SizedBox(height: 20),
                          ],

                          //real estate
                          // --- Rent is paid (conditional) ---
                          if (showRentPaid) ...[
                            Row(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(left: 20),
                                  child: Text(
                                    "Rent is paid",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.all(5),
                              child: SizedBox(
                                height: 60,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const ScrollPhysics(),
                                  itemCount: state.rentPaidOptions.length,
                                  itemBuilder: (context, index) {
                                    final bool isSelected = state
                                        .selectedRentPaidIndex == index;

                                    return GestureDetector(
                                      onTap: () {
                                        context.read<FilterBloc>().add(
                                            SelectRentPaid(index));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(5),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.black87
                                                : Colors.grey.shade300,
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.grey,
                                              offset: Offset(4, 4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                            BoxShadow(
                                              color: Colors.white,
                                              offset: Offset(-4, -4),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                          borderRadius: BorderRadius.circular(
                                              8),
                                        ),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isSelected) ...[
                                              const Icon(Icons.check, size: 18,
                                                  color: Colors.green),
                                              const SizedBox(width: 4),
                                            ],
                                            Text(
                                              state.rentPaidOptions[index],
                                              style: const TextStyle(
                                                color: Colors.black,
                                                letterSpacing: 0.5,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            // Divider and spacing only when Rent Paid section is visible
                            const SizedBox(height: 20),
                            const Divider(height: 1, indent: 15, endIndent: 15),
                            const SizedBox(height: 8),
                          ],

                          // Small spacing before the always-visible CTA
                          const SizedBox(height: 8),

                          /// SHOW RESULTS BUTTON - Pure Bloc version
                          GestureDetector(
                            onTap: state.isSearchingResults
                                ? null // Disable while loading
                                : () {
                              context.read<FilterBloc>().add(
                                ShowFilterResults(context),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 25.0, left: 15, bottom: 15, right: 15),
                              child: Container(
                                width: screenSize.width * 0.9,
                                height: 45,
                                decoration: BoxDecoration(
                                  color: state.isSearchingResults
                                      ? Colors.grey
                                      : Colors.red,
                                  borderRadius: BorderRadius.circular(6.0),
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
                                child: Center(
                                  child: state.isSearchingResults
                                      ? const CupertinoActivityIndicator(
                                    radius: 14,
                                    color: Colors.white,
                                  )
                                      : const Text(
                                    "Showing Results",
                                    style: TextStyle(
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ),



                          const SizedBox(height: 90),
                          Container(height: 10),
                        ], // End of Column children
                      ), // End of SingleChildScrollView
                    ), // End of Stack's children list
                  ], // End of Stack
                ), // End of Scaffold's body
              ), // End of GestureDetector
          ); // ← Closes the return inside BlocBuilder's builder
        },
    ); // ← Closes BlocBuilder

  // ← Closes return BlocBuilder<...>(...)
} // ← Closes @override Widget build(BuildContext context)

// Recommended: Move _inputBoxDecoration here (outside build)
BoxDecoration _inputBoxDecoration() {
  return BoxDecoration(
    borderRadius: BorderRadius.circular(6.0),
    boxShadow: const [
      BoxShadow(
        color: Colors.grey,
        offset: Offset(0.3, 0.3),
        blurRadius: 0.3,
        spreadRadius: 0.3,
      ),
      BoxShadow(
        color: Colors.white,
        offset: Offset(0, 0),
        blurRadius: 0,
        spreadRadius: 0,
      ),
    ],
  );
}
} // ← End of class _FilterDemoState