import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'leaderboard_repo.dart';
import 'progress_repo.dart';
import 'theme_code_repo.dart';

final leaderboardRepoProvider = Provider((ref) => LeaderboardRepo());
final progressRepoProvider = Provider((ref) => ProgressRepo());
final themeCodeRepoProvider = Provider((ref) => ThemeCodeRepo());
