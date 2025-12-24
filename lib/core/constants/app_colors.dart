import 'package:flutter/material.dart';

class AppColors {
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║              1920s ART DECO SEPIA THEME - GATSBY LUXURY               ║
  // ╚═══════════════════════════════════════════════════════════════════════╝

  // ═══════════════════════════════════════════════════════════════════════
  //  PRIMARY BACKGROUNDS - Warm Sepia & Cream Tones
  // ═══════════════════════════════════════════════════════════════════════
  static const Color background = Color(0xFFF8F0E3); // Warm Cream
  static const Color surface = Color(0xFFF2E6D0); // Aged Sepia Paper
  static const Color cardColor = Color(0xFFFDF8EF); // Soft Cream Card
  static const Color scaffoldDark = Color(0xFF1A1510); // Deep Charcoal Brown

  // Art Deco Dark Tones
  static const Color woodDark = Color(0xFF1E1812); // Ebony Black-Brown
  static const Color woodMedium = Color(0xFF3D2E24); // Deep Chocolate
  static const Color woodLight = Color(0xFF5C483A); // Warm Walnut
  static const Color woodAccent = Color(0xFF8C7A6B); // Dusty Taupe

  // Ivory & Sepia Spectrum
  static const Color ivory = Color(0xFFFFFBF5); // Pure Ivory
  static const Color cream = Color(0xFFF5E6D3); // Warm Cream
  static const Color tan = Color(0xFFD4C4A8); // Light Tan
  static const Color sepia = Color(0xFFB89F7D); // Classic Sepia
  static const Color sepiaDeep = Color(0xFF8B7355); // Deep Sepia

  // ═══════════════════════════════════════════════════════════════════════
  //  ACCENT COLORS - Art Deco Metallics (Gold, Bronze, Champagne)
  // ═══════════════════════════════════════════════════════════════════════
  static const Color primary = Color(0xFF6B4423); // Rich Tobacco Brown
  static const Color primaryDark = Color(0xFF3D2815); // Espresso
  static const Color primaryLight = Color(0xFF9C7A4F); // Caramel

  static const Color secondary = Color(0xFFD4A853); // Art Deco Gold
  static const Color gold = Color(0xFFDFB347); // Brilliant Gold
  static const Color goldDark = Color(0xFFB8960B); // Antique Gold
  static const Color goldLight = Color(0xFFF0D078); // Champagne Gold
  static const Color brass = Color(0xFFD4A853); // Polished Brass
  static const Color bronze = Color(0xFFA67C52); // Aged Bronze
  static const Color copper = Color(0xFFC08050); // Burnished Copper
  static const Color champagne = Color(0xFFF7E7CE); // Champagne

  // ═══════════════════════════════════════════════════════════════════════
  //  TEXT COLORS - Period Typography Shades
  // ═══════════════════════════════════════════════════════════════════════
  static const Color textPrimary = Color(0xFF1E1812); // Rich Charcoal
  static const Color textSecondary = Color(0xFF4A3C30); // Warm Brown
  static const Color textTertiary = Color(0xFF7D6D5D); // Muted Sepia
  static const Color textLight = Color(0xFFF5E6D3); // Cream Text
  static const Color textGold = Color(0xFFDFB347); // Gold Text

  // ═══════════════════════════════════════════════════════════════════════
  //  FUNCTIONAL COLORS - Deco Palette
  // ═══════════════════════════════════════════════════════════════════════
  static const Color success = Color(0xFF4A7C59); // Jade Green
  static const Color successLight = Color(0xFF6B9E7A); // Light Jade
  static const Color error = Color(0xFF9E3B33); // Art Deco Red
  static const Color errorLight = Color(0xFFBF5A52); // Soft Crimson
  static const Color warning = Color(0xFFD4A853); // Deco Gold (same as accent)
  static const Color warningLight = Color(0xFFE8C878); // Light Gold
  static const Color info = Color(0xFF5B7A8C); // Dusty Teal

  // ═══════════════════════════════════════════════════════════════════════
  //  DECORATIVE & UI ELEMENTS
  // ═══════════════════════════════════════════════════════════════════════
  static const Color border = Color(0xFFD4C4A8); // Tan Border
  static const Color borderDark = Color(0xFF8C7A6B); // Dark Taupe Border
  static const Color borderGold = Color(0xFFD4A853); // Gold Border
  static const Color divider = Color(0xFFE5D9C8); // Light Cream Divider

  static const Color shadow = Color(0xFF1A1510); // Deep Shadow
  static const Color overlay = Color(0x801A1510); // Dark Overlay 50%

  // Art Deco Decorative Colors
  static const Color velvet = Color(0xFF6B3A3A); // Deep Burgundy
  static const Color velvetDark = Color(0xFF4A2525); // Dark Wine
  static const Color leather = Color(0xFF8B5A2B); // Rich Leather
  static const Color rope = Color(0xFFCDB38C); // Hemp Rope
  static const Color whiskey = Color(0xFFCB8034); // Amber Whiskey

