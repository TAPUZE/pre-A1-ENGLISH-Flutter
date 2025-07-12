import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'models/user_log.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(UserLogAdapter());
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PRE A1 English Trip',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
