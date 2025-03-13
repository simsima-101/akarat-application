class AgentsModel {
 final int id;
 final String name;
 final String email;
 final String languages;
 final String expertise;
 final String agency;
 final int sale;
 final int rent;
 final String image;

  AgentsModel(
      {required this.id,
        required this.name,
        required this.email,
        required this.languages,
        required this.expertise,
        required this.agency,
        required this.sale,
        required this.rent,
        required  this.image});

  /*AgentsModel.fromJson(Map<String, dynamic> json, this.id, this.userId, this.name, this.email, this.languages, this.expertise,
      this.about, this.address, this.experience, this.image) */

 factory AgentsModel.fromJson(Map<String, dynamic> json) {
   if (json == null || json.isEmpty) {
     return AgentsModel(
       id: 0,
       name: 'na',
       email: 'na',
       languages: 'na',
       expertise: 'na',
       sale: 0,
       rent: 0,
       image: 'https://example.com/default_image.jpg',
       agency: 'na',
     );
   }

   return AgentsModel(
     id: json['id'] ?? 0,
     name: json['name'] ?? 'na',
     image: json['image'] ?? 'https://example.com/default_image.jpg',
     email: json['email'] ?? 'na',
     languages: json['languages'] ?? 'na',
     expertise: json['expertise'] ?? 'na',
     agency: json['agency'] ?? 'na',
     sale: json['sale'] ?? 0,
     rent: json['rent'] ?? 0,
   );
 }

}