import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/hair.dart';
import '../models/user.dart';

/// SERVICIO
///
/// Mismo papel que ProductService: es el único sitio que sabe URLs y JSON.
/// Si mañana la API cambia, se toca este archivo y nada más.
class UserService {
  static const String _baseUrl = 'https://dummyjson.com';

  /// GET /users -> lista de usuarios
  ///
  /// Responde { "users": [...], "total": 208, "skip": 0, "limit": 20 }
  Future<List<User>> getUsers({int limit = 20}) async {
    final url = Uri.parse('$_baseUrl/users?limit=$limit');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar usuarios (${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> jsonList = data['users'];
    return jsonList.map((json) => User.fromJson(json)).toList();
  }

  /// Colores de pelo para el filtro.
  ///
  /// DIFERENCIA CON PRODUCTOS: los productos tenían un endpoint
  /// /products/categories que ya te daba la lista hecha. Para el pelo NO
  /// existe nada parecido, así que la deducimos nosotros:
  ///
  ///   limit=0      -> "mándamelos todos" (no 20, todos los 208)
  ///   select=hair  -> "pero de cada uno solo el pelo"
  ///
  /// Traer 208 usuarios enteros para leerles un campo sería un desperdicio;
  /// con `select` la respuesta baja a unos pocos KB.
  Future<List<String>> getHairColors() async {
    final url = Uri.parse('$_baseUrl/users?limit=0&select=hair');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar los colores (${response.statusCode})');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> jsonList = data['users'];

    // Set = lista que NO admite repetidos. Le metemos 208 colores y se queda
    // solo con los distintos. Con una List habría que ir preguntando "¿ya está?".
    final colores = <String>{};
    for (final json in jsonList) {
      // Reutilizamos Hair: la respuesta trae solo el campo "hair", pero se
      // convierte igual que cuando viene dentro de un usuario completo.
      final hair = Hair.fromJson(
        json['hair'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      );
      if (hair.color.isNotEmpty) colores.add(hair.color);
    }

    // Ordenados alfabéticamente para que los chips no bailen entre recargas.
    return colores.toList()..sort();
  }

  /// GET /users/filter?key=hair.color&value=Brown -> usuarios de UN color
  ///
  /// `key` acepta rutas con punto para entrar en objetos anidados: por eso
  /// "hair.color" y no "color". Y `limit=0` para que no nos corte en 30.
  Future<List<User>> getUsersByHairColor(String color) async {
    // encodeComponent por si el color llevara espacios o caracteres raros.
    final valor = Uri.encodeComponent(color);
    final url = Uri.parse(
      '$_baseUrl/users/filter?key=hair.color&value=$valor&limit=0',
    );
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al filtrar por el color $color');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> jsonList = data['users'];
    return jsonList.map((json) => User.fromJson(json)).toList();
  }

  /// GET /users/{id} -> un solo usuario (aquí el JSON viene suelto, sin "users")
  Future<User> getUserById(int id) async {
    final url = Uri.parse('$_baseUrl/users/$id');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('No se encontró el usuario $id');
    }

    return User.fromJson(jsonDecode(response.body));
  }
}
