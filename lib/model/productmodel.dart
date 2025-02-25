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
      id: json['id'],
      title: json['title'],
      image: json['media'],
      property_type: json['property_type'],
      location: json['location'],
      price: json['price'].toDouble(),
       description: json['description'],
      bathrooms: json['bathrooms'],
      bedrooms: json['bedrooms'],
      square_feet: json['square_feet'],
      posted_on: json['posted_on'],
      regulatory_info: Regulatory_Info.fromJson(json['regulatory_info']),
      agent: Agent.fromJson(json['agent']),

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
  required this.name,
  required this.img,
  required this.rating,
  required this.whatsapp,
  required this.email,
});
factory Agent.fromJson(Map<String, dynamic> json){
 return Agent(
   name: json['name'],
   img: json['img'],
   rating: json['rating'],
   whatsapp: json['whatsapp'],
   email: json['email'],
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
    required this.reference,
    required this.listed,
    required this.brocker_license,
    required this.zone_name,
    required this.dld_permit_number,
    required this.agent_license,

    //required this.rating,
  });
   factory Regulatory_Info.fromJson(Map<String, dynamic> json) {
     return Regulatory_Info(
       reference: json['reference'],
       listed: json['listed'],
       brocker_license: json['broker_license'],
       zone_name: json['zone_name'],
       dld_permit_number: json['dld_permit_number'],
       agent_license: json['agent_license'],
       // rating: json['rating']['rate'].toDouble(),
     );
   }
}