  // Deco Accent Colors
  static const Color teal = Color(0xFF2D6B6B); // Art Deco Teal
  static const Color emerald = Color(0xFF50796F); // Deco Emerald
  static const Color ruby = Color(0xFF8B3A3A); // Ruby Red
  static const Color sapphire = Color(0xFF4A5D7A); // Sapphire Blue

  // ═══════════════════════════════════════════════════════════════════════
  //  ROLE-BASED COLORS
  // ═══════════════════════════════════════════════════════════════════════
  static const Color adminColor = Color(0xFF6B3A3A); // Ruby
  static const Color shopColor = Color(0xFF4A7C59); // Jade
  static const Color customerColor = Color(0xFF5B7A8C); // Teal

  // ═══════════════════════════════════════════════════════════════════════
  //  ART DECO GRADIENTS
  // ═══════════════════════════════════════════════════════════════════════

  // Signature Gold Gradient - The hero gradient for buttons & accents
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF0D078), // Champagne Gold
      Color(0xFFDFB347), // Brilliant Gold
      Color(0xFFD4A853), // Antique Gold
      Color(0xFFB8960B), // Dark Gold
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  // Bronze Metallic Gradient
  static const LinearGradient bronzeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4A853), // Brass
      Color(0xFFA67C52), // Bronze
      Color(0xFF8C6A45), // Deep Bronze
    ],
  );

  // Classic Wood Gradient (for dark headers)
  static const LinearGradient woodGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF3D2E24), // Chocolate
      Color(0xFF2A1E18), // Dark Wood
      Color(0xFF1E1812), // Ebony
    ],
  );

  // Sepia Paper Gradient (for cards & backgrounds)
  static const LinearGradient parchmentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFDF8EF), // Soft Cream
      Color(0xFFF8F0E3), // Warm Cream
      Color(0xFFF2E6D0), // Aged Paper
    ],
  );

  // Leather Gradient (for premium sections)
  static const LinearGradient leatherGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF9C7A4F), // Light Leather
      Color(0xFF6B4423), // Rich Tobacco
      Color(0xFF3D2815), // Dark Espresso
    ],
  );

  // Velvet Gradient (for luxury accents)
  static const LinearGradient velvetGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF8B4A4A), // Light Burgundy
      Color(0xFF6B3A3A), // Burgundy
      Color(0xFF4A2525), // Dark Wine
    ],
  );

  // Art Deco Background Gradient
  static const LinearGradient saloonBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A1510), // Deep Charcoal
      Color(0xFF2A1E18), // Dark Chocolate
      Color(0xFF3D2E24), // Warm Chocolate
    ],
  );

  // Champagne Shimmer Gradient (for subtle highlights)
  static const LinearGradient champagneGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFBF5), // Pure Ivory
      Color(0xFFF7E7CE), // Champagne
      Color(0xFFF5E6D3), // Warm Cream
    ],
  );

  // Geometric Art Deco Pattern Gradient
  static const LinearGradient decoAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFDFB347), // Gold
      Color(0xFF1E1812), // Ebony
      Color(0xFFDFB347), // Gold
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // ═══════════════════════════════════════════════════════════════════════
  //  BOX SHADOWS - Soft & Luxurious
  // ═══════════════════════════════════════════════════════════════════════
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.15),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.08),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  static List<BoxShadow> get signShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.25),
      blurRadius: 32,
      offset: const Offset(0, 16),
      spreadRadius: 4,
    ),
  ];

  static List<BoxShadow> get goldGlow => [
    BoxShadow(
      color: gold.withValues(alpha: 0.35),
      blurRadius: 16,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> get softGoldGlow => [
    BoxShadow(
      color: gold.withValues(alpha: 0.2),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  static List<BoxShadow> get innerShadow => [
    BoxShadow(
      color: shadow.withValues(alpha: 0.06),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get decoShadow => [
    BoxShadow(
      color: gold.withValues(alpha: 0.15),
      blurRadius: 20,
      spreadRadius: 2,
    ),
    BoxShadow(
      color: shadow.withValues(alpha: 0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  // ═══════════════════════════════════════════════════════════════════════
  //  BORDER DECORATIONS - Art Deco Style
  // ═══════════════════════════════════════════════════════════════════════
  static Border get goldBorder => Border.all(color: secondary, width: 2);
  static Border get thickGoldBorder => Border.all(color: secondary, width: 3);
  static Border get woodBorder => Border.all(color: woodAccent, width: 2);
  static Border get subtleBorder => Border.all(color: border, width: 1);
  static Border get decoBorder => Border.all(color: gold, width: 2);

  // ═══════════════════════════════════════════════════════════════════════
  //  ART DECO DECORATIVE HELPERS
  // ═══════════════════════════════════════════════════════════════════════

  // Get geometric corner decoration colors
  static List<Color> get decoCornerColors => [gold, bronze, goldDark];

  // Get chevron pattern colors
  static List<Color> get chevronColors => [goldLight, gold, goldDark];
}
