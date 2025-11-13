import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sudoku.dart';
// import '../providers/progress_provider.dart';
import '../widgets/leaderboard_top5.dart';
import '../widgets/app_bottom_nav_bar.dart';

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    final tabs = const [
      Tab(text: 'Fácil'),
      Tab(text: 'Medio'),
      Tab(text: 'Avanzado'),
      Tab(text: 'Experto'),
      Tab(text: 'Maestro'),
    ];
    final diffs = const [
      Difficulty.facil,
      Difficulty.medio,
      Difficulty.avanzado,
      Difficulty.experto,
      Difficulty.maestro,
    ];

    // Definimos el TabBar para recuperar su altura
    final tabBar = TabBar(
      tabs: tabs, 
      isScrollable: false, 
      labelColor:  Colors.black,
      unselectedLabelColor: Colors.white, 
      indicatorColor: Colors.yellow,
      tabAlignment: TabAlignment.center,
      
      );
    //final appBarHeight = kToolbarHeight + tabBar.preferredSize.height;

    return AppBottomNavBar(
      child: DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          extendBodyBehindAppBar: true,                   // <- clave
          backgroundColor: Colors.transparent,            // <- que no tape el bg
          appBar: AppBar(
            backgroundColor: Colors.transparent,           // <- transparente
            //elevation: 20,
            bottom: PreferredSize(           
              preferredSize: const Size.fromHeight(48.0),
              child: Container(
                color: Color.fromARGB(78, 255, 251, 251),
                child: tabBar,)
          ),),
          body: Stack(
            children: [
              // Fondo a pantalla completa
              Positioned.fill(
                child: Image.asset(
                  'assets/images/mainMenu_clean.png',
                  fit: BoxFit.fill, // usar cover en vez de fill para no deformar
                ),
              ),
              // Contenido por encima del fondo
              ListView(
                //padding: EdgeInsets.fromLTRB(16, appBarHeight + 16, 16, 16),
                children: [
                  Divider(color: theme.dividerColor.withValues(alpha: 0.4)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 360,
                    child: TabBarView(
                      children: diffs.map((d) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              LeaderboardTop5(
                                difficulty: d,
                                showHeader: true,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Top 5 por tiempo (mm:ss)',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
