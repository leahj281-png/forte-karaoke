import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://127.0.0.1:5000"; 

  static Future<Map<String, dynamic>> createRoom(String username) async {
    final response = await http.post(Uri.parse("$baseUrl/create_room"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username}));
    return jsonDecode(response.body);
  }

  static Future<void> joinRoom(String roomCode, String username) async {
    await http.post(Uri.parse("$baseUrl/join_room"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"room_code": roomCode.toUpperCase(), "username": username}));
  }

  static Future<Map<String, dynamic>> getRoomStatus(String roomCode) async {
    final response = await http.get(Uri.parse("$baseUrl/get_room_status/${roomCode.toUpperCase()}"));
    return jsonDecode(response.body);
  }

  static Future<void> approveGuest(String roomCode, String guestName) async {
    await http.post(Uri.parse("$baseUrl/approve_guest"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"room_code": roomCode.toUpperCase(), "user": guestName}));
  }

  static Future<void> startRoom(String roomCode) async {
    await http.post(Uri.parse("$baseUrl/start_room/${roomCode.toUpperCase()}"));
  }

  static Future<void> lockSetlist(String roomCode) async {
    await http.post(Uri.parse("$baseUrl/lock_setlist/${roomCode.toUpperCase()}"));
  }
  static Future<Map<String, dynamic>> generateLyrics(
  String roomCode,
  String username,
  String song,
  String topic
) async {

  final response = await http.post(
    Uri.parse("$baseUrl/generate_lyrics"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "room_code": roomCode,
      "username": username,
      "song": song,
      "topic": topic
    }),
  );

  return jsonDecode(response.body);
}
}