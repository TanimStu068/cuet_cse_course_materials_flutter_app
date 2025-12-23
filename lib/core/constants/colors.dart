import 'package:flutter/material.dart';

const LinearGradient kMainGradient = LinearGradient(
  colors: [Color(0xFF4A4BB5), Color(0xFF3D42A8), Color(0xFF2E3192)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

/// 🎨 App primary colors for consistent theming
class AppColors {
  static const Color primary = Color(0xFF3D42A8);
  static const Color secondary = Color(0xFF4A4BB5);
  static const Color accent = Color(0xFF2E3192);
  static const Color background = Color.fromARGB(255, 215, 217, 250);
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Colors.grey;
}
