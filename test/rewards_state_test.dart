import 'package:flutter_test/flutter_test.dart';
import 'package:bito_math/features/rewards/models/reward.dart';
import 'package:bito_math/features/rewards/providers/rewards_provider.dart';

void main() {
  group('RewardsState reward claimability', () {
    test('reward is not claimable below its star threshold', () {
      const state = RewardsState(
        pin: '',
        rewards: [
          Reward(id: '1', name: 'Movie night', emoji: '🎬', starCost: 100),
        ],
        sessionLogs: [],
      );

      expect(state.readyRewards(99), isEmpty);
    });

    test('reward becomes claimable exactly at its star threshold', () {
      const state = RewardsState(
        pin: '',
        rewards: [
          Reward(id: '1', name: 'Movie night', emoji: '🎬', starCost: 100),
        ],
        sessionLogs: [],
      );

      final ready = state.readyRewards(100);
      expect(ready, hasLength(1));
      expect(ready.first.id, '1');
    });

    test('already-redeemed rewards are excluded from readyRewards', () {
      const state = RewardsState(
        pin: '',
        rewards: [
          Reward(
            id: '1',
            name: 'Movie night',
            emoji: '🎬',
            starCost: 100,
            isRedeemed: true,
          ),
        ],
        sessionLogs: [],
      );

      expect(state.readyRewards(500), isEmpty);
    });

    test('availableStars deducts the cost of redeemed rewards', () {
      const state = RewardsState(
        pin: '',
        rewards: [
          Reward(
            id: '1',
            name: 'Redeemed reward',
            emoji: '🎁',
            starCost: 100,
            isRedeemed: true,
          ),
        ],
        sessionLogs: [],
      );

      expect(state.availableStars(150), 50);
    });
  });
}
