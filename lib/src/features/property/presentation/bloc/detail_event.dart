part of 'detail_bloc.dart';

abstract class DetailEvent extends Equatable {
  const DetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadPropertyDetail extends DetailEvent {
  final String propertyId;
  const LoadPropertyDetail(this.propertyId);

  @override
  List<Object?> get props => [propertyId];
}

class FetchFullDescription extends DetailEvent {
  const FetchFullDescription();

  @override
  List<Object?> get props => [];
}

class ToggleAmenities extends DetailEvent {
  const ToggleAmenities();

  @override
  List<Object?> get props => [];
}

class TrySendEmail extends DetailEvent {
  const TrySendEmail();

  @override
  List<Object?> get props => [];
}

class TryCallPhone extends DetailEvent {
  const TryCallPhone();

  @override
  List<Object?> get props => [];
}

class TryOpenWhatsApp extends DetailEvent {
  const TryOpenWhatsApp();

  @override
  List<Object?> get props => [];
}

class MarkAsContacted extends DetailEvent {
  final String contactType;
  const MarkAsContacted(this.contactType);

  @override
  List<Object?> get props => [contactType];
}

// NEW: Collapse description event (top-level, not nested!)
class CollapseDescription extends DetailEvent {
  const CollapseDescription();

  @override
  List<Object?> get props => [];
}