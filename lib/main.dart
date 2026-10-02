import 'package:darts/router.dart';
import 'package:darts/utils/ads.dart';
import 'package:darts/utils/analytics.dart';
import 'package:darts/utils/colors.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moon_design/moon_design.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await initializeDateFormatting('mn_MN', null);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Firebase needs GoogleService-Info.plist (iOS) and google-services.json
  // (Android). Until they exist, init fails and analytics stay switched off.
  try {
    await Firebase.initializeApp();
    Analytics.enable();
  } catch (e) {
    debugPrint('Firebase not configured, analytics disabled: $e');
  }
  await AdService.initialize();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
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
