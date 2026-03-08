import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'stage.dart';

class SongSelectionPage extends StatefulWidget {
  final List<String> players;
  final bool isHost;
  final String roomCode;

  const SongSelectionPage({super.key, required this.players, required this.isHost, required this.roomCode});

  @override
  State<SongSelectionPage> createState() => _SongSelectionPageState();
}

class _SongSelectionPageState extends State<SongSelectionPage> {
  bool _loading = false;
  String? _selectedTitle;
  final TextEditingController _customController = TextEditingController();

  final List<Map<String, String>> _songs = [
    {
      "title": "Shape Of You",
      "image": "https://upload.wikimedia.org/wikipedia/en/b/b4/Shape_Of_You_%28Official_Single_Cover%29_by_Ed_Sheeran.png",
      "audio": "http://localhost:5000/static/songs/shape_of_you.mp3"
    },
    {
      "title": "What Makes You Beautiful",
      "image": "https://cdn-images.dzcdn.net/images/cover/95f254f5a4b63ed50250e64386343ec8/1900x1900-000000-80-0-0.jpg",
      "audio": "http://localhost:5000/static/songs/thats_what_makes_you_beautiful.mp3"
    },
    {
      "title": "Shut Up and Dance",
      "image": "https://upload.wikimedia.org/wikipedia/en/7/71/Walk_the_Moon_-_Shut_Up_and_Dance_%28Official_Single_Cover%29.png",
      "audio": "http://localhost:5000/static/songs/shut_up_and_dance.mp3"
    },
  ];

  // Modified to take BOTH Title (for timing) and Theme (for content)
  Future<void> _fetchLyrics(String title, String audioUrl, String theme) async {
    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/generate_lyrics"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "title": title,
          "theme": theme.isEmpty ? "funny random topic" : theme,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => StagePage(
              lyrics: data['lyrics'],
              title: title,
              players: widget.players,
              audioUrl: audioUrl,
            ),
          ));
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          padding: const EdgeInsets.all(40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("LIBRARY", style: GoogleFonts.spaceMono(color: Colors.cyanAccent, letterSpacing: 3)),
              const SizedBox(height: 10),
              Text("CHOOSE A SONG OR ENTER A THEME", 
                  style: GoogleFonts.notoSans(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 30),
              
              TextField(
                controller: _customController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your own theme (e.g., A song about a lazy cat)...",
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.edit_note, color: Colors.cyanAccent),
                ),
                onChanged: (val) {
                  // REMOVED: setState(() => _selectedTitle = null);
                  // Calling setState here just to keep the UI reactive
                  setState(() {}); 
                },
              ),
              const SizedBox(height: 30),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, 
                    crossAxisSpacing: 30, 
                    mainAxisSpacing: 30,
                    childAspectRatio: 0.85
                  ),
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    bool isSelected = _selectedTitle == song['title'];
                    return GestureDetector(
                      onTap: () {
                        // Keeps theme, but updates selected song
                        setState(() => _selectedTitle = song['title']);
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.white10, width: 2),
                                image: DecorationImage(image: NetworkImage(song['image']!), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(song['title']!, style: GoogleFonts.spaceMono(color: isSelected ? Colors.cyanAccent : Colors.white70, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  },
                ),
              ),

              if (widget.isHost && (_selectedTitle != null)) 
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () {
                      final s = _songs.firstWhere((element) => element['title'] == _selectedTitle);
                      // Send the selected song for rhythm and the controller text for content
                      _fetchLyrics(s['title']!, s['audio']!, _customController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                    ),
                    child: Text(
                      _loading ? "GENERATING..." : "GENERATE & PLAY",
                      style: GoogleFonts.spaceMono(color: Colors.black, fontWeight: FontWeight.bold),
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