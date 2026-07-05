class Reward {
  final String id; // millisecondsSinceEpoch string
  final String name;
  final String emoji;
  final int starCost;
  final bool isRedeemed;
  final String? redeemedAt; // 'yyyy-MM-dd', null until redeemed

  const Reward({
    required this.id,
    required this.name,
    required this.emoji,
    required this.starCost,
    this.isRedeemed = false,
    this.redeemedAt,
  });

  Reward copyWith({
    String? name,
    String? emoji,
    int? starCost,
    bool? isRedeemed,
    String? redeemedAt,
  }) =>
      Reward(
        id: id,
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        starCost: starCost ?? this.starCost,
        isRedeemed: isRedeemed ?? this.isRedeemed,
        redeemedAt: redeemedAt ?? this.redeemedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'starCost': starCost,
        'isRedeemed': isRedeemed,
        'redeemedAt': redeemedAt,
      };

  factory Reward.fromJson(Map<String, dynamic> j) => Reward(
        id: j['id'] as String,
        name: j['name'] as String,
        emoji: j['emoji'] as String,
        starCost: j['starCost'] as int,
        isRedeemed: j['isRedeemed'] as bool? ?? false,
        redeemedAt: j['redeemedAt'] as String?,
      );
}
