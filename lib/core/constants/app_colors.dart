import 'package:flutter/material.dart';

class AppColors {
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║            PREMIUM VINTAGE SALOON THEME - LUXURIOUS 1880s             ║
  // ╚═══════════════════════════════════════════════════════════════════════╝

  // ═══════════════════════════════════════════════════════════════════════
  //  PRIMARY BACKGROUNDS - Rich Woods & Aged Parchment
  // ═══════════════════════════════════════════════════════════════════════
  static const Color background = Color(0xFFFAF3E8); // Warm Ivory Parchment
  static const Color surface = Color(0xFFF5EBD9); // Antique Paper
  static const Color cardColor = Color(0xFFFFF8EE); // Cream White Card
  static const Color scaffoldDark = Color(0xFF1C110A); // Deep Saloon Dark

  // Wood Tones
  static const Color woodDark = Color(0xFF2A1810); // Dark Mahogany
  static const Color woodMedium = Color(0xFF4A3528); // Rich Walnut
  static const Color woodLight = Color(0xFF6B5344); // Warm Oak
  static const Color woodAccent = Color(0xFF8B7355); // Light Cedar

  // ═══════════════════════════════════════════════════════════════════════
  //  ACCENT COLORS - Brass, Gold & Premium Metals
  // ═══════════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF5D3A1A); // Rich Saddle Brown
  static const Color primaryDark = Color(0xFF3D2415); // Deep Espresso
  static const Color primaryLight = Color(0xFF8B6914); // Warm Amber

  static const Color secondary = Color(0xFFD4A853); // Antique Gold
  static const Color gold = Color(0xFFE8C547); // Bright Gold
  static const Color goldDark = Color(0xFFB8860B); // Dark Goldenrod
  static const Color brass = Color(0xFFCD9B1D); // Polished Brass
  static const Color copper = Color(0xFFB87333); // Copper Accent
  static const Color bronze = Color(0xFF8C7853); // Aged Bronze

  // ═══════════════════════════════════════════════════════════════════════
  //  TEXT COLORS - Vintage Ink Shades
  // ═══════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF1A0F07); // Rich Black Ink
  static const Color textSecondary = Color(0xFF4A3828); // Brown Ink
  static const Color textTertiary = Color(0xFF7A6855); // Faded Sepia
  static const Color textLight = Color(0xFFF5EBD9); // Light Cream Text
  static const Color textGold = Color(0xFFE8C547); // Gold Lettering

  // ═══════════════════════════════════════════════════════════════════════
  //  FUNCTIONAL COLORS - Period Appropriate
  // ═══════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF2D5A27); // Forest Green
  static const Color successLight = Color(0xFF4A8C3F); // Leaf Green
  static const Color error = Color(0xFF8B2500); // Brick Red
  static const Color errorLight = Color(0xFFB33A3A); // Soft Red
  static const Color warning = Color(0xFFCD853F); // Sandy Brown
  static const Color warningLight = Color(0xFFDEB887); // Burlywood
  static const Color info = Color(0xFF4A6B8A); // Dusty Blue

  // ═══════════════════════════════════════════════════════════════════════
  //  DECORATIVE & UI ELEMENTS
  // ═══════════════════════════════════════════════════════════════════════
  static const Color border = Color(0xFFB8A082); // Tan Border
  static const Color borderDark = Color(0xFF6B5344); // Dark Border
  static const Color borderGold = Color(0xFFD4A853); // Gold Border
  static const Color divider = Color(0xFFD4C4A8); // Light Divider

  static const Color shadow = Color(0xFF1A0F07); // Deep Shadow
  static const Color overlay = Color(0x801A0F07); // Dark Overlay 50%

  // Decorative
  static const Color velvet = Color(0xFF722F37); // Wine Red Velvet
  static const Color velvetDark = Color(0xFF4A1F24); // Dark Burgundy
  static const Color leather = Color(0xFF8B4513); // Saddle Brown Leather
  static const Color rope = Color(0xFFCDB380); // Hemp Rope
  static const Color whiskey = Color(0xFFD2691E); // Whiskey Amber
  static const Color ivory = Color(0xFFFFFFF0); // Ivory White

  // ═══════════════════════════════════════════════════════════════════════
  //  ROLE-BASED COLORS
  // ═══════════════════════════════════════════════════════════════════════
  static const Color adminColor = Color(0xFF722F37); // Velvet Red
  static const Color shopColor = Color(0xFF2D5A27); // Forest Green
  static const Color customerColor = Color(0xFF4A6B8A); // Dusty Blue

  // ═══════════════════════════════════════════════════════════════════════
  //  PREMIUM GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE8C547), // Bright Gold
      Color(0xFFD4A853), // Antique Gold
      Color(0xFFB8860B), // Dark Gold
    ],
  );

  static const LinearGradient woodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF6B5344), // Light Oak
      Color(0xFF4A3528), // Rich Walnut
      Color(0xFF2A1810), // Dark Mahogany
    ],
  );

  static const LinearGradient parchmentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFF8EE), // Cream
      Color(0xFFFAF3E8), // Ivory
      Color(0xFFF5EBD9), // Antique Paper
    ],
  );

  static const LinearGradient leatherGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF8B6914), // Light Leather
      Color(0xFF5D3A1A), // Medium Leather
      Color(0xFF3D2415), // Dark Leather
    ],
  );

  static const LinearGradient velvetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF8B3A44), // Light Velvet
      Color(0xFF722F37), // Wine Red
      Color(0xFF4A1F24), // Dark Burgundy
    ],
  );

  static const LinearGradient saloonBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1C110A), // Dark Ceiling
      Color(0xFF2A1810), // Dark Mahogany
      Color(0xFF3D2415), // Espresso
    ],
  );

  // ═══════════════════════════════════════════════════════════════════════
  //  BOX SHADOWS
  // ═══════════════════════════════════════════════════════════════════════
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.15),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.25),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.1),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get signShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.4),
      blurRadius: 24,
      offset: const Offset(0, 12),
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: gold.withValues(alpha: 0.3),
      blurRadius: 12,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get innerShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════
  //  BORDER DECORATIONS
  // ═══════════════════════════════════════════════════════════════════════
  static Border get goldBorder => Border.all(color: secondary, width: 2);
  static Border get thickGoldBorder => Border.all(color: secondary, width: 4);
  static Border get woodBorder => Border.all(color: woodAccent, width: 2);
  static Border get subtleBorder => Border.all(color: border, width: 1);
}
