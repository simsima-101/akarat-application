// lib/screen/featured_detail.dart

import 'dart:async';
import 'dart:convert';


import 'package:Akarat/src/screen/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../device_id.dart';

import '../features/property/data/models/fdetailmodel.dart';
import '../providers/email_enquiry_provider.dart';
import '../core/services/api_service.dart';
import '../utils/shared_preference_manager.dart';
import 'ContactFormScreen.dart';
import 'about_agent.dart';
import 'full_map_screen.dart';
import 'htmlEpandableText.dart';

class Featured_Detail extends StatefulWidget {
  const Featured_Detail({
    super.key,
    required this.data,
  });

  final String data;

  @override
  State<Featured_Detail> createState() => _Featured_DetailState();
}

class _Featured_DetailState extends State<Featured_Detail> {
  Featured_DetailModel? featuredDetailModel;

  Map<String, dynamic>? _projectInfoRaw;

  // login data
  bool isDataRead = false;
  String token = '';
  String email = '';
  String result = '';
  final SharedPreferencesManager prefManager = SharedPreferencesManager();

  bool _hasProjectInfo() {
    return completionPercentage != null ||
        deliveryYear != null ||
        projectAnnouncementDate != null ||
        constructionStartDate != null ||
        expectedCompletionDate != null ||
        salesStartDate != null ||
        governmentFee != null ||
        paymentPeriod != null ||
        resolvedPaymentPlan != null ||
        officialProjectName != null || // ✅ only DLD
        officialDeveloperName != null || // ✅ only DLD
        dldAgencyName != null;
  }

