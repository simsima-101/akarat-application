class ProductModel {
  final int id;
  final String title;
  final String image;
  final String property_type;
  final String location;
  final double price;
  final String description;
  final int bathrooms;
  final int bedrooms;
  final double square_feet;
  final String posted_on;
  Regulatory_Info regulatory_info;
  Agent agent;
  // final double rating;

  ProductModel({
    required this.id,
    required this.title,
    required this.image,
    required this.property_type,
    required this.location,
    required this.price,
    required this.description,
    required this.bathrooms,
    required this.bedrooms,
    required this.square_feet,
    required this.posted_on,
    required this.regulatory_info,
    required this.agent,

    //required this.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']as int? ??0,
      title: json['title']as String? ??"No Title",
      image: json['media'] as String? ?? "",
      property_type: json['property_type'] as String? ?? "Unknown",
      location: json['location'] as String? ?? "Unknown",
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? "No Description",
      bathrooms: json['bathrooms'] as int? ?? 0,
      bedrooms: json['bedrooms'] as int? ?? 0,
      square_feet: double.tryParse(json['square_feet'].toString()) ?? 0.0,
      posted_on: json['posted_on'] as String? ?? "N/A",
      regulatory_info: json['regulatory_info'] != null
          ? Regulatory_Info.fromJson(json['regulatory_info'])
          : Regulatory_Info(),
      agent: json['agent'] != null ? Agent.fromJson(json['agent']) : Agent(),

      // rating: json['rating']['rate'].toDouble(),
    );
  }
}

class Agent {
String name;
String img;
int rating;
String whatsapp;
String email;

Agent({
   this.name="N/A",
   this.img="N/A",
   this.rating=0,
   this.whatsapp="N/A",
   this.email="N/A",
});
factory Agent.fromJson(Map<String, dynamic> json){
 return Agent(
   name: json['name']as String? ?? "No Name",
   img: json['img']as String? ?? "",
   rating: json['rating']as int? ??0,
   whatsapp: json['whatsapp']as String? ?? "Unknown",
   email: json['email']as String? ?? "Unknown",
 ) ;
}
}

class Regulatory_Info {
   String reference;
  String listed;
  String brocker_license;
  String zone_name;
  int dld_permit_number;
  String agent_license;


  Regulatory_Info({
     this.reference="N/A",
     this.listed="N/A",
     this.brocker_license="N/A",
     this.zone_name="N/A",
     this.dld_permit_number=0,
     this.agent_license="N/A",

    //required this.rating,
  });
   factory Regulatory_Info.fromJson(Map<String, dynamic> json) {
     return Regulatory_Info(
       reference: json['reference']as String? ?? "Unknown",
       listed: json['listed']as String? ?? "Unknown",
       brocker_license: json['broker_license']as String? ?? "Unknown",
       zone_name: json['zone_name']as String? ?? "Unknown",
       dld_permit_number: json['dld_permit_number']as int? ??0,
       agent_license: json['agent_license']as String? ?? "Unknown",
       // rating: json['rating']['rate'].toDouble(),
     );
   }
}