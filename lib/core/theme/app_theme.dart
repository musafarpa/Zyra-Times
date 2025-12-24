import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zyraslot/core/constants/app_colors.dart';

class AppTheme {
  // ╔═══════════════════════════════════════════════════════════════════════╗
  // ║            PREMIUM VINTAGE SALOON THEME - LUXURIOUS 1880s             ║
  // ╚═══════════════════════════════════════════════════════════════════════╝

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,

      // ═══════════════════════════════════════════════════════════════════
      //  COLOR SCHEME
      // ═══════════════════════════════════════════════════════════════════
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.gold,
        secondary: AppColors.secondary,
        onSecondary: AppColors.woodDark,
        tertiary: AppColors.velvet,
        surface: AppColors.cardColor,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        onError: Colors.white,
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  TYPOGRAPHY - PREMIUM VINTAGE FONTS
      // ═══════════════════════════════════════════════════════════════════
      textTheme: TextTheme(
        // Display - Western Headers (Rye)
        displayLarge: GoogleFonts.rye(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        displayMedium: GoogleFonts.rye(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.5,
        ),
        displaySmall: GoogleFonts.rye(
          fontSize: 24,
          color: AppColors.textPrimary,
          letterSpacing: 1,
        ),

        // Headlines - Elegant Victorian (Playfair Display)
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Titles - Classic Serif (Crimson Text)
        titleLarge: GoogleFonts.crimsonText(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.crimsonText(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: GoogleFonts.crimsonText(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),

        // Body - Readable (Crimson Text)
        bodyLarge: GoogleFonts.crimsonText(
          fontSize: 18,
          color: AppColors.textPrimary,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.crimsonText(
          fontSize: 16,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        bodySmall: GoogleFonts.crimsonText(
          fontSize: 14,
          color: AppColors.textTertiary,
          height: 1.4,
        ),

        // Labels
        labelLarge: GoogleFonts.rye(
          fontSize: 14,
          color: AppColors.primary,
          letterSpacing: 1,
        ),
        labelMedium: GoogleFonts.crimsonText(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelSmall: GoogleFonts.crimsonText(
          fontSize: 11,
          color: AppColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  APP BAR - WOODEN SALOON HEADER
      // ═══════════════════════════════════════════════════════════════════
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.woodMedium,
        foregroundColor: AppColors.gold,
        elevation: 8,
        shadowColor: AppColors.shadow,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.gold, size: 24),
        actionsIconTheme: const IconThemeData(color: AppColors.gold, size: 24),
        titleTextStyle: GoogleFonts.rye(
          color: AppColors.gold,
          fontSize: 20,
          letterSpacing: 2,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  ELEVATED BUTTON - LEATHER STYLE
      // ═══════════════════════════════════════════════════════════════════
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.gold,
          elevation: 6,
          shadowColor: AppColors.shadow.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: AppColors.secondary, width: 2),
          ),
          textStyle: GoogleFonts.rye(
            fontSize: 16,
            letterSpacing: 1.5,
          ),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  OUTLINED BUTTON
      // ═══════════════════════════════════════════════════════════════════
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.rye(
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  TEXT BUTTON
      // ═══════════════════════════════════════════════════════════════════
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.crimsonText(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  INPUT DECORATION - AGED PAPER
      // ═══════════════════════════════════════════════════════════════════
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.ivory.withValues(alpha: 0.8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.crimsonText(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
        hintStyle: GoogleFonts.crimsonText(
          color: AppColors.textTertiary,
          fontStyle: FontStyle.italic,
        ),
        floatingLabelStyle: GoogleFonts.rye(
          color: AppColors.primary,
          fontSize: 14,
        ),
        prefixIconColor: AppColors.primary,
        suffixIconColor: AppColors.textSecondary,
        errorStyle: GoogleFonts.crimsonText(
          color: AppColors.error,
          fontSize: 12,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  CARD - PARCHMENT PANELS
      // ═══════════════════════════════════════════════════════════════════
      cardTheme: CardThemeData(
        color: AppColors.cardColor,
        elevation: 4,
        shadowColor: AppColors.shadow.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  DIALOG - NOTICE BOARD
      // ═══════════════════════════════════════════════════════════════════
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.cardColor,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.secondary, width: 3),
        ),
        titleTextStyle: GoogleFonts.rye(
          color: AppColors.textPrimary,
          fontSize: 22,
        ),
        contentTextStyle: GoogleFonts.crimsonText(
          color: AppColors.textSecondary,
          fontSize: 16,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  BOTTOM NAVIGATION - WOODEN BAR
      // ═══════════════════════════════════════════════════════════════════
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.woodMedium,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.woodAccent,
        elevation: 16,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.rye(fontSize: 11, letterSpacing: 0.5),
        unselectedLabelStyle: GoogleFonts.crimsonText(fontSize: 11),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  NAVIGATION BAR (Material 3)
      // ═══════════════════════════════════════════════════════════════════
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.woodMedium,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.3),
        elevation: 8,
        height: 70,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.rye(fontSize: 11, color: AppColors.gold);
          }
          return GoogleFonts.crimsonText(fontSize: 11, color: AppColors.woodAccent);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.gold, size: 26);
          }
          return const IconThemeData(color: AppColors.woodAccent, size: 24);
        }),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  FLOATING ACTION BUTTON - BRASS MEDAL
      // ═══════════════════════════════════════════════════════════════════
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.woodDark,
        elevation: 8,
        shape: CircleBorder(
          side: BorderSide(color: AppColors.gold, width: 3),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  SNACKBAR
      // ═══════════════════════════════════════════════════════════════════
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.woodMedium,
        contentTextStyle: GoogleFonts.crimsonText(
          color: AppColors.textLight,
          fontSize: 15,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 8,
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  CHIP - BRASS TOKENS
      // ═══════════════════════════════════════════════════════════════════
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.secondary,
        disabledColor: AppColors.border,
        labelStyle: GoogleFonts.crimsonText(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        secondaryLabelStyle: GoogleFonts.crimsonText(
          color: AppColors.woodDark,
          fontSize: 14,
        ),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  DIVIDER
      // ═══════════════════════════════════════════════════════════════════
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 24,
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  ICON
      // ═══════════════════════════════════════════════════════════════════
      iconTheme: const IconThemeData(
        color: AppColors.primary,
        size: 24,
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  LIST TILE
      // ═══════════════════════════════════════════════════════════════════
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        iconColor: AppColors.primary,
        textColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  DRAWER
      // ═══════════════════════════════════════════════════════════════════
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.cardColor,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  BOTTOM SHEET
      // ═══════════════════════════════════════════════════════════════════
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.cardColor,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        dragHandleColor: AppColors.border,
        dragHandleSize: Size(40, 4),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  TAB BAR
      // ═══════════════════════════════════════════════════════════════════
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.gold,
        unselectedLabelColor: AppColors.woodAccent,
        indicatorColor: AppColors.gold,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.rye(fontSize: 14),
        unselectedLabelStyle: GoogleFonts.crimsonText(fontSize: 14),
        dividerColor: Colors.transparent,
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  SWITCH
      // ═══════════════════════════════════════════════════════════════════
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.gold;
          }
          return AppColors.woodAccent;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  CHECKBOX
      // ═══════════════════════════════════════════════════════════════════
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.gold),
        side: const BorderSide(color: AppColors.border, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  RADIO
      // ═══════════════════════════════════════════════════════════════════
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.border;
        }),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  PROGRESS INDICATOR
      // ═══════════════════════════════════════════════════════════════════
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.gold,
        linearTrackColor: AppColors.border,
        circularTrackColor: AppColors.border,
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  SLIDER
      // ═══════════════════════════════════════════════════════════════════
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.gold,
        overlayColor: AppColors.gold.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.woodMedium,
        valueIndicatorTextStyle: GoogleFonts.crimsonText(
          color: AppColors.gold,
          fontSize: 14,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  DATE PICKER
      // ═══════════════════════════════════════════════════════════════════
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.cardColor,
        headerBackgroundColor: AppColors.woodMedium,
        headerForegroundColor: AppColors.gold,
        dayStyle: GoogleFonts.crimsonText(fontSize: 14),
        yearStyle: GoogleFonts.crimsonText(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  TIME PICKER
      // ═══════════════════════════════════════════════════════════════════
      timePickerTheme: TimePickerThemeData(
        backgroundColor: AppColors.cardColor,
        hourMinuteColor: AppColors.surface,
        dialBackgroundColor: AppColors.surface,
        dialHandColor: AppColors.primary,
        entryModeIconColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.secondary, width: 2),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  DROPDOWN
      // ═══════════════════════════════════════════════════════════════════
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: GoogleFonts.crimsonText(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.cardColor),
          elevation: WidgetStateProperty.all(8),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  POPUP MENU
      // ═══════════════════════════════════════════════════════════════════
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.cardColor,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
        textStyle: GoogleFonts.crimsonText(
          fontSize: 15,
          color: AppColors.textPrimary,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  TOOLTIP
      // ═══════════════════════════════════════════════════════════════════
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.woodMedium,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.secondary),
        ),
        textStyle: GoogleFonts.crimsonText(
          color: AppColors.textLight,
          fontSize: 13,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  BADGE
      // ═══════════════════════════════════════════════════════════════════
      badgeTheme: BadgeThemeData(
        backgroundColor: AppColors.velvet,
        textColor: AppColors.textLight,
        textStyle: GoogleFonts.crimsonText(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  EXPANSION TILE
      // ═══════════════════════════════════════════════════════════════════
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: AppColors.cardColor,
        collapsedBackgroundColor: Colors.transparent,
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
        collapsedTextColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════
      //  SEGMENTED BUTTON
      // ═══════════════════════════════════════════════════════════════════
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.surface;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.gold;
            }
            return AppColors.textSecondary;
          }),
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
