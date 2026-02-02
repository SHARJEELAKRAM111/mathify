import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/persistence/prefs_service.dart';
import '../core/theme/theme_controller.dart';
import '../features/calculator/presentation/controllers/calculator_controller.dart';
import '../features/calculator/presentation/screens/calculator_screen.dart';

class CalcNovaApp extends StatelessWidget {
  const CalcNovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: PrefsService.instance.ensureReady(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ThemeController(PrefsService.instance)),
            ChangeNotifierProvider(create: (_) => CalculatorController(PrefsService.instance)),
          ],
          child: Consumer<ThemeController>(
            builder: (context, themeController, _) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'CalcNova',
                theme: themeController.themeData,
                home: const CalculatorScreen(),
                builder: (context, child) {
                  // Force consistent text scaling (optional)
                  final mediaQuery = MediaQuery.of(context);
                  return MediaQuery(
                    data: mediaQuery.copyWith(textScaler: TextScaler.noScaling),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
