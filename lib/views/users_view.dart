import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/user.dart';
import '../providers/user_providers.dart';
import 'punto_pelo.dart';
import 'user_detail_view.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

/// Provider local para controlar el índice seleccionado en la barra inferior
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Provider local para controlar la búsqueda de texto
final searchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

/// Provider derivado que filtra la lista final combinando texto y color de pelo
final filteredUsersProvider = Provider.autoDispose<AsyncValue<List<User>>>((ref) {
  final usersAsync = ref.watch(usersProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return usersAsync.whenData((usuarios) {
    if (query.isEmpty) return usuarios;
    return usuarios.where((user) {
      final nombreCoincide = user.nombreCompleto.toLowerCase().contains(query);
      final empresaCoincide = user.companyTitle.toLowerCase().contains(query);
      return nombreCoincide || empresaCoincide;
    }).toList();
  });
});

/// VISTA PRINCIPAL
class UsersView extends ConsumerWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colores = Theme.of(context).colorScheme;
    final esOscuroEfectivo = Theme.of(context).brightness == Brightness.dark;
    final navIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      backgroundColor: colores.surface,
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          return ref.invalidate(usersProvider);
        },
        edgeOffset: 120,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // AppBar Moderno
            SliverAppBar.large(
              title: const Text(
                'Directorio',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: colores.surface,
              surfaceTintColor: Colors.transparent,
              actions: [
                // BOTÓN MODO OSCURO / CLARO
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: colores.surfaceVariant.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    tooltip: 'Cambiar tema',
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => ScaleTransition(
                        scale: anim,
                        child: child,
                      ),
                      child: Icon(
                        esOscuroEfectivo
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        key: ValueKey(esOscuroEfectivo),
                        color: esOscuroEfectivo
                            ? Colors.amber
                            : colores.primary,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      ref.read(themeModeProvider.notifier).state =
                          esOscuroEfectivo ? ThemeMode.light : ThemeMode.dark;
                    },
                  ),
                ),

                // Botón Recargar
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: colores.surfaceVariant.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      ref.invalidate(usersProvider);
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Recargar',
                  ),
                ),
              ],
            ),

            // 1. Barra de Búsqueda adhesiva
            const SliverPersistentHeader(
              pinned: true,
              delegate: _CabeceraFijaDelegate(
                altura: 76,
                child: _BarraDeBusqueda(),
              ),
            ),

            // 2. Cabecera Fija de Filtros por Color
            const SliverPersistentHeader(
              pinned: true,
              delegate: _CabeceraFijaDelegate(
                altura: 62,
                child: _BarraDeColores(),
              ),
            ),

            // 3. Lista Principal
            const _ListaDeUsuarios(),
          ],
        ),
      ),
    );
  }
}

/// Componente de Búsqueda Integrado
class _BarraDeBusqueda extends ConsumerStatefulWidget {
  const _BarraDeBusqueda();

  @override
  ConsumerState<_BarraDeBusqueda> createState() => _BarraDeBusquedaState();
}

class _BarraDeBusquedaState extends ConsumerState<_BarraDeBusqueda> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final query = ref.watch(searchQueryProvider);

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SizedBox(
        height: 48,
        child: TextField(
          controller: _controller,
          onChanged: (val) => ref.read(searchQueryProvider.notifier).state = val,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre o cargo...',
            hintStyle: TextStyle(
              color: colores.onSurfaceVariant.withOpacity(0.7),
              fontSize: 14,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: colores.primary,
              size: 22,
            ),
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                      HapticFeedback.selectionClick();
                    },
                  )
                : null,
            filled: true,
            fillColor: colores.surfaceVariant.withOpacity(0.4),
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colores.outlineVariant.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: colores.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cabecera Fija Reutilizable
class _CabeceraFijaDelegate extends SliverPersistentHeaderDelegate {
  final double altura;
  final Widget child;

  const _CabeceraFijaDelegate({
    required this.altura,
    required this.child,
  });

  @override
  double get minExtent => altura;

  @override
  double get maxExtent => altura;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final colores = Theme.of(context).colorScheme;
    final estaFlotando = shrinkOffset > 0 || overlapsContent;

    return Container(
      height: altura,
      color: colores.surface.withOpacity(estaFlotando ? 0.95 : 1.0),
      child: SizedBox.expand(child: child),
    );
  }

  @override
  bool shouldRebuild(covariant _CabeceraFijaDelegate old) =>
      old.altura != altura || old.child != child;
}

/// Barra Horizontal de Chips Modernizados
class _BarraDeColores extends ConsumerWidget {
  const _BarraDeColores();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coloresAsync = ref.watch(hairColorsProvider);
    final seleccionado = ref.watch(colorSeleccionadoProvider);
    final esquema = Theme.of(context).colorScheme;

    return coloresAsync.when(
      loading: () => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, __) => const _Latido(
          child: _Bloque(ancho: 84, alto: 38, radio: 16),
        ),
      ),
      error: (error, _) => Center(
        child: Text(
          'Error al cargar filtros',
          style: TextStyle(color: esquema.error, fontSize: 13),
        ),
      ),
      data: (colores) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        itemCount: colores.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final esTodos = index == 0;
          final color = esTodos ? null : colores[index - 1];
          final activo = seleccionado == color;

          return FilterChip(
            showCheckmark: false,
            elevation: activo ? 2 : 0,
            pressElevation: 0,
            shadowColor: esquema.primary.withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            side: BorderSide(
              color: activo
                  ? Colors.transparent
                  : esquema.outlineVariant.withOpacity(0.5),
            ),
            backgroundColor: esquema.surfaceVariant.withOpacity(0.3),
            selectedColor: esquema.primaryContainer,
            labelStyle: TextStyle(
              fontWeight: activo ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
              color: activo
                  ? esquema.onPrimaryContainer
                  : esquema.onSurfaceVariant,
            ),
            avatar: esTodos
                ? Icon(
                    Icons.grid_view_rounded,
                    size: 15,
                    color: activo
                        ? esquema.onPrimaryContainer
                        : esquema.onSurfaceVariant,
                  )
                : PuntoPelo(color!, tamano: 12),
            label: Text(esTodos ? 'Todos' : color!),
            selected: activo,
            onSelected: (_) {
              HapticFeedback.selectionClick();
              ref.read(colorSeleccionadoProvider.notifier).seleccionar(color);
            },
          );
        },
      ),
    );
  }
}

