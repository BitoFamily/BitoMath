import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/age_band_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/persistence/player_profile.dart';
import '../../../core/persistence/player_provider.dart';
import '../../../core/services/locale_provider.dart';
import '../../../core/services/sound_settings_provider.dart';
import '../../../core/services/theme_mode_provider.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';

/// Native display name for each supported locale. Language names aren't
/// translated — "Français" reads as "Français" no matter the current UI
/// language, same convention as every OS language picker.
const Map<String, String> _localeDisplayNames = {
  'en': 'English',
  'fr': 'Français',
  'hi': 'हिन्दी',
  'ar': 'العربية',
};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.watch(playerProfileProvider);

    return Scaffold(
      backgroundColor: colors.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: colors.textSecondary),
        title: Text(l10n.settingsTitle, style: AppTextStyles.headline3(colors)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _SoundSection(),
          const SizedBox(height: 20),
          const _ThemeSection(),
          const SizedBox(height: 20),
          _NameSection(profile: profile),
          const SizedBox(height: 20),
          _LevelSection(profile: profile),
          const SizedBox(height: 20),
          const _LanguageSection(),
          const SizedBox(height: 20),
          const _ResetProgressSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Sound ────────────────────────────────────────────────────────────────

class _SoundSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final enabled = ref.watch(soundSettingsProvider);

    return _SectionCard(
      title: l10n.soundSectionLabel,
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        value: enabled,
        activeThumbColor: colors.primaryLight,
        title: Text(l10n.soundToggleLabel, style: AppTextStyles.body(colors)),
        onChanged: (v) => ref.read(soundSettingsProvider.notifier).setEnabled(v),
      ),
    );
  }
}

// ── Theme ────────────────────────────────────────────────────────────────

class _ThemeSection extends ConsumerWidget {
  const _ThemeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final mode = ref.watch(themeModeProvider);

    Widget option(AppThemeMode value, String label) {
      final selected = mode == value;
      return Padding(
        padding: EdgeInsets.only(
            bottom: value == AppThemeMode.values.last ? 0 : 8),
        child: GestureDetector(
          onTap: () => ref.read(themeModeProvider.notifier).setMode(value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? colors.primary.withValues(alpha: 0.15)
                  : colors.bgCardLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? colors.primaryLight : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                    child: Text(label, style: AppTextStyles.body(colors))),
                if (selected)
                  Icon(Icons.check_circle_rounded,
                      color: colors.primaryLight, size: 20),
              ],
            ),
          ),
        ),
      );
    }

    return _SectionCard(
      title: l10n.themeSectionLabel,
      child: Column(
        children: [
          option(AppThemeMode.classic, l10n.themeClassicLabel),
          option(AppThemeMode.playground, l10n.themePlaygroundLabel),
        ],
      ),
    );
  }
}

// ── Name ─────────────────────────────────────────────────────────────────

class _NameSection extends ConsumerStatefulWidget {
  final PlayerProfile profile;
  const _NameSection({required this.profile});

  @override
  ConsumerState<_NameSection> createState() => _NameSectionState();
}

class _NameSectionState extends ConsumerState<_NameSection> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.profile.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.nameSectionLabel,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              style: AppTextStyles.body(colors),
              decoration: const InputDecoration(
                counterText: '',
                isDense: true,
                border: InputBorder.none,
              ),
            ),
          ),
          TextButton(
            onPressed: () => ref
                .read(playerProfileProvider.notifier)
                .setName(_controller.text),
            child: Text(l10n.nameSaveButton,
                style: AppTextStyles.label(colors)
                    .copyWith(color: colors.primaryLight)),
          ),
        ],
      ),
    );
  }
}

// ── Level ────────────────────────────────────────────────────────────────

class _LevelSection extends ConsumerWidget {
  final PlayerProfile profile;
  const _LevelSection({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.levelSectionLabel,
      child: Column(
        children: List.generate(AppConstants.ageBandCount, (i) {
          final selected = profile.ageBand == i;
          return Padding(
            padding: EdgeInsets.only(
                bottom: i == AppConstants.ageBandCount - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () =>
                  ref.read(playerProfileProvider.notifier).setAgeBand(i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.15)
                      : colors.bgCardLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? colors.primaryLight : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AgeBandStrings.name(context, i),
                              style: AppTextStyles.body(colors)),
                          Text(
                            '${AgeBandStrings.description(context, i)} (${AgeBandStrings.ageRange(context, i)})',
                            style: AppTextStyles.label(colors)
                                .copyWith(color: colors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle_rounded,
                          color: colors.primaryLight, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Language ─────────────────────────────────────────────────────────────

class _LanguageSection extends ConsumerWidget {
  const _LanguageSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    final currentOverride = ref.watch(localeProvider);
    final deviceLocale = Localizations.localeOf(context);
    final activeCode = (currentOverride ?? deviceLocale).languageCode;

    return _SectionCard(
      title: l10n.languageSectionLabel,
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: AppLocalizations.supportedLocales.map((locale) {
            final selected = locale.languageCode == activeCode;
            final name =
                _localeDisplayNames[locale.languageCode] ?? locale.languageCode;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(name, style: AppTextStyles.body(colors)),
              trailing: selected
                  ? Icon(Icons.check_circle_rounded,
                      color: colors.primaryLight, size: 20)
                  : null,
              onTap: () =>
                  ref.read(localeProvider.notifier).setLocale(locale),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Reset progress ─────────────────────────────────────────────────────────

class _ResetProgressSection extends ConsumerWidget {
  const _ResetProgressSection();

  void _confirmReset(BuildContext context, WidgetRef ref) {
    final colors = ref.read(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.resetConfirmTitle,
            style: AppTextStyles.headline3(colors)),
        content: Text(
          l10n.resetConfirmBody,
          style: AppTextStyles.body(colors).copyWith(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancelButton,
                style: AppTextStyles.label(colors)
                    .copyWith(color: colors.primaryLight)),
          ),
          TextButton(
            onPressed: () {
              ref.read(playerProfileProvider.notifier).resetProgress();
              Navigator.pop(context);
            },
            child: Text(l10n.resetConfirmButton,
                style: AppTextStyles.label(colors)
                    .copyWith(color: colors.accentCoral)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    final l10n = AppLocalizations.of(context)!;
    return _SectionCard(
      title: l10n.resetProgressSectionLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.resetProgressDescription,
            style: AppTextStyles.label(colors).copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.accentCoral,
                side: BorderSide(color: colors.accentCoral),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _confirmReset(context, ref),
              child: Text(l10n.resetProgressButton,
                  style: AppTextStyles.label(colors)
                      .copyWith(color: colors.accentCoral)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared section card ────────────────────────────────────────────────────

class _SectionCard extends ConsumerWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = ref.watch(appPaletteProvider);
    return AppCard(
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headline3(colors)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
