// lib/features/property/presentation/bloc/detail_bloc.dart

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/services/api_service.dart';
import '../../data/repositories/property_repository.dart';
import '../../data/models/fdetailmodel.dart';

part 'detail_event.dart';
part 'detail_state.dart';

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final PropertyRepository repository;

  DetailBloc({required this.repository}) : super(const DetailState()) {
    on<LoadPropertyDetail>(_onLoadPropertyDetail);
    on<FetchFullDescription>(_onFetchFullDescription);
    on<ToggleAmenities>(_onToggleAmenities);
    on<TrySendEmail>(_onTrySendEmail);
    on<TryCallPhone>(_onTryCallPhone);
    on<TryOpenWhatsApp>(_onTryOpenWhatsApp);
    on<MarkAsContacted>(_onMarkAsContacted);

    on<CollapseDescription>((event, emit) {
      emit(state.copyWith(hasExpandedDescription: false));
    });
  }

  Future<void> _onLoadPropertyDetail(
      LoadPropertyDetail event,
      Emitter<DetailState> emit,
      ) async {
    emit(state.copyWith(status: DetailStatus.loading));

    try {
      final detail = await repository.fetchPropertyDetail(event.propertyId);

      // Parse permit_response once
      Map<String, dynamic>? permitJson;
      final rawPermit = detail.data?.property?.regulatoryInfo?.permitResponse;
      if (rawPermit != null) {
        if (rawPermit is String && rawPermit.trim().isNotEmpty) {
          try {
            permitJson = jsonDecode(rawPermit) as Map<String, dynamic>?;
          } catch (_) {}
        } else if (rawPermit is Map<String, dynamic>) {
          permitJson = rawPermit;
        }
      }

      final prop = detail.data?.property;

      final imageUrls = prop?.media?.map((m) => m.originalUrl.toString()).toList() ?? [];

      // ── Contact fields (cleaned) ──
      final phone = _cleanPhoneNumber(prop?.phoneNumber);
      final whatsapp = _cleanPhoneNumber(prop?.whatsapp);
      final email = prop?.email?.trim();
      final reference = prop?.reference?.trim();

      // ── Pre-computed display fields ──
      final resolvedAddr = _computeResolvedAddress(prop, permitJson);
      final dispSize = _computeDisplaySizeSqft(prop);
      final cat = prop != null ? _computeCategory(prop) : null;
      final payPlan = _computePaymentPlan(prop, permitJson);
      final dispPrice = _formatPrice(prop?.price);

      // Payment period
      final payPeriodText = prop?.paymentPeriod?.trim();
      final payPeriodDisplay = (payPeriodText != null && payPeriodText.isNotEmpty) ? payPeriodText : null;

      // Beds & Baths
      final bedsCount = prop?.bedrooms ?? 0;
      final bedsTxt = bedsCount > 0 ? '$bedsCount beds' : null;

      final bathsCount = prop?.bathrooms ?? 0;
      final bathsTxt = bathsCount > 0 ? '$bathsCount baths' : null;

      // Title & Location
      final titleRaw = prop?.title?.trim();
      final cleanTitle = (titleRaw != null && titleRaw.isNotEmpty) ? titleRaw : null;

      final locRaw = prop?.location?.toString()?.trim();
      final locName = (locRaw != null && locRaw.isNotEmpty) ? locRaw : null;

      // ── Building Information ──
      final bldName = _dldThenProjectInfoByKeys(permitJson, ['building_name', 'buildingName', 'building'], 'building_name');
      final totalPark = _dldThenProjectInfoByKeys(permitJson, ['total_parking', 'totalParking', 'parking_spaces'], 'total_parking');
      final bldArea = _dldThenProjectInfoByKeys(permitJson, ['building_area', 'buildingArea', 'area'], 'building_area');
      final yearComp = _dldThenProjectInfoByKeys(permitJson, ['year_of_completion', 'yearOfCompletion', 'completion_year'], 'year_of_completion');
      final elev = _dldThenProjectInfoByKeys(permitJson, ['elevators', 'lift_count', 'lifts'], 'elevators');
      final floors = _dldThenProjectInfoByKeys(permitJson, ['total_floors', 'totalFloors', 'floors'], 'total_floors');
      final pools = _dldThenProjectInfoByKeys(permitJson, ['swimming_pools', 'swimmingPools', 'pools'], 'swimming_pools');
      final retail = _dldThenProjectInfoByKeys(permitJson, ['retail_centers', 'retailCenters', 'retail'], 'retail_centers');

      // ── Extra Project fields ──
      final compPerc = _cleanStr(permitJson?['result']?[0]?['completion'] ?? prop?.completionPercentage);
      final govFee = _cleanStr(permitJson?['result']?[0]?['governmentFee'] ?? prop?.governmentFee);
      final delYear = _dldThenProjectInfoByKeys(permitJson, ['delivery_year', 'deliveryYear'], 'delivery_year');
      final projAnnounce = _dldThenProjectInfoByKeys(permitJson, ['project_announcement', 'projectAnnouncement'], 'project_announcement');
      final constStart = _dldThenProjectInfoByKeys(permitJson, ['construction_started', 'constructionStarted'], 'construction_started');
      final expComp = _dldThenProjectInfoByKeys(permitJson, ['expected_completion', 'expectedCompletion'], 'expected_completion');
      final salesStart = _dldThenProjectInfoByKeys(permitJson, ['sales_started', 'salesStarted'], 'sales_started');

      // ── DLD / Official names ──
      final offProjName = _cleanStr(permitJson?['result']?[0]?['project']);
      final offDevName = _cleanStr(permitJson?['result']?[0]?['authorityNameEn']);
      final agencyName = _computeDldAgencyName(permitJson, prop);

      // ── Regulatory fields ──
      String? dldPermitNum = _cleanStr(permitJson?['result']?[0]?['listingNumber'] ?? prop?.regulatoryInfo?.dldPermitNumber);
      String? zone = _cleanStr(
        permitJson?['result']?[0]?['property']?['zoneNameEn'] ??
            permitJson?['result']?[0]?['property']?['zoneNameAr'] ??
            prop?.zoneName,
      );
      String? dedNum = _cleanStr(permitJson?['result']?[0]?['licenseNumber'] ?? prop?.regulatoryInfo?.ded);
      String? reraNum = _cleanStr(prop?.regulatoryInfo?.rera);
      String? brnNum = _cleanStr(prop?.regulatoryInfo?.brn);

      // QR code (base64 only - remove prefix if present)
      String? qrBase64 = prop?.permitInfo?.qr;
      if (qrBase64 != null && qrBase64.contains(',')) {
        qrBase64 = qrBase64.split(',').last.trim();
      }

      // ── Agent info (safe null handling) ──
      final agentName = prop?.agent?.toString().trim();
      final rawAgentImage = prop?.agentImage?.trim();
      final agentImageUrl = (rawAgentImage != null && rawAgentImage.isNotEmpty) ? rawAgentImage : null;
      final agentId = prop?.agentId?.toString();

      // ── Property Details pre-computed fields ──
      final propertyId = prop?.reference?.trim() ?? prop?.id?.toString();
      final propertyType = prop?.propertyType?.trim();
      final listedOn = prop?.postedOn?.trim();

      final formattedPriceWithPeriod = prop?.price != null
          ? () {
        final pricePart = 'AED ${_formatPrice(prop!.price)}';
        final period = prop.paymentPeriod?.trim();
        final periodPart = (period != null && period.isNotEmpty) ? ' / $period' : '';
        return '$pricePart$periodPart';
      }()
          : null;

      final categoryText = prop != null ? _computeCategory(prop) : null;

      // ── Amenities & Map coordinates (main property) ──
      final amenities = prop?.amenities;
      final latitude = double.tryParse(prop?.latitude ?? '');
      final longitude = double.tryParse(prop?.longitude ?? '');

      // ── Recommended Properties (pre-formatted) ──
      final recommendedList = <RecommendedItem>[];

      for (final rec in detail.data?.recommended ?? []) {
        final rawPrice = rec.price?.toString();
        final displayPrice = _formatPrice(rawPrice) ?? '0';

        String displaySize = '';
        String? rawSize = rec.propertySizeSqft ?? rec.squareFeet;
        if (rawSize != null && rawSize.trim().isNotEmpty && rawSize != '0') {
          final clean = rawSize.replaceAll(RegExp(r'[^0-9.]'), '');
          final numSize = num.tryParse(clean);
          if (numSize != null && numSize > 0) {
            displaySize = '${numSize.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (m) => '${m[1]},',
            )} sqft';
          }
        }

        final beds = rec.bedrooms ?? 0;
        final baths = rec.bathrooms ?? 0;
        final location = rec.location?.toString().trim() ?? 'Dubai';
        final imageUrl = rec.media?.isNotEmpty == true ? rec.media!.first.originalUrl.toString() : '';

        recommendedList.add(RecommendedItem(
          id: rec.id.toString(),
          displayPrice: displayPrice,
          beds: beds,
          baths: baths,
          displaySize: displaySize,
          location: location,
          imageUrl: imageUrl,
        ));
      }

      emit(state.copyWith(
        status: DetailStatus.loaded,
        detail: detail,
        permitJson: permitJson,

        // Contact
        phoneNumber: phone,
        whatsappNumber: whatsapp,
        emailAddress: email?.isNotEmpty == true ? email : null,
        referenceNumber: reference?.isNotEmpty == true ? reference : null,

        fullDescription: prop?.description ?? '',

        // Display fields
        resolvedAddress: resolvedAddr,
        displaySizeSqft: dispSize,
        category: cat,
        paymentPlan: payPlan,
        displayPrice: dispPrice,
        paymentPeriodText: payPeriodDisplay,
        bedsText: bedsTxt,
        bathsText: bathsTxt,
        title: cleanTitle,
        locationName: locName,

        // Building
        buildingName: bldName,
        totalParking: totalPark,
        buildingArea: bldArea,
        yearOfCompletion: yearComp,
        elevators: elev,
        totalFloors: floors,
        swimmingPools: pools,
        retailCenters: retail,

        // Project extra
        completionPercentage: compPerc,
        governmentFee: govFee,
        deliveryYear: delYear,
        projectAnnouncementDate: projAnnounce,
        constructionStartDate: constStart,
        expectedCompletionDate: expComp,
        salesStartDate: salesStart,

        // DLD names
        officialProjectName: offProjName,
        officialDeveloperName: offDevName,
        dldAgencyName: agencyName,

        // Regulatory + QR
        dldPermitNumber: dldPermitNum,
        zoneName: zone,
        ded: dedNum,
        rera: reraNum,
        brn: brnNum,
        qrCodeBase64: qrBase64,

        // Recommended
        recommendedProperties: recommendedList,

        // Agent & Images
        imageUrls: imageUrls,
        agentName: agentName,
        agentImageUrl: agentImageUrl,
        agentId: agentId,

        // Property Details fields
        propertyId: propertyId,
        propertyType: propertyType,
        listedOn: listedOn,
        formattedPriceWithPeriod: formattedPriceWithPeriod,
        categoryText: categoryText,

        // Amenities & Map
        amenities: amenities,
        latitude: latitude,
        longitude: longitude,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
  // ────────────────────────────────────────────────
  // Existing handlers (unchanged)
  // ────────────────────────────────────────────────

  Future<void> _onTrySendEmail(TrySendEmail event, Emitter<DetailState> emit) async {
    final email = state.emailAddress;
    if (email == null || email.isEmpty) {
      emit(state.copyWith(contactFeedbackMessage: 'No email address available'));
      return;
    }

    emit(state.copyWith(isContactActionInProgress: true));

    try {
      final ref = state.referenceNumber ?? '—';
      final uri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': 'Property Enquiry – Ref $ref',
          'body':
          'Hello,\n\n'
              'I am interested in your property (Ref: $ref).\n'
              'Could you please provide more information regarding availability, '
              'viewing times, final price, payment plan, etc.?\n\n'
              'Thank you!\n',
        },
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        emit(state.copyWith(contactFeedbackMessage: 'Opening email client...'));
      } else {
        emit(state.copyWith(contactFeedbackMessage: 'No email application found'));
      }
    } catch (_) {
      emit(state.copyWith(contactFeedbackMessage: 'Failed to open email client'));
    } finally {
      emit(state.copyWith(isContactActionInProgress: false));
    }
  }

  Future<void> _onTryCallPhone(TryCallPhone event, Emitter<DetailState> emit) async {
    final phone = state.phoneNumber;
    if (phone == null || phone.isEmpty) {
      emit(state.copyWith(contactFeedbackMessage: 'No phone number available'));
      return;
    }

    emit(state.copyWith(isContactActionInProgress: true));

    try {
      final uri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        emit(state.copyWith(contactFeedbackMessage: 'Cannot make call on this device'));
      }
    } catch (_) {
      // silent fail
    } finally {
      emit(state.copyWith(isContactActionInProgress: false));
    }
  }

  Future<void> _onTryOpenWhatsApp(TryOpenWhatsApp event, Emitter<DetailState> emit) async {
    final wa = state.whatsappNumber;
    if (wa == null || wa.isEmpty) {
      emit(state.copyWith(contactFeedbackMessage: 'No WhatsApp number available'));
      return;
    }

    emit(state.copyWith(isContactActionInProgress: true));

    try {
      final clean = wa.replaceAll(RegExp(r'[^0-9+]'), '');
      final ref = state.referenceNumber ?? '—';
      final message = Uri.encodeComponent(
        "Hello! I'm interested in your property (Ref: $ref). "
            "Could you please share more details (availability, viewing, price, etc.)?",
      );
      final uri = Uri.parse("https://wa.me/$clean?text=$message");

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        emit(state.copyWith(contactFeedbackMessage: 'Cannot open WhatsApp'));
      }
    } catch (_) {
      emit(state.copyWith(contactFeedbackMessage: 'Failed to open WhatsApp'));
    } finally {
      emit(state.copyWith(isContactActionInProgress: false));
    }
  }

  Future<void> _onFetchFullDescription(FetchFullDescription event, Emitter<DetailState> emit) async {
    if (state.hasExpandedDescription) return;

    emit(state.copyWith(isLoadingFullDescription: true));

    try {
      final permit = state.detail?.data?.property?.regulatoryInfo?.dldPermitNumber ?? '';
      final ded = state.detail?.data?.property?.regulatoryInfo?.ded ?? '';

      if (permit.isEmpty || ded.isEmpty) {
        emit(state.copyWith(
          isLoadingFullDescription: false,
          hasExpandedDescription: true,
        ));
        return;
      }

      final uri = ApiService.buildUri(
        'validate-listing/$permit/$ded',
        query: {'isGenerateQrCode': 'true'},
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 12));

      String? officialDesc;
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        officialDesc = (json['result'] as List<dynamic>?)
            ?.firstOrNull?['property']?['propertyDescription']
            ?.toString();
      }

      emit(state.copyWith(
        fullDescription: officialDesc?.isNotEmpty == true ? officialDesc : state.fullDescription,
        hasExpandedDescription: true,
        isLoadingFullDescription: false,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingFullDescription: false,
        hasExpandedDescription: true,
      ));
    }
  }

  void _onToggleAmenities(ToggleAmenities event, Emitter<DetailState> emit) {
    emit(state.copyWith(showAllAmenities: !state.showAllAmenities));
  }

  Future<void> _onMarkAsContacted(MarkAsContacted event, Emitter<DetailState> emit) async {
    emit(state.copyWith(isContactLoading: true));

    try {
      await Future.delayed(const Duration(milliseconds: 900));

      emit(state.copyWith(
        isContactLoading: false,
        hasBeenContacted: true,
        contactFeedbackMessage: 'Marked as contacted',
      ));
    } catch (e) {
      emit(state.copyWith(
        isContactLoading: false,
        contactFeedbackMessage: 'Could not mark as contacted',
      ));
    }
  }

  // ────────────────────────────────────────────────
  // Computation helpers
  // ────────────────────────────────────────────────

  String? _computeResolvedAddress(Property? prop, Map<String, dynamic>? permitJson) {
    if (prop == null) return null;

    String? addr = _readFromDld(permitJson, ['address', 'addressEn', 'addressAr', 'propertyAddress', 'fullAddress']);
    if (addr != null) return addr;

    return _cleanStr(prop.address);
  }

  String? _computeDisplaySizeSqft(Property? prop) {
    if (prop == null) return null;

    String? raw = prop.propertySizeSqft ?? prop.squareFeet;
    if (raw == null || raw.trim().isEmpty || raw == '0' || raw == 'null') return null;

    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    final size = num.tryParse(clean);
    if (size == null || size <= 0) return null;

    final formatted = size.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );

    return '$formatted sqft';
  }

  String _computeCategory(Property prop) {
    final purpose = (prop.purpose ?? '').toLowerCase();
    final type = (prop.propertyType ?? '').toLowerCase();

    if (purpose.contains('rent') || purpose == 'to-rent') return 'Residential Rental';
    if (purpose.contains('sale') || purpose == 'for-sale') {
      if (type.contains(RegExp(r'(apartment|villa|townhouse|penthouse|studio|residential)'))) {
        return 'Residential Sale';
      }
      if (type.contains(RegExp(r'(commercial|office|shop|retail|warehouse)'))) {
        return 'Commercial Sale';
      }
      return 'Residential Sale';
    }
    if (purpose == 'projects') return 'Off-Plan Project';
    return 'Property';
  }

  Map<String, int>? _computePaymentPlan(Property? prop, Map<String, dynamic>? permitJson) {
    final sources = [
      permitJson?['result']?[0],
      permitJson?['result']?[0]?['property'],
      prop?.projectInformation?.toJson(),
      prop?.toJson(),
    ];

    for (final src in sources.whereType<Map<String, dynamic>>()) {
      final plan = _readPaymentPlanFromMap(src);
      if (plan != null && plan.values.any((v) => v > 0)) return plan;
    }
    return null;
  }

  String? _formatPrice(String? price) {
    if (price == null || price == 'null' || price.trim().isEmpty) return null;
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    final number = double.tryParse(cleaned);
    if (number == null) return null;
    return number.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }

  String? _dldThenProjectInfoByKeys(
      Map<String, dynamic>? permitJson,
      List<String> dldKeys,
      String projectInfoKey,
      ) {
    if (permitJson == null) return null;

    String? value;
    final first = permitJson['result']?[0];
    final propMap = first?['property'];

    for (final key in dldKeys) {
      value = _cleanStr(propMap?[key] ?? first?[key]);
      if (value != null && value.isNotEmpty && value != 'null') return value;
    }

    final proj = propMap?['project_information'] ?? first?['project_information'];
    return _cleanStr(proj?[projectInfoKey]);
  }

  String? _computeOfficialProjectName(Map<String, dynamic>? permitJson) {
    return _cleanStr(permitJson?['result']?[0]?['project']);
  }

  String? _computeOfficialDeveloperName(Map<String, dynamic>? permitJson) {
    return _cleanStr(permitJson?['result']?[0]?['authorityNameEn']);
  }

  String? _computeDldAgencyName(Map<String, dynamic>? permitJson, Property? prop) {
    final dld = _cleanStr(permitJson?['result']?[0]?['authorityNameEn']);
    return dld ?? _cleanStr(prop?.agencyName);
  }

  // ────────────────────────────────────────────────
  // Small helpers
  // ────────────────────────────────────────────────

  String? _cleanStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  String? _readFromDld(Map<String, dynamic>? permitJson, List<String> keys) {
    if (permitJson == null) return null;

    final first = permitJson['result']?[0];
    if (first == null) return null;

    final propMap = first['property'];

    for (final key in keys) {
      final v = _cleanStr(propMap?[key] ?? first[key]);
      if (v != null && v.isNotEmpty) return v;
    }

    return null;
  }

  Map<String, int>? _readPaymentPlanFromMap(Map<String, dynamic>? map) {
    if (map == null) return null;

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v > 0 ? v : null;
      if (v is double) return v.round() > 0 ? v.round() : null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(digits);
    }

    int? read(List<String> keys) {
      for (final k in keys) {
        final val = toInt(map[k]);
        if (val != null) return val;
      }
      return null;
    }

    const downKeys = ['down_payment', 'downPayment', 'dp'];
    const duringKeys = ['during_construction', 'duringConstruction', 'dc'];
    const handoverKeys = ['on_handover', 'onHandover', 'handover', 'oh'];

    final dp = read(downKeys);
    final dc = read(duringKeys);
    final oh = read(handoverKeys);

    if (dp != null || dc != null || oh != null) {
      return {
        if (dp != null) 'down_payment': dp,
        if (dc != null) 'during_construction': dc,
        if (oh != null) 'on_handover': oh,
      };
    }

    return null;
  }

  String? _cleanPhoneNumber(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final cleaned = raw.replaceAll(RegExp(r'[^0-9+]'), '').trim();
    return cleaned.isEmpty ? null : cleaned;
  }
}