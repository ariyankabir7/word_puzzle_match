import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/player_progress.dart';
import '../../core/providers/app_providers.dart';

final homeProvider = Provider<PlayerProgress>((ref) {
  return ref.watch(playerProgressProvider);
});
