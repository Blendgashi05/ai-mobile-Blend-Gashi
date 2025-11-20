import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/shopping_lists_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  // The URL and anon key should be set as environment variables
  final supabaseUrl = const String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  final supabaseAnonKey = const String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Missing Supabase credentials. Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping List',
      debugShowCheckedModeBanner: false,
      theme: _buildModernDarkTheme(),
      
      // Check if user is already logged in
      home: Supabase.instance.client.auth.currentUser != null
          ? const ShoppingListsScreen()
          : const LoginScreen(),
    );
  }

  ThemeData _buildModernDarkTheme() {
    // Midnight Emerald Color Palette
    const deepSpace = Color(0xFF0B0F2A);
    const midnightBlue = Color(0xFF111936);
    const emeraldGlow = Color(0xFF27E8A7);
    const purpleAccent = Color(0xFF8B5CF6);
    const primaryText = Color(0xFFFFFFFF);
    const secondaryText = Color(0xFFB8B8D1);
    
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      
      // Scaffold background
      scaffoldBackgroundColor: deepSpace,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: emeraldGlow,
        secondary: purpleAccent,
        surface: midnightBlue,
        background: deepSpace,
        error: Color(0xFFFF5C5C),
        onPrimary: Color(0xFF000000),
        onSecondary: primaryText,
        onSurface: primaryText,
        onBackground: primaryText,
      ),

      // Typography with Google Fonts
      textTheme: TextTheme(
        // Headlines with Poppins
        displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: primaryText,
        ),
        displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: primaryText,
        ),
        headlineMedium: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        headlineSmall: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        
        // Body with Inter
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: primaryText,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        
        // Labels
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),

      // App bar with glassmorphism
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: midnightBlue.withOpacity(0.85),
        foregroundColor: primaryText,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
      ),

      // Card with glass effect
      cardTheme: CardThemeData(
        elevation: 0,
        color: midnightBlue.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primaryText.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),

      // Elevated button with gradient (will use custom widget)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: emeraldGlow,
          foregroundColor: const Color(0xFF000000),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: emeraldGlow,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Floating action button with gradient
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: emeraldGlow,
        foregroundColor: Color(0xFF000000),
        elevation: 8,
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: midnightBlue.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryText.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryText.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: emeraldGlow,
            width: 2,
          ),
        ),
        labelStyle: GoogleFonts.inter(
          color: secondaryText,
        ),
        hintStyle: GoogleFonts.inter(
          color: secondaryText.withOpacity(0.7),
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return emeraldGlow;
          }
          return secondaryText.withOpacity(0.3);
        }),
        checkColor: MaterialStateProperty.all(const Color(0xFF000000)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: midnightBlue,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: primaryText.withOpacity(0.1),
          ),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        contentTextStyle: GoogleFonts.inter(
          fontSize: 14,
          color: secondaryText,
        ),
      ),

      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: midnightBlue,
        contentTextStyle: GoogleFonts.inter(
          color: primaryText,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
