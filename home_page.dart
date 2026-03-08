import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'registration.dart'; // Ensure registration.dart has: class RegistrationPage extends StatelessWidget...

void main() => runApp(const ForteApp());

class ForteApp extends StatelessWidget {
  const ForteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000), // Deep pure black
      ),
      home: const ForteLoadingScreen(),
    );
  }
}

class ForteLoadingScreen extends StatefulWidget {
  const ForteLoadingScreen({super.key});

  @override
  State<ForteLoadingScreen> createState() => _ForteLoadingScreenState();
}

class _ForteLoadingScreenState extends State<ForteLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  bool _isFinishedLoading = false;
  String _currentMessage = "Tuning the stage...";
  late Timer _messageTimer;

  final List<String> _messages = [
    "CONSULTING LESTER...",
    "WARMING UP VOCAL CHORDS...",
    "OO-EE-AA-II...",
    "TRAINING THE CAT TO SING...",
    "HAVE A FAHNTASTIC DAY...",
    "GET SCRATCHED BY THE CAT...",
    "CLEANING THE MICROPHONES...",
    "SETTING THE REVERB...",
  ];

  @override
  void initState() {
    super.initState();
    
    // Smooth infinite rotation for the multicolor ring
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _startLoadingSequence();
  }

  void _startLoadingSequence() {
    // Cycle entertaining messages
    _messageTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted) {
        setState(() {
          _currentMessage = _messages[Random().nextInt(_messages.length)];
        });
      }
    });

    // Loading duration logic
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _isFinishedLoading = true);
        _messageTimer.cancel();
      }

      // Briefly show FORTE logo then navigate to Registration
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 1000),
              pageBuilder: (context, anim, secondAnim) => const RegistrationScreen(),
              transitionsBuilder: (context, anim, secondAnim, child) {
                return FadeTransition(opacity: anim, child: child);
              },
            ),
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _messageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: _isFinishedLoading ? _buildLogo() : _buildLoader(),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Column(
      key: const ValueKey(1),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Multi-color Gradient Loading Ring
        RotationTransition(
          turns: _rotationController,
          child: Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Colors.cyan,
                  Color.fromRGBO(227, 36, 198, 1),
                  Color.fromRGBO(255, 235, 59, 1),
                  Colors.cyan,
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(4.0), // Thickness of the ring
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 50),
        Text(
          _currentMessage,
          style: GoogleFonts.spaceMono( // A softer, modern monospace
            fontSize: 13,
            color: Colors.white.withOpacity(0.7),
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'FORTE',
          style: GoogleFonts.spaceMono(
            fontSize: 60,
            fontWeight: FontWeight.bold,
            letterSpacing: 12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          'KARAOKE REVOLUTION',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            color: Color.fromRGBO(182, 63, 203, 1),
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}