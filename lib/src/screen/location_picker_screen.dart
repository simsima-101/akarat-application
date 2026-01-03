import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../features/property/data/models/location_model.dart';
import '../features/property/presentation/bloc/location_picker_bloc.dart';
import '../features/property/presentation/bloc/filter_bloc.dart';
import 'filter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationBloc = context.read<LocationPickerBloc>();

      locationBloc.add(ClearLocationSuggestions());

      if (locationBloc.state.selectedLocations.isEmpty) {
        locationBloc.add(LoadLastSearchedLocations());
      }

      locationBloc.add(UpdatePopularSearches());
    });
  }

  static const _chipRadius = 9.0;
  static const _sheetRadius = 20.0;
  static const _borderColor = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: BlocBuilder<LocationPickerBloc, LocationPickerState>(
        builder: (context, locationState) {
          final filterBloc = context.read<FilterBloc>();

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(_sheetRadius)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context, locationState),
                const SizedBox(height: 1),
                const Divider(thickness: 0.8, height: 1),
                const SizedBox(height: 12),

                Column(
                  children: [
                    // SEARCH FIELD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 49,
                        child: TextFormField(
                          controller: locationState.searchController,
                          onChanged: (query) {
                            context.read<LocationPickerBloc>().add(
                              SearchLocations(query: query),
                            );
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.place_sharp, size: 23),
                            hintText: 'e.g. Dubai Marina',
                            hintStyle: const TextStyle(color: Colors.black45),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            suffixIcon: locationState.searchController.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                context.read<LocationPickerBloc>().add(ClearLocationSuggestions());
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
                    _buildSelectedChipsRow(locationState),
                    if (locationState.selectedLocations.isNotEmpty) const SizedBox(height: 15),
                    if (locationState.selectedLocations.isNotEmpty)
                      const Divider(thickness: 0.8, height: 1),
                  ],
                ),
                const SizedBox(height: 5),
                Expanded(child: _buildBody(locationState)),
                const Divider(thickness: 0.8, height: 1),
                _buildFooter(locationState, filterBloc),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LocationPickerState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
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
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: state.selectedLocations.isEmpty
                ? null
                : () {
              context.read<LocationPickerBloc>().add(ClearAllLocations());
            },
            child: Text(
              'Clear All',
              style: TextStyle(
                color: state.selectedLocations.isEmpty ? Colors.grey : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChipsRow(LocationPickerState state) {
    if (state.selectedLocations.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.only(left: 16, right: 10),
        scrollDirection: Axis.horizontal,
        itemCount: state.selectedLocations.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = state.selectedLocations[index];
          return _buildSelectedChip(
            locModel: item,
            onTap: () {
              context.read<LocationPickerBloc>().add(DeselectLocation(location: item))

              ;
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectedChip({required LocationModel locModel, required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(_chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            locModel.location ?? locModel.country ?? 'Unknown',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: const Icon(Icons.close, size: 19, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(LocationPickerState state) {
    final query = state.searchController.text;

    if (query.isNotEmpty) {
      return state.suggestions.isEmpty
          ? const Center(
        child: Text(
          'No results found',
          style: TextStyle(color: Colors.black54, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      )
          : ListView.separated(
        itemCount: state.suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFE0E0E0)),
        itemBuilder: (_, index) {
          final loc = state.suggestions[index];
          return ListTile(
            title: Text(loc.location ?? '', style: const TextStyle(fontSize: 15)),
            subtitle: Text(loc.country ?? ''),
            onTap: () {
              context.read<LocationPickerBloc>().add(SelectLocation(location: loc));
            },
          );
        },
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(4),

          // Last Searches
          if (state.lastSearched.isNotEmpty)
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.lastSearched.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final loc = state.lastSearched[index];
                      return GestureDetector(
                        onTap: () {
                          context.read<LocationPickerBloc>().add(SelectLocation(location: loc));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _borderColor),
                          ),
                          child: Text(
                            loc.location ?? loc.country ?? 'Unknown',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),

          // Popular Searches
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _sectionTitle(Icons.trending_up, 'Popular searches'),
          ),
          const SizedBox(height: 12),
          state.isLoadingPopular
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.popularLocations.map((loc) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      context.read<LocationPickerBloc>().add(SelectLocation(location: loc));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Text(
                        loc.location ?? loc.country ?? 'Unknown',
                        style: const TextStyle(fontSize: 15),
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
        Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16.3)),
      ],
    );
  }

  Widget _buildFooter(LocationPickerState state, FilterBloc filterBloc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18).copyWith(bottom: 50, top: 10),
      child: Row(
        children: [
          Expanded(
            child: BlocBuilder<FilterBloc, FilterState>(
              builder: (context, filterState) {
                return Text(
                  "${filterState.filterResultCount} results",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Sync selected locations to FilterBloc
              filterBloc.add(UpdateLocationsFromPicker(state.selectedLocations));

              // Close the location picker bottom sheet
              Navigator.pop(context);

              // Navigate to Filter screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Filter(data: "Rent"), // ← Your filter.dart screen
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}