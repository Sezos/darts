import 'package:darts/core/providers/settings/settings.provider.dart';
import 'package:darts/firebase_options.dart';
import 'package:darts/l10n/l10n.dart';
import 'package:darts/router.dart';
import 'package:darts/utils/ads.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moon_design/moon_design.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  SettingsNotifier.keepMongolianForExistingInstalls();
  await initializeDateFormatting('mn_MN', null);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Firebase project darts-onoo (configured with `flutterfire configure`).
  // Only iOS and Android have options; elsewhere init throws and analytics
  // stay switched off.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    Analytics.enable();
  } catch (e) {
    debugPrint('Firebase not configured, analytics disabled: $e');
  }
  await AdService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(
      settingsProvider.select((s) => s.language),
    );
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => context.l10n.appName,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // A picked language is forced through `locale`. Under Auto it's null
      // and Flutter asks the callback, again whenever the phone's languages
      // change. Flutter doesn't re-run the callback when only the callback
      // changes, so it must not depend on the setting.
      locale: language.locale,
      localeListResolutionCallback: (deviceLocales, _) =>
          autoLocale(deviceLocales ?? const []),
      theme: ThemeData.dark().copyWith(
        extensions: <ThemeExtension<dynamic>>[
          MoonTheme(
            tokens: MoonTokens.dark.copyWith(
              colors: MoonColors.dark.copyWith(
                piccolo: BColors().primary,
              ),
            ),
          ),
        ],
        primaryColor: BColors().primary,
        appBarTheme: AppBarTheme(
          elevation: 0,
          leadingWidth: 56,
          surfaceTintColor: Colors.transparent,
          backgroundColor: BColors().background,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: BColors().background,
            // Light icons on the near-black bar (Android) / light status
            // text (iOS). Both read "dark background".
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        scaffoldBackgroundColor: BColors().background,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: BColors().primary,
          selectionColor: BColors().primaryGlow,
          selectionHandleColor: BColors().primary,
        ),
      ),
    );
  }
}
