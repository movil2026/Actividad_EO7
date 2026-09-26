import 'package:flutter/material.dart';

import 'products_view.dart';
import 'users_view.dart';

/// CONTENEDOR
///
/// Las dos secciones de la app con una barra abajo para saltar entre ellas.
///
/// ¿Y por qué esto SÍ es un StatefulWidget con setState, si dijimos que
/// Riverpod venía a quitarlos? Porque la pestaña abierta no es un dato de la
/// app: nadie más la necesita, no se pide a la API y no sobrevive a nada.
/// Es estado puramente visual y local, y para eso setState sobra.
/// Riverpod es para lo que se comparte entre pantallas.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _indice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack construye las dos pantallas y solo ENSEÑA una. Así, al
      // volver de Usuarios a Productos, sigues donde estabas: mismo scroll y
      // mismo filtro. Con un `children[_indice]` normal se perdería todo.
      body: IndexedStack(
        index: _indice,
        children: const [ProductsView(), UsersView()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: (i) => setState(() => _indice = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Usuarios',
          ),
        ],
      ),
    );
  }
}
