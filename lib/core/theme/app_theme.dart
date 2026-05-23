import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.green),
      scaffoldBackgroundColor: AppColors.page,
      fontFamily: 'Microsoft YaHei UI',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(fontWeight: FontWeight.w900),
        titleLarge: TextStyle(fontWeight: FontWeight.w900),
        titleMedium: TextStyle(fontWeight: FontWeight.w800),
        bodyLarge: TextStyle(fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontWeight: FontWeight.w500),
      ).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    );
  }
}
