import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';
import 'song_selection.dart';

class RoomCreationPage extends StatefulWidget {
  final String username;
  final String? existingCode;
  const RoomCreationPage({super.key, required this.username, this.existingCode});

  @override
  State<RoomCreationPage> createState() => _RoomCreationPageState();
}

class _RoomCreationPageState extends State<RoomCreationPage> {
  String currentRoomCode = "....";
  String hostName = "";
  List<String> joinedPeople = [];
  List<String> waitingList = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _setupRoom();
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (t) => _fetchRoomStatus());
  }

  void _setupRoom() async {
    try {
      if (widget.existingCode == null) {
        final data = await ApiService.createRoom(widget.username);
        setState(() {
          currentRoomCode = data['room_code'];
          hostName = data['host'];
        });
      } else {
        setState(() => currentRoomCode = widget.existingCode!);
        await ApiService.joinRoom(currentRoomCode, widget.username);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _fetchRoomStatus() async {
    if (currentRoomCode == "....") return;
    try {
      final data = await ApiService.getRoomStatus(currentRoomCode);
      if (mounted) {
        setState(() {
          joinedPeople = List<String>.from(data['joined'] ?? []);
          waitingList = List<String>.from(data['waiting'] ?? []);
          hostName = data['host'] ?? "";
        });

        if (data['is_started'] == true) {
          _refreshTimer?.cancel();
          bool isHost = widget.username.trim().toLowerCase() == hostName.trim().toLowerCase();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SongSelectionPage(
                players: joinedPeople,
                isHost: isHost,
                roomCode: currentRoomCode,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isHost = widget.username.trim().toLowerCase() == hostName.trim().toLowerCase();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Room Header
              Text(
                "LOBBY_SESSION",
                style: GoogleFonts.spaceMono(color: Colors.cyanAccent, fontSize: 12, letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "ROOM CODE",
                    style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      currentRoomCode,
                      style: GoogleFonts.spaceMono(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              
              // People List
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    if (waitingList.isNotEmpty) ...[
                      _buildSectionTitle("PENDING_APPROVAL"),
                      ...waitingList.map((name) => _buildUserCard(name, isPending: true, isHost: isHost)),
                    ],
                    const SizedBox(height: 20),
                    _buildSectionTitle("ON_STAGE"),
                    ...joinedPeople.map((name) => _buildUserCard(name, isPending: false, isHost: isHost)),
                  ],
                ),
              ),
              
              // Action Button
              if (isHost) _buildStartButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: GoogleFonts.spaceMono(color: Colors.white24, fontSize: 10, letterSpacing: 1),
      ),
    );
  }

  Widget _buildUserCard(String name, {required bool isPending, required bool isHost}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPending ? Colors.amberAccent.withOpacity(0.2) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(
          isPending ? Icons.hourglass_empty_rounded : Icons.check_circle_outline_rounded,
          color: isPending ? Colors.amberAccent : Colors.cyanAccent,
          size: 18,
        ),
        title: Text(
          name.toUpperCase(),
          style: GoogleFonts.spaceMono(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        trailing: (isPending && isHost)
            ? IconButton(
                icon: const Icon(Icons.add_task_rounded, color: Colors.cyanAccent),
                onPressed: () => ApiService.approveGuest(currentRoomCode, name),
              )
            : null,
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () => ApiService.startRoom(currentRoomCode),
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Colors.cyanAccent, Color.fromRGBO(182, 63, 203, 1)],
          ),
        ),
        child: Center(
          child: Text(
            "OPEN_THE_STAGE",
            style: GoogleFonts.spaceMono(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}