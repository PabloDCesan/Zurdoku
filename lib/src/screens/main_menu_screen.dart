import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/bottom_nav_provider.dart';
import 'package:flutter/services.dart';

class MainMenuScreen extends ConsumerWidget {
  const MainMenuScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final theme = Theme.of(context);
    final bottomNavState = ref.watch(bottomNavProvider);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 140, 33),
      //body: SafeArea(
      body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/mainMenu_lineas.png'), fit: BoxFit.fill),
          ),
        
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Logo
              /*Container(
                width: 120,
                height: 120,
                /*decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ), */


                /*child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo1.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si la imagen no se encuentra
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 191, 245, 66),
                              const Color.fromARGB(255, 229, 30, 30),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(
                          Icons.grid_on,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),*/
              ),*/
              
              // const SizedBox(height: 30),
              
              // Título
              /*
              Text(
                'ZURDOKU',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineLarge?.color,
                  letterSpacing: 6,
                ),
              ),
              
              
              */
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              // Botones del menú
              _buildMenuButton(
                context: context,
                text: 'COMENZAR',
                //icon: Icons.play_arrow,
                onTap: () => context.go('/difficulty'),
              ),
              
              const SizedBox(height: 20),
              
              _buildMenuButton(
                context: context,
                text: 'CONTINUAR',
                //icon: Icons.refresh,
                onTap: () {
                  // TODO: Implementar continuar partida guardada
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No hay partidas guardadas'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              
            ],),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              _buildMenuButton(
                context: context,
                text: 'OPCIONES',
                //icon: Icons.settings,
                onTap: () => context.go('/options'),
              ),],),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
            bottomNavigationBar: BottomNavigationBar(
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
            ),
    );
  }

  void _onItemTapped(BuildContext context, WidgetRef ref, int index) {
    ref.read(bottomNavProvider.notifier).setSelectedIndex(index);
    
    switch (index) {
      case 0:
        // Ya estoy en inicio. No agregar nadaaaa
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

  Widget _buildMenuButton({
    required BuildContext context,
    required String text,
    // required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: 150,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 8,
          shadowColor: theme.primaryColor.withValues(alpha:0.3),
          
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            const SizedBox(width: 13),
            Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
