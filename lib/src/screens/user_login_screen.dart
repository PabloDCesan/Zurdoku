import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/auth_provider.dart';
import '../repos/providers.dart'; // progressRepoProvider
import '../widgets/app_bottom_nav_bar.dart';

class UserLoginScreen extends ConsumerStatefulWidget {
  const UserLoginScreen({super.key});

  @override
  ConsumerState<UserLoginScreen> createState() => _UserLoginScreenState();
}

class _UserLoginScreenState extends ConsumerState<UserLoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });

    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text;

    try {
      final auth = FirebaseAuth.instance;
      final cred = EmailAuthProvider.credential(email: email, password: pass);

    // 1) Intentar SIGN-IN directo
        try {
          await auth.signInWithEmailAndPassword(email: email, password: pass);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'user-not-found' && (auth.currentUser?.isAnonymous ?? false)) {
            // 2) Si no existe y estoy anónimo -> LINK (crea la cuenta con este uid)
            await auth.currentUser!.linkWithCredential(cred);
          } else {
            // otras causas: wrong-password, invalid-email, etc.
            rethrow;
          }
        }

        // 3) Asegurar defaults remotos para el uid logueado
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await ref.read(progressRepoProvider).ensureDefaults(uid);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión iniciada')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Mensajes más claros
      String msg;
      switch (e.code) {
        case 'wrong-password': msg = 'Contraseña incorrecta.'; break;
        case 'invalid-email': msg = 'Email inválido.'; break;
        case 'user-disabled': msg = 'Usuario deshabilitado.'; break;
        case 'email-already-in-use':
          msg = 'El email ya está en uso por otra cuenta.';
          break;
        default: msg = e.message ?? 'Error de autenticación';
      }
      setState(() => _error = msg);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await FirebaseAuth.instance.signOut();
      // Volvemos a anónimo para que la app siga funcional
      await FirebaseAuth.instance.signInAnonymously();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión cerrada')),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authStateProvider);
    return AppBottomNavBar(
      child: Scaffold(
        
        body: authAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (user) {
            final loggedIn = user != null && !user.isAnonymous;
            final welcome = loggedIn
                ? (user.displayName?.isNotEmpty == true
                    ? user.displayName!
                    : user.email ?? 'Usuario')
                : 'Invitado';

            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/mainMenu_clean.png'),
                  fit: BoxFit.fill,
                ),
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            loggedIn ? Icons.verified_user : Icons.person,
                            size: 64,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loggedIn ? 'Bienvenido/a $welcome' : 'Iniciar sesión',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),

                          if (!loggedIn) ...[
                            TextField(
                              controller: _emailCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              enabled: !_busy,
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _passCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Contraseña',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              enabled: !_busy,
                              onSubmitted: (_) => _signIn(),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _busy ? null : _signIn,
                                icon: const Icon(Icons.login),
                                label: Text(_busy ? 'Ingresando...' : 'Ingresar'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Si aún no existe, creá el usuario en la consola de Firebase.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _busy ? null : _signOut,
                                icon: const Icon(Icons.logout),
                                label: Text(_busy ? 'Cerrando...' : 'Cerrar sesión'),
                              ),
                            ),
                          ],

                          if (_error != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _error!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
