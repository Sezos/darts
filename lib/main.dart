import 'package:darts/router.dart';
import 'package:darts/utils/colors.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:moon_design/moon_design.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Option A: initialize for a specific locale used by your app:
  await initializeDateFormatting('mn_MN', null);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    // DeviceOrientation.portraitDown,
    // DeviceOrientation.landscapeLeft,
    // DeviceOrientation.landscapeRight,
  ]);

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: false,
        builder: (ctx) => const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
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
          surfaceTintColor: Color.fromARGB(255, 27, 59, 48),
          backgroundColor: BColors().background,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: BColors().background,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark,
          ),
        ),
        scaffoldBackgroundColor: BColors().background,
      ),
    );
  }
}
