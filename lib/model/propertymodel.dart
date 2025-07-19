import 'projectmodel.dart' as projectDetail;
import 'productmodel.dart' as productModel;
import 'searchmodel.dart' as search;


String getFullImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return 'https://via.placeholder.com/400x300.png?text=No+Image';
  }

  if (url.startsWith('http')) {
    return url;
  }

  return 'https://akarat.com/$url';
}




class Property {
  final String id;
  final String title;
  final String description;
  final String image;
  final String price;
  final String location;
  final List<Media>? media;
  final int bedrooms;
  final int bathrooms;
  final String squareFeet;
  final String? phoneNumber;
  final String? whatsapp;
  final String? agent;
  final String? agentImage;
  final String? agencyLogo;
  final String? postedOn;


  bool saved;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.price,
    required this.location,
    required this.media,
    required this.bedrooms,
    required this.bathrooms,
    required this.squareFeet,
    required this.phoneNumber,
    required this.whatsapp,
    this.agent,
    this.agentImage,
    this.agencyLogo,
    this.postedOn,
    this.saved = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'price': price,
      'location': location,
      'media': media?.map((m) => m.toJson()).toList(),
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'square_feet': squareFeet,
      'phone_number': phoneNumber,
      'whatsapp': whatsapp,
      'agent': agent,
      'agent_image': agentImage,
      'agency_logo': agencyLogo,
      'posted_on': postedOn,

      'saved': saved,
    };
  }


  // 🔧 1️⃣ For project detail data
  factory Property.fromProjectDetail(projectDetail.Data data) {
    return Property(
      id: data.id?.toString() ?? '',
      title: data.title ?? '',
      description: data.description ?? '',
      image: getFullImageUrl(
          (data.media != null && data.media!.isNotEmpty)
              ? data.media!.first.originalUrl
              : null
      ),

      price: data.price ?? '',
      location: data.location ?? '',
      media: data.media?.map((m) => Media(originalUrl: m.originalUrl)).toList(),
      bedrooms: data.bedrooms ?? 0,
      bathrooms: data.bathrooms ?? 0,
      squareFeet: data.squareFeet ?? '',
      phoneNumber: data.phoneNumber ?? '',
      whatsapp: data.whatsapp ?? '',
    );
  }

  // 🔧 2️⃣ For product detail data
  factory Property.fromProductModel(productModel.Data data) {
    return Property(
      id: data.id?.toString() ?? '',
      title: data.title ?? '',
      description: data.description ?? '',
      image: getFullImageUrl(
        (data.media != null && data.media!.isNotEmpty)
            ? data.media!.first.originalUrl
            : null,
      ),

      price: data.price ?? '',
      location: data.location ?? '',
      media: data.media?.map((m) => Media(originalUrl: m.originalUrl)).toList(),
      bedrooms: data.bedrooms ?? 0,
      bathrooms: data.bathrooms ?? 0,
      squareFeet: data.squareFeet ?? '',
      phoneNumber: data.phoneNumber ?? '',
      whatsapp: data.whatsapp ?? '',
    );
  }

  // 🔧 3️⃣ For search model data
  factory Property.fromSearchModel(search.Data data) {
    return Property(
      id: data.id?.toString() ?? '',
      title: data.title ?? '',
      description: '',
      image: getFullImageUrl(data.image),

      price: data.price ?? '',
      location: data.location ?? data.address ?? '',
      media: [],
      bedrooms: data.bedrooms ?? 0,
      bathrooms: data.bathrooms ?? 0,
      squareFeet: data.squareFeet ?? '',
      phoneNumber: data.phone ?? '',
      whatsapp: data.whatsapp ?? '',
    );
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    String? rawImage;
    final mediaField = json['media'];

    if (mediaField is List && mediaField.isNotEmpty) {
      final orig = mediaField[0]['original_url']?.toString();
      if (orig != null && orig.isNotEmpty) {
        rawImage = orig; // ✅ Prefer original
      }
    }

    rawImage ??= json['image']?.toString(); // fallback if media is not available



    final fullImageUrl = getFullImageUrl(rawImage);

    int parseInt(dynamic val) {
      if (val is int) return val;
      return int.tryParse(val?.toString() ?? '') ?? 0;
    }

    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      image: fullImageUrl,
      price: json['price']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      media: mediaField is List
          ? mediaField.map((m) => Media.fromJson(m)).toList()
          : [],
      bedrooms: parseInt(json['bedrooms']),
      bathrooms: parseInt(json['bathrooms']),
      squareFeet: json['square_feet']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      agent: json['agent']?.toString(),
      agentImage: json['agent_image']?.toString(),
      agencyLogo: json['agency_logo']?.toString(),
      postedOn: json['posted_on']?.toString(),

    );
  }
}

