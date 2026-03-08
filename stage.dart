import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';

// Helper class to store a single timed line
class LyricLine {
  final Duration time;
  final String text;
  LyricLine(this.time, this.text);
}

class StagePage extends StatefulWidget {
  final String lyrics; // Expects "[00:14.00] My funny lyric line..."
  final String title;
  final List<String> players;
  final String audioUrl;

  const StagePage({
    super.key,
    required this.lyrics,
    required this.title,
    required this.players,
    required this.audioUrl,
  });

  @override
  State<StagePage> createState() => _StagePageState();
}

class _StagePageState extends State<StagePage> {
  final AudioPlayer _player = AudioPlayer();
  List<LyricLine> _parsedLyrics = [];
  int _currentIndex = 0;
  
  // Track exact playback time to control line visibility
  Duration _currentPosition = Duration.zero;

  @override
  void initState() {
    super.initState();
    _parseLyrics();
    _initAudio();
  }

  // Converts the raw AI string into a list of LyricLine objects
  void _parseLyrics() {
    // Regex matches [minutes : seconds . centiseconds/milliseconds]
    final regExp = RegExp(r"\[(\d+):(\d+)\.(\d+)\]\s*(.*)");
    
    final lines = widget.lyrics.split('\n');
    List<LyricLine> tempLyrics = [];

    for (var line in lines) {
      final match = regExp.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final msString = match.group(3)!;
        final text = match.group(4)!;

        // If the AI gives 2 digits (centiseconds), multiply by 10
        // If it gives 3 digits (milliseconds), use as is
        int ms = int.parse(msString);
        if (msString.length == 2) ms *= 10;

        final duration = Duration(
          minutes: minutes,
          seconds: seconds,
          milliseconds: ms,
        );
        
        tempLyrics.add(LyricLine(duration, text));
      }
    }

    // Sort lyrics by time to ensure logic works if AI returns them out of order
    tempLyrics.sort((a, b) => a.time.compareTo(b.time));

    setState(() {
      _parsedLyrics = tempLyrics;
    });
  }

  void _initAudio() async {
    // Start playback
    await _player.play(UrlSource(widget.audioUrl));

    // Listen to the audio position
    _player.onPositionChanged.listen((p) {
      if (!mounted) return;
      
      setState(() {
        _currentPosition = p;
      });

      // Logic to determine which line is the "active" one
      int newIndex = 0;
      for (int i = 0; i < _parsedLyrics.length; i++) {
        if (p >= _parsedLyrics[i].time) {
          newIndex = i;
        }
      }

      if (newIndex != _currentIndex) {
        setState(() {
          _currentIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we are currently in a "waiting" period (before first lyric)
    bool isWaiting = _parsedLyrics.isNotEmpty && _currentPosition < _parsedLyrics[0].time;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Row(
        children: [
          // --- SIDEBAR: QUEUE / PERFORMERS ---
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              border: Border(right: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60, left: 25, bottom: 20),
                  child: Text("PERFORMERS", 
                    style: GoogleFonts.spaceMono(color: Colors.cyanAccent, fontSize: 12, letterSpacing: 2)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.players.length,
                    itemBuilder: (context, index) {
                      bool isCurrent = index == 0;
                      return ListTile(
                        leading: Text("${index + 1}", 
                          style: TextStyle(color: isCurrent ? Colors.cyanAccent : Colors.white24)),
                        title: Text(widget.players[index], 
                          style: GoogleFonts.kanit(
                            color: isCurrent ? Colors.white : Colors.white24,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          )),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- MAIN STAGE ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Waiting Indicator
                  if (isWaiting)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        "GET READY...",
                        style: GoogleFonts.spaceMono(
                          color: Colors.cyanAccent.withOpacity(0.5),
                          fontSize: 24,
                          letterSpacing: 4,
                        ),
                      ),
                    ),

                  // Lyrics List
                  ..._parsedLyrics.asMap().entries.map((entry) {
                    int index = entry.key;
                    String text = entry.value.text;
                    Duration lyricTime = entry.value.time;
                    
                    bool isActive = index == _currentIndex && !isWaiting;
                    bool isVisible = _currentPosition >= lyricTime;

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: isVisible ? 1.0 : 0.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(15),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.cyanAccent.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          text.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kanit(
                            fontSize: isActive ? 48 : 32,
                            fontWeight: isActive ? FontWeight.w900 : FontWeight.w300,
                            color: isActive ? Colors.cyanAccent : Colors.white.withOpacity(0.15),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}