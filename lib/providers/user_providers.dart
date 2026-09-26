import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/user_service.dart';

/// PROVIDERS (usuarios)
///
/// Copia calcada de product_providers.dart. Esa es la gracia: una vez
/// entendido el patrón, cambiar "categoría de producto" por "color de pelo"
/// es cambiar nombres, no arquitectura.
///
///   Provider         -> un valor fijo (el servicio)
///   FutureProvider   -> algo asíncrono (la API)
///   NotifierProvider -> un estado que cambia cuando el usuario toca algo

/// 1. El servicio, uno solo para toda la app.
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

/// 2. Los colores de pelo del filtro.
///    Son `String` pelados, no hay modelo: la API no devuelve un objeto con
///    slug y nombre como pasaba con Category, solo el texto "Brown". Crear una
///    clase con un único campo String no aportaría nada.
final hairColorsProvider = FutureProvider<List<String>>((ref) {
  final service = ref.watch(userServiceProvider);
  return service.getHairColors();
});

/// 3. El color seleccionado. El único estado mutable de esta pantalla.
///    null = "Todos".
class ColorSeleccionado extends Notifier<String?> {
  @override
  String? build() => null;

  /// Tocar el chip que ya estaba activo lo desactiva (vuelve a Todos).
  void seleccionar(String? color) {
    state = (state == color) ? null : color;
  }
}

final colorSeleccionadoProvider =
    NotifierProvider<ColorSeleccionado, String?>(ColorSeleccionado.new);

/// 4. Los usuarios a mostrar.
///
///    Este provider OBSERVA el color. Cuando el color cambia, Riverpod
///    reejecuta esta función, llama a la API y redibuja la lista. Sin
///    setState y sin que la vista se entere de nada.
final usersProvider = FutureProvider<List<User>>((ref) {
  final service = ref.watch(userServiceProvider);
  final color = ref.watch(colorSeleccionadoProvider);

  return color == null
      ? service.getUsers()
      : service.getUsersByHairColor(color);
});

/// 5. Un usuario por id, para la pantalla de detalle.
final userByIdProvider = FutureProvider.family<User, int>((ref, id) {
  final service = ref.watch(userServiceProvider);
  return service.getUserById(id);
});
