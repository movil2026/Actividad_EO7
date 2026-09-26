import 'package:flutter/material.dart';

/// Puntito de color para el filtro de pelo.
///
/// Mismo espíritu que PrecioChip: un widget diminuto pero reutilizado en la
/// lista y en el detalle. Además centraliza la traducción "nombre en inglés
/// que manda la API" -> "Color de Flutter", que si no acabaría copiada en
/// cada vista.
class PuntoPelo extends StatelessWidget {
  final String nombreColor;
  final double tamano;

  const PuntoPelo(this.nombreColor, {super.key, this.tamano = 12});

  /// La API manda "Brown", "Blonde"... Flutter necesita un Color de verdad.
  /// toLowerCase() para no depender de si viene en mayúsculas o no.
  static Color colorDe(String nombre) {
    switch (nombre.toLowerCase()) {
      case 'black':
        return const Color(0xFF1F1F1F);
      case 'blonde':
      case 'blond':
        return const Color(0xFFE3C16F);
      case 'blue':
        return const Color(0xFF3D7EFF);
      case 'brown':
        return const Color(0xFF6D4C2F);
      case 'gray':
      case 'grey':
        return const Color(0xFF9E9E9E);
      case 'green':
        return const Color(0xFF2E9E5B);
      case 'purple':
        return const Color(0xFF8E4EC6);
      case 'red':
        return const Color(0xFFC0392B);
      case 'white':
        return const Color(0xFFF5F5F5);
      default:
        // Un color desconocido no debe romper la pantalla.
        return const Color(0xFFBDBDBD);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: tamano,
      height: tamano,
      decoration: BoxDecoration(
        color: colorDe(nombreColor),
        shape: BoxShape.circle,
        // El borde es para que el blanco no desaparezca sobre fondo claro.
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
