import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/progress_provider.dart';

class OptionsScreen extends ConsumerStatefulWidget {
  const OptionsScreen({super.key});

  @override
  ConsumerState<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends ConsumerState<OptionsScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = ref.watch(progressProvider);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Opciones'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/main-menu'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Configuración de audio
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Audio',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      // Música
                      SwitchListTile(
                        title: const Text('Música'),
                        subtitle: const Text('Activar música de fondo'),
                        value: progress.musicEnabled,
                        onChanged: (value) {
                          ref.read(progressProvider.notifier).setMusicEnabled(value);
                        },
                      ),
                      
                      const Divider(),
                      
                      // Efectos de sonido
                      SwitchListTile(
                        title: const Text('Efectos de sonido'),
                        subtitle: const Text('Activar efectos de sonido'),
                        value: progress.soundEffectsEnabled,
                        onChanged: (value) {
                          ref.read(progressProvider.notifier).setSoundEffectsEnabled(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Ingreso de clave
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temas Desbloqueables',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      TextField(
                        controller: _codeController,
                        decoration: const InputDecoration(
                          labelText: 'Código de tema',
                          hintText: 'Ingresa un código de 6 caracteres',
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(6),
                          UpperCaseTextFormatter(),
                        ],
                        textCapitalization: TextCapitalization.characters,
                        onSubmitted: _handleCodeSubmission,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleCodeSubmission(_codeController.text),
                          child: const Text('DESBLOQUEAR TEMA'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Reiniciar progreso
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progreso',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showResetProgressDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('REINICIAR PROGRESO'),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Esto eliminará todos los tiempos récord y temas desbloqueados.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha:0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /*
  el handler del loop que no era loop...

  void _handleCodeSubmission(String code) {
    if (code.length != 6) {
      _showSnackBar('Codigo mal ingresado!');
      return;
    }

    try {
      ref.read(progressProvider.notifier).unlockTheme(code);
      _showSnackBar('¡Tema agregado!');
      _codeController.clear();
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }
  */

bool _submitting = false;

Future<void> _handleCodeSubmission(String raw) async {
  if (_submitting) return;
  _submitting = true;

  // Normalizar
  final code = raw.trim().toUpperCase();

  // Validación estricta: 6 alfanuméricos (A-Z, 0-9)
  final isValid = RegExp(r'^[A-Z0-9]{6}$').hasMatch(code);
  if (!isValid) {
    _showSnackBar('Código inválido. Debe tener 6 caracteres A-Z/0-9.');
    _submitting = false;
    return;
  }

  // Cerrar teclado para evitar re-submit
  FocusScope.of(context).unfocus();

  try {
    // Si unlockTheme es Future, esto atrapa BIEN  las excepciones internas
    await ref.read(progressProvider.notifier).unlockTheme(code);
    if (!mounted) return;
    _showSnackBar('¡Tema agregado!');
    _codeController.clear();
  } catch (e) {
    if (!mounted) return;
    final message = e.toString().replaceFirst('Exception: ', '');
    // Evitando mostrar e.toString()..
    _showSnackBar(message);
    debugPrint('unlockTheme error: $e');
  } finally {
    _submitting = false;
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showResetProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reiniciar Progreso'),
          content: const Text(
            '¿Estás seguro de que quieres reiniciar todo el progreso? '
            'Esto no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(progressProvider.notifier).resetProgress();
                Navigator.of(context).pop();
                _showSnackBar('Progreso reiniciado');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
