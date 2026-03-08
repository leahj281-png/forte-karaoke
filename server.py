print("SERVER STARTING")

from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
import random
import string
import os
import re

import librosa
import numpy as np
from openai import OpenAI

# load environment variables from .env
load_dotenv()

app = Flask(__name__)
CORS(app)

# -----------------------------
# OpenRouter API setup
# -----------------------------

client = OpenAI(
    api_key=os.getenv("OPENROUTER_API_KEY"),
    base_url="https://openrouter.ai/api/v1"
)

# -----------------------------
# Room storage
# -----------------------------

rooms = {}

def generate_code():
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=4))

# -----------------------------
# Song database (matches your filenames)
# -----------------------------

song_files = {
    "1": {
        "name": "What Makes You Beautiful",
        "file": "songs/what makes u beautiful.txt",
        "audio": "audio/One Direction - What Makes You Beautiful (Karaoke Version).mp3"
    },
    "2": {
        "name": "Shape of You",
        "file": "songs/shapeofyou.txt",
        "audio": "audio/Ed Sheeran - Shape of You (Official Music Video).mp3"
    },
    "3": {
        "name": "Shut Up and Dance With Me",
        "file": "songs/shutupanddancewithme.txt",
        "audio": "audio/WALK THE MOON - Shut Up and Dance (Official Video).mp3"
    },
    "4":{
        "name": "Die With A Smile",
        "file": "diewithasmile.txt",
        "audio":"Lady Gaga, Bruno Mars - Die With A Smile (Official Music Video).mp3"
    },
    "5":{
        "name": "Lush Life",
        "file": "lushlife.txt",
        "audio": "Zara Larsson - Lush Life (Lyrics).mp3"
    }
}

# -----------------------------
# Syllable counting functions
# -----------------------------

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


def line_syllables(line):

    words = re.findall(r'\w+', line)

    return sum(count_syllables(w) for w in words)

# -----------------------------
# ROOM SYSTEM
# -----------------------------

@app.route("/create_room", methods=["POST"])
def create_room():

    data = request.json
    username = data.get("username", "Unknown")

    code = generate_code()

    rooms[code] = {
        "host": username,
        "joined": [username],
        "waiting": [],
        "is_started": False,
        "is_locked": False,
        "turn_order": [],
        "current_turn": 0
    }

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

        return jsonify({
            "host": rooms[code]["host"],
            "joined": rooms[code]["joined"],
            "waiting": rooms[code]["waiting"],
            "is_started": rooms[code]["is_started"],
            "is_locked": rooms[code]["is_locked"]
        })

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
        rooms[code]["turn_order"] = rooms[code]["joined"].copy()
        rooms[code]["current_turn"] = 0
        return jsonify({"success": True})

    return jsonify({"error": "Room not found"}), 404


@app.route("/lock_setlist/<room_code>", methods=["POST"])
def lock_setlist(room_code):

    code = room_code.upper()

    if code in rooms:

        rooms[code]["is_locked"] = True
        return jsonify({"success": True})

    return jsonify({"error": "Room not found"}), 404

# -----------------------------
# GET CURRENT PLAYER TURN
# -----------------------------

@app.route("/get_current_turn/<room_code>", methods=["GET"])
def get_turn(room_code):

    code = room_code.upper()

    if code not in rooms:
        return jsonify({"error": "Room not found"}), 404

    room = rooms[code]

    player = room["turn_order"][room["current_turn"]]

    return jsonify({
        "current_player": player
    })

# -----------------------------
# AI PARODY LYRIC GENERATION
# -----------------------------

@app.route("/generate_lyrics", methods=["POST"])
def generate_lyrics():

    data = request.json
    room_code = data.get("room_code")
    username = data.get("username")
    song_choice = data.get("song")
    topic = data.get("topic")

    code = room_code.upper()
    if code not in rooms:
        return jsonify({"error": "Room not found"}), 404

    room = rooms[code]

    current_player = room["turn_order"][room["current_turn"]]

    # Only allow the player whose turn it is
    if username != current_player:
        return jsonify({"error": "Not your turn"}), 403

    selected_song = song_files.get(song_choice)

    if not selected_song:
        return jsonify({"error": "Invalid song"}), 400

    lyrics_file = selected_song["file"]
    audio_file = selected_song["audio"]
    song_name = selected_song["name"]

    # Load lyrics

    with open(lyrics_file, "r", encoding="utf-8") as f:
        all_lyrics = [line.strip() for line in f.readlines() if line.strip()]

    reference_lyrics = all_lyrics[:4]

    # Beat detection

    y, sr = librosa.load(audio_file)

    tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
    tempo = float(tempo)

    beat_times = librosa.frames_to_time(beat_frames, sr=sr)

    beats_total = len(beat_times)
    lines_total = len(reference_lyrics)

    beat_structure = []
    start = 0

    for i in range(lines_total):

        end = int((i + 1) * beats_total / lines_total)

        beat_structure.append(end - start)

        start = end

    # Syllable structure

    syllable_structure = [line_syllables(line) for line in reference_lyrics]

    beats_per_second = tempo / 60

    # AI prompt

    prompt = f"""
You are a creative lyric writer.

The original song is "{song_name}".

Use the rhythm of these lyrics:

{reference_lyrics}

Write 5 parody lyric lines about "{topic}".

Match rhythm and syllables.

Syllables per line:
{syllable_structure}

Beats per line:
{beat_structure}

Tempo:
{tempo:.2f} BPM
"""

    response = client.chat.completions.create(
        model="openai/gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}]
    )

    generated_lyrics = response.choices[0].message.content.splitlines()
    generated_lyrics = [l.strip() for l in generated_lyrics if l.strip()]

    return jsonify({
        "song": song_name,
        "lyrics": generated_lyrics,
        "tempo": tempo,
        "beats_per_second": beats_per_second
    })


# -----------------------------
# Run server
# -----------------------------

# -----------------------------
# Run server
# -----------------------------

if __name__ == "__main__":
    print("STARTING FLASK SERVER...")
    app.run(host="0.0.0.0", port=5000, debug=True)