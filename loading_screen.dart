import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_menu.dart'; // Ensure this matches your next filename

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Neon Mic Header
              ShaderMask(
                shaderCallback: (rect) => const LinearGradient(
                  colors: [Color(0xFFFF00CC), Color(0xFF3333FF)],
                ).createShader(rect),
                child: const Icon(Icons.mic_external_on, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                "STAGE NAME",
                style: GoogleFonts.oswald(
                  color: Colors.white,
                  fontSize: 28,
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              
              // Input Field with Blue Neon Focus
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "ENTER YOUR ALIAS...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3333FF), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              
              // Neon Continue Button
              GestureDetector(
                onTap: () {
                  if (_nameController.text.trim().isNotEmpty) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (c) => MainMenu(username: _nameController.text.trim()),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFFFF00CC), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF00CC).withOpacity(0.3),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "CONTINUE",
                      style: GoogleFonts.oswald(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
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