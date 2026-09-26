import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme.dart';
import 'views/home_view.dart';

/// Punto de entrada.
///
/// Estructura del proyecto:
///   lib/models/    -> cómo son los datos       (Product, Category, User, Hair)
///   lib/services/  -> de dónde salen los datos (ProductService, UserService -> API)
///   lib/providers/ -> quién guarda el estado   (Riverpod)
///   lib/theme.dart -> cómo se ve todo (colores, bordes)
///   lib/views/     -> cómo se ven los datos    (listas, detalles, widgets sueltos)
///
/// Hay dos secciones montadas con el MISMO patrón, para verlo repetido:
///   Productos -> /products, filtro por categoría
///   Usuarios  -> /users,    filtro por color de pelo
void main() {
  // ProviderScope guarda el estado de TODOS los providers.
  // Sin este widget envolviendo la app, Riverpod no funciona.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servicios App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const HomeView(),
    );
  }
}
