// // EVENT FILE
//
// // filter_event.dart
// part of 'filter_bloc.dart';
//
// abstract class FilterEvent extends Equatable {
//   const FilterEvent();
//   @override
//   List<Object?> get props => [];
// }
//
// class FilterInitFilterFields extends FilterEvent {
//   final dynamic data;
//   final int? propertyType;
//   final String? propertyCategoryType;
//   final String? optionType;
//   final BuildContext context;
//
//   const FilterInitFilterFields({
//     required this.data,
//     required this.propertyType,
//     this.propertyCategoryType,
//     this.optionType,
//     required this.context,
//   });
//
//   @override
//   List<Object?> get props =>
//       [data, propertyType, propertyCategoryType, optionType];
// }
//
// class FilterSetSelectedProductType extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedProductType(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedPropertyCategoryType extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedPropertyCategoryType(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedPropertyType extends FilterEvent {
//   final int? index;
//   final BuildContext context;
//   const FilterSetSelectedPropertyType(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedBedrooms extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedBedrooms(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedBathrooms extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedBathrooms(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedFurnishedType extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedFurnishedType(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedPriceRange extends FilterEvent {
//   final SfRangeValues value;
//   final BuildContext context;
//   const FilterSetSelectedPriceRange(this.value, this.context);
//   @override
//   List<Object?> get props => [value.start, value.end];
// }
//
// class FilterSetSelectedAreaRange extends FilterEvent {
//   final SfRangeValues value;
//   final BuildContext context;
//   const FilterSetSelectedAreaRange(this.value, this.context);
//   @override
//   List<Object?> get props => [value.start, value.end];
// }
//
// class FilterSetSelectedAmenities extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedAmenities(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedRentType extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedRentType(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedCompletionStatus extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedCompletionStatus(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedHandOverBy extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedHandOverBy(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedCompletionPercentage extends FilterEvent {
//   final int index;
//   final BuildContext context;
//   const FilterSetSelectedCompletionPercentage(this.index, this.context);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterUpdateFilterCount extends FilterEvent {
//   final BuildContext context;
//   final bool loadMore;
//   const FilterUpdateFilterCount({required this.context, this.loadMore = false});
//   @override
//   List<Object?> get props => [loadMore];
// }
//
// class FilterResetAll extends FilterEvent {
//   final BuildContext context;
//   final bool isUpdate;
//   const FilterResetAll({required this.context, required this.isUpdate});
//   @override
//   List<Object?> get props => [isUpdate];
// }
//
// class FilterCaptureInitialSnapshot extends FilterEvent {
//   const FilterCaptureInitialSnapshot();
// }
//
// class FilterSetInitialHomeCategory extends FilterEvent {
//   final int index;
//   const FilterSetInitialHomeCategory(this.index);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetNewProjects extends FilterEvent {
//   final BuildContext context;
//   const FilterSetNewProjects(this.context);
// }
//
// class FilterSetProperties extends FilterEvent {
//   final BuildContext context;
//   const FilterSetProperties(this.context);
// }
//
// class FilterShowResult extends FilterEvent {
//   final BuildContext context;
//   final bool autoUpdate;
//   final VoidCallback onFilterResultZero;
//   final VoidCallback onFilterResultNotZero;
//
//   const FilterShowResult({
//     required this.context,
//     this.autoUpdate = false,
//     required this.onFilterResultZero,
//     required this.onFilterResultNotZero,
//   });
//   @override
//   List<Object?> get props => [autoUpdate];
// }
//
// class FilterSetFilterNavigation extends FilterEvent {
//   final bool value;
//   const FilterSetFilterNavigation(this.value);
//   @override
//   List<Object?> get props => [value];
// }
//
// class FilterLoadInitialData extends FilterEvent {
//   const FilterLoadInitialData();
// }
//
// class FilterPropertyApi extends FilterEvent {
//   final String purpose;
//   const FilterPropertyApi(this.purpose);
//   @override
//   List<Object?> get props => [purpose];
// }
//
// class FilterFetchAmenities extends FilterEvent {
//   const FilterFetchAmenities();
// }
//
// // Filter List Screen Events
// class FilterSetSelectedFilterListProductLocally extends FilterEvent {
//   final int index;
//   const FilterSetSelectedFilterListProductLocally(this.index);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedFilterListPropertyCategoryType extends FilterEvent {
//   final int index;
//   const FilterSetSelectedFilterListPropertyCategoryType(this.index);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedFilterListPropertyType extends FilterEvent {
//   final int? index;
//   const FilterSetSelectedFilterListPropertyType(this.index);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedFilterListPropertyCategory extends FilterEvent {
//   final int? index;
//   const FilterSetSelectedFilterListPropertyCategory(this.index);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedFilterRangePriceRange extends FilterEvent {
//   final double minPrice;
//   final double maxPrice;
//   const FilterSetSelectedFilterRangePriceRange(
//       {required this.minPrice, required this.maxPrice});
//   @override
//   List<Object?> get props => [minPrice, maxPrice];
// }
//
// class FilterSetSelectedFilterListBedrooms extends FilterEvent {
//   final int index;
//   const FilterSetSelectedFilterListBedrooms(this.index);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedFilterListBathrooms extends FilterEvent {
//   final int index;
//   const FilterSetSelectedFilterListBathrooms(this.index);
//   @override
//   List<Object?> get props => [index];
// }
//
// class FilterSetSelectedFilterListAreaSize extends FilterEvent {
//   final double minSqrFeet;
//   final double maxSqrFeet;
//   const FilterSetSelectedFilterListAreaSize(
//       {required this.minSqrFeet, required this.maxSqrFeet});
//   @override
//   List<Object?> get props => [minSqrFeet, maxSqrFeet];
// }
//
// class FilterSetSelectedFilterListCompletionStatus extends FilterEvent {
//   final int index;
//   const FilterSetSelectedFilterListCompletionStatus(this.index);
//   @override
//   List<Object?> get props => [index];
// }
