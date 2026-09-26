import 'package:flutter/material.dart';

/// Etiqueta de precio. Widget minúsculo, pero reutilizado en lista y detalle:
/// si mañana cambia el estilo del precio, se cambia aquí y ya.
class PrecioChip extends StatelessWidget {
  final double precio;
  final bool grande;

  const PrecioChip(this.precio, {super.key, this.grande = false});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: grande ? 14 : 10, vertical: 6),
      decoration: BoxDecoration(
        color: colores.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '\$${precio.toStringAsFixed(2)}',
        style: TextStyle(
          color: colores.onPrimaryContainer,
          fontWeight: FontWeight.w700,
          fontSize: grande ? 20 : 14,
        ),
      ),
    );
  }
}
