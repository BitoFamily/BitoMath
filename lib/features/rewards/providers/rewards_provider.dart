import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/persistence/player_provider.dart';
import '../models/reward.dart';
import '../models/session_log.dart';

class RewardsState {
  final String pin; // '' = not set yet
  final List<Reward> rewards;
  final List<SessionLog> sessionLogs; // newest first, max 30

  const RewardsState({
    required this.pin,
    required this.rewards,
    required this.sessionLogs,
  });

  static const empty = RewardsState(pin: '', rewards: [], sessionLogs: []);

  RewardsState copyWith({
    String? pin,
    List<Reward>? rewards,
    List<SessionLog>? sessionLogs,
  }) =>
      RewardsState(
        pin: pin ?? this.pin,
        rewards: rewards ?? this.rewards,
        sessionLogs: sessionLogs ?? this.sessionLogs,
      );

  /// Stars left after deducting the cost of every redeemed reward.
  int availableStars(int totalStars) {
    final spent = rewards
        .where((r) => r.isRedeemed)
        .fold(0, (sum, r) => sum + r.starCost);
    return (totalStars - spent).clamp(0, totalStars);
  }

  /// Unredeemed rewards whose cost has already been met by availableStars.
  List<Reward> readyRewards(int totalStars) {
    final avail = availableStars(totalStars);
    return rewards
        .where((r) => !r.isRedeemed && r.starCost <= avail)
        .toList();
  }

  /// Cheapest reward the child is still working toward (not yet affordable).
  Reward? nextPendingReward(int totalStars) {
    final pending = upcomingRewards(totalStars);
    return pending.isEmpty ? null : pending.first;
  }

  /// All unredeemed rewards not yet affordable, cheapest first.
  List<Reward> upcomingRewards(int totalStars) {
    final avail = availableStars(totalStars);
    return rewards.where((r) => !r.isRedeemed && r.starCost > avail).toList()
      ..sort((a, b) => a.starCost.compareTo(b.starCost));
  }

  /// Redeemed rewards, most recently redeemed first (legacy entries with no
  /// redemption date sort last).
  List<Reward> get redeemedRewards {
    final redeemed = rewards.where((r) => r.isRedeemed).toList();
    redeemed.sort((a, b) {
      final ad = a.redeemedAt;
      final bd = b.redeemedAt;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });
    return redeemed;
  }
}

class RewardsNotifier extends StateNotifier<RewardsState> {
  RewardsNotifier(SharedPreferences prefs)
      : _prefs = prefs,
        super(_load(prefs));

  final SharedPreferences _prefs;

  static RewardsState _load(SharedPreferences p) {
    final pin = p.getString('parent_pin') ?? '';

    List<Reward> rewards = [];
    final rewardsJson = p.getString('rewards_json');
    if (rewardsJson != null) {
      final list = jsonDecode(rewardsJson) as List<dynamic>;
      rewards = list
          .map((e) => Reward.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    List<SessionLog> logs = [];
    final logsJson = p.getString('session_logs_json');
    if (logsJson != null) {
      final list = jsonDecode(logsJson) as List<dynamic>;
      logs = list
          .map((e) => SessionLog.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return RewardsState(pin: pin, rewards: rewards, sessionLogs: logs);
  }

  Future<void> _save() async {
    await Future.wait([
      _prefs.setString('parent_pin', state.pin),
      _prefs.setString(
        'rewards_json',
        jsonEncode(state.rewards.map((r) => r.toJson()).toList()),
      ),
      _prefs.setString(
        'session_logs_json',
        jsonEncode(state.sessionLogs.map((l) => l.toJson()).toList()),
      ),
    ]);
  }

  // ── PIN ──────────────────────────────────────────────────────────────────

  Future<void> setPin(String pin) async {
    state = state.copyWith(pin: pin);
    await _save();
  }

  bool verifyPin(String input) => state.pin == input;

  // ── Rewards ───────────────────────────────────────────────────────────────

  Future<void> addReward(Reward reward) async {
    if (state.rewards.length >= 5) return; // max 5
    state = state.copyWith(rewards: [...state.rewards, reward]);
    await _save();
  }

  Future<void> deleteReward(String id) async {
    state = state.copyWith(
      rewards: state.rewards.where((r) => r.id != id).toList(),
    );
    await _save();
  }

  Future<void> redeemReward(String id) async {
    final today = _todayStr();
    state = state.copyWith(
      rewards: state.rewards
          .map((r) => r.id == id
              ? r.copyWith(isRedeemed: true, redeemedAt: today)
              : r)
          .toList(),
    );
    await _save();
  }

  static String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  // ── Session log ───────────────────────────────────────────────────────────

  Future<void> addSessionLog(SessionLog log) async {
    final updated = [log, ...state.sessionLogs].take(30).toList();
    state = state.copyWith(sessionLogs: updated);
    await _save();
  }
}

final rewardsProvider =
    StateNotifierProvider<RewardsNotifier, RewardsState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return RewardsNotifier(prefs);
});
