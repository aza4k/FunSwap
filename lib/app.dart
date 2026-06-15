import 'package:flutter/material.dart';
import 'package:funswap/core/theme/app_theme.dart';
import 'package:funswap/features/splash/splash_page.dart';
import 'package:funswap/core/services/localization_service.dart';

class FunSwapApp extends StatelessWidget {
  const FunSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: appLanguageNotifier,
      builder: (context, currentLanguage, child) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: appThemeNotifier,
          builder: (context, currentThemeMode, child) {
            return MaterialApp(
              title: 'FunSwap',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                primaryColor: AppColors.primary,
              ),
              darkTheme: AppTheme.darkTheme,
              themeMode: currentThemeMode,
              home: const SplashPage(), // Start with Splash / Loading Screen
            );
          },
        );
      },
    );
  }
}

