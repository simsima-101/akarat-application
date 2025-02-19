class Product {
  final int id;
  final String title;
  final double price;
 // final String description;
  final String category;
  final String image;
 // final double rating;

  Product({
    required this.id,
    required this.title,
    required this.price,
   // required this.description,
    required this.category,
    required this.image,
    //required this.rating,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
     // price: json['price'],
       price: json['price'].toDouble(),
     // description: json['description'],
      category: json['address'],
      image: json['media']['original_url'],
     // rating: json['rating']['rate'].toDouble(),
    );
  }
}
