import os
import random
import string
import re
from flask import Flask, request, jsonify
from flask_cors import CORS
from openai import OpenAI
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)
CORS(app)

client = OpenAI(
    api_key=os.getenv("OPENROUTER_API_KEY"),
    base_url="https://openrouter.ai/api/v1"
)

# --- 1. CODE-LEVEL SYLLABLE CALCULATION ---
def count_syllables(word):
    word = word.lower()
    vowels = "aeiouy"
    count = 0
    prev_vowel = False
    for char in word:
        is_vowel = char in vowels
        if is_vowel and not prev_vowel:
            count += 1
        prev_vowel = is_vowel
    if word.endswith("e"):
        count = max(1, count - 1)
    return max(1, count)

def get_line_structure(line):
    words = re.findall(r'\w+', line)
    return sum(count_syllables(w) for w in words)

# --- 2. SONG STRUCTURE DATABASE ---
# Added 'gap' to help the AI know how many seconds to put between lines
song_templates = {
    "What Makes You Beautiful": {
        "delay": "00:16:30",
        "gap": 4, 
        "original_lyrics": [
            "You're insecure, don't know what for",
            "You're turning heads when you walk through the door",
            "Don't need make-up, to cover up",
            "Being the way that you are is enough",
            "Everyone else in the room can see it"
        ]
    },
    "Shape of You": {
        "delay": "00:30.00",
        "gap": 3,
        "original_lyrics": [
            "The club isn't the best place to find a lover",
            "So the bar is where I go",
            "Me and my friends at the table doing shots",
            "Drinking fast and then we talk slow",
            "And you come over and start up a conversation"
        ]
    },
    "Shut Up and Dance": {
        "delay": "00:11.00",
        "gap": 3,
        "original_lyrics": [
            "Oh don't you dare look back",
            "Just keep your eyes on me",
            "I said you're holding back",
            "She said shut up and dance with me",
            "This woman is my destiny"
        ]
    }
}

# --- 3. ROOM SYSTEM ---
rooms = {}

@app.route("/create_room", methods=["POST"])
def create_room():
    data = request.json
    username = data.get("username", "Host")
    code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))
    rooms[code] = {"host": username, "joined": [username], "waiting": [], "is_started": False}
    return jsonify({"room_code": code, "host": username})

@app.route("/join_room", methods=["POST"])
def join_room():
    data = request.json
    code = data.get("room_code", "").upper()
    username = data.get("username")
    if code in rooms:
        if username not in rooms[code]["waiting"] and username not in rooms[code]["joined"]:
            rooms[code]["waiting"].append(username)
        return jsonify({"success": True})
    return jsonify({"error": "Room not found"}), 404

@app.route("/get_room_status/<room_code>", methods=["GET"])
def get_status(room_code):
    code = room_code.upper()
    if code in rooms:
        return jsonify(rooms[code])
    return jsonify({"error": "Room not found"}), 404

@app.route("/approve_guest", methods=["POST"])
def approve_guest():
    data = request.json
    code = data.get("room_code", "").upper()
    user = data.get("user")
    if code in rooms and user in rooms[code]["waiting"]:
        rooms[code]["waiting"].remove(user)
        rooms[code]["joined"].append(user)
        return jsonify({"success": True})
    return jsonify({"error": "Failed"}), 400

@app.route("/start_room/<room_code>", methods=["POST"])
def start_room(room_code):
    code = room_code.upper()
    if code in rooms:
        rooms[code]["is_started"] = True
        return jsonify({"success": True})
    return jsonify({"error": "Room not found"}), 404

# --- 4. AI PARODY GENERATION ---
@app.route("/generate_lyrics", methods=["POST"])
def generate_lyrics():
    data = request.json
    title = data.get("title", "")
    theme = data.get("theme", "something funny")
    
    song_info = song_templates.get(title, {
        "delay": "00:11.00",
        "gap": 3,
        "original_lyrics": ["Line one", "Line two", "Line three", "Line four", "Line five"]
    })

    syllable_map = [get_line_structure(line) for line in song_info["original_lyrics"]]
    template_str = "\n".join([f"- {line}" for line in song_info["original_lyrics"]])

    # We tell the AI EXACTLY what the first timestamp should be
    # and roughly how many seconds to add for each subsequent line.
    prompt = (
        f"You are a professional parody songwriter.\n"
        f"SONG: '{title}'\n"
        f"NEW THEME: '{theme}'\n\n"
        f"ORIGINAL STRUCTURE:\n{template_str}\n\n"
        "STRICT INSTRUCTIONS:\n"
        f"1. Match these syllable counts exactly: {syllable_map}.\n"
        "2. Keep the original rhyme scheme.\n"
        f"3. START TIME: Line 1 must be exactly [{song_info['delay']}].\n"
        f"4. PROGRESSION: Increment each subsequent line by roughly {song_info['gap']} seconds.\n"
        "5. Return ONLY 5 lines with [mm:ss.xx] timestamps."
    )
    
    try:
        response = client.chat.completions.create(
            model="openai/gpt-4o-mini",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.7
        )
        raw_output = response.choices[0].message.content.strip()
        clean_lines = [line.replace("*", "").strip() for line in raw_output.split('\n') if "[" in line]
        return jsonify({"lyrics": '\n'.join(clean_lines[:5])})
    except Exception as e:
        return jsonify({"lyrics": f"Error: {str(e)}"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)