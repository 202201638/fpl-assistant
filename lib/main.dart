import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'providers/fpl_provider.dart';
import 'providers/starred_matches_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(const FPLAssistantApp());
}

class FPLAssistantApp extends StatelessWidget {
  const FPLAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FPLProvider()..loadInitialData(),
        ),
        ChangeNotifierProvider(
          create: (context) => StarredMatchesProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..initialize(),
        ),
      ],
      child: MaterialApp(
        title: 'FPL Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
