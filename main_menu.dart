
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'room_creation.dart'; // Ensure this exists for your lobby

class MainMenu extends StatelessWidget {
  final String username;
  const MainMenu({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _codeController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Subtle glow in the background
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF3333FF).withOpacity(0.15),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 80),
                Text(
                  "WELCOME BACK,",
                  style: GoogleFonts.oswald(color: Colors.white54, fontSize: 16, letterSpacing: 2),
                ),
                Text(
                  username.toUpperCase(),
                  style: GoogleFonts.oswald(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),
                
                // Host Option
                _buildMenuCard(
                  context,
                  title: "HOST A PARTY",
                  subtitle: "Create a room and lead the stage",
                  icon: Icons.add_box_rounded,
                  color: const Color(0xFFFF00CC),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (c) => RoomCreationPage(username: username)),
                  ),
                ),
                
                const SizedBox(height: 25),
                
                // Join Option
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _codeController,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.oswald(color: Colors.white, fontSize: 32, letterSpacing: 15),
                        decoration: const InputDecoration(
                          hintText: "CODE",
                          hintStyle: TextStyle(color: Colors.white10, letterSpacing: 2),
                          border: InputBorder.none,
                          counterText: "",
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3333FF),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          if (_codeController.text.length == 4) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => RoomCreationPage(
                                  username: username, 
                                  existingCode: _codeController.text
                                ),
                              ),
                            );
                          }
                        },
                        child: Text("JOIN ROOM", style: GoogleFonts.oswald(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {
    required String title, 
    required String subtitle, 
    required IconData icon, 
    required Color color,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.oswald(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
          ],
        ),
      ),
    );
  }
}
