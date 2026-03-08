import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_menu.dart'; 

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() {
        _isFieldEmpty = _nameController.text.trim().isEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start, // Left aligned for modern look
            children: [
              // Icon - Modern and Clean
              const Center(
                child: Icon(Icons.music_note_rounded, color: Colors.white, size: 48),
              ),
              const SizedBox(height: 60),

              // Question Title - Monospace
              Text(
                "WHAT IS YOUR\nSTAGE NAME?",
                style: GoogleFonts.spaceMono(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "This is how fans and rivals will see you.",
                style: GoogleFonts.spaceMono(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 48),

              // Input Field - Modern Glass-style
              TextField(
                controller: _nameController,
                cursorColor: Colors.white,
                style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: "TYPE_NAME_HERE",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.cyanAccent), // Subtle focus color
                  ),
                ),
              ),
              const SizedBox(height: 80),

              // Interactive Button
              GestureDetector(
                onTap: () {
                  if (!_isFieldEmpty) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (c) => MainMenu(username: _nameController.text.trim()),
                      ),
                    );
                  }
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _isFieldEmpty ? 0.3 : 1.0,
                  child: Container(
                    width: double.infinity,
                    height: 65,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      // Modern multi-color gradient border
                      gradient: const LinearGradient(
                        colors: [Colors.cyanAccent, Color.fromRGBO(182, 63, 203, 1)],
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(2), // Creates the "border" effect
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          "ENTER_FORTE",
                          style: GoogleFonts.spaceMono(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}