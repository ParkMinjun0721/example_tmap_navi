import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:example_tmap_navi/theme/theme.dart';
import 'package:example_tmap_navi/viewmodels/theme_controller.dart';

import 'package:example_tmap_navi/routes/app_routes.dart'; // GoRouter 정의된 파일

import 'package:firebase_core/firebase_core.dart';
import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: CashDrivingTmapApp()));
}

class CashDrivingTmapApp extends ConsumerWidget {
  const CashDrivingTmapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLightTheme = ref.watch(themeProvider);
    final themeCtrl    = ref.read(themeProvider.notifier);

    return MaterialApp.router(
      routerConfig: router(),
    );
  }
}
