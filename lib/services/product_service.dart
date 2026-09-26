import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/product.dart';


class ProductService {
  /// URL base de la API fake (https://dummyjson.com/docs/products)
  static const String _baseUrl = 'https://dummyjson.com';

  /// GET /products -> lista de productos
  Future<List<Product>> getProducts({int limit = 20}) async {
    final url = Uri.parse('$_baseUrl/products?limit=$limit');

    // 1. Pedimos los datos a la API (await = espera la respuesta)
    final response = await http.get(url);

    // 2. Revisamos que todo haya salido bien (200 = OK)
    if (response.statusCode != 200) {
      throw Exception('Error al cargar productos (${response.statusCode})');
    }

    // 3. Convertimos el texto JSON en un Map de Dart
    final Map<String, dynamic> data = jsonDecode(response.body);

    // 4. La API responde { "products": [...], "total": 194, ... }
    //    Nos quedamos con la lista y la mapeamos a objetos Product.
    final List<dynamic> jsonList = data['products'];
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }

  /// GET /products/categories -> lista de categorías para el filtro
  ///
  /// Ojo: aquí la API responde un ARRAY directo (no un objeto con "products"),
  /// por eso el jsonDecode nos da una List y no un Map.
  Future<List<Category>> getCategories() async {
    final url = Uri.parse('$_baseUrl/products/categories');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar categorías (${response.statusCode})');
    }

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.map((json) => Category.fromJson(json)).toList();
  }

  /// GET /products/category/{slug} -> productos de UNA categoría
  ///
  /// Responde igual que /products: { "products": [...], "total": ... }
  Future<List<Product>> getProductsByCategory(String slug) async {
    final url = Uri.parse('$_baseUrl/products/category/$slug');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar la categoría $slug');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final List<dynamic> jsonList = data['products'];
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }

  /// GET /products/{id} -> un solo producto
  Future<Product> getProductById(int id) async {
    final url = Uri.parse('$_baseUrl/products/$id');
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('No se encontró el producto $id');
    }

    return Product.fromJson(jsonDecode(response.body));
  }
}
