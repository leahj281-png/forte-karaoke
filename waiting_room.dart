// lib/waiting_room.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'song_selection.dart'; // Your song selection file

class GuestWaitingRoom extends StatefulWidget {
  final String roomCode;
  final String username;

  const GuestWaitingRoom({super.key, required this.roomCode, required this.username});

  @override
  State<GuestWaitingRoom> createState() => _GuestWaitingRoomState();
}

class _GuestWaitingRoomState extends State<GuestWaitingRoom> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Check status every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) => _checkApprovalStatus());
  }

  Future<void> _checkApprovalStatus() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.0.2.2:5000/get_room_status/${widget.roomCode}"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List joinedPlayers = data['joined'];

        // If the host approved us, we will now be in the 'joined' list
        if (joinedPlayers.contains(widget.username)) {
          _timer?.cancel();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SongSelectionPage(
                  players: List<String>.from(joinedPlayers),
                  isHost: false,
                  roomCode: widget.roomCode,
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint("Polling error: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.cyanAccent),
            const SizedBox(height: 30),
            Text(
              "WAITING_FOR_HOST_APPROVAL",
              style: GoogleFonts.spaceMono(color: Colors.white, letterSpacing: 2),
            ),
            Text(
              "ROOM: ${widget.roomCode}",
              style: GoogleFonts.spaceMono(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