class ProjectDetailModel {
  Data? data;

  ProjectDetailModel({this.data});

  ProjectDetailModel.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  int? id;
  String? title;
  String? price;
  String? phoneNumber;
  String? whatsapp;
  String? description;
  String? paymentPeriod;
  int? bedrooms;
  int? bathrooms;
  String? propertyType;
  String? agent;
  int? agentId;
  String? agentImage;
  String? deliveryDate;
  int? paymentPlan;
  Null? governmentFee;
  Null? downPayment;
  Null? duringConstruction;
  Null? onHandover;
  String? projectAnnouncement;
  String? constructionStarted;
  String? expectedCompletion;
  List<Media>? media;
  String? location;
  String? squareFeet;
  bool? saved;

  Data({
    this.id,
    this.title,
    this.price,
    this.phoneNumber,
    this.whatsapp,
    this.description,
    this.paymentPeriod,
    this.bedrooms,
    this.bathrooms,
    this.propertyType,
    this.agent,
    this.agentId,
    this.agentImage,
    this.deliveryDate,
    this.paymentPlan,
    this.governmentFee,
    this.downPayment,
    this.duringConstruction,
    this.onHandover,
    this.projectAnnouncement,
    this.constructionStarted,
    this.expectedCompletion,
    this.media,
    this.location,
    this.squareFeet,
    this.saved,
  });

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    price = json['price'];
    phoneNumber = json['phone_number'];
    whatsapp = json['whatsapp'];
    description = json['description'];
    paymentPeriod = json['payment_period'];
    bedrooms = json['bedrooms'];
    bathrooms = json['bathrooms'];
    propertyType = json['property_type'];
    agent = json['agent'];
    agentId = json['agent_id'];
    agentImage = json['agent_image'];
    deliveryDate = json['delivery_date'];
    paymentPlan = json['payment_plan'];
    governmentFee = json['government_fee'];
    downPayment = json['down_payment'];
    duringConstruction = json['during_construction'];
    onHandover = json['on_handover'];
    projectAnnouncement = json['project_announcement'];
    constructionStarted = json['construction_started'];
    expectedCompletion = json['expected_completion'];
    location = json['location'];
    squareFeet = json['square_feet'];
    saved = json['saved'];
    if (json['media'] != null && json['media'] is List) {
      media = (json['media'] as List)
          .map((v) => Media.fromJson(v))
          .toList();
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['price'] = this.price;
    data['phone_number'] = this.phoneNumber;
    data['whatsapp'] = this.whatsapp;
    data['description'] = this.description;
    data['payment_period'] = this.paymentPeriod;
    data['bedrooms'] = this.bedrooms;
    data['bathrooms'] = this.bathrooms;
    data['property_type'] = this.propertyType;
    data['agent'] = this.agent;
    data['agent_id'] = this.agentId;
    data['agent_image'] = this.agentImage;
    data['delivery_date'] = this.deliveryDate;
    data['payment_plan'] = this.paymentPlan;
    data['government_fee'] = this.governmentFee;
    data['down_payment'] = this.downPayment;
    data['during_construction'] = this.duringConstruction;
    data['on_handover'] = this.onHandover;
    data['project_announcement'] = this.projectAnnouncement;
    data['construction_started'] = this.constructionStarted;
    data['expected_completion'] = this.expectedCompletion;
    data['location'] = this.location;
    data['square_feet'] = this.squareFeet;
    if (this.media != null) {
      data['media'] = this.media!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


class Media {
  String? originalUrl;

  Media({this.originalUrl});

  Media.fromJson(Map<String, dynamic> json) {
    originalUrl = json['original_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['original_url'] = this.originalUrl;
    return data;
  }
}


String sanitizeImageUrl(String? url) {
  if (url == null || url.isEmpty) {
    return 'https://via.placeholder.com/400x300.png?text=No+Image';
  }

  return url; // Just return the URL as-is (even if it's a .webp or thumbnail)
}


