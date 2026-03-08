
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SongSelectionPage extends StatefulWidget {
  const SongSelectionPage({super.key});

  @override
  State<SongSelectionPage> createState() => _SongSelectionPageState();
}

class _SongSelectionPageState extends State<SongSelectionPage> {
  final List<Map<String, String>> _allSongs = [
    {"title": "What makes you beautiful", "artist": "One Direction"},
    {"title": "Shape of You", "artist": "Ed Sheeran"},
    {"title": "Shut Up and Dance", "artist": "WALK THE MOON"},
    {"title": "Lush Life", "artist": "Zara Larsson"},
    {"title": "Die With A Smile", "artist": "Lady Gaga, Bruno Mars"},
  ];

  List<Map<String, String>> _selectedSongs = [];

  void _toggleSong(Map<String, String> song) {
    setState(() {
      if (_selectedSongs.contains(song)) {
        _selectedSongs.remove(song);
      } else {
        _selectedSongs.add(song);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("SELECT SETLIST", style: GoogleFonts.oswald(letterSpacing: 2)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // SONG LIST
          Expanded(
            child: ListView.builder(
              itemCount: _allSongs.length,
              itemBuilder: (context, index) {
                final song = _allSongs[index];
                final isSelected = _selectedSongs.contains(song);
                return ListTile(
                  onTap: () => _toggleSong(song),
                  leading: Icon(Icons.music_note, color: isSelected ? const Color(0xFF00FF88) : Colors.white24),
                  title: Text(song['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Text(song['artist']!, style: const TextStyle(color: Colors.white54)),
                  trailing: Icon(
                    isSelected ? Icons.check_circle : Icons.add_circle_outline,
                    color: isSelected ? const Color(0xFF00FF88) : Colors.white24,
                  ),
                );
              },
            ),
          ),
          
          // GO TO STAGE BUTTON
          if (_selectedSongs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3333FF),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const KaraokeStage())),
                child: Text("ENTER THE STAGE", style: GoogleFonts.oswald(fontSize: 20, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// --- THE KARAOKE STAGE ---

class KaraokeStage extends StatefulWidget {
  const KaraokeStage({super.key});

  @override
  State<KaraokeStage> createState() => _KaraokeStageState();
}

class _KaraokeStageState extends State<KaraokeStage> {
  // Mock users
  final List<String> singers = ["YOU", "DJ_KHALED", "DRE_99"];
  int currentSingerIndex = 0; // The person currently singing

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // 1. SINGER SIDEBAR
          Container(
            width: 100,
            color: Colors.white.withOpacity(0.05),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(singers.length, (index) {
                bool isCurrent = index == currentSingerIndex;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isCurrent ? const Color(0xFFFF00CC) : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isCurrent ? [BoxShadow(color: const Color(0xFFFF00CC).withOpacity(0.5), blurRadius: 15)] : [],
                        ),
                        child: CircleAvatar(
                          radius: 25,
                          backgroundColor: Colors.white10,
                          child: Icon(Icons.person, color: isCurrent ? Colors.white : Colors.white24),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(singers[index], style: TextStyle(color: isCurrent ? Colors.white : Colors.white24, fontSize: 10)),
                    ],
                  ),
                );
              }),
            ),
          ),

          // 2. LYRIC AREA
          Expanded(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("NEVER GONNA GIVE YOU UP", 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.oswald(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      Text("NEVER GONNA LET YOU DOWN", 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.oswald(fontSize: 28, color: Colors.white38)),
                    ],
                  ),
                ),
                
                // Progress Bar at bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 5,
                    width: double.infinity,
                    color: Colors.white10,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.4, // Progress of the song
                      child: Container(color: const Color(0xFF3333FF)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
