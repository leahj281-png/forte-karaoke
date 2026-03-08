import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'room_creation.dart';

class MainMenu extends StatefulWidget {
  final String username;
  const MainMenu({super.key, required this.username});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeValid = false;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      setState(() {
        _isCodeValid = _codeController.text.length == 4;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated-style background glow (Modern Sleek)
          Positioned(
            top: -50,
            left: -50,
            child: _GlowSphere(color: Colors.cyanAccent.withOpacity(0.05), size: 400),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: _GlowSphere(color: Color.fromRGBO(182, 63, 203, 1).withOpacity(0.05), size: 350),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  
                  // Greeting Section
                  Text(
                    "PLAYER_AUTH_SUCCESS",
                    style: GoogleFonts.spaceMono(
                      color: Colors.cyanAccent.withOpacity(0.5),
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.username.toUpperCase(),
                    style: GoogleFonts.spaceMono(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 60),

                  // Host Card
                  _buildMenuCard(
                    context,
                    title: "HOST_SESSION",
                    subtitle: "Initialize a new karaoke stage",
                    icon: Icons.mic_external_on_rounded,
                    accentColor: Colors.cyanAccent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => RoomCreationPage(username: widget.username)),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Join Section (Glassmorphism Style)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "JOIN_BY_ID",
                          style: GoogleFonts.spaceMono(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _codeController,
                          maxLength: 4,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.spaceMono(
                            color: Colors.white,
                            fontSize: 40,
                            letterSpacing: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: "0000",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.05)),
                            counterText: "",
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Color.fromRGBO(182, 63, 203, 1)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Action Button with dynamic state
                        _buildActionButton(
                          label: "CONNECT",
                          isActive: _isCodeValid,
                          onPressed: () {
                            // Navigation logic...
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accentColor.withOpacity(0.2)),
          gradient: LinearGradient(
            colors: [accentColor.withOpacity(0.05), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 32),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceMono(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.spaceMono(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: accentColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String label, required bool isActive, required VoidCallback onPressed}) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.2,
      child: GestureDetector(
        onTap: isActive ? onPressed : null,
        child: Container(
          height: 55,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.spaceMono(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowSphere extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowSphere({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size / 2,
            spreadRadius: size / 4,
          ),
        ],
      ),
    );
  }
}