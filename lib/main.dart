import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
      title: 'Shopping List App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Modern color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo
          brightness: Brightness.light,
        ),
        
        // Typography
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        // App bar theme
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          backgroundColor: Color(0xFF6366F1),
          foregroundColor: Colors.white,
        ),

        // Card theme
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Floating action button theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 4,
        ),

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        // Use Material 3
        useMaterial3: true,
      ),
      
      // Check if user is already logged in
      home: Supabase.instance.client.auth.currentUser != null
          ? const ShoppingListsScreen()
          : const LoginScreen(),
    );
  }
}
