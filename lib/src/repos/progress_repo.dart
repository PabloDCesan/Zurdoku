import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressRepo {
  final _db = FirebaseFirestore.instance;

  /// Crea un doc de progreso con defaults si no existe.
  Future<void> ensureDefaults(String uid) async {
    final coll = _db.collection('users').doc(uid).collection('progress');
    final doc = coll.doc('main'); // un único doc “main”
    final snap = await doc.get();
    if (snap.exists) return;

    // Defaults: 99 min por dificultad, temas básicos, audio ON
    await doc.set({
      'themesUnlocked': ['light','dark'],
      'bestTimes': {
        'facil':     99 * 60,
        'medio':     99 * 60,
        'avanzado':  99 * 60,
        'experto':   99 * 60,
        'maestro':   99 * 60,
      },
      'audio': {'enabled': true, 'volume': 0.7},
      'currentTheme': 'light',
    });
  }
}
