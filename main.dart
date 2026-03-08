import 'package:flutter/material.dart';
import 'registration.dart'; // Make sure the file name matches

void main() {
  runApp(const ForteApp());
}

class ForteApp extends StatelessWidget {
  const ForteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forte Karaoke',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.pink,
      ),
      // This is what starts the flow!
      home: const RegistrationScreen(), 
    );
  }
}