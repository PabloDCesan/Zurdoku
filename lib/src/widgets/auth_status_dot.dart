import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart'; // authStateProvider

/// Pequeño punto de estado (verde/gris) para superponer sobre un ícono.
/// Uso típico: dentro de un Stack junto a un Icon(Icons.person)
class AuthStatusDot extends ConsumerWidget {
  const AuthStatusDot({
    super.key,
    this.size = 10,
    this.onlineColor = const Color.fromARGB(255, 44, 235, 50),
    this.offlineColor = Colors.grey,
    this.borderColor,
    this.offset = const Offset(10, -2), // x,y relativo al centro del ícono
  });

  final double size;
  final Color onlineColor;
  final Color offlineColor;
  final Color? borderColor;
  final Offset offset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).value;
    final loggedIn = auth != null && !auth.isAnonymous;

    // Animado para que se vea lindo al loguear/cerrar sesión
    return Transform.translate(
      offset: offset,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: loggedIn ? onlineColor : offlineColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Theme.of(context).scaffoldBackgroundColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
