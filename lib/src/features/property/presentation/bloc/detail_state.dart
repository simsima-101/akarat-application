part of 'detail_bloc.dart';

enum DetailStatus { initial, loading, loaded, error }

class DetailState extends Equatable {
  // ── Core status & data ──
  final DetailStatus status;
  final Featured_DetailModel? detail;
  final Map<String, dynamic>? permitJson;
  final String? fullDescription;

  // ── UI toggles & loading states ──
  final bool hasExpandedDescription;
  final bool isLoadingFullDescription;
  final bool showAllAmenities;
  final bool isContactLoading;

  // ── Error & feedback ──
  final String? errorMessage;
  final bool isContactActionInProgress;
  final String? contactFeedbackMessage;

  // ── Contact information (cleaned & ready to use) ──
  final String? phoneNumber;
  final String? whatsappNumber;
  final String? emailAddress;
  final String? referenceNumber;

  // ── Contact tracking ──
  final bool hasBeenContacted;

  // ── Pre-computed / formatted fields ──
  final String? resolvedAddress;
  final String? displaySizeSqft;
  final String? category;
  final Map<String, int>? paymentPlan;
  final String? displayPrice;
  final String? paymentPeriodText;
  final String? bedsText;
  final String? bathsText;
  final String? title;
  final String? locationName;

  // ── Building Information fields ──
  final String? buildingName;
  final String? totalParking;
  final String? buildingArea;
  final String? yearOfCompletion;
  final String? elevators;
  final String? totalFloors;
  final String? swimmingPools;
  final String? retailCenters;

  // ── Project Information fields (extra dates & percentages) ──
  final String? completionPercentage;
  final String? governmentFee;
  final String? deliveryYear;
  final String? projectAnnouncementDate;
  final String? constructionStartDate;
  final String? expectedCompletionDate;
  final String? salesStartDate;

  // ── DLD / Official names ──
  final String? officialProjectName;
  final String? officialDeveloperName;
  final String? dldAgencyName;

  // ── Regulatory / QR fields ──
  final String? dldPermitNumber;
  final String? zoneName;
  final String? ded;
  final String? rera;
  final String? brn;
  final String? qrCodeBase64;

  // ── Recommended Properties (pre-formatted) ──
  final List<RecommendedItem> recommendedProperties;

  final List<String> imageUrls;
  final String? agentName;
  final String? agentImageUrl;
  final String? agentId;

  final String? categoryText;

  final String? propertyId;
  final String? propertyType;
  final String? listedOn;
  final String? formattedPriceWithPeriod;

  // ── Amenities (full list from Bloc) ──
  final List<Amenities>? amenities;

  // ── Map coordinates (pre-parsed) ──
  final double? latitude;
  final double? longitude;

  const DetailState({
    this.status = DetailStatus.initial,
    this.detail,
    this.permitJson,
    this.fullDescription,
    this.hasExpandedDescription = false,
    this.isLoadingFullDescription = false,
    this.showAllAmenities = false,
    this.isContactLoading = false,
    this.errorMessage,
    this.isContactActionInProgress = false,
    this.contactFeedbackMessage,
    this.phoneNumber,
    this.whatsappNumber,
    this.emailAddress,
    this.referenceNumber,
    this.hasBeenContacted = false,

    // Pre-computed fields
    this.resolvedAddress,
    this.displaySizeSqft,
    this.category,
    this.paymentPlan,
    this.displayPrice,
    this.paymentPeriodText,
    this.bedsText,
    this.bathsText,
    this.title,
    this.locationName,

    // Building
    this.buildingName,
    this.totalParking,
    this.buildingArea,
    this.yearOfCompletion,
    this.elevators,
    this.totalFloors,
    this.swimmingPools,
    this.retailCenters,

    // Project extra
    this.completionPercentage,
    this.governmentFee,
    this.deliveryYear,
    this.projectAnnouncementDate,
    this.constructionStartDate,
    this.expectedCompletionDate,
    this.salesStartDate,

    // DLD names
    this.officialProjectName,
    this.officialDeveloperName,
    this.dldAgencyName,

    // Regulatory + QR
    this.dldPermitNumber,
    this.zoneName,
    this.ded,
    this.rera,
    this.brn,
    this.qrCodeBase64,

    // Recommended
    this.recommendedProperties = const [],
    this.imageUrls = const [],
    this.agentName,
    this.agentImageUrl,
    this.agentId,

    this.categoryText,

    this.propertyId,
    this.propertyType,
    this.listedOn,
    this.formattedPriceWithPeriod,

    this.amenities,
    this.latitude,
    this.longitude,
  });

