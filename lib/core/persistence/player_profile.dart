class PlayerProfile {
  final String name;
  final int ageBand;
  final int stars;
  final int bestScore;
  final int streakDays;
  final String lastPlayedDate; // 'yyyy-MM-dd', empty = never played
  final int selectedCharacter;
  final bool hasCompletedOnboarding;
  final Set<String> enabledTopics; // which operations are active
  final Map<String, double> topicAccuracy; // topic → EMA accuracy 0.0–1.0

  const PlayerProfile({
    required this.name,
    required this.ageBand,
    required this.stars,
    required this.bestScore,
    required this.streakDays,
    required this.lastPlayedDate,
    required this.selectedCharacter,
    required this.hasCompletedOnboarding,
    required this.enabledTopics,
    required this.topicAccuracy,
  });

  static const defaults = PlayerProfile(
    name: '',
    ageBand: 0,
    stars: 0,
    bestScore: 0,
    streakDays: 0,
    lastPlayedDate: '',
    selectedCharacter: 0,
    hasCompletedOnboarding: false,
    enabledTopics: {'add', 'sub'},
    topicAccuracy: {},
  );

  PlayerProfile copyWith({
    String? name,
    int? ageBand,
    int? stars,
    int? bestScore,
    int? streakDays,
    String? lastPlayedDate,
    int? selectedCharacter,
    bool? hasCompletedOnboarding,
    Set<String>? enabledTopics,
    Map<String, double>? topicAccuracy,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      ageBand: ageBand ?? this.ageBand,
      stars: stars ?? this.stars,
      bestScore: bestScore ?? this.bestScore,
      streakDays: streakDays ?? this.streakDays,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      selectedCharacter: selectedCharacter ?? this.selectedCharacter,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      enabledTopics: enabledTopics ?? this.enabledTopics,
      topicAccuracy: topicAccuracy ?? this.topicAccuracy,
    );
  }

  /// Focus topic: enabled topic with the lowest stored accuracy
  String? get focusTopic {
    final filtered = Map.fromEntries(
      topicAccuracy.entries.where((e) => enabledTopics.contains(e.key)),
    );
    if (filtered.isEmpty) return null;
    return filtered.entries
        .reduce((a, b) => a.value < b.value ? a : b)
        .key;
  }
}
