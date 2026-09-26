import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/user_providers.dart';
import 'punto_pelo.dart';

/// VISTA (detalle de usuario)
///
/// Recibe solo el id y se lo pasa al provider `.family`; el provider se
/// encarga de pedirlo a la API y de cachearlo.
class UserDetailView extends ConsumerWidget {
  final int userId;

  const UserDetailView({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarioAsync = ref.watch(userByIdProvider(userId));
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: usuarioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (usuario) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            // Mismo tag que en la lista -> la foto "vuela" hasta aquí.
            Center(
              child: Hero(
                tag: 'usuario-${usuario.id}',
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: colores.surfaceContainerHighest,
                  foregroundImage: NetworkImage(usuario.image),
                  child: const Icon(Icons.person, size: 60),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              usuario.nombreCompleto,
              textAlign: TextAlign.center,
              style: texto.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              usuario.companyTitle,
              textAlign: TextAlign.center,
              style: texto.bodyMedium?.copyWith(color: colores.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Wrap = como un Row, pero si no caben pasa a la línea siguiente.
            // Con textos de longitud imprevisible (un color, un país) evita
            // el clásico overflow amarillo y negro.
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: PuntoPelo(usuario.hair.color),
                  label: Text('${usuario.hair.color} · ${usuario.hair.type}'),
                  backgroundColor: colores.secondaryContainer,
                ),
                Chip(
                  label: Text('${usuario.age} años'),
                  backgroundColor: colores.surfaceContainerHighest,
                ),
                Chip(
                  label: Text(usuario.gender),
                  backgroundColor: colores.surfaceContainerHighest,
                ),
              ],
            ),

            const Divider(height: 32),

            // Las filas son todas iguales, así que hay UN widget (_Dato) y
            // aquí solo se listan los datos. Si cambia el estilo, se toca
            // en un sitio.
            _Dato(Icons.mail_outline, 'Email', usuario.email),
            _Dato(Icons.phone_outlined, 'Teléfono', usuario.phone),
            _Dato(
              Icons.place_outlined,
              'Ciudad',
              '${usuario.city}, ${usuario.country}',
            ),
            _Dato(Icons.school_outlined, 'Universidad', usuario.university),
          ],
        ),
      ),
    );
  }
}

/// Una fila "icono + etiqueta + valor" del perfil.
class _Dato extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _Dato(this.icono, this.etiqueta, this.valor);

  @override
  Widget build(BuildContext context) {
    final texto = Theme.of(context).textTheme;
    final colores = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icono, color: colores.primary),
      title: Text(etiqueta, style: texto.labelMedium?.copyWith(
        color: colores.onSurfaceVariant,
      )),
      subtitle: Text(valor, style: texto.bodyLarge),
    );
  }
}