  DetailState copyWith({
    DetailStatus? status,
    Featured_DetailModel? detail,
    Map<String, dynamic>? permitJson,
    String? fullDescription,
    bool? hasExpandedDescription,
    bool? isLoadingFullDescription,
    bool? showAllAmenities,
    bool? isContactLoading,
    String? errorMessage,
    bool? isContactActionInProgress,
    String? contactFeedbackMessage,
    String? phoneNumber,
    String? whatsappNumber,
    String? emailAddress,
    String? referenceNumber,
    bool? hasBeenContacted,

    String? resolvedAddress,
    String? displaySizeSqft,
    String? category,
    Map<String, int>? paymentPlan,
    String? displayPrice,
    String? paymentPeriodText,
    String? bedsText,
    String? bathsText,
    String? title,
    String? locationName,

    String? buildingName,
    String? totalParking,
    String? buildingArea,
    String? yearOfCompletion,
    String? elevators,
    String? totalFloors,
    String? swimmingPools,
    String? retailCenters,

    String? completionPercentage,
    String? governmentFee,
    String? deliveryYear,
    String? projectAnnouncementDate,
    String? constructionStartDate,
    String? expectedCompletionDate,
    String? salesStartDate,

    String? officialProjectName,
    String? officialDeveloperName,
    String? dldAgencyName,

    String? dldPermitNumber,
    String? zoneName,
    String? ded,
    String? rera,
    String? brn,
    String? qrCodeBase64,

    List<RecommendedItem>? recommendedProperties,
    List<String>? imageUrls,

    String? agentName,
    String? agentImageUrl,
    String? agentId,

    String? categoryText,

    String? propertyId,
    String? propertyType,
    String? listedOn,
    String? formattedPriceWithPeriod,

    List<Amenities>? amenities,
    double? latitude,
    double? longitude,
  }) {
    return DetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      permitJson: permitJson ?? this.permitJson,
      fullDescription: fullDescription ?? this.fullDescription,
      hasExpandedDescription: hasExpandedDescription ?? this.hasExpandedDescription,
      isLoadingFullDescription: isLoadingFullDescription ?? this.isLoadingFullDescription,
      showAllAmenities: showAllAmenities ?? this.showAllAmenities,
      isContactLoading: isContactLoading ?? this.isContactLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isContactActionInProgress: isContactActionInProgress ?? this.isContactActionInProgress,
      contactFeedbackMessage: contactFeedbackMessage ?? this.contactFeedbackMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      hasBeenContacted: hasBeenContacted ?? this.hasBeenContacted,

      resolvedAddress: resolvedAddress ?? this.resolvedAddress,
      displaySizeSqft: displaySizeSqft ?? this.displaySizeSqft,
      category: category ?? this.category,
      paymentPlan: paymentPlan ?? this.paymentPlan,
      displayPrice: displayPrice ?? this.displayPrice,
      paymentPeriodText: paymentPeriodText ?? this.paymentPeriodText,
      bedsText: bedsText ?? this.bedsText,
      bathsText: bathsText ?? this.bathsText,
      title: title ?? this.title,
      locationName: locationName ?? this.locationName,

      buildingName: buildingName ?? this.buildingName,
      totalParking: totalParking ?? this.totalParking,
      buildingArea: buildingArea ?? this.buildingArea,
      yearOfCompletion: yearOfCompletion ?? this.yearOfCompletion,
      elevators: elevators ?? this.elevators,
      totalFloors: totalFloors ?? this.totalFloors,
      swimmingPools: swimmingPools ?? this.swimmingPools,
      retailCenters: retailCenters ?? this.retailCenters,

      completionPercentage: completionPercentage ?? this.completionPercentage,
      governmentFee: governmentFee ?? this.governmentFee,
      deliveryYear: deliveryYear ?? this.deliveryYear,
      projectAnnouncementDate: projectAnnouncementDate ?? this.projectAnnouncementDate,
      constructionStartDate: constructionStartDate ?? this.constructionStartDate,
      expectedCompletionDate: expectedCompletionDate ?? this.expectedCompletionDate,
      salesStartDate: salesStartDate ?? this.salesStartDate,

      officialProjectName: officialProjectName ?? this.officialProjectName,
      officialDeveloperName: officialDeveloperName ?? this.officialDeveloperName,
      dldAgencyName: dldAgencyName ?? this.dldAgencyName,

      dldPermitNumber: dldPermitNumber ?? this.dldPermitNumber,
      zoneName: zoneName ?? this.zoneName,
      ded: ded ?? this.ded,
      rera: rera ?? this.rera,
      brn: brn ?? this.brn,
      qrCodeBase64: qrCodeBase64 ?? this.qrCodeBase64,

      recommendedProperties: recommendedProperties ?? this.recommendedProperties,
      imageUrls: imageUrls ?? this.imageUrls,

      agentName: agentName ?? this.agentName,
      agentImageUrl: agentImageUrl ?? this.agentImageUrl,
      agentId: agentId ?? this.agentId,

      categoryText: categoryText ?? this.categoryText,
      propertyId: propertyId ?? this.propertyId,
      propertyType: propertyType ?? this.propertyType,
      listedOn: listedOn ?? this.listedOn,
      formattedPriceWithPeriod: formattedPriceWithPeriod ?? this.formattedPriceWithPeriod,

      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // ── Lightweight convenience getters ──
  bool get isLoading => status == DetailStatus.loading;
  bool get isLoaded => status == DetailStatus.loaded;
  bool get isError => status == DetailStatus.error;
  bool get hasDetail => detail != null;
  Property? get property => detail?.data?.property;

  bool get hasBuildingInfo => [
    buildingName,
    totalParking,
    buildingArea,
    yearOfCompletion,
    elevators,
    totalFloors,
    swimmingPools,
    retailCenters,
  ].any((v) => v != null && v.trim().isNotEmpty);

  bool get hasExtraProjectInfo => [
    completionPercentage,
    governmentFee,
    deliveryYear,
    projectAnnouncementDate,
    constructionStartDate,
    expectedCompletionDate,
    salesStartDate,
  ].any((v) => v != null && v.trim().isNotEmpty);

  bool get hasQrCode => qrCodeBase64 != null && qrCodeBase64!.trim().isNotEmpty;

  bool get hasRecommended => recommendedProperties.isNotEmpty;

  bool get hasProjectInfo =>
      completionPercentage != null ||
          governmentFee != null ||
          deliveryYear != null ||
          projectAnnouncementDate != null ||
          constructionStartDate != null ||
          expectedCompletionDate != null ||
          salesStartDate != null ||
          paymentPlan != null && paymentPlan!.isNotEmpty ||
          officialProjectName != null ||
          officialDeveloperName != null ||
          dldAgencyName != null;

  @override
  List<Object?> get props => [
    status,
    detail,
    permitJson,
    fullDescription,
    hasExpandedDescription,
    isLoadingFullDescription,
    showAllAmenities,
    isContactLoading,
    errorMessage,
    isContactActionInProgress,
    contactFeedbackMessage,
    phoneNumber,
    whatsappNumber,
    emailAddress,
    referenceNumber,
    hasBeenContacted,
    resolvedAddress,
    displaySizeSqft,
    category,
    paymentPlan,
    displayPrice,
    paymentPeriodText,
    bedsText,
    bathsText,
    title,
    locationName,
    buildingName,
    totalParking,
    buildingArea,
    yearOfCompletion,
    elevators,
    totalFloors,
    swimmingPools,
    retailCenters,
    completionPercentage,
    governmentFee,
    deliveryYear,
    projectAnnouncementDate,
    constructionStartDate,
    expectedCompletionDate,
    salesStartDate,
    officialProjectName,
    officialDeveloperName,
    dldAgencyName,
    dldPermitNumber,
    zoneName,
    ded,
    rera,
    brn,
    qrCodeBase64,
    recommendedProperties,
    imageUrls,
    agentName,
    agentImageUrl,
    agentId,
    categoryText,
    propertyId,
    propertyType,
    listedOn,
    formattedPriceWithPeriod,
    amenities,
    latitude,
    longitude,
  ];
}

// ── Simple data class for recommended items ──
class RecommendedItem extends Equatable {
  final String id;
  final String displayPrice;
  final int beds;
  final int baths;
  final String displaySize;
  final String location;
  final String imageUrl;

  const RecommendedItem({
    required this.id,
    required this.displayPrice,
    required this.beds,
    required this.baths,
    required this.displaySize,
    required this.location,
    required this.imageUrl,
  });

  @override
  List<Object?> get props => [id, displayPrice, beds, baths, displaySize, location, imageUrl];
}