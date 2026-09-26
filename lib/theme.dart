import 'package:flutter/material.dart';

/// TEMA
///
/// Todo el diseño en un solo sitio. Las vistas no llevan colores "a mano":
/// piden los del tema con `Theme.of(context)`.
/// Cambiando esta única línea cambia el color de toda la app:
const _semilla = Color(0xFF3D5AFE);

final appTheme = ThemeData(
  // fromSeed genera una paleta completa y coherente a partir de UN color,
  // incluyendo los tonos claros/oscuros que combinan entre sí.
  colorScheme: ColorScheme.fromSeed(seedColor: _semilla),

  appBarTheme: const AppBarThemeData(
    centerTitle: true,
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
  ),

  cardTheme: CardThemeData(
    elevation: 0,
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  chipTheme: const ChipThemeData(showCheckmark: false, side: BorderSide.none),

  listTileTheme: const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(horizontal: 12),
  ),
);
