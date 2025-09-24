import 'package:flutter/material.dart';

void main() {
  // TODO: Add Firebase initialization logic here (Milestone 1, Step 2)
  runApp(const FermentrackApp());
}

class FermentrackApp extends StatelessWidget {
  const FermentrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fermentrack',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // TODO: Add router configuration here (Milestone 1, Step 3)
      home: const Scaffold(body: Center(child: Text('Welcome to Fermentrack!'))),
    );
  }
}
