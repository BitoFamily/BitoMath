/// Encapsulates which operations are enabled and the per-topic accuracy
/// used to adapt question difficulty within each operation.
class QuestionConfig {
  final int ageBand;
  final Set<String> enabledTopics; // 'add' | 'sub' | 'mul' | 'div'
  final Map<String, double> topicAccuracy; // topic → 0.0–1.0

  QuestionConfig({
    required this.ageBand,
    required this.enabledTopics,
    required this.topicAccuracy,
  });

  /// Default config for an age band with no stored accuracy
  factory QuestionConfig.defaults(int ageBand) {
    return QuestionConfig(
      ageBand: ageBand,
      enabledTopics: _defaultTopics(ageBand),
      topicAccuracy: const {},
    );
  }

  static Set<String> _defaultTopics(int ageBand) {
    if (ageBand == 0) return {'add', 'sub'};
    if (ageBand == 1) return {'add', 'sub', 'mul'};
    return {'add', 'sub', 'mul', 'div'};
  }

  /// 0 = easier range, 1 = normal, 2 = harder range
  int adaptLevel(String topic) {
    final acc = topicAccuracy[topic];
    if (acc == null) return 1;
    if (acc > 0.85) return 2;
    if (acc < 0.60) return 0;
    return 1;
  }

  /// Available operations for this config (intersection of enabled and band-appropriate)
  List<String> get available {
    final allowed = _defaultTopics(ageBand);
    final result = enabledTopics.intersection(allowed).toList();
    return result.isEmpty ? allowed.toList() : result;
  }

  /// Encodes to a stable string suitable for use in a Riverpod family key
  String get key =>
      '${ageBand}_${(available..sort()).join(',')}';
}
