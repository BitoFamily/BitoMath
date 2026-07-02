import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Localized display label for a topic code ('add' | 'sub' | 'mul' | 'div').
class TopicStrings {
  static String label(BuildContext context, String topic) {
    final l10n = AppLocalizations.of(context)!;
    return switch (topic) {
      'add' => l10n.topicAddition,
      'sub' => l10n.topicSubtraction,
      'mul' => l10n.topicMultiplication,
      'div' => l10n.topicDivision,
      _ => topic,
    };
  }
}
