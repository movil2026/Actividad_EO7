import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_providers.dart';
import 'precio_chip.dart';

/// VISTA (detalle)
///
/// Recibe solo el id y se lo pasa al provider `.family`.
/// También pasó de StatefulWidget a ConsumerWidget: sin initState.
class ProductDetailView extends ConsumerWidget {
  final int productId;

  const ProductDetailView({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Al provider .family se le pasa el parámetro entre paréntesis.
    final productoAsync = ref.watch(productByIdProvider(productId));
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: productoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (producto) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Mismo tag que en la lista -> la imagen "vuela" hasta aquí.
            Hero(
              tag: 'producto-${producto.id}',
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  color: colores.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(16),
                child: Image.network(
                  producto.thumbnail,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(Icons.image, size: 120),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(producto.title, style: texto.headlineSmall),
            const SizedBox(height: 12),
            Row(
              children: [
                PrecioChip(producto.price, grande: true),
                const Spacer(),
                const Icon(Icons.star_rounded, size: 20, color: Colors.amber),
                Text(
                  ' ${producto.rating.toStringAsFixed(1)}',
                  style: texto.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(producto.category),
              backgroundColor: colores.secondaryContainer,
            ),
            const Divider(height: 32),
            Text(
              producto.description,
              style: texto.bodyLarge?.copyWith(
                color: colores.onSurfaceVariant,
                height: 1.5, // interlineado: el truco más barato para que se lea bien
              ),
            ),
          ],
        ),
      ),
    );
  }
}
