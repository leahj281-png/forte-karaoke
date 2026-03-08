
import 'dart:async';
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
        setState(() { currentRoomCode = data['room_code']; hostName = data['host']; });
      } else {
        setState(() => currentRoomCode = widget.existingCode!);
        await ApiService.joinRoom(currentRoomCode, widget.username);
      }
    } catch (e) { debugPrint(e.toString()); }
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
          Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (context) => SongSelectionPage(
              players: joinedPeople, 
              isHost: isHost, 
              roomCode: currentRoomCode
            )
          ));
        }
      }
    } catch (e) { debugPrint(e.toString()); }
  }

  @override
  void dispose() { _refreshTimer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    bool isHost = widget.username.trim().toLowerCase() == hostName.trim().toLowerCase();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 50),
          Text(currentRoomCode, style: GoogleFonts.monoton(fontSize: 40, color: Colors.white)),
          Expanded(
            child: ListView(
              children: [
                ...waitingList.map((name) => ListTile(
                  title: Text(name, style: const TextStyle(color: Colors.amber)),
                  trailing: isHost ? IconButton(icon: const Icon(Icons.check, color: Colors.green), 
                    onPressed: () => ApiService.approveGuest(currentRoomCode, name)) : null,
                )),
                const Divider(color: Colors.white24),
                ...joinedPeople.map((name) => ListTile(
                  leading: const Icon(Icons.person, color: Colors.white),
                  title: Text(name, style: const TextStyle(color: Colors.white)),
                )),
              ],
            ),
          ),
          if (isHost) Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF00CC)),
              onPressed: () => ApiService.startRoom(currentRoomCode),
              child: const Text("OPEN THE STAGE"),
            ),
          ),
        ],
      ),
    );
  }
}
