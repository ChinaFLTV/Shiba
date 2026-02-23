import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shiba/core/theme/app_theme.dart';
import 'package:shiba/data/database/database_helper.dart';
import 'package:shiba/l10n/app_localizations.dart';
import 'package:shiba/ui/home/home_page.dart';

const _themeModeKey = 'theme_mode';
const _localeKey = 'app_locale';

class LocalModelApp extends ConsumerWidget {
  const LocalModelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Shiba',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.supportedLocales,
      home: const _AppBootstrapPage(),
    );
  }
}

class _AppBootstrapPage extends StatefulWidget {
  const _AppBootstrapPage();

  @override
  State<_AppBootstrapPage> createState() => _AppBootstrapPageState();
}

class _AppBootstrapPageState extends State<_AppBootstrapPage> {
  late final Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _bootstrap();
  }

  Future<void> _bootstrap() async {
    await DatabaseHelper.instance.database;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<void>(
      future: _bootstrapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return _BootstrapError(error: snapshot.error.toString());
          }
          return const HomePage();
        }
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.pets,
                        size: 38,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Shiba',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Builder(
                      builder: (context) {
                        final l10n = S.of(context);
                        return Text(
                          l10n.preparingEnvironment,
                          style: TextStyle(
                            color: colorScheme.outline,
                            fontSize: 13,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BootstrapError extends StatelessWidget {
  final String error;
  const _BootstrapError({required this.error});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = S.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(l10n.bootFailed, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
    (ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final value = await DatabaseHelper.instance.getSetting(_themeModeKey);
    if (value != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == value,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await DatabaseHelper.instance.setSetting(_themeModeKey, mode.name);
  }
}

/// Supported app locales with display names.
class AppLocale {
  final Locale locale;
  final String displayName;
  const AppLocale(this.locale, this.displayName);
}

const supportedAppLocales = [
  AppLocale(Locale('zh'), '简体中文'),
  AppLocale(Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'), '繁體中文'),
  AppLocale(Locale('en'), 'English'),
  AppLocale(Locale('fr'), 'Français'),
  AppLocale(Locale('de'), 'Deutsch'),
];

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
    (ref) => LocaleNotifier());

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('zh')) {
    _load();
  }

  Future<void> _load() async {
    final value = await DatabaseHelper.instance.getSetting(_localeKey);
    if (value != null) {
      final locale = _parseLocale(value);
      if (locale != null) state = locale;
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await DatabaseHelper.instance.setSetting(_localeKey, _serializeLocale(locale));
  }

  static String _serializeLocale(Locale locale) {
    if (locale.scriptCode != null) {
      return '${locale.languageCode}_${locale.scriptCode}';
    }
    return locale.languageCode;
  }

  static Locale? _parseLocale(String value) {
    if (value.contains('_')) {
      final parts = value.split('_');
      return Locale.fromSubtags(languageCode: parts[0], scriptCode: parts[1]);
    }
    return Locale(value);
  }
}
