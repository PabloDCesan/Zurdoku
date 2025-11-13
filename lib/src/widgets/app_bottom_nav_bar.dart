import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bottom_nav_provider.dart';
import 'package:flutter/services.dart';
import 'auth_status_dot.dart';

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
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          const BottomNavigationBarItem(icon: Icon(Icons.star_half_sharp), label: 'Logros'),
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Usuario'), 
          BottomNavigationBarItem(
                label: 'Usuario',
                icon: SizedBox(
                  width: 28,
                  height: 28,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: const [
                      Icon(Icons.person, size: 24),
                      // puedo usar Positioned o offset en el dot
                      Positioned(
                        right: -2,
                        top: -2,
                        child: AuthStatusDot(size: 10),
                      ),
                    ],
                  ),
                ),
              ),
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
        context.go('/user');
        break;
      case 3:
        SystemNavigator.pop();
        break;
    }
  }
}
