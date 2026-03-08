
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';

class SongSelectionPage extends StatefulWidget {
  final List<String> players;
  final bool isHost;
  final String roomCode;

  const SongSelectionPage({
    super.key,
    required this.players,
    required this.isHost,
    required this.roomCode,
  });

  @override
  State<SongSelectionPage> createState() => _SongSelectionPageState();
}

class _SongSelectionPageState extends State<SongSelectionPage> {
  final List<Map<String, String>> _allSongs = [
    {"title": "That's What Makes You Beautiful", "artist": "One Direction"},
    {"title": "Bohemian Rhapsody", "artist": "Queen"},
    {"title": "Toxicity", "artist": "System of a Down"},
    {"title": "Stay", "artist": "The Kid LAROI"}, 
  ];
  final List<Map<String, String>> _selectedSongs = [];
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    // Guests poll the server to see when the Host confirms the setlist
    if (!widget.isHost) {
      _syncTimer = Timer.periodic(const Duration(seconds: 2), (t) => _checkIfLocked());
    }
  }

  void _checkIfLocked() async {
    try {
      final data = await ApiService.getRoomStatus(widget.roomCode);
      if (data['is_locked'] == true && mounted) {
        _syncTimer?.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (c) => KaraokeStage(players: widget.players)),
        );
      }
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.isHost ? "PICK THE VIBE" : "HOST IS CHOOSING...",
          style: GoogleFonts.oswald(letterSpacing: 2, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _allSongs.length,
              itemBuilder: (context, index) {
                final song = _allSongs[index];
                final isSelected = _selectedSongs.contains(song);
                return ListTile(
                  onTap: widget.isHost
                      ? () => setState(() => isSelected ? _selectedSongs.remove(song) : _selectedSongs.add(song))
                      : null,
                  leading: Icon(Icons.music_note, color: isSelected ? const Color(0xFF00FF88) : Colors.white10),
                  title: Text(song['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(song['artist']!, style: const TextStyle(color: Colors.white54)),
                  trailing: widget.isHost
                      ? Icon(isSelected ? Icons.check_circle : Icons.add_circle_outline,
                          color: isSelected ? const Color(0xFF00FF88) : Colors.white24)
                      : (isSelected ? const Icon(Icons.check, color: Color(0xFF00FF88)) : null),
                );
              },
            ),
          ),
          if (widget.isHost)
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3333FF),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _selectedSongs.isEmpty
                    ? null
                    : () async {
                        await ApiService.lockSetlist(widget.roomCode);
                        if (mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (c) => KaraokeStage(players: widget.players)),
                          );
                        }
                      },
                child: Text("CONFIRM SETLIST", style: GoogleFonts.oswald(fontSize: 18, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// --- THE PROFESSIONAL NEON KARAOKE STAGE ---

class KaraokeStage extends StatefulWidget {
  final List<String> players;
  const KaraokeStage({super.key, required this.players});

  @override
  State<KaraokeStage> createState() => _KaraokeStageState();
}

class _KaraokeStageState extends State<KaraokeStage> with TickerProviderStateMixin {
  late AnimationController _noteController;
  late AnimationController _pulseController;
  final List<FloatingNote> _backgroundNotes = List.generate(15, (index) => FloatingNote());
  double _songProgress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _noteController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat(reverse: true);
    
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) setState(() => _songProgress = (_songProgress + 0.001) % 1.0);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _pulseController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Floating Icons
          AnimatedBuilder(
            animation: _noteController,
            builder: (context, child) => CustomPaint(size: Size.infinite, painter: NotePainter(_backgroundNotes)),
          ),
          Row(
            children: [
              // Neon Sidebar
              _buildSidebar(),
              // Lyric Stage
              Expanded(child: _buildMainStage()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 130,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        border: const Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Text("QUEUE", style: GoogleFonts.oswald(color: const Color(0xFFFF00CC), letterSpacing: 2)),
          Expanded(
            child: ListView.builder(
              itemCount: widget.players.length,
              itemBuilder: (context, index) {
                bool isSinging = index == 0;
                return _buildPlayerTile(widget.players[index], isSinging);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerTile(String name, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? const Color(0xFF3333FF) : Colors.transparent, width: 2),
              boxShadow: isActive ? [BoxShadow(color: const Color(0xFF3333FF).withOpacity(0.4), blurRadius: 10)] : [],
            ),
            child: CircleAvatar(
              radius: 25,
              backgroundColor: isActive ? const Color(0xFFFF00CC) : Colors.white10,
              child: Icon(Icons.person, color: isActive ? Colors.white : Colors.white24),
            ),
          ),
          const SizedBox(height: 5),
          Text(name, style: GoogleFonts.oswald(color: isActive ? Colors.white : Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildMainStage() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Text("FORTE STAGE", style: GoogleFonts.monoton(color: Colors.white10, fontSize: 20)),
          const Spacer(),
          ShaderMask(
            shaderCallback: (rect) => const LinearGradient(colors: [Color(0xFFFF00CC), Color(0xFF3333FF)]).createShader(rect),
            child: Text("NEVER GONNA GIVE YOU UP", textAlign: TextAlign.center, style: GoogleFonts.monoton(fontSize: 40, color: Colors.white)),
          ),
          const SizedBox(height: 15),
          Text("NEVER GONNA LET YOU DOWN", style: GoogleFonts.oswald(fontSize: 24, color: Colors.white38)),
          const Spacer(),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _songProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFF00CC), Color(0xFF3333FF)]),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: const Color(0xFFFF00CC).withOpacity(0.5), blurRadius: 8)],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text("LIVE PERFORMANCE", style: TextStyle(color: Color(0xFF00FF88), letterSpacing: 3, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// --- HELPER CLASSES FOR ANIMATION ---

class FloatingNote {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double speed = 0.0006 + math.Random().nextDouble() * 0.0012;
  double size = 12 + math.Random().nextDouble() * 18;
  IconData icon = [Icons.music_note, Icons.audiotrack, Icons.mic_none][math.Random().nextInt(3)];

  void update() {
    y -= speed;
    if (y < -0.1) { y = 1.1; x = math.Random().nextDouble(); }
  }
}

class NotePainter extends CustomPainter {
  final List<FloatingNote> notes;
  NotePainter(this.notes);
  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var note in notes) {
      note.update();
      textPainter.text = TextSpan(
        text: String.fromCharCode(note.icon.codePoint),
        style: TextStyle(fontSize: note.size, fontFamily: note.icon.fontFamily, package: note.icon.fontPackage, color: Colors.white.withOpacity(0.08)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(note.x * size.width, note.y * size.height));
    }
  }
  @override
  bool shouldRepaint(NotePainter oldDelegate) => true;
}
