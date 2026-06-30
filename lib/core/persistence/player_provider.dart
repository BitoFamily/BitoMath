import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/game/models/game_state.dart';
import 'player_profile.dart';

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPrefsProvider was not overridden in main()');
});

class PlayerProfileNotifier extends StateNotifier<PlayerProfile> {
  PlayerProfileNotifier(SharedPreferences prefs)
      : _prefs = prefs,
        super(_fromPrefs(prefs));

  final SharedPreferences _prefs;

  static PlayerProfile _fromPrefs(SharedPreferences p) {
    final topicsRaw = p.getString('topics_enabled') ?? '';
    final Set<String> topics = topicsRaw.isEmpty
        ? {'add', 'sub'}
        : topicsRaw.split(',').toSet();

    final topicAccuracy = <String, double>{};
    for (final t in ['add', 'sub', 'mul', 'div']) {
      final v = p.getDouble('topic_acc_$t');
      if (v != null) topicAccuracy[t] = v;
    }

    return PlayerProfile(
      name: p.getString('player_name') ?? '',
      ageBand: p.getInt('age_band') ?? 0,
      stars: p.getInt('stars') ?? 0,
      bestScore: p.getInt('best_score') ?? 0,
      streakDays: p.getInt('streak_days') ?? 0,
      lastPlayedDate: p.getString('last_played_date') ?? '',
      selectedCharacter: p.getInt('selected_character') ?? 0,
      hasCompletedOnboarding: p.getBool('has_onboarded') ?? false,
      enabledTopics: topics,
      topicAccuracy: topicAccuracy,
    );
  }

  Future<void> _save() async {
    final s = state;
    final futures = <Future>[
      _prefs.setString('player_name', s.name),
      _prefs.setInt('age_band', s.ageBand),
      _prefs.setInt('stars', s.stars),
      _prefs.setInt('best_score', s.bestScore),
      _prefs.setInt('streak_days', s.streakDays),
      _prefs.setString('last_played_date', s.lastPlayedDate),
      _prefs.setInt('selected_character', s.selectedCharacter),
      _prefs.setBool('has_onboarded', s.hasCompletedOnboarding),
      _prefs.setString('topics_enabled', s.enabledTopics.join(',')),
    ];
    for (final entry in s.topicAccuracy.entries) {
      futures.add(_prefs.setDouble('topic_acc_${entry.key}', entry.value));
    }
    await Future.wait(futures);
  }

  Future<void> completeOnboarding({
    required String name,
    required int ageBand,
  }) async {
    state = state.copyWith(
      name: name.trim(),
      ageBand: ageBand,
      hasCompletedOnboarding: true,
      enabledTopics: _defaultTopics(ageBand),
    );
    await _save();
  }

  Future<void> setCharacter(int index) async {
    final clamped = index.clamp(0, AppConstants.characterImages.length - 1);
    state = state.copyWith(selectedCharacter: clamped);
    await _save();
  }

  Future<void> setEnabledTopics(Set<String> topics) async {
    if (topics.isEmpty) return;
    state = state.copyWith(enabledTopics: topics);
    await _save();
  }

  Future<void> recordGameResult(GameState result) async {
    final newStars = state.stars + result.correctCount;
    final newBest =
        result.score > state.bestScore ? result.score : state.bestScore;

    final today = _todayStr();
    int newStreak;
    if (state.lastPlayedDate.isEmpty) {
      newStreak = 1;
    } else if (state.lastPlayedDate == today) {
      newStreak = state.streakDays;
    } else {
      final last = DateTime.parse(state.lastPlayedDate);
      final now = DateTime.now();
      final diff = DateTime(now.year, now.month, now.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;
      newStreak = diff == 1 ? state.streakDays + 1 : 1;
    }

    // Blend topic accuracy: 70 % existing + 30 % new session
    final newAccuracy = Map<String, double>.from(state.topicAccuracy);
    for (final entry in result.sessionTopicAccuracy.entries) {
      final existing = newAccuracy[entry.key] ?? 0.7;
      newAccuracy[entry.key] = existing * 0.7 + entry.value * 0.3;
    }

    state = state.copyWith(
      stars: newStars,
      bestScore: newBest,
      streakDays: newStreak,
      lastPlayedDate: today,
      topicAccuracy: newAccuracy,
    );
    await _save();
  }

  static Set<String> _defaultTopics(int ageBand) {
    if (ageBand == 0) return {'add', 'sub'};
    if (ageBand == 1) return {'add', 'sub', 'mul'};
    return {'add', 'sub', 'mul', 'div'};
  }

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}

final playerProfileProvider =
    StateNotifierProvider<PlayerProfileNotifier, PlayerProfile>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return PlayerProfileNotifier(prefs);
});
