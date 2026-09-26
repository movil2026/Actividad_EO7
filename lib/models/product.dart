/// MODELO
///
/// Un modelo es una clase Dart que representa los datos que devuelve la API.
/// La API nos manda JSON (`Map<String, dynamic>`) y nosotros lo convertimos
/// en un objeto tipado para trabajar cómodos y con autocompletado.
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String category;
  final String thumbnail;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.category,
    required this.thumbnail,
  });

  /// Constructor de fábrica: recibe el JSON de un producto y arma el objeto.
  /// Ejemplo del JSON que manda dummyjson.com:
  /// { "id": 1, "title": "Essence Mascara...", "price": 9.99, ... }
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      // La API puede mandar int o double, por eso usamos num -> toDouble()
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
      category: json['category'] as String,
      thumbnail: json['thumbnail'] as String,
    );
  }
}
