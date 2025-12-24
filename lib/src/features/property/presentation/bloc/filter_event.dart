part of 'filter_bloc.dart';

abstract class FilterEvent {
  const FilterEvent();
}

// Tab switch: Properties ↔ New Projects
class SwitchTab extends FilterEvent {
  final int tabIndex; // 0 = Properties, 1 = New Projects
  const SwitchTab(this.tabIndex);
}

// Rent / Buy pills
class SelectProduct extends FilterEvent {
  final int index; // 0 = Rent, 1 = Buy
  const SelectProduct(this.index);
}

// Residential vs Commercial
class SelectPropertyType extends FilterEvent {
  final int? type; // 0 = Residential, 1 = Commercial, null = none
  const SelectPropertyType(this.type);
}

// Category icons (Apartment, Villa, etc.)
class SelectPropertyCategory extends FilterEvent {
  final String? category;
  const SelectPropertyCategory(this.category);
}

// Price range
class UpdatePriceRange extends FilterEvent {
  final double min;
  final double max;
  const UpdatePriceRange(this.min, this.max);
}

// Area range
class UpdateAreaRange extends FilterEvent {
  final double min;
  final double max;
  const UpdateAreaRange(this.min, this.max);
}

// Bedrooms & Bathrooms multi-select
class ToggleBedroom extends FilterEvent {
  final String bedroom;
  const ToggleBedroom(this.bedroom);
}

class ToggleBathroom extends FilterEvent {
  final String bathroom;
  const ToggleBathroom(this.bathroom);
}

// Locations
class AddLocation extends FilterEvent {
  final String location;
  const AddLocation(this.location);
}

class RemoveLocation extends FilterEvent {
  final String location;
  const RemoveLocation(this.location);
}

// Furnished Type - single select by index (matches your UI usage)
class SelectFurnishedType extends FilterEvent {
  final int index; // -1 = none, 0 = Unfurnished, etc.
  const SelectFurnishedType(this.index);
}

// Completion Status (Ready / Off-Plan)
class SelectCompletionStatus extends FilterEvent {
  final int? index;
  const SelectCompletionStatus(this.index);
}

// Handover By (Q1 2025, etc.) - matches your UI call: SelectHandover(i)
class SelectHandover extends FilterEvent {
  final int index; // -1 = none
  const SelectHandover(this.index);
}

// % Completion - matches your UI call: SelectPercentCompletion(i)
class SelectPercentCompletion extends FilterEvent {
  final int index; // -1 = none
  const SelectPercentCompletion(this.index);
}

// Rent is Paid (Yearly, Monthly, etc.) - matches your UI call: SelectRentPaid(i)
class SelectRentPaid extends FilterEvent {
  final int index; // -1 = none
  const SelectRentPaid(this.index);
}

// Agent or Agency search text field
class UpdateAgentOrAgencySearch extends FilterEvent {
  final String text;
  const UpdateAgentOrAgencySearch(this.text);
}

// Amenities - single toggle
class ToggleAmenity extends FilterEvent {
  final int amenityId;
  const ToggleAmenity(this.amenityId);
}

// Amenities - bulk update from FullAmenitiesScreen
class UpdateSelectedAmenities extends FilterEvent {
  final List<int> selectedIds;
  const UpdateSelectedAmenities(this.selectedIds);
}

class LoadPropertyTypes extends FilterEvent {
  final int type; // 0 = Residential, 1 = Commercial
  const LoadPropertyTypes(this.type);
}

class LoadAmenities extends FilterEvent {
  const LoadAmenities();
}

// Reset & Search
class ResetFilter extends FilterEvent {
  const ResetFilter();
}

class SearchProperties extends FilterEvent {
  const SearchProperties();
}

// From home screen category cards
class SetHomeCategory extends FilterEvent {
  final int categoryIndex;
  const SetHomeCategory(this.categoryIndex);
}

/// Triggered when user taps "Showing Results" button
class ShowFilterResults extends FilterEvent {
  final BuildContext context;
  const ShowFilterResults(this.context);
}