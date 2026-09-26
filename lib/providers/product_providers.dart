import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';

/// PROVIDERS
///
/// Esta capa es el "pegamento" entre el servicio y las vistas.
/// Antes cada vista creaba su propio ProductService y guardaba el estado
/// con setState. Ahora el estado vive aquí y las vistas solo lo LEEN.
///
/// Regla mental:
///   Provider        -> un valor que no cambia (una instancia, una config)
///   FutureProvider  -> algo asíncrono (una llamada a la API)
///   NotifierProvider-> un estado que cambia por acciones del usuario

/// 1. El servicio, disponible para toda la app.
///    Una sola instancia compartida, en vez de una por pantalla.
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});



/// 2. Las categorías del filtro.
///    Riverpod las cachea: aunque varias vistas lo lean, la API se llama UNA vez.
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  final service = ref.watch(productServiceProvider);
  return service.getCategories();
});

/// 3. La categoría seleccionada. Es el único estado "mutable" de la app.
///    null = "Todas".
class CategoriaSeleccionada extends Notifier<String?> {
  /// Valor inicial.
  @override
  String? build() => null;

  /// Si tocas la categoría que ya estaba activa, se desactiva (vuelve a Todas).
  /// Cambiar `state` avisa automáticamente a todo el que esté escuchando.
  void seleccionar(String? slug) {
    state = (state == slug) ? null : slug;
  }
}

final categoriaSeleccionadaProvider =
    NotifierProvider<CategoriaSeleccionada, String?>(CategoriaSeleccionada.new);

/// 4. Los productos a mostrar.
///
///    AQUÍ ESTÁ LO BUENO: este provider "observa" (watch) la categoría.
///    Cuando la categoría cambia, Riverpod vuelve a ejecutar esta función
///    solo, llama a la API y reconstruye la vista. Nadie llamó a setState.
final productsProvider = FutureProvider<List<Product>>((ref) {
  final service = ref.watch(productServiceProvider);
  final slug = ref.watch(categoriaSeleccionadaProvider);

  return slug == null
      ? service.getProducts()
      : service.getProductsByCategory(slug);
});

/// 5. Un producto por id, para la pantalla de detalle.
///    `.family` = un provider que recibe un parámetro (en este caso, el id).
final productByIdProvider = FutureProvider.family<Product, int>((ref, id) {
  final service = ref.watch(productServiceProvider);
  return service.getProductById(id);
});
