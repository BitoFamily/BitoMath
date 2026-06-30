class Reward {
  final String id; // millisecondsSinceEpoch string
  final String name;
  final String emoji;
  final int starCost;
  final bool isRedeemed;

  const Reward({
    required this.id,
    required this.name,
    required this.emoji,
    required this.starCost,
    this.isRedeemed = false,
  });

  Reward copyWith({
    String? name,
    String? emoji,
    int? starCost,
    bool? isRedeemed,
  }) =>
      Reward(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        starCost: starCost ?? this.starCost,
        isRedeemed: isRedeemed ?? this.isRedeemed,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'starCost': starCost,
        'isRedeemed': isRedeemed,
      };

  factory Reward.fromJson(Map<String, dynamic> j) => Reward(
        id: j['id'] as String,
        name: j['name'] as String,
        emoji: j['emoji'] as String,
        starCost: j['starCost'] as int,
        isRedeemed: j['isRedeemed'] as bool? ?? false,
      );
}
