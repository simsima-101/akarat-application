part of 'filter_bloc.dart';

abstract class FilterEvent {
  const FilterEvent();
}

class SwitchTab extends FilterEvent {
  final int tabIndex;
  const SwitchTab(this.tabIndex);
}

class SelectProduct extends FilterEvent {
  final int index;
  const SelectProduct(this.index);
}

class SelectPropertyType extends FilterEvent {
  final int? type;
  const SelectPropertyType(this.type);
}

class SelectPropertyCategory extends FilterEvent {
  final String? category;
  const SelectPropertyCategory(this.category);
}

class UpdatePriceRange extends FilterEvent {
  final double min;
  final double max;
  const UpdatePriceRange(this.min, this.max);
}

class UpdateAreaRange extends FilterEvent {
  final double min;
  final double max;
  const UpdateAreaRange(this.min, this.max);
}

class ToggleBedroom extends FilterEvent {
  final String bedroom;
  const ToggleBedroom(this.bedroom);
}

class ToggleBathroom extends FilterEvent {
  final String bathroom;
  const ToggleBathroom(this.bathroom);
}

class AddLocation extends FilterEvent {
  final String location;
  const AddLocation(this.location);
}

class RemoveLocation extends FilterEvent {
  final String location;
  const RemoveLocation(this.location);
}

class SelectFurnishedType extends FilterEvent {
  final int index;
  const SelectFurnishedType(this.index);
}

class SelectCompletionStatus extends FilterEvent {
  final int? index;
  const SelectCompletionStatus(this.index);
}

class SelectHandover extends FilterEvent {
  final int index;
  const SelectHandover(this.index);
}

class SelectPercentCompletion extends FilterEvent {
  final int index;
  const SelectPercentCompletion(this.index);
}

class SelectRentPaid extends FilterEvent {
  final int index;
  const SelectRentPaid(this.index);
}

class UpdateAgentOrAgencySearch extends FilterEvent {
  final String text;
  const UpdateAgentOrAgencySearch(this.text);
}

class ToggleAmenity extends FilterEvent {
  final int amenityId;
  const ToggleAmenity(this.amenityId);
}

class UpdateSelectedAmenities extends FilterEvent {
  final List<int> selectedIds;
  const UpdateSelectedAmenities(this.selectedIds);
}

class LoadPropertyTypes extends FilterEvent {
  final int type;
  const LoadPropertyTypes(this.type);
}

class LoadAmenities extends FilterEvent {
  const LoadAmenities();
}

class ResetFilter extends FilterEvent {
  const ResetFilter();
}

class SearchProperties extends FilterEvent {
  const SearchProperties();
}

class SetHomeCategory extends FilterEvent {
  final int categoryIndex;
  const SetHomeCategory(this.categoryIndex);
}

class ShowFilterResults extends FilterEvent {
  final BuildContext context;
  const ShowFilterResults(this.context);
}

class UpdateLocationsFromPicker extends FilterEvent {
  final List<LocationModel> locations;
  const UpdateLocationsFromPicker(this.locations);
}