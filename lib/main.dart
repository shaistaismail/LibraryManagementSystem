import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:practiceflutter/Screens/Home_Screen.dart';
import 'Screens/Splash_Screen.dart';
import 'firebase_options.dart'; // flutterfire configure se banti hai


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF1E3A8A),
      ),
      home: SplashScreen(),
    );
  }
}