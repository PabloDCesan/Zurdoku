import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeCodeRepo {
  final _db = FirebaseFirestore.instance;

  Future<String> redeem(String code) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    final codeRef   = _db.collection('theme_codes').doc(code);
    final redeemRef = _db.collection('users').doc(uid)
                         .collection('redeems').doc(code);

    return _db.runTransaction((tx) async {
      final codeSnap = await tx.get(codeRef);
      if (!codeSnap.exists) throw Exception('Código inexistente');

      final data = codeSnap.data()!;
      final themeId = (data['themeId'] as String?) ?? '';
      if (themeId.isEmpty) throw Exception('Código mal configurado');

      final redeemSnap = await tx.get(redeemRef);
      if (redeemSnap.exists) throw Exception('Código ya usado por este usuario');

      tx.set(redeemRef, {
        'themeId': themeId,
        'ts': FieldValue.serverTimestamp(),
      });

      return themeId;
    });
  }
}

