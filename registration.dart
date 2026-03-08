
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main_menu.dart'; // Ensure this matches your file name

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
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Neon Mic Icon
              const Icon(Icons.mic_none, color: Color(0xFFFF00CC), size: 60),
              const SizedBox(height: 20),
              Text(
                "WHAT'S YOUR STAGE NAME?",
                textAlign: TextAlign.center,
                style: GoogleFonts.oswald(
                  color: Colors.white, 
                  fontSize: 24, 
                  letterSpacing: 2
                ),
              ),
              const SizedBox(height: 40),
              
              // Input Field
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: "E.G. NEON_VOICE",
                  hintStyle: TextStyle(color: Colors.white10),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3333FF))
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFFF00CC))
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
                        color: const Color(0xFFFF00CC).withOpacity(0.2),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "CONTINUE",
                      style: GoogleFonts.oswald(
                        color: Colors.white, 
                        fontSize: 18, 
                        fontWeight: FontWeight.bold
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
