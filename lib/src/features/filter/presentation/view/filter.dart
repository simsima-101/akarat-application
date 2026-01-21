// FILTER  UI

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../../../providers/location_picker_provider.dart';
import '../../../../screen/full_amenities_screen.dart';
import '../../../../screen/location_picker_screen.dart';
import '../../data/model/filtermodel.dart';
import '../bloc/filter_bloc.dart';
import 'filter_list.dart' hide Data;

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
  RangeController priceRangeController = RangeController(
    start: 500.0,
    end: 300000.0,
  );

  RangeController areaRangeController = RangeController(
    start: 0.0,
    end: 10000,
  );
  RangeController priceRangeSelectionController = RangeController(
    start: 500.0,
    end: 300000.0,
  );
  RangeController areaRangeSelectionController = RangeController(
    start: 0.0,
    end: 10000,
  );
  int pageIndex = 0;

  TextEditingController agentOrAgencyController = TextEditingController();

  final List<int> yValues = [5000, 3000, 9000, 7000, 10000, 1500, 4000];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context.read<FilterBloc>().add(FilterInitFilterFields(
              data: widget.data,
              propertyType: widget.propertyType,
              propertyCategoryType: widget.propertyCategoryType,
              optionType: widget.optionType,
              context: context,
            ));

        // context.read<FilterProvider>().initFilterFields(
        //       context,
        //       data: widget.data,
        //       propertyType: widget.propertyType,
        //       propertyCategoryType: widget.propertyCategoryType,
        //       optionType: widget.optionType,
        //     );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.sizeOf(context);
    return BlocBuilder<FilterBloc, FilterState>(
        builder: (context, filterProvider) {
      final int rentIndex = FilterBloc.product.indexOf('Rent');
      final int buyIndex = FilterBloc.product.indexOf('Buy');

      final bool isNewProjects = filterProvider.selected == 1;
      final bool isProperties = filterProvider.selected == 0;
      final bool isOffPlan =
          FilterBloc.completion.elementAt(filterProvider.selectedCompletion) ==
              'Off-Plan';

      final bool showProductPills = isProperties; // Properties only
      final bool showRentPaid = isProperties &&
          (filterProvider.selectedproduct ==
              rentIndex); // Properties + Rent only
      final bool showHandoverBy = isNewProjects // New Projects
          ||
          (isProperties &&
              filterProvider.selectedproduct == buyIndex &&
              isOffPlan); // Properties → Buy → Off-Plan

      final bool isBuyMode =
          isProperties && filterProvider.selectedproduct == buyIndex;

      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child:
            // filterProvider.propertyTypeModel == null
            //     ? Scaffold(
            //         body: ListView.builder(
            //         itemCount: 5,
            //         itemBuilder: (context, index) => const ShimmerCard(),
            //       ) // Show loading state
            //         )
            //     :
            Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: Color(0xFFF9F9F9),
            backgroundColor: Color(0xFFF9F9F9), // Softer white
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
              onPressed: () async {
                if (filterProvider.isFromFilterList) {
                  context.read<FilterBloc>().add(await FilterShowResult(
                        context: context,
                        autoUpdate: false,
                        onFilterResultNotZero: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: 'FliterList'),
                              builder: (context) => FliterList(
                                  // filterModel: filterProvider.filterModel,
                                  // // forceRefresh: true,
                                  // // 👇 send the exact UI selections forward
                                  // selectedPurpose: filterProvider
                                  //     .currentUiPurpose, // "Buy" | "Rent" | "New Projects"
                                  // selectedPropertyType: filterProvider
                                  //     .currentPropertyType, // "Apartment" | "Villa" | "Studio" | "Offices" | "Commercials" | ''
                                  ),
                            ),
                          );
                        },
                        onFilterResultZero: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text('Results'),
                                  backgroundColor: Colors.red,
                                ),
                                body: Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            "assets/images/not_found.png",
                                            width: 50,
                                            height: 50),
                                        SizedBox(height: 20),
                                        Text('No Property Found',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10),
                                        Text(
                                          'Please select other filters to get results.',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 30),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Back to Filters',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ));
                } else {
                  Navigator.pop(context);
                }
              },
            ),

            actions: [
              TextButton(
                onPressed: filterProvider.hasChanges
                    ? filterProvider.isResetLoading
                        ? null
                        : () async {
                            context.read<FilterBloc>().add(FilterResetAll(
                                context: context, isUpdate: false));

                            context
                                .read<FilterBloc>()
                                .add(FilterCaptureInitialSnapshot());
                          }
                    : null,
                child: filterProvider.isResetLoading
                    ? CupertinoActivityIndicator(
                        radius: 13,
                      )
                    : Text(
                        "Reset",
                        style: TextStyle(
                          color: filterProvider.hasChanges
                              ? Colors.red
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(children: <Widget>[
              Column(
                children: [
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
                        // Properties
                        // ✅ UPDATED: Properties toggle
                        GestureDetector(
                          onTap: () async {
                            context
                                .read<FilterBloc>()
                                .add(FilterSetProperties(context));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 180,
                            height: 45,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: filterProvider.selected == 0
                                  ? const Color(0xFF3A7CED)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: const Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              "Properties",
                              style: TextStyle(
                                color: filterProvider.selected == 0
                                    ? Colors.white
                                    : Colors.black,
                                letterSpacing: 0.5,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),

                        // New Projects
                        GestureDetector(
                          onTap: () async {
                            context
                                .read<FilterBloc>()
                                .add(FilterSetNewProjects(context));
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 180,
                            height: 45,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: filterProvider.selected == 1
                                  ? const Color(0xFF3A7CED)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: const Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Text(
                              "New Projects",
                              style: TextStyle(
                                color: filterProvider.selected == 1
                                    ? Colors.white
                                    : Colors.black,
                                letterSpacing: 0.5,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              //properties
              if (showProductPills) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: SizedBox(
                        height: 60,
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: FilterBloc.product.length,
                          itemBuilder: (context, index) {
                            final isSelected =
                                filterProvider.selectedproduct == index;
                            return GestureDetector(
                              onTap: () async {
                                context
                                    .read<FilterBloc>()
                                    .add(FilterSetSelectedProductType(
                                      index,
                                      context,
                                    ));
                              },
                              child: Container(
                                width: 180,
                                height: 34,
                                alignment: Alignment.center,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 5),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF5F4F9)
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.transparent,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.8),
                                      offset: const Offset(-4, -4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  FilterBloc.product[index],
                                  style: const TextStyle(
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 20),
              const Divider(
                height: 1,
                indent: 15,
                endIndent: 15,
              ),
              const SizedBox(height: 20),

              Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Location",
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
                          onTap: () {
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
                          readOnly: true,
                          // enableInteractiveSelection: false,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16.5),
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.only(left: 4, right: 0),
                              child: Icon(
                                Icons.place,
                                color: Colors.redAccent,
                                size: 26,
                              ),
                            ),
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white, // Background red
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 2),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            hintText: 'Search locations',
                            hintStyle: const TextStyle(
                                color: Colors.black54, fontSize: 16),
                          ),
                          cursorColor: Colors.redAccent,
                        )),
                    Consumer<LocationPickerProvider>(
                        builder: (context, locationProvider, _) {
                      return locationProvider.selectedLocationList.isEmpty
                          ? SizedBox.shrink()
                          : Column(
                              children: [
                                SizedBox(
                                  height: 15,
                                ),
                                SizedBox(
                                  height: 32,
                                  child: ListView.separated(
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 10),
                                    scrollDirection: Axis.horizontal,
                                    itemCount: locationProvider
                                        .selectedLocationList.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final item = locationProvider
                                          .selectedLocationList[index];

                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius:
                                              BorderRadius.circular(9.0),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                                item.location ??
                                                    item.country ??
                                                    'null',
                                                style: const TextStyle(
                                                    color: Colors.white)),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: () async {
                                                await locationProvider
                                                    .removeSelectedLocations(
                                                  item,
                                                );
                                                // await filterProvider
                                                //     .updateFilterCount(
                                                //         context);
                                              },
                                              child: const Icon(Icons.close,
                                                  size: 19,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                    }),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                indent: 15,
                endIndent: 15,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 18),
                      // child:  Text(purpose,
                      child: Text(
                        "Property Type",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5),
                        textAlign: TextAlign.left,
                      )),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  const SizedBox(width: 12),

                  // Residential
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        context
                            .read<FilterBloc>()
                            .add(FilterSetSelectedPropertyType(0, context));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 40,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          // selected: subtle gray gradient; unselected: white
                          gradient: filterProvider.selectedPropType == 0
                              ? const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFF5F4F9),
                                    Color(0xFFEFEFF3)
                                  ],
                                )
                              : null,
                          color: filterProvider.selectedPropType == 0
                              ? null
                              : Colors.white,
                          border: Border.all(
                            color: filterProvider.selectedPropType == 0
                                ? Colors.black
                                : Color(0xFFE6E4EE),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.9),
                              offset: const Offset(-2, -2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Residential',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Commercial
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        context
                            .read<FilterBloc>()
                            .add(FilterSetSelectedPropertyType(1, context));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: 40,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(left: 8, right: 12),
                        decoration: BoxDecoration(
                          gradient: filterProvider.selectedPropType == 1
                              ? const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0xFFF5F4F9),
                                    Color(0xFFEFEFF3)
                                  ],
                                )
                              : null,
                          color: filterProvider.selectedPropType == 1
                              ? null
                              : Colors.white,
                          border: Border.all(
                            color: filterProvider.selectedPropType == 1
                                ? Colors.black
                                : Color(0xFFE6E4EE),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              offset: const Offset(0, 3),
                              blurRadius: 6,
                              spreadRadius: 0,
                            ),
                            BoxShadow(
                              color: Colors.white.withOpacity(0.9),
                              offset: const Offset(-2, -2),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Commercial',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (filterProvider.selectedPropType != null) ...[
                SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: filterProvider.isPropertyTypeLoading ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.all(5),
                    height: screenSize.height * 0.125,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          filterProvider.propertyTypeModel?.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            context.read<FilterBloc>().add(
                                FilterSetSelectedPropertyCategoryType(
                                    index, context));
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: filterProvider.selectedtype == index
                                  ? Color(0xFFEEEEEE)
                                  : Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: Offset(0, 2),
                                  blurRadius: 4,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  offset: Offset(-4, -4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Image.network(
                                      height: 37,
                                      filterProvider
                                          .propertyTypeModel!.data![index].icon
                                          .toString(),
                                    )

                                    //     CachedNetworkImage(
                                    //   imageUrl: filterProvider
                                    //       .propertyTypeModel!
                                    //       .data![index]
                                    //       .icon
                                    //       .toString(),
                                    //   height: 35,
                                    //   placeholder: (context, url) =>
                                    //       const CupertinoActivityIndicator(
                                    //     radius: 13,
                                    //   ),
                                    //   errorWidget: (context, url, error) =>
                                    //       const Icon(Icons.error, size: 35),
                                    // ),
                                    ),
                                Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Text(
                                    filterProvider
                                        .propertyTypeModel!.data![index].name
                                        .toString(),
                                    style: TextStyle(
                                      color:
                                          filterProvider.selectedtype == index
                                              ? Colors.black
                                              : Colors.black,
                                      letterSpacing: 0.5,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    textAlign: TextAlign.center,
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
              if (isBuyMode && filterProvider.selected == 0) ...[
                Padding(
                  padding: const EdgeInsets.only(right: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Completion Status',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      // Pills row (scrollable if needed)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children:
                              List.generate(FilterBloc.completion.length, (i) {
                            final bool isSelected =
                                filterProvider.selectedCompletion == i;

                            return GestureDetector(
                              onTap: () async {
                                context.read<FilterBloc>().add(
                                    FilterSetSelectedCompletionStatus(
                                        i, context));
                              },
                              child: Container(
                                // auto width based on label
                                constraints:
                                    const BoxConstraints(minHeight: 34),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF5F4F9)
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.black
                                        : const Color(0xFFE6E4EE),
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.15),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.9),
                                      offset: const Offset(-2, -2),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  FilterBloc.completion[i],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            );
                          }),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Price range",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Padding(
                  padding: const EdgeInsets.only(top: 0, left: 20, right: 10),
                  child: Row(spacing: 15, children: [
                    Container(
                      width: screenSize.width * 0.38,
                      height: 40,
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          // controller: filterProvider.minPriceController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          // onTap: () => filterProvider.isMinTyping =
                          //     true, // 👈 starts typing
                          // onEditingComplete: () => filterProvider.isMinTyping =
                          //     false, // 👈 ends typing (on "done")
                          onChanged: (val) async {
                            final start = double.tryParse(val) ?? 0;
                            if (start <= filterProvider.values.end) {
                              setState(() {
                                filterProvider.values = SfRangeValues(
                                    start, filterProvider.values.end);
                                filterProvider.min_price =
                                    start.toStringAsFixed(0);
                              });

                              // await filterProvider.showResult(
                              //   context,
                              //   autoUpdate: true,
                              //   onFilterResultNotZero: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         settings: const RouteSettings(
                              //             name: 'FliterList'),
                              //         builder: (context) => FliterList(
                              //             // filterModel:
                              //             //     filterProvider.filterModel,
                              //             // // forceRefresh: true,
                              //             // // 👇 send the exact UI selections forward
                              //             // selectedPurpose: filterProvider
                              //             //     .currentUiPurpose, // "Buy" | "Rent" | "New Projects"
                              //             // selectedPropertyType: filterProvider
                              //             //     .currentPropertyType, // "Apartment" | "Villa" | "Studio" | "Offices" | "Commercials" | ''
                              //             ),
                              //       ),
                              //     );
                              //   },
                              //   onFilterResultZero: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => Scaffold(
                              //           appBar: AppBar(
                              //             title: Text('Results'),
                              //             backgroundColor: Colors.red,
                              //           ),
                              //           body: Container(
                              //             color: Colors.white,
                              //             child: Center(
                              //               child: Column(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment
                              //                         .center,
                              //                 children: [
                              //                   Image.asset(
                              //                       "assets/images/not_found.png",
                              //                       width: 50,
                              //                       height: 50),
                              //                   SizedBox(height: 20),
                              //                   Text('No Property Found',
                              //                       style: TextStyle(
                              //                           fontSize: 20,
                              //                           fontWeight:
                              //                               FontWeight
                              //                                   .bold)),
                              //                   SizedBox(height: 10),
                              //                   Text(
                              //                     'Please select other filters to get results.',
                              //                     style: TextStyle(
                              //                         fontSize: 16,
                              //                         color:
                              //                             Colors.black54),
                              //                     textAlign:
                              //                         TextAlign.center,
                              //                   ),
                              //                   SizedBox(height: 30),
                              //                   ElevatedButton(
                              //                     style: ElevatedButton
                              //                         .styleFrom(
                              //                             backgroundColor:
                              //                                 Colors.red),
                              //                     onPressed: () {
                              //                       Navigator.pop(
                              //                           context);
                              //                     },
                              //                     child: Text(
                              //                         'Back to Filters',
                              //                         style: TextStyle(
                              //                             fontSize: 14,
                              //                             color: Colors
                              //                                 .white)),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // );
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Text(
                        "to",
                        style: TextStyle(color: Colors.black, fontSize: 15.0),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                      width: screenSize.width * 0.38,
                      height: 40,
                      padding: const EdgeInsets.only(top: 8, left: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(6.0),
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
                          // controller: filterProvider.maxPriceController,
                          keyboardType: TextInputType.number,
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          // onTap: () => filterProvider.isMaxTyping = true,
                          // onEditingComplete: () =>
                          //     filterProvider.isMaxTyping = false,
                          onChanged: (val) async {
                            final end = double.tryParse(val) ?? 0;
                            if (end >= filterProvider.values.start) {
                              setState(() {
                                filterProvider.values = SfRangeValues(
                                    filterProvider.values.start, end);
                                filterProvider.max_price =
                                    end.toStringAsFixed(0);
                              });
                              // await filterProvider.showResult(
                              //   context,
                              //   autoUpdate: true,
                              //   onFilterResultNotZero: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         settings: const RouteSettings(
                              //             name: 'FliterList'),
                              //         builder: (context) => FliterList(
                              //             // filterModel:
                              //             //     filterProvider.filterModel,
                              //             // // forceRefresh: true,
                              //             // // 👇 send the exact UI selections forward
                              //             // selectedPurpose: filterProvider
                              //             //     .currentUiPurpose, // "Buy" | "Rent" | "New Projects"
                              //             // selectedPropertyType: filterProvider
                              //             //     .currentPropertyType, // "Apartment" | "Villa" | "Studio" | "Offices" | "Commercials" | ''
                              //             ),
                              //       ),
                              //     );
                              //   },
                              //   onFilterResultZero: () {
                              //     Navigator.push(
                              //       context,
                              //       MaterialPageRoute(
                              //         builder: (context) => Scaffold(
                              //           appBar: AppBar(
                              //             title: Text('Results'),
                              //             backgroundColor: Colors.red,
                              //           ),
                              //           body: Container(
                              //             color: Colors.white,
                              //             child: Center(
                              //               child: Column(
                              //                 mainAxisAlignment:
                              //                     MainAxisAlignment
                              //                         .center,
                              //                 children: [
                              //                   Image.asset(
                              //                       "assets/images/not_found.png",
                              //                       width: 50,
                              //                       height: 50),
                              //                   SizedBox(height: 20),
                              //                   Text('No Property Found',
                              //                       style: TextStyle(
                              //                           fontSize: 20,
                              //                           fontWeight:
                              //                               FontWeight
                              //                                   .bold)),
                              //                   SizedBox(height: 10),
                              //                   Text(
                              //                     'Please select other filters to get results.',
                              //                     style: TextStyle(
                              //                         fontSize: 16,
                              //                         color:
                              //                             Colors.black54),
                              //                     textAlign:
                              //                         TextAlign.center,
                              //                   ),
                              //                   SizedBox(height: 30),
                              //                   ElevatedButton(
                              //                     style: ElevatedButton
                              //                         .styleFrom(
                              //                             backgroundColor:
                              //                                 Colors.red),
                              //                     onPressed: () {
                              //                       Navigator.pop(
                              //                           context);
                              //                     },
                              //                     child: Text(
                              //                         'Back to Filters',
                              //                         style: TextStyle(
                              //                             fontSize: 14,
                              //                             color: Colors
                              //                                 .white)),
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //     );
                              //   },
                              // );
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
                    overlappingTooltipStrokeColor: Color(0x80E0E0E0),
                    tooltipBackgroundColor: Colors.black,
                    activeDividerStrokeWidth: 1,
                    activeDividerRadius: 2,
                    thumbStrokeWidth: 0.5, // Change tooltip background color
                    tooltipTextStyle: TextStyle(
                      color: Colors.white, // Change tooltip text color
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: SfRangeSelector(
                    min: 500,
                    max: 300000,
                    interval: 10000,
                    activeColor: Color(0xFF2575D4), // ✅ blue line

                    inactiveColor: Color(0x80F1EEEE),
                    enableTooltip: true,
                    shouldAlwaysShowTooltip: true,
                    controller: priceRangeController,

                    tooltipTextFormatterCallback: (actualValue, _) =>
                        'AED ${actualValue.toInt()}',
                    onChanged: (SfRangeValues value) async {
                      // setState(() {
                      //   filterProvider.values =
                      //       SfRangeValues(value.start, value.end);
                      //   filterProvider.min_price =
                      //       value.start.toStringAsFixed(0);
                      //   filterProvider.max_price = value.end.toStringAsFixed(0);
                      //
                      //   // ✅ Force update min only if not currently editing, or if value actually changed
                      //   if (
                      //       filterProvider.minPriceController.text !=
                      //           value.start.toStringAsFixed(0)) {
                      //     filterProvider.minPriceController.text =
                      //         value.start.toStringAsFixed(0);
                      //   }
                      //
                      //   if (
                      //       filterProvider.maxPriceController.text !=
                      //           value.end.toStringAsFixed(0)) {
                      //     filterProvider.maxPriceController.text =
                      //         value.end.toStringAsFixed(0);
                      //   }
                      // });

                      // await filterProvider.showResult(
                      //   context,
                      //   autoUpdate: true,
                      //   onFilterResultNotZero: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         settings:
                      //             const RouteSettings(name: 'FliterList'),
                      //         builder: (context) => FliterList(
                      //             // filterModel: filterProvider.filterModel,
                      //             // // forceRefresh: true,
                      //             // // 👇 send the exact UI selections forward
                      //             // selectedPurpose: filterProvider
                      //             //     .currentUiPurpose, // "Buy" | "Rent" | "New Projects"
                      //             // selectedPropertyType: filterProvider
                      //             //     .currentPropertyType, // "Apartment" | "Villa" | "Studio" | "Offices" | "Commercials" | ''
                      //             ),
                      //       ),
                      //     );
                      //   },
                      //   onFilterResultZero: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) => Scaffold(
                      //           appBar: AppBar(
                      //             title: Text('Results'),
                      //             backgroundColor: Colors.red,
                      //           ),
                      //           body: Container(
                      //             color: Colors.white,
                      //             child: Center(
                      //               child: Column(
                      //                 mainAxisAlignment:
                      //                     MainAxisAlignment.center,
                      //                 children: [
                      //                   Image.asset(
                      //                       "assets/images/not_found.png",
                      //                       width: 50,
                      //                       height: 50),
                      //                   SizedBox(height: 20),
                      //                   Text('No Property Found',
                      //                       style: TextStyle(
                      //                           fontSize: 20,
                      //                           fontWeight:
                      //                               FontWeight.bold)),
                      //                   SizedBox(height: 10),
                      //                   Text(
                      //                     'Please select other filters to get results.',
                      //                     style: TextStyle(
                      //                         fontSize: 16,
                      //                         color: Colors.black54),
                      //                     textAlign: TextAlign.center,
                      //                   ),
                      //                   SizedBox(height: 30),
                      //                   ElevatedButton(
                      //                     style: ElevatedButton.styleFrom(
                      //                         backgroundColor:
                      //                             Colors.red),
                      //                     onPressed: () {
                      //                       Navigator.pop(context);
                      //                     },
                      //                     child: Text('Back to Filters',
                      //                         style: TextStyle(
                      //                             fontSize: 14,
                      //                             color: Colors.white)),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // );

                      // Trigger light haptic feedback on slide
                      HapticFeedback.selectionClick();
                    },

                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: SfCartesianChart(
                        backgroundColor: Colors.transparent,
                        plotAreaBorderColor: Colors.transparent,
                        margin: const EdgeInsets.all(0),
                        primaryXAxis: NumericAxis(
                          minimum: 500,
                          maximum: 10000,
                          isVisible: false,
                        ),
                        primaryYAxis: NumericAxis(isVisible: false),
                        plotAreaBorderWidth: 0,
                        plotAreaBackgroundColor: Colors.transparent,
                        series: <ColumnSeries<Datas, double>>[
                          ColumnSeries<Datas, double>(
                            trackColor: Colors.transparent,
                            //color: Color.fromARGB(255, 126, 184, 253),
                            //opacity: 0.5,
                            dataSource: List.generate(
                              96,
                              (index) => Datas(500 + index * 100.0,
                                  yValues[index % yValues.length].toDouble()),
                            ),
                            selectionBehavior: SelectionBehavior(
                              unselectedOpacity: 0.0,
                              selectedColor: Colors.transparent,
                              selectedOpacity: 0.0,
                              unselectedColor: Colors.transparent,
                              // selectionController:
                              //     filterProvider.priceRangeController,
                            ),
                            xValueMapper: (Datas sales, int index) => sales.x,
                            yValueMapper: (Datas sales, int index) => sales.y,
                            pointColorMapper: (Datas sales, int index) {
                              return const Color.fromARGB(255, 37, 117, 212);
                            },
                            // color: const Color.fromRGBO(255, 255, 255, 0),
                            dashArray: const <double>[5, 3],
                            // borderColor: const Color.fromRGBO(194, 194, 194, 1),
                            animationDuration: 0,
                            borderWidth: 0,
                            //opacity: 0.5,
                          ),
                        ],
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
                    itemCount: FilterBloc.bedroomList.length,
                    itemBuilder: (context, index) {
                      final isSelected = filterProvider.selectedBedrooms
                          .contains(FilterBloc.bedroomList[index]);

                      return GestureDetector(
                        onTap: () async {
                          context
                              .read<FilterBloc>()
                              .add(FilterSetSelectedBedrooms(index, context));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                offset: Offset(0, 2),
                                blurRadius: 4,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                offset: Offset(-4, -4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected) ...[
                                Icon(Icons.check,
                                    size: 18, color: Colors.green),
                                SizedBox(width: 4),
                              ],
                              Text(
                                FilterBloc.bedroomList[index],
                                style: TextStyle(
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
                    itemCount: FilterBloc.bathroomList.length,
                    itemBuilder: (context, index) {
                      final isSelected = filterProvider.selectedBathrooms
                          .contains(FilterBloc.bathroomList[index]);

                      return GestureDetector(
                        onTap: () {
                          context
                              .read<FilterBloc>()
                              .add(FilterSetSelectedBathrooms(index, context));
                        },
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected) ...[
                                Icon(Icons.check,
                                    size: 18, color: Colors.green),
                                SizedBox(width: 4),
                              ],
                              Text(
                                FilterBloc.bathroomList[index],
                                style: TextStyle(
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
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Minimum area input
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.only(left: 8),
                            decoration: _inputBoxDecoration(),
                            child: TextFormField(
                              // controller: filterProvider.minAreaController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              // onTap: () =>
                              //     filterProvider.isMinAreaTyping = true,
                              // onEditingComplete: () =>
                              //     filterProvider.isMinAreaTyping = false,
                              onChanged: (val) {
                                final start = double.tryParse(val) ?? 0;
                                if (start <= filterProvider.valuesArea.end) {
                                  setState(() {
                                    filterProvider.valuesArea = SfRangeValues(
                                        start, filterProvider.valuesArea.end);
                                    filterProvider.min_sqrfeet =
                                        start.toStringAsFixed(0);
                                  });
                                  // filterProvider
                                  //     .updateFilterCount(context);
                                }
                              },
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("to", style: TextStyle(fontSize: 15)),
                        ),
                        // Maximum area input
                        Expanded(
                          child: Container(
                            height: 40,
                            padding: const EdgeInsets.only(left: 8),
                            decoration: _inputBoxDecoration(),
                            child: TextFormField(
                              // controller: filterProvider.maxAreaController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  border: InputBorder.none),
                              // onTap: () =>
                              //     filterProvider.isMaxAreaTyping = true,
                              // onEditingComplete: () =>
                              //     filterProvider.isMaxAreaTyping = false,
                              onChanged: (val) {
                                final end = double.tryParse(val) ?? 0;
                                if (end >= filterProvider.valuesArea.start) {
                                  setState(() {
                                    filterProvider.valuesArea = SfRangeValues(
                                        filterProvider.valuesArea.start, end);
                                    filterProvider.max_sqrfeet =
                                        end.toStringAsFixed(0);
                                  });
                                  // filterProvider
                                  //     .updateFilterCount(context);
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
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SfRangeSelectorTheme(
                      data: SfRangeSelectorThemeData(
                        tooltipBackgroundColor: Colors.black,
                        tooltipTextStyle: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      child: SfRangeSelector(
                        min: 0,
                        max: 10000,
                        interval: 1000,
                        enableTooltip: true,
                        shouldAlwaysShowTooltip: true,
                        activeColor: const Color(0xFF2575D4),
                        inactiveColor: const Color(0x80F1EEEE),
                        controller: areaRangeController,
                        onChanged: (value) async {
                          context
                              .read<FilterBloc>()
                              .add(FilterSetSelectedAreaRange(
                                value,
                                context,
                              ));

                          // Trigger light haptic feedback on slide
                          HapticFeedback.selectionClick();
                        },
                        child: SizedBox(
                          height: 70,
                          width: double.infinity,
                          child: SfCartesianChart(
                            plotAreaBorderColor: Colors.transparent,
                            margin: const EdgeInsets.all(0),
                            primaryXAxis: NumericAxis(
                                minimum: 0, maximum: 10000, isVisible: false),
                            primaryYAxis: NumericAxis(isVisible: false),
                            plotAreaBorderWidth: 0,
                            plotAreaBackgroundColor: Colors.transparent,
                            series: <ColumnSeries<Dataarea, double>>[
                              ColumnSeries<Dataarea, double>(
                                dataSource: List.generate(
                                  96,
                                  (index) => Dataarea(
                                      x: 500 + index * 100.0,
                                      y: yValues[index % yValues.length]
                                          .toDouble()),
                                ),
                                selectionBehavior: SelectionBehavior(
                                  unselectedOpacity: 0,
                                  selectedOpacity: 0,
                                  unselectedColor: Colors.transparent,
                                  // selectionController:
                                  //     filterProvider.areaRangeController,
                                ),
                                xValueMapper: (Dataarea sales, int index) =>
                                    sales.x,
                                yValueMapper: (Dataarea sales, int index) =>
                                    sales.y,
                                pointColorMapper: (Dataarea sales, int index) =>
                                    const Color.fromARGB(255, 37, 117, 212),
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
                    itemCount: FilterBloc.ftypeList.length,
                    itemBuilder: (context, index) {
                      final isSelected = filterProvider.selectedIndex == index;
                      return GestureDetector(
                        onTap: () {
                          context.read<FilterBloc>().add(
                              FilterSetSelectedFurnishedType(index, context));
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 5),
                          padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                color: Colors.grey.withOpacity(0.2),
                                offset: Offset(0, 0),
                                blurRadius: 1,
                                spreadRadius: 1,
                              ),
                              // BoxShadow(
                              //   color: Colors.white.withOpacity(0.8),
                              //   offset: Offset(-4, -4),
                              //   blurRadius: 8,
                              //   spreadRadius: 2,
                              // ),
                            ],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                Icon(Icons.check,
                                    size: 18, color: Colors.green),
                                SizedBox(width: 4),
                              ],
                              Text(
                                FilterBloc.ftypeList[index],
                                style: TextStyle(
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
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      // ✅ Handover By chips (4 visible + scrollable)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const double spacing = 10;
                          final double chipWidth =
                              (constraints.maxWidth - (spacing * 3)) /
                                  4; // 4 per viewport

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  FilterBloc.handoverOptions.length, (i) {
                                final bool isSelected =
                                    filterProvider.selectedHandover == i;

                                return Container(
                                  width: chipWidth,
                                  margin: EdgeInsets.only(
                                      right: i ==
                                              FilterBloc
                                                      .handoverOptions.length -
                                                  1
                                          ? 0
                                          : spacing),
                                  child: GestureDetector(
                                    onTap: () async {
                                      context.read<FilterBloc>().add(
                                          FilterSetSelectedHandOverBy(
                                              i, context));
                                    },
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 34),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFF5F4F9)
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black
                                              : const Color(0xFFE6E4EE),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.grey.withOpacity(0.15),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            offset: const Offset(-2, -2),
                                            blurRadius: 6,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        FilterBloc.handoverOptions[i],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          letterSpacing: 0.2,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),

                      // 4 visible + scrollable, same as Handover By
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const double spacing = 10;
                          final double chipWidth =
                              (constraints.maxWidth - (spacing * 3)) /
                                  4; // 4 per viewport

                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(
                                  FilterBloc.percentCompletionOptions.length,
                                  (i) {
                                final bool isSelected =
                                    filterProvider.selectedPercentCompletion ==
                                        i;

                                return Container(
                                  width: chipWidth,
                                  margin: EdgeInsets.only(
                                    right: i ==
                                            FilterBloc.percentCompletionOptions
                                                    .length -
                                                1
                                        ? 0
                                        : spacing,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      context.read<FilterBloc>().add(
                                              FilterSetSelectedCompletionPercentage(
                                            i,
                                            context,
                                          ));
                                    },
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(minHeight: 34),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? const Color(0xFFF5F4F9)
                                            : Colors.white,
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black
                                              : const Color(0xFFE6E4EE),
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                Colors.grey.withOpacity(0.15),
                                            offset: const Offset(0, 2),
                                            blurRadius: 4,
                                            spreadRadius: 0,
                                          ),
                                          BoxShadow(
                                            color:
                                                Colors.white.withOpacity(0.9),
                                            offset: const Offset(-2, -2),
                                            blurRadius: 6,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        FilterBloc.percentCompletionOptions[i],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          letterSpacing: 0.2,
                                          color: Colors.black,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                );
                              }),
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
                          controller: agentOrAgencyController,
                          // onChanged: (value) {
                          //   EasyDebounce.debounce(
                          //     'agentFilter',
                          //     Duration(milliseconds: 400),
                          //     () async {
                          //       // await filterProvider
                          //       //     .updateFilterCount(context);
                          //     },
                          //   );
                          // },
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                          decoration: InputDecoration(
                            labelStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white, // Background red
                            contentPadding: const EdgeInsets.symmetric(
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
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            hintText: 'Search agent or agency by name',
                            hintStyle: const TextStyle(
                                color: Colors.black54, fontSize: 14.7),
                          ),
                          cursorColor: Colors.redAccent,
                        )),
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
                child: GridView.builder(
                  itemCount: filterProvider.amenities.length > 6
                      ? 6
                      : filterProvider.amenities.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final isSelected = filterProvider.selectedAmenitiesId
                        .contains(filterProvider.amenities[index].id);

                    return GestureDetector(
                      onTap: () {
                        context
                            .read<FilterBloc>()
                            .add(FilterSetSelectedAmenities(
                              index,
                              context,
                            ));
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
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl:
                                  filterProvider.amenities[index].icon ?? '',
                              width: 18,
                              height: 18,
                              placeholder: (context, url) => const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.broken_image, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                filterProvider.amenities[index].title ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
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
              if (filterProvider.amenities.length > 6)
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: TextButton(
                    onPressed: () async {
                      await Future.wait(
                        filterProvider.amenities.map((a) async {
                          final url = a.icon;
                          if (url != null && url.isNotEmpty) {
                            try {
                              final provider = CachedNetworkImageProvider(url);
                              await precacheImage(provider, context);
                            } catch (_) {}
                          }
                        }),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullAmenitiesScreen(
                            allAmenities: filterProvider.amenities,
                            selectedAmenitiesIds:
                                filterProvider.selectedAmenitiesId,
                            onDone: (selected) async {
                              setState(() => filterProvider
                                  .selectedAmenitiesId = selected);
                              // await filterProvider
                              //     .updateFilterCount(context);
                            },
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Show more amenities",
                      style: const TextStyle(
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
                      itemCount: FilterBloc.rentList.length,
                      itemBuilder: (context, index) {
                        final isSelected = filterProvider.selectedrent == index;
                        return GestureDetector(
                          onTap: () {
                            context
                                .read<FilterBloc>()
                                .add(FilterSetSelectedRentType(
                                  index,
                                  context,
                                ));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            padding: const EdgeInsets.symmetric(horizontal: 15),
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
                                  color: Colors.white.withOpacity(0.8),
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
                                  const Icon(Icons.check,
                                      size: 18, color: Colors.green),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  FilterBloc.rentList[index],
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
              ],

              if (showRentPaid) ...[
                const SizedBox(height: 20),
                const Divider(height: 1, indent: 15, endIndent: 15),
                const SizedBox(height: 8),
              ],

              // ✅ always show the CTA (not inside any condition)
              const SizedBox(height: 8),

              ///   SHOW RESULT BUTTON
              GestureDetector(
                onTap: () async {
                  if (filterProvider.isLoading) return;
                  context.read<FilterBloc>().add(FilterShowResult(
                        context: context,
                        autoUpdate: false,
                        onFilterResultNotZero: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: const RouteSettings(name: 'FliterList'),
                              builder: (context) => FliterList(
                                  // filterModel: filterProvider.filterModel,
                                  // // forceRefresh: true,
                                  // // 👇 send the exact UI selections forward
                                  // selectedPurpose: filterProvider
                                  //     .currentUiPurpose, // "Buy" | "Rent" | "New Projects"
                                  // selectedPropertyType: filterProvider
                                  //     .currentPropertyType, // "Apartment" | "Villa" | "Studio" | "Offices" | "Commercials" | ''
                                  ),
                            ),
                          );
                        },
                        onFilterResultZero: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text('Results'),
                                  backgroundColor: Colors.red,
                                ),
                                body: Container(
                                  color: Colors.white,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            "assets/images/not_found.png",
                                            width: 50,
                                            height: 50),
                                        SizedBox(height: 20),
                                        Text('No Property Found',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        SizedBox(height: 10),
                                        Text(
                                          'Please select other filters to get results.',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 30),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Back to Filters',
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ));
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 25.0, left: 15, bottom: 15, right: 15),
                  child: Container(
                    width: screenSize.width * 0.9,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadiusDirectional.circular(6.0),
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
                      child: filterProvider.isLoading
                          ? CupertinoActivityIndicator(
                              radius: 14,
                              color: Colors.white,
                            )
                          : Text(
                              // ${filterProvider.displayedFilterResultCount}
                              "Showing Results",
                              style: const TextStyle(
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

              Container(
                height: 10,
              ),
            ]),
          ),
        ),
      );
    });
  }

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
}
