class FilterResponseModel {
  bool? success;
  String? message;
  FilterModel? data;

  FilterResponseModel({this.success, this.message, this.data});

  FilterResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? FilterModel.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class FilterModel {
  List<Data>? data;
  Links? links;
  Meta? meta;

  FilterModel({this.data, this.links, this.meta});

  FilterModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null
        ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
        : [];
    links = json['links'] != null ? Links.fromJson(json['links']) : null;
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (links != null) {
      data['links'] = links!.toJson();
    }
    if (meta != null) {
      data['meta'] = meta!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? price;
  String? address;
  String? location;
  String? phoneNumber;
  String? whatsapp;
  String? email;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? squareFeet;
  String? postedOn;
  String? agencyLogo;
  List<Media>? media;
  bool? saved;
  String? agentName;
  String? agentImage;

  // NEW: Accurate size from backend
  double? propertySizeSqft;

  Data({
    this.id,
    this.title,
    this.price,
    this.address,
    this.location,
    this.phoneNumber,
    this.whatsapp,
    this.email,
    this.paymentPeriod,
    this.bedrooms,
    this.bathrooms,
    this.squareFeet,
    this.media,
    this.saved,
    this.agentName,
    this.agentImage,
    this.postedOn,
    this.agencyLogo,
    this.propertySizeSqft, // ← NEW FIELD
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    address = json['address'];
    location = json['location'];
    phoneNumber = json['phone_number'];
    whatsapp = json['whatsapp'];
    paymentPeriod = json['payment_period'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    squareFeet = json['square_feet'];
    saved = json['saved'];
    agentName = json['agent'];
    agentImage = json['agent_image'];
    postedOn = json['posted_on'];
    agencyLogo = json['agency_logo'];
    media = json['media'] != null
        ? List<Media>.from(json['media'].map((v) => Media.fromJson(v)))
        : [];

    // PARSE propertySizeSqft safely
    final sizeVal = json['propertySizeSqft'];
    if (sizeVal != null) {
      if (sizeVal is num) {
        propertySizeSqft = sizeVal.toDouble();
      } else if (sizeVal is String) {
        propertySizeSqft = double.tryParse(sizeVal.trim());
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['price'] = price;
    data['address'] = address;
    data['location'] = location;
    data['phone_number'] = phoneNumber;
    data['whatsapp'] = whatsapp;
    data['payment_period'] = paymentPeriod;
    data['bedrooms'] = bedrooms;
    data['bathrooms'] = bathrooms;
    data['square_feet'] = squareFeet;
    data['agent'] = agentName;
    data['agent_image'] = agentImage;
    data['posted_on'] = postedOn;
    data['agency_logo'] = agencyLogo;
    data['propertySizeSqft'] = propertySizeSqft; // ← include in JSON
    if (media != null) {
      data['media'] = media!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  // SMART SIZE GETTER - NO DECIMAL POINTS EVER
  String get displaySize {
    // 1. Priority: propertySizeSqft (accurate double) → always round to whole number
    if (propertySizeSqft != null && propertySizeSqft! > 0) {
      final size = propertySizeSqft!.round(); // ← Rounds to nearest integer
      final formatted = size.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
      );
      return '$formatted sqft';
    }

    // 2. Fallback: old squareFeet string → clean and round
    if (squareFeet?.isNotEmpty == true && squareFeet != '0' && squareFeet != 'null') {
      final clean = squareFeet!.replaceAll(RegExp(r'[^0-9.]'), '');
      final size = num.tryParse(clean);
      if (size != null && size > 0) {
        final rounded = size.round();
        final formatted = rounded.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
        );
        return '$formatted sqft';
      }
    }

    // Hide if no valid size
    return '';
  }
}

class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['original_url'] = originalUrl;
    return data;
  }
}

class Links {
  String? first;
  String? last;
  String? prev;
  String? next;

  Links({this.first, this.last, this.prev, this.next});

  Links.fromJson(Map<String, dynamic> json) {
    first = json['first'];
    last = json['last'];
    prev = json['prev'];
    next = json['next'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['first'] = first;
    data['last'] = last;
    data['prev'] = prev;
    data['next'] = next;
    return data;
  }
}

class Meta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<MetaLinks>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  Meta({
    this.currentPage,
    this.from,
    this.lastPage,
    this.links,
    this.path,
    this.perPage,
    this.to,
    this.total,
  });

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    from = json['from'];
    lastPage = json['last_page'];
    links = json['links'] != null
        ? List<MetaLinks>.from(json['links'].map((v) => MetaLinks.fromJson(v)))
        : [];
    path = json['path'];
    perPage = json['per_page'];
    to = json['to'];
    total = json['total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['from'] = from;
    data['last_page'] = lastPage;
    if (links != null) {
      data['links'] = links!.map((v) => v.toJson()).toList();
    }
    data['path'] = path;
    data['per_page'] = perPage;
    data['to'] = to;
    data['total'] = total;
    return data;
  }
}

class MetaLinks {
  String? url;
  String? label;
  bool? active;

  MetaLinks({this.url, this.label, this.active});

  MetaLinks.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    label = json['label']?.toString();
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['label'] = label;
    data['active'] = active;
    return data;
  }
}

class FilterParams {
  final String? location;
  final String purpose;
  final String propertyType;
  final String bedroom;
  final String bathroom;
  final String minPrice;
  final String maxPrice;
  final String paymentPeriod;

  FilterParams({
    this.location,
    required this.purpose,
    required this.propertyType,
    required this.bedroom,
    required this.bathroom,
    required this.minPrice,
    required this.maxPrice,
    required this.paymentPeriod,
  });

  Map<String, String> toQueryMap() {
    return {
      if (location != null && location!.isNotEmpty) 'location': location!,
      if (purpose.isNotEmpty) 'purpose': purpose,
      if (propertyType.isNotEmpty) 'property_type': propertyType,
      if (bedroom.isNotEmpty) 'bedrooms': bedroom,
      if (bathroom.isNotEmpty) 'bathrooms': bathroom,
      if (minPrice.isNotEmpty) 'min_price': minPrice,
      if (maxPrice.isNotEmpty) 'max_price': maxPrice,
      if (paymentPeriod.isNotEmpty) 'payment_period': paymentPeriod,
    };
  }
}