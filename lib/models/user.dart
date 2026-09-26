import 'hair.dart';

/// MODELO
///
/// Representa un usuario de https://dummyjson.com/users
///
/// OJO, este JSON no es plano como el de Product: trae objetos DENTRO del
/// objeto ("hair", "address", "company"). En Dart eso llega como un Map
/// dentro de otro Map, así que hay que bajar un nivel más para sacar el dato:
///
///   { "firstName": "Emily", "hair": { "color": "Brown", "type": "Curly" } }
///                                     ^^^^^^^^^^^^^^^^ esto es hair['color']
///
/// Con "hair" hacemos lo correcto: como en el JSON es un objeto, aquí es una
/// clase ([Hair]) y User solo la guarda. Los datos de address y company los
/// aplanamos porque solo usamos un par de campos sueltos de cada uno; el día
/// que necesitemos más, les tocará su propia clase igual que a Hair.
class User {
  final int id;
  final String firstName;
  final String lastName;
  final int age;
  final String gender;
  final String email;
  final String phone;
  final String image;

  /// El objeto anidado, ya convertido. Se lee `usuario.hair.color`.
  final Hair hair;

  final String city;
  final String country;
  final String university;
  final String companyTitle;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.gender,
    required this.email,
    required this.phone,
    required this.image,
    required this.hair,
    required this.city,
    required this.country,
    required this.university,
    required this.companyTitle,
  });

  /// Getter: no se guarda, se calcula al pedirlo. Así el nombre completo se
  /// arma en UN sitio y no en cada vista.
  String get nombreCompleto => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    // Los sub-objetos del JSON. Si alguno no viniera (la API permite pedir
    // solo ciertos campos con `select`), usamos un mapa vacío y no revienta.
    const vacio = <String, dynamic>{};
    final address = json['address'] as Map<String, dynamic>? ?? vacio;
    final company = json['company'] as Map<String, dynamic>? ?? vacio;

    return User(
      id: json['id'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      image: json['image'] as String? ?? '',
      // Aquí está la delegación: User no sabe cómo es el pelo por dentro,
      // se lo pregunta a Hair.
      hair: Hair.fromJson(json['hair'] as Map<String, dynamic>? ?? vacio),
      city: address['city'] as String? ?? '',
      country: address['country'] as String? ?? '',
      university: json['university'] as String? ?? '',
      companyTitle: company['title'] as String? ?? '',
    );
  }
}