  String _formatDate(String date) {
    try {
      final cleaned = date.split(' ').first;
      final parsed = DateTime.parse(cleaned);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (e) {
      return date;
    }
  }

  // ====== EMAIL CONTROLLERS ======
  final GlobalKey<FormState> _emailFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // ====== FULL DESCRIPTION STATE ======
  bool _isLoadingFullDescription = false;
  bool _hasExpandedDescription = false;
  String _fullDescription = '';

  // ====== COMMON HELPERS ======
  String phoneCallNumber(String rawNumber) {
    return rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  String whatsAppNumber(String rawNumber) {
    return rawNumber.replaceAll(RegExp(r'\D'), '');
  }

  String safeSubstring(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength);
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    String cleaned = price.toString().replaceAll(RegExp(r'[^0-9.]'), '');
    double? number = double.tryParse(cleaned);
    if (number == null) return price.toString();
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(number);
  }

  // ===== permit_response parsed data =====
  Map<String, dynamic>? _permitJson;
  Map<String, dynamic>? _permitResult;
  Map<String, dynamic>? _permitProperty;

  String? _cleanStr(dynamic v) {
    if (v == null) return null;

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    final lower = s.toLowerCase();

    // reject null-ish / default-ish
    const badValues = {
      'null',
      '0',
      '-',
      'n/a',
      'na',
      'none',
      'undefined',
      'test',
      'test company',
      'test companies',
      'developer',
      'unknown',
    };

    if (badValues.contains(lower)) return null;

    // also reject strings that look like placeholders
    if (lower.contains('test') && lower.contains('comp')) return null;

    return s;
  }

  String? get displaySizeSqft {
    final property = featuredDetailModel?.data?.property;
    if (property == null) return null;

    // PRIORITY 1: DLD verified size (most accurate)
    String? raw = property.propertySizeSqft;

    // PRIORITY 2: Fallback to old squareFeet
    if (raw == null || raw.trim().isEmpty || raw == 'null' || raw == '0') {
      raw = property.squareFeet;
    }

    if (raw == null || raw.trim().isEmpty || raw == '0') return null;

    final clean = raw.replaceAll(RegExp(r'[^0-9.]'), '');
    final size = num.tryParse(clean);
    if (size == null || size <= 0) return null;

    final formatted = size.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

    return '$formatted sqft';
  }

  String? _dldStr(dynamic permitResponse, List<String> keys) {
    if (permitResponse == null) return null;

    // permitResponse might be Map or JSON string
    Map<String, dynamic>? map;
    if (permitResponse is Map) {
      map = Map<String, dynamic>.from(permitResponse);
    } else if (permitResponse is String) {
      try {
        map = jsonDecode(permitResponse) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }

    if (map == null) return null;

    for (final k in keys) {
      final v = map[k];
      if (v != null) {
        final s = v.toString().trim();
        if (s.isNotEmpty && s.toLowerCase() != "null" && s != "0") {
          return s;
        }
      }
    }
    return null;
  }

  // ==================== RECOMMENDED CARD: DLD FIRST → recProperty FIELDS ====================

  Map<String, dynamic>? _recPermitFirst(dynamic permitResponse) {
    if (permitResponse is Map<String, dynamic>) {
      final data = permitResponse['data'];
      if (data is List && data.isNotEmpty && data.first is Map) {
        return Map<String, dynamic>.from(data.first);
      }
    }
    return null;
  }

  Map<String, dynamic>? _recPermitProperty(dynamic permitResponse) {
    final first = _recPermitFirst(permitResponse);
    final prop = first?['property'];
    if (prop is Map) return Map<String, dynamic>.from(prop);
    return null;
  }

  String? _recDldStr(dynamic permitResponse, List<String> keys) {
    final prop = _recPermitProperty(permitResponse);
    final first = _recPermitFirst(permitResponse);

    // try property node first
    for (final k in keys) {
      final v = prop?[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }

    // then try first record root
    for (final k in keys) {
      final v = first?[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }

    return null;
  }

  num? _recDldNum(dynamic permitResponse, List<String> keys) {
    final str = _recDldStr(permitResponse, keys);
    if (str == null) return null;
    return num.tryParse(str.replaceAll(',', '').trim());
  }

// ================= PAYMENT PLAN HELPERS (ROBUST) =================

  Map<String, int>? _readPaymentPlanFromMap(Map? mapAny) {
    if (mapAny == null) return null;

    // ✅ allow Map<dynamic,dynamic> also
    final map = Map<String, dynamic>.from(mapAny);

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v > 0 ? v : null;
      if (v is double) return v.round() > 0 ? v.round() : null;

      final s = v.toString().trim();
      if (s.isEmpty) return null;

      final digitsOnly = s.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.isEmpty) return null;

      final parsed = int.tryParse(digitsOnly);
      if (parsed == null || parsed <= 0) return null;
      return parsed;
    }

    int? readAny(List<String> keys, Map<String, dynamic> source) {
      for (final k in keys) {
        final parsed = toInt(source[k]);
        if (parsed != null) return parsed;
      }
      return null;
    }

    const downKeys = ['down_payment', 'downPayment', 'dp'];
    const duringKeys = ['during_construction', 'duringConstruction', 'dc'];
    const handoverKeys = ['on_handover', 'onHandover', 'handover', 'oh'];

    // ✅ 1) DIRECT KEYS FIRST (your case)
    final dpDirect = readAny(downKeys, map);
    final dcDirect = readAny(duringKeys, map);
    final ohDirect = readAny(handoverKeys, map);

    if (dpDirect != null || dcDirect != null || ohDirect != null) {
      return {
        if (dpDirect != null) 'down_payment': dpDirect,
        if (dcDirect != null) 'during_construction': dcDirect,
        if (ohDirect != null) 'on_handover': ohDirect,
      };
    }

    // ✅ 2) Then try nested / formatted payment_plan
    final rawPlan = map['payment_plan_details'] ??
        map['paymentPlanDetails'] ??
        map['payment_plan'];

    if (rawPlan is Map) {
      final m = Map<String, dynamic>.from(rawPlan);
      final dp = readAny(downKeys, m);
      final dc = readAny(duringKeys, m);
      final oh = readAny(handoverKeys, m);
      if (dp != null || dc != null || oh != null) {
        return {
          if (dp != null) 'down_payment': dp,
          if (dc != null) 'during_construction': dc,
          if (oh != null) 'on_handover': oh,
        };
      }
    }

    if (rawPlan is List) {
      int? dp, dc, oh;
      for (final item in rawPlan) {
        if (item is Map) {
          final m = Map<String, dynamic>.from(item);
          final title =
              (m['title'] ?? m['name'] ?? '').toString().toLowerCase();
          final percent = toInt(m['percentage'] ?? m['percent'] ?? m['value']);
          if (percent == null) continue;

          if (title.contains('down')) dp = percent;
          if (title.contains('during') || title.contains('construction'))
            dc = percent;
          if (title.contains('handover')) oh = percent;
        }
      }
      if (dp != null || dc != null || oh != null) {
        return {
          if (dp != null) 'down_payment': dp,
          if (dc != null) 'during_construction': dc,
          if (oh != null) 'on_handover': oh,
        };
      }
    }

    if (rawPlan is String) {
      final parts = rawPlan.split(RegExp(r'[/\-]'));
      if (parts.length >= 3) {
        final dp = toInt(parts[0]);
        final dc = toInt(parts[1]);
        final oh = toInt(parts[2]);
        if (dp != null || dc != null || oh != null) {
          return {
            if (dp != null) 'down_payment': dp,
            if (dc != null) 'during_construction': dc,
            if (oh != null) 'on_handover': oh,
          };
        }
      }
    }

    return null;
  }

// ✅ FINAL resolver: DLD first → project_information second
  Map<String, int>? get resolvedPaymentPlan {
    // 1) DLD permit_response first
    final dldPlan = _readPaymentPlanFromMap(_permitFirst);
    if (dldPlan != null) return dldPlan;

    // 1b) DLD property node
    final dldPropPlan = _readPaymentPlanFromMap(_permitProperty);
    if (dldPropPlan != null) return dldPropPlan;

    // 2) project_information from api/properties
    final infoPlan = _readPaymentPlanFromMap(_projectInfoMap);
    if (infoPlan != null) return infoPlan;

    return null;
  }

  /// ✅ First DLD record (already parsed into _permitResult)
  Map<String, dynamic>? get _permitFirst => _permitResult;

  /// ✅ project_information map (from model or json)
  /// ✅ project_information map (ONLY from json map)
  Map<String, dynamic>? get _projectInfoMap {
    // ✅ priority: raw API
    if (_projectInfoRaw != null) return _projectInfoRaw;

    final p = featuredDetailModel?.data?.property;
    final dataMap = featuredDetailModel?.data?.toJson();

    // ✅ try data.project_information first
    final info1 = dataMap?['project_information'];
    if (info1 is Map<String, dynamic>) return info1;

    // ✅ fallback to property.project_information
    if (p != null) {
      final info2 = p.toJson()['project_information'];
      if (info2 is Map<String, dynamic>) return info2;
    }

    return null;
  }

  /// ✅ If DLD missing -> fallback to project_information key
  String? _dldThenProjectInfo({
    required dynamic dldValue,
    required String projectInfoKey,
    dynamic directPropertyValue, // ✅ optional fallback
  }) {
    final dldClean = _cleanStr(dldValue);
    if (dldClean != null) return dldClean;

    // 1) try direct property field first
    final directClean = _cleanStr(directPropertyValue);
    if (directClean != null) return directClean;

    // 2) then try project_information map
    final info = _projectInfoMap;
    return _cleanStr(info?[projectInfoKey]);
  }

  /// ✅ If DLD missing -> fallback to normal property key
  String? _dldThenProperty({
    required dynamic dldValue,
    required String propertyKey,
  }) {
    final dldClean = _cleanStr(dldValue);
    if (dldClean != null) return dldClean;

    final propMap = featuredDetailModel?.data?.property?.toJson();
    return _cleanStr(propMap?[propertyKey]);
  }

  // ==================== BUILDING INFO (DLD FIRST → project_information) ====================

  String? _readFromDld(List<String> keys) {
    // try inside DLD "property" node first
    for (final k in keys) {
      final v1 = _cleanStr(_permitProperty?[k]);
      if (v1 != null) return v1;
    }

    // then try first root record
    for (final k in keys) {
      final v2 = _cleanStr(_permitFirst?[k]);
      if (v2 != null) return v2;
    }

    return null;
  }

  String? _dldThenProjectInfoByKeys({
    required List<String> dldKeys,
    required String projectInfoKey,
  }) {
    final dld = _readFromDld(dldKeys);
    if (dld != null) return dld;

    final info = _projectInfoMap;
    return _cleanStr(info?[projectInfoKey]);
  }

// ✅ individual building fields
  String? get buildingName => _dldThenProjectInfoByKeys(
        dldKeys: ['building_name', 'buildingName', 'building'],
        projectInfoKey: 'building_name',
      );

  String? get totalParking => _dldThenProjectInfoByKeys(
        dldKeys: ['total_parking', 'totalParking', 'parking_spaces'],
        projectInfoKey: 'total_parking',
      );

  String? get buildingArea => _dldThenProjectInfoByKeys(
        dldKeys: ['building_area', 'buildingArea', 'area'],
        projectInfoKey: 'building_area',
      );

  String? get yearOfCompletion => _dldThenProjectInfoByKeys(
        dldKeys: ['year_of_completion', 'yearOfCompletion', 'completion_year'],
        projectInfoKey: 'year_of_completion',
      );

  String? get elevators => _dldThenProjectInfoByKeys(
        dldKeys: ['elevators', 'lift_count', 'lifts'],
        projectInfoKey: 'elevators',
      );

  String? get totalFloors => _dldThenProjectInfoByKeys(
        dldKeys: ['total_floors', 'totalFloors', 'floors'],
        projectInfoKey: 'total_floors',
      );

  String? get swimmingPools => _dldThenProjectInfoByKeys(
        dldKeys: ['swimming_pools', 'swimmingPools', 'pools'],
        projectInfoKey: 'swimming_pools',
      );

  String? get retailCenters => _dldThenProjectInfoByKeys(
        dldKeys: ['retail_centers', 'retailCenters', 'retail'],
        projectInfoKey: 'retail_centers',
      );

// show section only if any value exists
  bool _hasBuildingInfo() {
    return buildingName != null ||
        totalParking != null ||
        yearOfCompletion != null ||
        elevators != null ||
        totalFloors != null ||
        swimmingPools != null ||
        buildingArea != null ||
        retailCenters != null;
  }

  String? _safeNullable(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  void _parsePermitResponse() {
    try {
      final reg = featuredDetailModel?.data?.property?.regulatoryInfo;
      if (reg == null) return;

      final raw = reg.permitResponse;
      if (raw == null) return;

      dynamic decoded;
      if (raw is String) {
        final cleaned = _cleanStr(raw);
        if (cleaned == null) return;
        decoded = jsonDecode(cleaned);
      } else if (raw is Map<String, dynamic>) {
        decoded = raw;
      } else {
        return;
      }

      _permitJson = decoded as Map<String, dynamic>;
      final result = decoded['result'];

      if (result is List && result.isNotEmpty) {
        final first = result.first;
        if (first is Map<String, dynamic>) {
          _permitResult = first; // Root level
          final prop = first['property']; // THIS IS CRUCIAL
          if (prop is Map<String, dynamic>) {
            _permitProperty = prop; // ← This holds brokerNameEn!
          }
        }
      }
    } catch (e) {
      debugPrint('permit_response parse error: $e');
    }
  }

  // ==================================================================
  // PRIORITY GETTERS: permit_response (DLD verified) → fallback to model
  // ==================================================================

  String? get dldProject => _cleanStr(_permitResult?['project']);
  String? get dldDeveloper => _cleanStr(_permitResult?['authorityNameEn']);

  String? get displayProject =>
      dldProject ?? _cleanStr(featuredDetailModel?.data?.property?.project);

  String? get displayDeveloper =>
      dldDeveloper ?? _cleanStr(featuredDetailModel?.data?.property?.developer);

  String? get displayPropertyType {
    final fromPermit = _cleanStr(_permitProperty?['propertyTypeNameEn']);
    if (fromPermit != null && fromPermit.isNotEmpty) return fromPermit;
    return _cleanStr(featuredDetailModel?.data?.property?.propertyType);
  }

  String? get displayDeliveryDate {
    final fromPermit = _cleanStr(_permitResult?['endDate']);
    if (fromPermit != null) return fromPermit;
    return _cleanStr(featuredDetailModel?.data?.property?.deliveryDate);
  }

  String? get displayZoneName {
    final fromPermit = _cleanStr(_permitProperty?['zoneNameEn']);
    if (fromPermit != null) return fromPermit;
    return _cleanStr(featuredDetailModel?.data?.property?.zoneName);
  }

  String? get displayReference {
    final fromPermit = _cleanStr(_permitResult?['listingNumber']);
    if (fromPermit != null) return fromPermit;
    return _cleanStr(featuredDetailModel?.data?.property?.reference);
  }

  // ==================== FINAL CLEAN GETTERS (API ONLY) ====================

  // Always prefer direct model fields first.
// Fallback to map keys (snake_case + title-case) only if needed.

  // ==================== FINAL CLEAN GETTERS (DLD FIRST) ====================

// ----- Project info fields (priority DLD, fallback project_information) -----

  // ----- Project info fields (priority DLD, fallback direct property, then project_information) -----

  String? get completionPercentage {
    final p = featuredDetailModel?.data?.property;
    final info = _projectInfoMap;

    return _cleanStr(_permitFirst?['completion'] ??
            p?.completionPercentage ??
            info?['completion'] ??
            info?['completion_percentage'] // ✅ add this
        );
  }

  String? get deliveryYear {
    final p = featuredDetailModel?.data?.property;
    return _dldThenProjectInfo(
      dldValue: _permitFirst?['delivery_year'],
      projectInfoKey: 'delivery_year',
      directPropertyValue: p?.deliveryYear,
    );
  }

  String? get projectAnnouncementDate {
    final p = featuredDetailModel?.data?.property;
    return _dldThenProjectInfo(
      dldValue: _permitFirst?['projectAnnouncement'] ??
          _permitFirst?['project_announcement'],
      projectInfoKey: 'project_announcement',
      directPropertyValue: p?.projectAnnouncementDate, // ✅ fallback
    );
  }

  String? get constructionStartDate {
    final p = featuredDetailModel?.data?.property;
    return _dldThenProjectInfo(
      dldValue: _permitFirst?['constructionStarted'] ??
          _permitFirst?['construction_started'],
      projectInfoKey: 'construction_started',
      directPropertyValue: p?.constructionStartDate, // ✅ fallback
    );
  }

  String? get expectedCompletionDate {
    final p = featuredDetailModel?.data?.property;
    return _dldThenProjectInfo(
      dldValue: _permitFirst?['expectedCompletion'] ??
          _permitFirst?['expected_completion'],
      projectInfoKey: 'expected_completion',
      directPropertyValue: p?.expectedCompletionDate, // ✅ fallback
    );
  }

  String? get salesStartDate {
    final p = featuredDetailModel?.data?.property;
    return _dldThenProjectInfo(
      dldValue: _permitFirst?['salesStarted'] ?? _permitFirst?['sales_started'],
      projectInfoKey: 'sales_started',
      directPropertyValue: p?.salesStartDate, // ✅ fallback
    );
  }

  String? get governmentFee {
    final p = featuredDetailModel?.data?.property;
    return _dldThenProjectInfo(
      dldValue:
          _permitFirst?['governmentFee'] ?? _permitFirst?['government_fee'],
      projectInfoKey: 'government_fee',
      directPropertyValue: p?.governmentFee, // ✅ fallback
    );
  }

  String? get paymentPeriod {
    final p = featuredDetailModel?.data?.property;

    // 1) DLD first
    final dld = _cleanStr(
      _permitFirst?['paymentPeriod'] ?? _permitFirst?['payment_period'],
    );
    if (dld != null) return dld;

    // 2) direct property field next
    final direct = _cleanStr(p?.paymentPeriod);
    if (direct != null) return direct;

    // 3) then project_information.payment_period
    final info = _projectInfoMap;
    return _cleanStr(info?['payment_period']);
  }

// ----- DLD Verified block (priority DLD, fallback direct property, then map) -----

  // ==================== PROJECT / DEVELOPER PRIORITY FIX ====================

// Official values ONLY from DLD sources (permit_response or project_information)
// ==================== PROJECT / DEVELOPER STRICT ====================

// ✅ Official values ONLY from DLD permit_response
  String? get officialProjectName {
    return _cleanStr(_permitFirst?['project']);
  }

  String? get officialDeveloperName {
    return _cleanStr(_permitFirst?['authorityNameEn']);
  }

// ✅ Resolved values: DLD first → fallback ONLY to api/properties → else null
  String? get resolvedProjectName {
    final dld = officialProjectName;
    if (dld != null) return dld;

    return _cleanStr(featuredDetailModel?.data?.property?.project);
  }

  String? get resolvedDeveloperName {
    final dld = officialDeveloperName;
    if (dld != null) return dld;

    return _cleanStr(featuredDetailModel?.data?.property?.developer);
  }

  String? get dldAgencyName {
    final p = featuredDetailModel?.data?.property;

    // 1. No DLD permit at all → use user agency
    if (_permitFirst == null) {
      final user = p?.agencyName?.trim();
      debugPrint("No DLD permit → Using user agency: $user");
      return user;
    }

    // 2. ALWAYS take authorityNameEn – even if it's "Test companies"
    // We use raw access + manual trim to avoid any cleaning that removes it
    final rawAuthority = _permitFirst?['authorityNameEn'];
    if (rawAuthority != null && rawAuthority is String) {
      final authorityEn = rawAuthority.toString().trim();

      if (authorityEn.isNotEmpty) {
        debugPrint(
            "Registered Agency → From DLD authorityNameEn: '$authorityEn'");
        return authorityEn; // This will now correctly show "Test companies"
      }
    }

    // 3. Only if authorityNameEn is truly missing/null → fallback
    final userAgency = p?.agencyName?.trim();
    debugPrint(
        "DLD has permit but authorityNameEn missing → Fallback to user: $userAgency");
    return userAgency;
  }

  // ==================== ADDRESS (DLD → data.property → data root) ====================
  String? get resolvedAddress {
    // 1) DLD first (if they ever send it)
    final dld = _readFromDld([
      'address',
      'addressEn',
      'addressAr',
      'propertyAddress',
      'fullAddress',
    ]);
    if (dld != null) return dld;

    // 2) property.address (your usual place)
    final p = featuredDetailModel?.data?.property;
    final propAddr = _cleanStr(p?.address);
    if (propAddr != null) return propAddr;

    // 3) sometimes backend sends address directly under data
    final dataMap = featuredDetailModel?.data?.toJson();
    final rootAddr = _cleanStr(dataMap?['address']);
    if (rootAddr != null) return rootAddr;

    // 4) last fallback
    return null;
  }

  String getCategory() {
    final property = featuredDetailModel?.data?.property;
    if (property == null) return 'Property';

    final purpose = (property.purpose ?? '').toLowerCase();
    final type = (property.propertyType ?? '').toLowerCase();

    if (purpose.contains('rent') || purpose == 'to-rent') {
      return 'Residential Rental';
    }

    if (purpose.contains('sale') || purpose == 'for-sale') {
      if (type.contains('apartment') ||
          type.contains('villa') ||
          type.contains('townhouse') ||
          type.contains('penthouse') ||
          type.contains('studio') ||
          type.contains('residential')) {
        return 'Residential Sale';
      }
      if (type.contains('commercial') ||
          type.contains('office') ||
          type.contains('shop') ||
          type.contains('retail') ||
          type.contains('warehouse')) {
        return 'Commercial Sale';
      }
      return 'Residential Sale';
    }

    if (purpose == 'projects') {
      return 'Off-Plan Project';
    }

    return 'Property';
  }

  List<Widget> _buildProjectInfoRows() {
    final List<Widget> rows = [];
    final property = featuredDetailModel?.data?.property;
    if (property == null) return rows;

    void addRow(String label, String? value) {
      final cleaned = _cleanStr(value);
      if (cleaned == null || cleaned.isEmpty) return;

      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 11.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  cleaned,
                  style: const TextStyle(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Parse permit_response if needed (already parsed globally too)
    final regulatoryInfo = property.regulatoryInfo;
    final permitResponseJson = regulatoryInfo?.permitResponse;

    Map<String, dynamic>? permitResult;
    try {
      if (permitResponseJson is String && permitResponseJson.isNotEmpty) {
        final decoded = jsonDecode(permitResponseJson);
        if (decoded['result'] is List && decoded['result'].isNotEmpty) {
          permitResult = decoded['result'][0];
        }
      } else if (permitResponseJson is Map) {
        final result = permitResponseJson['result'];
        if (result is List && result.isNotEmpty) {
          permitResult = result[0];
        }
      }
    } catch (e) {
      debugPrint("Failed to parse permit_response: $e");
    }

    final propertyFromPermit = permitResult?['property'];

    final price = property.price;
    final address = resolvedAddress;

    final period = property.paymentPeriod;
    final size = displaySizeSqft;
    final propertyType = property.propertyType;
    final postedOn = property.postedOn;
    final reference = property.reference ?? property.id.toString();

    String formatPrice(String? p) {
      if (p == null) return '';
      final num = int.tryParse(p.replaceAll(',', ''));
      if (num == null) return p;
      return NumberFormat('#,##0').format(num);
    }

    addRow('Property ID', reference);
    addRow('Property Type', propertyType);

    addRow('Size', size != null ? '$size' : null);
    addRow('Listed On', postedOn);
    addRow('Category', getCategory());
    addRow(
      'Price',
      price != null
          ? 'AED ${formatPrice(price)}${period != null && period!.isNotEmpty ? ' / $period' : ''}'
          : null,
    );
    addRow(
      'Address',
      address != null ? ' $address' : null,
    );

    return rows;
  }

  Widget _buildDetailRow({
    required String iconPath,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Image.asset(iconPath, height: 18, width: 18),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>?> _fetchListingValidation(String ded) async {
    if (ded.isEmpty) return null;

    final url =
        "https://akarat.com/api/validate-listing/$ded/567315?isGenerateQrCode=true";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json["result"][0];
      }
    } catch (e) {
      debugPrint("Error fetching validate-listing: $e");
    }
    return null;
  }

  // ========= LOGIN / PREFS =========
  void readData() async {
    token = await prefManager.readStringFromPref();
    email = await prefManager.readStringFromPrefemail();
    result = await prefManager.readStringFromPrefresult();

    if (email.isNotEmpty) {
      _emailController.text = email;
      if (_nameController.text.isEmpty) {
        _nameController.text = email.split('@').first;
      }
    }

    setState(() {
      isDataRead = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(
    //   SystemUiMode.manual,
    //   overlays: [SystemUiOverlay.bottom],
    // );
    readData();
    fetchProducts(widget.data);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchFullVerifiedDescription() async {
    if (_hasExpandedDescription) return;

    setState(() => _isLoadingFullDescription = true);

    final property = featuredDetailModel?.data?.property;
    if (property == null) {
      setState(() => _isLoadingFullDescription = false);
      return;
    }

    final permitNumber = property.regulatoryInfo?.dldPermitNumber ?? '';
    final ded = property.regulatoryInfo?.ded ?? '';

    if (permitNumber.isEmpty || ded.isEmpty) {
      setState(() => _isLoadingFullDescription = false);
      return;
    }

    final url =
        'https://akarat.com/api/validate-listing/$permitNumber/$ded?isGenerateQrCode=true';

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final result = json['result'] as List<dynamic>?;

        if (result != null && result.isNotEmpty) {
          final first = result.first;
          final officialDescription =
              first['property']?['propertyDescription']?.toString() ?? '';

          setState(() {
            _fullDescription = officialDescription.trim().isNotEmpty
                ? officialDescription.trim()
                : (property.description ?? '');
            _hasExpandedDescription = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to fetch verified description: $e');
      setState(() {
        _fullDescription = property.description ?? '';
        _hasExpandedDescription = true;
      });
    } finally {
      setState(() => _isLoadingFullDescription = false);
    }
  }

  // ========= PROPERTY FETCHING =========
  Future<void> fetchProducts(String data) async {
    final url = ApiService.buildUri('properties/$data');

    try {
      debugPrint("📡 Fetching property detail: $url");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        // ✅ extract project_information from raw API only
        _projectInfoRaw = jsonData['data']?['project_information'] ??
            jsonData['data']?['property']?['project_information'];

        debugPrint("🟨 RAW project_information: $_projectInfoRaw");
        debugPrint("🟨 RAW project_information keys: ${_projectInfoRaw?.keys}");

        final parsedModel = Featured_DetailModel.fromJson(jsonData);

        if (!mounted) return;
        setState(() => featuredDetailModel = parsedModel);

        _parsePermitResponse();
      } else {
        debugPrint('❌ API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🚨 Unexpected error: $e');
    }
  }

  // ========= OPEN CONTACT FORM DIALOG =========
  Future<void> _showEmailAgentDialog() async {
    final property = featuredDetailModel?.data?.property;
    if (property == null) return;

    final int? propId = property.id;
    if (propId == null) return;

    final String subtitle = property.title ?? '';

    final String ref =
        (property.reference != null && property.reference!.trim().isNotEmpty)
            ? property.reference!.trim()
            : propId.toString();

    final String initialMessage =
        'Hi, I found your property with ref: $ref on Akarat. '
        'Please contact me. Thank you.';

    await showEmailAgentDialog(
      context,
      subtitle: subtitle,
      initialMessage: initialMessage,
      onSubmit: ({
        required String name,
        required String email,
        required String phone,
        required String message,
      }) async {
        // Clean phone -> digits only
        String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
        if (cleanPhone.startsWith('971')) {
          cleanPhone = cleanPhone.substring(3);
        }

        final deviceId = await getDeviceId();
        final emailProvider =
            Provider.of<EmailEnquiryProvider>(context, listen: false);

        final ok = await emailProvider.submitEmailEnquiry(
          propertyId: propId,
          name: name,
          email: email,
          phone: cleanPhone,
          message: message.isEmpty ? '-' : message,
          deviceId: deviceId,
          token: token,
        );

        if (!ok) {
          final msg = emailProvider.lastError ??
              'Failed to submit enquiry. Please try again later.';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(msg), backgroundColor: Colors.red),
            );
          }
          throw Exception(msg);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email enquiry sent successfully')),
            );
          }
        }
      },
    );
  }

  Widget _buildProjectInfoRow(String label, String value,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                color: isBold ? Colors.black87 : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedInput({
    required TextEditingController controller,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          isDense: true,
        ),
        validator: validator,
      ),
    );
  }

  // ========= UI =========
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    if (featuredDetailModel == null) {
      return Scaffold(
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) => const ShimmerCard(),
        ),
      );
    }

    final property = featuredDetailModel!.data!.property!;

    final addressText = resolvedAddress;

    final latStr = property.latitude;
    final lngStr = property.longitude;
    final double latitude = double.tryParse(latStr ?? '') ?? 25.0657;
    final double longitude = double.tryParse(lngStr ?? '') ?? 55.2030;

    final permitResponse = property.regulatoryInfo?.permitResponse;

    // ✅ 2) resolvedSqft defined HERE (same scope as UI)
    final resolvedSqft = displaySizeSqft ?? '';

    final projectInfoRows = _buildProjectInfoRows();

    // ===== build QR widget from base64 (permit_info.qr) =====
    Widget qrWidget = const SizedBox.shrink();
    try {
      final permitInfo = property.permitInfo;
      final qrStr = permitInfo?.qr;
      final url = permitInfo?.url;

      if (qrStr != null && qrStr.trim().isNotEmpty) {
        final String base64Part =
            qrStr.contains(',') ? qrStr.split(',').last.trim() : qrStr.trim();

        final bytes = base64Decode(base64Part);

        qrWidget = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'RERA QR Code',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                if (url == null ||
                    url.trim().isEmpty ||
                    url.toLowerCase() == 'null') return;

                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Could not launch the QR link')),
                  );
                }
              },
              child: Image.memory(bytes, width: 120, height: 120),
            ),
          ],
        );
      }
    } catch (e) {
      debugPrint('⚠️ QR decode error: $e');
      qrWidget = const SizedBox.shrink();
    }

    final periodText = (property.paymentPeriod != null &&
            property.paymentPeriod.toString().trim().isNotEmpty)
        ? "/${property.paymentPeriod}"
        : "";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(30.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFFFFFFF),
          iconTheme: const IconThemeData(color: Colors.red),
        ),
      ),

      /// ====== BOTTOM BAR (Email / Call / WhatsApp) ======
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // EMAIL
              Expanded(
                child: GestureDetector(
                  onTap: _showEmailAgentDialog,
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.email_outlined,
                            size: 20, color: Colors.blue),
                        SizedBox(width: 6),
                        Text(
                          'Email',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // CALL
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final phone = phoneCallNumber(property.phoneNumber ?? '');
                    if (phone.isNotEmpty) {
                      final telUrl = 'tel:$phone';
                      if (await canLaunchUrlString(telUrl)) {
                        await launchUrlString(telUrl,
                            mode: LaunchMode.externalApplication);
                      }
                    }
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.call_outlined, size: 20, color: Colors.red),
                        SizedBox(width: 6),
                        Text(
                          'Call',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // WHATSAPP
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final phoneRaw = property.whatsapp ?? '';
                    final phone = whatsAppNumber(phoneRaw);
                    if (phone.isEmpty) return;

                    final message = Uri.encodeComponent("Hello");
                    final waUrl =
                        Uri.parse("https://wa.me/$phone?text=$message");

                    if (await canLaunchUrl(waUrl)) {
                      await launchUrl(waUrl,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset("assets/images/whats.png", height: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'WhatsApp',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ====== MAIN BODY ======
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // ==== IMAGES ====
            // ==== IMAGES ====
            Container(
              height: screenSize.height * 0.55,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: property.media?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  final imageUrl =
                      property.media![index].originalUrl.toString();

                  return GestureDetector(
                    onTap: () {
                      // Image preview logic remains the same
                      showGeneralDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "ImagePreview",
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (context, animation, secondaryAnimation) {
                          PageController controller =
                              PageController(initialPage: index);
                          return Scaffold(
                            backgroundColor: Colors.black,
                            body: SafeArea(
                              child: Stack(
                                children: [
                                  PageView.builder(
                                    controller: controller,
                                    itemCount: property.media?.length ?? 0,
                                    itemBuilder: (context, pageIndex) {
                                      final previewUrl = property
                                          .media![pageIndex].originalUrl
                                          .toString();
                                      return InteractiveViewer(
                                        child: CachedNetworkImage(
                                          imageUrl: previewUrl,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    top: 20,
                                    right: 20,
                                    child: IconButton(
                                      icon: const Icon(Icons.close,
                                          color: Colors.white, size: 30),
                                      onPressed: () =>
                                          Navigator.of(context).pop(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 200, // Fixed height for each image
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 2.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Container(
                              width: double.infinity,
                              height: 200,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),

            if (addressText != null) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📍",
                      style: TextStyle(fontSize: 16), // adjust size if you want
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        addressText,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ==== PRICE ====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  Text(
                    _formatPrice(property.price),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Text("  AED",
                      style: TextStyle(fontSize: 19, letterSpacing: 0.5)),
                  Text(
                    periodText, // ✅ FIX
                    style: const TextStyle(fontSize: 16, letterSpacing: 0.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ==== BEDS / BATHS / AREA (Smart Conditional Rendering) ====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Beds – only show if > 0
                  if ((property.bedrooms ?? 0) > 0) ...[
                    Image.asset("assets/images/bed.png", height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Text(
                        '${property.bedrooms} beds',
                        style:
                            const TextStyle(fontSize: 14, letterSpacing: 0.5),
                      ),
                    ),
                  ],

                  // Baths – only show if > 0
                  if ((property.bathrooms ?? 0) > 0) ...[
                    // Add left padding only if beds were shown OR this is first visible item
                    if ((property.bedrooms ?? 0) > 0) const SizedBox(width: 15),
                    Image.asset("assets/images/bath.png", height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Text(
                        '${property.bathrooms} baths',
                        style:
                            const TextStyle(fontSize: 14, letterSpacing: 0.5),
                      ),
                    ),
                  ],

                  // SqFt – only show if resolvedSqft is not null, not empty, and not "0"
                  if (resolvedSqft.isNotEmpty && resolvedSqft != '0') ...[
                    // Add spacing only if previous item exists
                    if ((property.bedrooms ?? 0) > 0 ||
                        (property.bathrooms ?? 0) > 0)
                      const SizedBox(width: 15),
                    Image.asset("assets/images/messure.png", height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 3.0),
                      child: Text(
                        '$resolvedSqft',
                        style:
                            const TextStyle(fontSize: 14, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==== TITLE ====
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      property.title ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ==== LOCATION ====
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    property.location.toString(),
                    style: const TextStyle(letterSpacing: 0.5, fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // ==== DESCRIPTION ====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _hasExpandedDescription || _isLoadingFullDescription
                        ? null
                        : _fetchFullVerifiedDescription,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: _isLoadingFullDescription
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 10),
                                Text("Loading full description..."),
                              ],
                            )
                          : HtmlExpandableText(
                              htmlContent: _hasExpandedDescription
                                  ? _fullDescription.replaceAll('\r\n', '<br>')
                                  : (property.description ?? '')
                                      .replaceAll('\r\n', '<br>')
                                      .replaceAll('\n', '<br>'),
                            ),
                    ),
                  ),
                  if (_hasExpandedDescription)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => _hasExpandedDescription = false);
                          },
                          icon: const Icon(Icons.keyboard_arrow_up, size: 18),
                          label: const Text("Read less"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // // ==== POSTED ON ====
            // Row(
            //   children: [
            //     const Padding(
            //       padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            //       child: Text(
            //         "Posted On:",
            //         style: TextStyle(
            //           fontSize: 16,
            //           letterSpacing: 0.5,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //     Text(property.postedOn.toString()),
            //   ],
            // ),

            const SizedBox(height: 5),

            // ==== PROPERTY DETAILS ====
            if (projectInfoRows.isNotEmpty) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Property Details",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ✅ same grey container style as Project Information
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: projectInfoRows,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ✅ BUILDING INFORMATION (after Property Details)
            _buildBuildingInformationSection(),

            const SizedBox(height: 5),

            // ==== PROJECT INFORMATION ====
            if (_hasProjectInfo()) ...[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Project Information",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          if (completionPercentage != null)
                            _buildProjectInfoRow(
                              "Completion",
                              "${completionPercentage!}%",
                            ),

                          if (governmentFee != null)
                            _buildProjectInfoRow(
                              "Government Fee",
                              "${governmentFee!}%",
                            ),

                          if (deliveryYear != null)
                            _buildProjectInfoRow(
                              "Delivery Year",
                              deliveryYear!,
                            ),

                          if (paymentPeriod != null)
                            _buildProjectInfoRow(
                              "Payment Period",
                              paymentPeriod!.toUpperCase(),
                            ),

                          if (projectAnnouncementDate != null)
                            _buildProjectInfoRow(
                              "Project Announcement",
                              _formatDate(projectAnnouncementDate!),
                            ),

                          if (constructionStartDate != null)
                            _buildProjectInfoRow(
                              "Construction Started",
                              _formatDate(constructionStartDate!),
                            ),

                          if (expectedCompletionDate != null)
                            _buildProjectInfoRow(
                              "Expected Completion",
                              _formatDate(expectedCompletionDate!),
                            ),

                          if (salesStartDate != null)
                            _buildProjectInfoRow(
                              "Sales Started",
                              _formatDate(salesStartDate!),
                            ),

                          // ==== PAYMENT PLAN (DLD → project_information → property json) ====
                          Builder(
                            builder: (_) {
                              final plan = resolvedPaymentPlan;

                              if (plan == null || plan.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 28, thickness: 1),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Payment Plan",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                        color: Colors.grey[900],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _planBox(
                                          "${plan['down_payment'] ?? '--'}%",
                                          "Down Payment",
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _planBox(
                                          "${plan['during_construction'] ?? '--'}%",
                                          "During Construction",
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _planBox(
                                          "${plan['on_handover'] ?? '--'}%",
                                          "On Handover",
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),

                          // ==== DLD VERIFIED BLOCK (OFFICIAL ONLY) ====
                          if (officialProjectName != null ||
                              officialDeveloperName != null ||
                              dldAgencyName != null) ...[
                            const Divider(height: 32, thickness: 1),

                            // ✅ Project / Developer ONLY official values
                            if (officialProjectName != null)
                              _buildProjectInfoRow(
                                "Project",
                                officialProjectName!,
                                isBold: true,
                              ),

                            if (officialDeveloperName != null)
                              _buildProjectInfoRow(
                                "Developer",
                                officialDeveloperName!,
                                isBold: true,
                              ),

                            // If you ever want to show registered agency here again:
                            // if (dldAgencyName != null)
                            //   _buildProjectInfoRow("Registered Agency", dldAgencyName!, isBold: true),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 15),

            // ==== LOCATION & NEARBY ====
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text(
                    "Location & nearby",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              height: screenSize.height * 0.3,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.circular(15.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(0.3, 0.3),
                    blurRadius: 0.3,
                    spreadRadius: 0.3,
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(0.0, 0.0),
                    blurRadius: 0.0,
                    spreadRadius: 0.0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(latitude, longitude),
                        zoom: 12,
                      ),
                      zoomControlsEnabled: false,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  resolvedAddress ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  height: 28,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              MyGoogleMapWidget(
                                            latitude: latitude,
                                            longitude: longitude,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("View on map"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            _buildAmenitiesSection(property),

            const SizedBox(height: 10),

            // ==== PROVIDED BY ====
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                  child: Text(
                    "Provided by",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
              child: Column(
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(60.0),
                      boxShadow: const [
                        BoxShadow(color: Colors.grey, blurRadius: 0.1),
                        BoxShadow(color: Colors.white),
                      ],
                    ),
                    child: CachedNetworkImage(
                      imageUrl: (property.agentImage?.isNotEmpty ?? false)
                          ? property.agentImage!
                          : 'https://via.placeholder.com/100',
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      property.agent.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      final String agentId = property.agentId.toString();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutAgent(
                            data: agentId,
                            initialTabIndex: 0, // 🔥 Open "Properties" tab
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 35,
                      width: screenSize.width * 0.5,
                      margin:
                          const EdgeInsets.only(left: 15, right: 10, top: 15),
                      padding: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(8.0),
                        boxShadow: const [
                          BoxShadow(color: Colors.red, blurRadius: 0.5),
                          BoxShadow(color: Colors.white),
                        ],
                      ),
                      child: const Text(
                        "See Agent Details",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 0.5,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 5),

            // ===== Regulatory Information + QR =====
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(
                  left: 18, right: 14, top: 20, bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.5, 0.5),
                      blurRadius: 1,
                      spreadRadius: 0.3),
                ],
              ),
              child: Builder(
                builder: (context) {
                  Map<String, dynamic>? dld;
                  final raw = property.regulatoryInfo?.permitResponse;

                  if (raw != null) {
                    dynamic parsed;
                    if (raw is String && raw.trim().isNotEmpty) {
                      try {
                        parsed = jsonDecode(raw);
                      } catch (_) {
                        parsed = null;
                      }
                    } else if (raw is Map<String, dynamic>) {
                      parsed = raw;
                    }

                    if (parsed is Map<String, dynamic>) {
                      final list = parsed['result'] as List<dynamic>?;
                      if (list != null &&
                          list.isNotEmpty &&
                          list.first is Map<String, dynamic>) {
                        dld = list.first as Map<String, dynamic>;
                      }
                    }
                  }

                  String? get(dynamic dldValue, dynamic userValue) {
                    final d = _cleanStr(dldValue);
                    if (d != null) return d;

                    final u = _cleanStr(userValue);
                    if (u != null) return u;

                    return null;
                  }

                  Widget row(String label, String? value) {
                    if (value == null || value.isEmpty)
                      return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildInfoRow(label, value),
                    );
                  }

                  final hasQr =
                      property.permitInfo?.qr?.trim().isNotEmpty == true ||
                          property.permitInfo?.url?.trim().isNotEmpty == true;

                  return Column(
                    crossAxisAlignment: hasQr
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Regulatory Information",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          if (dld != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "DLD Verified",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      row(
                          "DLD Permit Number",
                          get(
                              dld?['listingNumber'],
                              property.regulatoryInfo?.dldPermitNumber
                                  ?.toString())),
                      row(
                          "Zone",
                          get(
                              dld?['property']?['zoneNameEn'] ??
                                  dld?['property']?['zoneNameAr'],
                              property.zoneName)),
                      row(
                          "DED",
                          get(dld?['licenseNumber'],
                              property.regulatoryInfo?.ded?.toString())),
                      row("RERA",
                          get(null, property.regulatoryInfo?.rera?.toString())),
                      row("BRN",
                          get(null, property.regulatoryInfo?.brn?.toString())),
                      row("Registered Agency", dldAgencyName),
                      const SizedBox(height: 16),
                      if (property.permitInfo?.qr?.trim().isNotEmpty ==
                          true) ...[
                        const Text("RERA QR Code",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Center(
                          child: GestureDetector(
                            onTap: property.permitInfo?.url?.isNotEmpty == true
                                ? () => launchUrl(
                                    Uri.parse(property.permitInfo!.url!))
                                : null,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.memory(
                                base64Decode(property.permitInfo!.qr!
                                    .split(',')
                                    .last
                                    .trim()),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.qr_code, size: 80),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ] else if (property.permitInfo?.url?.isNotEmpty ==
                          true) ...[
                        Center(
                          child: GestureDetector(
                            onTap: () =>
                                launchUrl(Uri.parse(property.permitInfo!.url!)),
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.qr_code_scanner,
                                  size: 80, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            const SizedBox(height: 5),

            // ===== Recommended Properties =====
            // ===== Recommended Properties =====
            if (featuredDetailModel?.data?.recommended != null &&
                featuredDetailModel!.data!.recommended!.isNotEmpty) ...[
              SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: featuredDetailModel?.data?.recommended?.length ?? 0,
                  itemBuilder: (context, index) {
                    final recProperty = featuredDetailModel!.data!.recommended![index];

                    // === Resolve values for recommended property (same logic as main property) ===
                    final int resolvedBeds = recProperty.bedrooms ?? 0;
                    final int resolvedBaths = recProperty.bathrooms ?? 0;

                    // Size: try propertySizeSqft → squareFeet → fallback
                    String displaySize = '';
                    String? rawSize = recProperty.propertySizeSqft;
                    if (rawSize == null || rawSize.trim().isEmpty || rawSize == '0') {
                      rawSize = recProperty.squareFeet;
                    }
                    if (rawSize != null && rawSize.trim().isNotEmpty && rawSize != '0') {
                      final clean = rawSize.replaceAll(RegExp(r'[^0-9.]'), '');
                      final sizeNum = num.tryParse(clean);
                      if (sizeNum != null && sizeNum > 0) {
                        final formatted = sizeNum
                            .toStringAsFixed(0)
                            .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (m) => '${m[1]},');
                        displaySize = '$formatted sqft';
                      }
                    }

                    final String resolvedPrice = _formatPrice(recProperty.price);
                    final String resolvedLocation =
                        recProperty.location?.toString() ?? 'Dubai';

                    final imageUrl = (recProperty.media?.isNotEmpty ?? false)
                        ? recProperty.media!.first.originalUrl.toString()
                        : '';

                    return Container(
                      width: 270,
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      child: Card(
                        color: Colors.white,
                        elevation: 5,
                        shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    Featured_Detail(data: recProperty.id.toString()),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // === IMAGE ===
                              ClipRRect(
                                borderRadius:
                                const BorderRadius.vertical(top: Radius.circular(15)),
                                child: imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    height: 120,
                                    color: Colors.grey[300],
                                    child:
                                    const Icon(Icons.image_not_supported, size: 40),
                                  ),
                                )
                                    : Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child:
                                  const Icon(Icons.image_not_supported, size: 40),
                                ),
                              ),

                              // === CONTENT ===
                              Padding(
                                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Price
                                    Text(
                                      'AED $resolvedPrice',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Beds • Baths • Sqft Row
                                    Row(
                                      children: [
                                        if (resolvedBeds > 0) ...[
                                          const Icon(Icons.king_bed_outlined,
                                              size: 18, color: Colors.redAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$resolvedBeds bed${resolvedBeds > 1 ? 's' : ''}',
                                            style: const TextStyle(fontSize: 13.5),
                                          ),
                                        ],

                                        if (resolvedBeds > 0 && resolvedBaths > 0)
                                          const SizedBox(width: 14),

                                        if (resolvedBaths > 0) ...[
                                          const Icon(Icons.bathtub_outlined,
                                              size: 18, color: Colors.redAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            '$resolvedBaths bath${resolvedBaths > 1 ? 's' : ''}',
                                            style: const TextStyle(fontSize: 13.5),
                                          ),
                                        ],

                                        if ((resolvedBeds > 0 || resolvedBaths > 0) &&
                                            displaySize.isNotEmpty)
                                          const SizedBox(width: 14),

                                        if (displaySize.isNotEmpty) ...[
                                          const Icon(Icons.square_foot,
                                              size: 18, color: Colors.redAccent),
                                          const SizedBox(width: 4),
                                          Text(
                                            displaySize,
                                            style: const TextStyle(fontSize: 13.5),
                                          ),
                                        ],
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // Location
                                    Text(
                                      resolvedLocation,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _planBox(String value, String label) {
    return Container(
      height: 120, // Fixed height → all boxes same size
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.8,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuildingInformationSection() {
    if (!_hasBuildingInfo()) return const SizedBox.shrink();

    Widget row(String label, String? value) {
      final v = _cleanStr(value);
      if (v == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 140,
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13.8,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            Expanded(
              child: Text(
                v,
                style: const TextStyle(
                  fontSize: 13.8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          const Text(
            "Building Information",
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                row("Building Name", buildingName),
                row("Total Parking Space", totalParking),
                row("Building Area", buildingArea),
                row("Year of Completion", yearOfCompletion),
                row("Elevators", elevators),
                row("Total Floors", totalFloors),
                row("Swimming Pools", swimmingPools),
                row("Retail Centers", retailCenters),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesSection(Property property) {
    final amenities = property.amenities;

    if (amenities == null || amenities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),

        // ==== AMENITIES TITLE ====
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            "Amenities",
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 5),

        LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 360;

            return GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: amenities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isSmallScreen ? 1 : 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: isSmallScreen ? 4.5 : 5,
              ),
              itemBuilder: (context, index) {
                final amenity = amenities[index];
                final iconUrl = amenity.icon?.trim();

                return Row(
                  children: [
                    // ✅ Only try to load network image if URL is non-empty
                    if (iconUrl != null && iconUrl.isNotEmpty)
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: Image.network(
                          iconUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // debug print if needed
                            // print('Amenity icon failed: $iconUrl -> $error');
                            return const Icon(Icons.broken_image, size: 18);
                          },
                        ),
                      )
                    else
                      const Icon(Icons.check_circle_outline, size: 18),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        amenity.title ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$title:",
              style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
