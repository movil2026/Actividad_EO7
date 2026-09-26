import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/product_providers.dart';
import 'precio_chip.dart';
import 'product_detail_view.dart';

/// VISTA (lista + filtro por categoría)
///
/// Fíjate: ya NO es un StatefulWidget. No hay initState, ni setState,
/// ni variables de estado. Solo lee providers y dibuja.
///
/// ConsumerWidget = StatelessWidget + un `ref` para leer providers.
class ProductsView extends ConsumerWidget {
  const ProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos'),
        actions: [
          IconButton(
            // invalidate = "tira el dato cacheado y vuelve a pedirlo a la API"
            onPressed: () => ref.invalidate(productsProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: Column(
        children: [
          const _BarraDeCategorias(),
          const Divider(height: 1),
          // Expanded: la lista ocupa todo el espacio que sobra debajo del filtro.
          const Expanded(child: _ListaDeProductos()),
        ],
      ),
    );
  }
}

/// Barra horizontal de chips con las categorías que devuelve la API.
///
/// Es un widget aparte a propósito: así, cuando cambian los productos,
/// Flutter NO reconstruye la barra de categorías (y al revés).




class _BarraDeCategorias extends ConsumerWidget {
  const _BarraDeCategorias();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch = "escúchame este provider y reconstruye si cambia"
    final categoriasAsync = ref.watch(categoriesProvider);
    final seleccionada = ref.watch(categoriaSeleccionadaProvider);

    return SizedBox(
      height: 56,
      // .when nos obliga a cubrir los 3 estados. Adiós al if/else de snapshot.
      child: categoriasAsync.when(
        loading: () => const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        error: (error, _) =>
            const Center(child: Text('No se pudieron cargar las categorías')),
        data: (categorias) => ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          // +1 porque el primer chip es "Todas", que no viene de la API.
          itemCount: categorias.length + 1,
          itemBuilder: (context, index) {
            final esTodas = index == 0;
            final slug = esTodas ? null : categorias[index - 1].slug;
            final texto = esTodas ? 'Todas' : categorias[index - 1].name;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: ChoiceChip(
                label: Text(texto),
                selected: seleccionada == slug,
                // read = "solo quiero llamar a un método, no escuchar cambios"
                // (dentro de callbacks siempre read, nunca watch)
                onSelected: (_) => ref
                    .read(categoriaSeleccionadaProvider.notifier)
                    .seleccionar(slug),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Lista de productos.
///
/// No sabe nada del filtro. Solo mira `productsProvider`; si la categoría
/// cambia, ese provider se recalcula solo y esta lista se redibuja.
class _ListaDeProductos extends ConsumerWidget {
  const _ListaDeProductos();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productsProvider);

    return productosAsync.when(
      // 1. Todavía esperando la respuesta
      loading: () => const Center(child: CircularProgressIndicator()),

      // 2. Algo falló (sin internet, error del servidor, etc.)
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('$error'),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => ref.invalidate(productsProvider),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),

      // 3. Datos listos
      data: (productos) {
        if (productos.isEmpty) {
          return const Center(child: Text('No hay productos en esta categoría'));
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(productsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: productos.length,
            itemBuilder: (context, index) => _TarjetaProducto(productos[index]),
          ),
        );
      },
    );
  }
}

/// Una fila de la lista. Antes era un ListTile pelado; ahora es una tarjeta
/// con la imagen redondeada, la valoración y el precio destacado.
class _TarjetaProducto extends StatelessWidget {
  final Product producto;

  const _TarjetaProducto(this.producto);

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Card(
      // clipBehavior hace que el efecto de "onda" al tocar respete los bordes.
      clipBehavior: Clip.antiAlias,
      color: colores.surfaceContainerLow,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailView(productId: producto.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Hero: anima la imagen volando hacia la pantalla de detalle.
              // Solo hay que poner el MISMO tag en las dos pantallas.
              Hero(
                tag: 'producto-${producto.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    producto.thumbnail,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.image),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: texto.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 15, color: Colors.amber),
                        Text(
                          ' ${producto.rating.toStringAsFixed(1)}  ·  ${producto.category}',
                          style: texto.bodySmall
                              ?.copyWith(color: colores.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PrecioChip(producto.price),
            ],
          ),
        ),
      ),
    );
  }
}