/// Lista de Usuarios
class _ListaDeUsuarios extends ConsumerWidget {
  const _ListaDeUsuarios();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(filteredUsersProvider);
    final textoBusqueda = ref.watch(searchQueryProvider);

    return usuariosAsync.when(
      loading: () => SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        sliver: SliverList.separated(
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, __) => const _TarjetaEsqueleto(),
        ),
      ),
      error: (error, _) => SliverFillRemaining(
        hasScrollBody: false,
        child: _EstadoVacio(
          icono: Icons.wifi_off_rounded,
          titulo: 'Sin conexión',
          mensaje: 'No pudimos obtener la lista de usuarios. Revisa tu red.',
          accion: FilledButton.icon(
            onPressed: () {
              HapticFeedback.lightImpact();
              ref.invalidate(usersProvider);
            },
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Reintentar'),
          ),
        ),
      ),
      data: (usuarios) {
        if (usuarios.isEmpty) {
          final esBusquedaTexto = textoBusqueda.trim().isNotEmpty;

          return SliverFillRemaining(
            hasScrollBody: false,
            child: _EstadoVacio(
              icono: esBusquedaTexto
                  ? Icons.search_off_rounded
                  : Icons.person_search_rounded,
              titulo: 'Sin coincidencia',
              mensaje: esBusquedaTexto
                  ? 'No hay nadie que coincida con "$textoBusqueda".'
                  : 'No hay usuarios disponibles con ese filtro.',
              accion: FilledButton.tonal(
                onPressed: () {
                  HapticFeedback.selectionClick();
                  ref.read(searchQueryProvider.notifier).state = '';
                  ref
                      .read(colorSeleccionadoProvider.notifier)
                      .seleccionar(null);
                },
                child: const Text('Limpiar todos los filtros'),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          sliver: SliverList.separated(
            itemCount: usuarios.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) return _Contador(total: usuarios.length);
              return _TarjetaUsuario(usuarios[index - 1]);
            },
          ),
        );
      },
    );
  }
}

class _Contador extends StatelessWidget {
  final int total;
  const _Contador({required this.total});

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Text(
            'RESULTADOS',
            style: texto.labelSmall?.copyWith(
              color: colores.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colores.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$total',
              style: texto.labelSmall?.copyWith(
                color: colores.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de Usuario
class _TarjetaUsuario extends StatelessWidget {
  final User usuario;

  const _TarjetaUsuario(this.usuario);

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colores.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colores.outlineVariant.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserDetailView(userId: usuario.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: 'usuario-${usuario.id}',
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          colores.primary,
                          colores.tertiary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: colores.surfaceVariant,
                      foregroundImage: NetworkImage(usuario.image),
                      child: Icon(
                        Icons.person_rounded,
                        color: colores.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario.nombreCompleto,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texto.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        usuario.companyTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: texto.bodyMedium?.copyWith(
                          color: colores.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Etiqueta(
                            inicio: Icon(
                              Icons.cake_outlined,
                              size: 13,
                              color: colores.onSurfaceVariant,
                            ),
                            texto: '${usuario.age} años',
                          ),
                          _Etiqueta(
                            inicio: PuntoPelo(usuario.hair.color, tamano: 10),
                            texto: '${usuario.hair.color}, ${usuario.hair.type}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colores.surfaceVariant.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: colores.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final Widget inicio;
  final String texto;

  const _Etiqueta({required this.inicio, required this.texto});

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colores.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          inicio,
          const SizedBox(width: 6),
          Text(
            texto,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colores.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String mensaje;
  final Widget accion;

  const _EstadoVacio({
    required this.icono,
    required this.titulo,
    required this.mensaje,
    required this.accion,
  });

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colores.primaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icono,
                size: 40,
                color: colores.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: texto.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: texto.bodyMedium?.copyWith(
                color: colores.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            accion,
          ],
        ),
      ),
    );
  }
}

class _TarjetaEsqueleto extends StatelessWidget {
  const _TarjetaEsqueleto();

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;

    return _Latido(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colores.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: colores.outlineVariant.withOpacity(0.2),
          ),
        ),
        child: const Row(
          children: [
            _Bloque(ancho: 56, alto: 56, radio: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Bloque(ancho: 130, alto: 16, radio: 8),
                  SizedBox(height: 8),
                  _Bloque(ancho: 90, alto: 12, radio: 6),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      _Bloque(ancho: 65, alto: 20, radio: 8),
                      SizedBox(width: 6),
                      _Bloque(ancho: 85, alto: 20, radio: 8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  final double ancho;
  final double alto;
  final double radio;

  const _Bloque({
    required this.ancho,
    required this.alto,
    required this.radio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ancho,
      height: alto,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(radio),
      ),
    );
  }
}

class _Latido extends StatefulWidget {
  final Widget child;
  const _Latido({required this.child});

  @override
  State<_Latido> createState() => _LatidoState();
}

class _LatidoState extends State<_Latido> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return widget.child;

    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}