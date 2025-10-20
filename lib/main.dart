import 'package:flutter/material.dart';
import 'folders_screen.dart';

void main() {
  // Ensure Flutter bindings are initialized for database operations
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Organizer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FoldersScreen(),
    );
  }
}