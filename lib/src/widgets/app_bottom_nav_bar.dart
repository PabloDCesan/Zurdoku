import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bottom_nav_provider.dart';
import 'package:flutter/services.dart';

class AppBottomNavBar extends ConsumerWidget {
  final Widget child;
  final bool showBottomNav;

  const AppBottomNavBar({
    super.key,
    required this.child,
    this.showBottomNav = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomNavState = ref.watch(bottomNavProvider);
    
    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomNav ? BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 30, 35, 43),
        currentIndex: bottomNavState.selectedIndex,
        selectedItemColor: const Color.fromARGB(255, 226, 204, 176),
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.star_half_sharp), label: 'Logros'),
          BottomNavigationBarItem(icon: Icon(Icons.question_mark_rounded), label: 'Acerca de'),
          BottomNavigationBarItem(icon: Icon(Icons.exit_to_app), label: 'SALIR'),
        ],
        onTap: (index) => _onItemTapped(context, ref, index),
        type: BottomNavigationBarType.fixed,
      ) : null,
    );
  }

  void _onItemTapped(BuildContext context, WidgetRef ref, int index) {
    ref.read(bottomNavProvider.notifier).setSelectedIndex(index);
    
    switch (index) {
      case 0:
        context.go('/main-menu');
        break;
      case 1:
        context.go('/achievements');
        break;
      case 2:
        context.go('/about');
        break;
      case 3:
        SystemNavigator.pop();
        break;
    }
  }
}
