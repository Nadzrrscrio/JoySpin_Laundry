import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Pastikan import ini ada
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- WARNA UTAMA ---
  static const Color primaryColor = Color(0xFF00BFA5); 
  static const Color secondaryColor = Color(0xFF00897B); 
  
  // --- WARNA LIGHT MODE ---
  static const Color lightBackgroundColor = Color(0xFFE0F2F1);
  static const Color lightCardColor = Colors.white;

  // --- WARNA DARK MODE ---
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkInputFill = Color(0xFF2C2C2C);

  // --- JEMBATAN (FIX ERROR) ---
  // Getter ini membuat kode lama 'AppTheme.backgroundColor' tetap jalan
  // dan otomatis berubah warna sesuai mode gelap/terang
  static Color get backgroundColor => Get.isDarkMode ? darkBackgroundColor : lightBackgroundColor;
  static Color get cardColor => Get.isDarkMode ? darkCardColor : lightCardColor;

  // ===========================================================================
  // TEMA TERANG (LIGHT THEME)
  // ===========================================================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackgroundColor,
      cardColor: lightCardColor,
      
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightCardColor,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.black87, 
          fontSize: 18, 
          fontWeight: FontWeight.bold
        ),
        iconTheme: const IconThemeData(color: secondaryColor),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: secondaryColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          foregroundColor: secondaryColor,
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: primaryColor.withOpacity(0.1),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        labelStyle: const TextStyle(color: secondaryColor),
        prefixIconColor: secondaryColor,
      ),
      
      iconTheme: const IconThemeData(color: secondaryColor),
    );
  }

  // ===========================================================================
  // TEMA GELAP (DARK THEME)
  // ===========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      cardColor: darkCardColor,

      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkCardColor,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),

      appBarTheme: AppBarTheme(
        backgroundColor: darkCardColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          color: Colors.white, 
          fontSize: 18, 
          fontWeight: FontWeight.bold
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 12),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        labelStyle: const TextStyle(color: primaryColor),
        prefixIconColor: primaryColor,
        hintStyle: TextStyle(color: Colors.grey.shade600),
      ),

      iconTheme: const IconThemeData(color: primaryColor),
      bottomSheetTheme: const BottomSheetThemeData(backgroundColor: darkCardColor), dialogTheme: DialogThemeData(backgroundColor: darkCardColor),
    );
  }
}