import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/sudoku.dart';

class LeaderboardRepo {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> _scoresCol(Difficulty d) =>
      _db.collection('leaderboards').doc(d.name).collection('scores');

  Future<void> submit({
      required Difficulty difficulty,
      required int timeSec,
      String? name,
    }) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('No hay usuario autenticado');
      }

      // sanity checks opcionales (alineados a tus rules):
      final t = timeSec.clamp(1, 3600);

      final data = <String, dynamic>{
        'timeSec': t,
        'uid': uid,
        'ts': FieldValue.serverTimestamp(),
      };

      final trimmed = name?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        data['name'] = trimmed.length > 50 ? trimmed.substring(0, 50) : trimmed;
      }

      await _scoresCol(difficulty).add(data);
    }

    Stream<List<Map<String, dynamic>>> top5Stream(Difficulty d) =>
        _scoresCol(d).orderBy('timeSec').limit(5).snapshots()
          .map((s) => s.docs.map((e) => e.data()).toList());
}