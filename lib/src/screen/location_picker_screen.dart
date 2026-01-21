// LOCATION PROVIDER

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';

import '../features/filter/presentation/bloc/filter_bloc.dart';
import '../features/property/data/models/location_model.dart';
import '../providers/location_picker_provider.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final locProvider = context.read<LocationPickerProvider>();

        locProvider.clearSearchSuggestions();

        if (locProvider.selectedLocationList.isEmpty) {
          locProvider.fetchLastSearch();
        }

        locProvider.updatePopularSearchBasedOnFirstItem();

        // if (locProvider.selectedLocationList.isEmpty) {
        //   locProvider.fetchPopularSearch();
        // } else {
        //   int? locationID;
        //   final firstLocation = locProvider.selectedLocationList.first;
        //   if (firstLocation.location == null) {
        //     locationID = firstLocation.id;
        //   } else {
        //     locationID = firstLocation.emirateId;
        //   }
        //   locProvider.fetchPopularSearch(locationId: locationID);
        // }
      },
    );
    super.initState();
  }

  // State
  // String _query = '';

  // UI / Styling helpers
  static const _chipRadius = 9.0;
  static const _sheetRadius = 20.0;
  static const _borderColor = Color(0xFFBDBDBD);

  // --------------------- BUILD ---------------------
  @override
  Widget build(BuildContext context) {
    // final filterProvider = context.read<FilterProvider>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: BlocBuilder<FilterBloc, FilterState>(
          builder: (context, filterProvider) {
        return Consumer<LocationPickerProvider>(
            builder: (context, locationProvider, _) {
          return Container(
            // Outer sheet container
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, locationProvider),
                const SizedBox(height: 1),
                const Divider(
                  thickness: 0.8,
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    // SEARCH FIELD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 49,
                        child: TextFormField(
                          controller: locationProvider.searchController,
                          onChanged: (q) async {
                            // EasyDebounce.debounce(
                            //   'fetch location',
                            //   Duration(milliseconds: 0),
                            //   () {
                            locationProvider.fetchLocationSuggestions(q);
                            // },
                            // );
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.place_sharp,
                              size: 23,
                            ),
                            hintText: 'e.g. Dubai Marina',
                            hintStyle: const TextStyle(color: Colors.black45),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 14),
                            suffixIcon: locationProvider
                                    .searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      locationProvider.clearSearchSuggestions();
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: _borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSelectedChipsRow(locationProvider),
                    if (locationProvider.selectedLocationList.isNotEmpty)
                      const SizedBox(height: 15),
                    if (locationProvider.selectedLocationList.isNotEmpty)
                      const Divider(
                        thickness: 0.8,
                        height: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Expanded(child: _buildBody(locationProvider)),
                const Divider(
                  thickness: 0.8,
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                _buildFooter(locationProvider),
              ],
            ),
          );
        });
      }),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    LocationPickerProvider locationProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4, bottom: 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Location',
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          TextButton(
            onPressed: locationProvider.selectedLocationList.isEmpty
                ? null
                : () async {
                    await locationProvider.clearAll();
                    context
                        .read<FilterBloc>()
                        .add(FilterUpdateFilterCount(context: context));
                  },
            child: Text('Clear All',
                style: TextStyle(
                  letterSpacing: 0,
                  color: locationProvider.selectedLocationList.isEmpty
                      ? Colors.grey
                      : Colors.red,
                  fontWeight: FontWeight.w500,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChipsRow(
    LocationPickerProvider locationProvider,
  ) {
    if (locationProvider.selectedLocationList.isEmpty)
      return const SizedBox.shrink();

    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 10),
        scrollDirection: Axis.horizontal,
        itemCount: locationProvider.selectedLocationList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = locationProvider.selectedLocationList[index];
          return _buildSelectedChip(
              locModel: item,
              onTap: () async {
                await locationProvider.removeSelectedLocations(item);

                context
                    .read<FilterBloc>()
                    .add(FilterUpdateFilterCount(context: context));

                // await filterProvider.updateFilterCount(context);
              });
        },
      ),
    );
  }

  Widget _buildSelectedChip(
      {required LocationModel locModel, required void Function()? onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(_chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(locModel.location ?? locModel.country ?? 'null',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: const Icon(Icons.close, size: 19, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    LocationPickerProvider locationProvider,
  ) {
    if (locationProvider.searchController.text.isNotEmpty) {
      return locationProvider.locationSuggestionsList.isEmpty
          ? Center(
              child: Text(
                'No results found for "${locationProvider.searchController.text}"',
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.only(top: 0),
              itemCount: locationProvider.locationSuggestionsList.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, color: Color(0xFFE0E0E0)),
              itemBuilder: (_, index) {
                final locModel =
                    locationProvider.locationSuggestionsList[index];
                return ListTile(
                  title: Text(
                    locModel.location ?? '',
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  ),
                  subtitle: Text(locModel.country ?? ''),
                  onTap: () async {
                    await locationProvider.addSelectedLocation(
                      locationModel: locModel,
                    );
                    locationProvider.clearSearchSuggestions();
                    context
                        .read<FilterBloc>()
                        .add(FilterUpdateFilterCount(context: context));
                  },
                );
              },
            );
    }

    // --- Dynamic popular section based on selected cities ---

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(4),
          /////////////////  LAST SEARCH //////////////////
          if (locationProvider.lastSearchList.isNotEmpty)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _sectionTitle(Icons.history, 'Your last searches'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: locationProvider.lastSearchList.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final lastSearch = locationProvider.lastSearchList[index];

                      return GestureDetector(
                        onTap: () async {
                          await locationProvider
                              .addSelectedLocationFromLastSearch(
                            locationModel: lastSearch,
                          );

                          context
                              .read<FilterBloc>()
                              .add(FilterUpdateFilterCount(context: context));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                lastSearch.location ??
                                    lastSearch.country ??
                                    'null',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),

          /////////////////  POPULAR SEARCH //////////////////
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sectionTitle(Icons.trending_up, 'Popular searches'),
          ),
          const SizedBox(height: 12),
          locationProvider.isLoadingPopularSearch
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    clipBehavior: Clip.none,
                    children: locationProvider.popularLocationList
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final popularLoc = entry.value;
                      return Material(
                        key: ValueKey('popular_${popularLoc.id}_$index'),
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await locationProvider.addSelectedLocation(
                                locationModel: popularLoc);

                            context
                                .read<FilterBloc>()
                                .add(FilterUpdateFilterCount(context: context));
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: _borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  popularLoc.location ??
                                      popularLoc.country ??
                                      'null',
                                  style: const TextStyle(
                                      fontSize: 15, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 23),
        const SizedBox(width: 8),
        Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.3)),
      ],
    );
  }

  Widget _buildResultTitl(String full) {
    final parts = full.split(' ');
    if (parts.isEmpty) return Text(full);

    final first = parts.first;
    final rest = parts.length > 1 ? ' ' + parts.sublist(1).join(' ') : '';

    return RichText(
      text: TextSpan(
        text: first,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
        children: [
          TextSpan(
              text: rest,
              style: const TextStyle(
                  fontWeight: FontWeight.normal, color: Colors.black))
        ],
      ),
    );
  }

  Widget _buildFooter(
    LocationPickerProvider locationProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18)
          .copyWith(bottom: 50, top: 10),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<FilterBloc, FilterState>(
                builder: (context, filterProvider) {
              return Text(
                "${filterProvider.displayedFilterResultCount} results",
                // locationProvider.selectedLocationList.isNotEmpty
                // ? '88,795 results'
                // : '107,617 results',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              );
            }),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, locationProvider.selectedLocationList),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            ),
            child: const Text('Continue',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
