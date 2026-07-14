import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';
import 'core/services/locale_provider.dart';
import 'core/services/theme_mode_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_type_scale.dart';
import 'l10n/app_localizations.dart';

class BitoMathApp extends ConsumerWidget {
  const BitoMathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Bito Math',
      debugShowCheckedModeBanner: false,
      theme: themeMode == AppThemeMode.playground
          ? AppTheme.light
          : AppTheme.dark,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        final factor = AppTypeScale.factorFor(mq.size);
        final combined = factor * mq.textScaler.scale(1.0);
        return MediaQuery(
          data: mq.copyWith(textScaler: TextScaler.linear(combined)),
          child: child!,
        );
      },
    );
  }
}
