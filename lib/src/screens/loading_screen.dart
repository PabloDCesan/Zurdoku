import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoadingScreen extends ConsumerStatefulWidget {
  const LoadingScreen({super.key});

  @override
  ConsumerState<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends ConsumerState<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _progressAnimation;

  static const _assetsToPrecache = [
    //cosas para pre cachear
    'assets/images/mainMenu_clean.png',
    'assets/images/mainMenu_lineas.png',
    
  ];


  @override
  void initState() {
    super.initState();
    
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 7000),
      vsync: this,
    );

    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));

    _startLoading();
  }

  void _startLoading() {
    _logoAnimationController.forward();
    
    // Iniciar la animación de progreso después de que aparezca el logo
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _progressAnimationController.forward().then((_) {
          if (mounted) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // Precarga de lo q declare antes
              await Future.wait(
                _assetsToPrecache.map((p) => precacheImage(AssetImage(p), context)),
              );
              if (mounted) {
            context.go('/main-menu');
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 235, 140, 33),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo del juego
            AnimatedBuilder(
              animation: _logoAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _logoAnimation,
                  child: Transform.scale(
                    scale: _logoAnimation.value,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/logo2.png',
                          width: 300,
                          height: 300,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback si la imagen no se encuentra
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade400,
                                    Colors.blue.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Icon(
                                Icons.grid_on,
                                size: 80,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 80),
            
            // Barra de progreso
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _progressAnimation,
                  child: Column(
                    children: [
                      Container(
                        width: 250,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: theme.dividerColor,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: _progressAnimation.value,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color.fromARGB(255, 245, 66, 66),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Cargando...',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
