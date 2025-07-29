import os
import re
import json
import asyncio
import random
import httpx
import requests
from dotenv import load_dotenv
import google.generativeai as genai

# Load environment variables
load_dotenv()
QLOO_API_KEY = os.getenv("QLOO_API_KEY")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")

# Configure Gemini
genai.configure(api_key=GOOGLE_API_KEY)
model = genai.GenerativeModel("gemini-1.5-flash")

def parse_user_input_with_ai(user_input):
    prompt = f"""
Analyze this user input and extract travel parameters in JSON format.

User input: \"{user_input}\"

Extract:
1. Music preference (artist, band, or genre)
2. Movie/film preference (movie, director, genre, or franchise)  
3. Fashion/style preference (brand, style, or fashion category)
4. Destination city
5. Number of days for the trip

Rules:
- If any preference category isn't mentioned, use these defaults:
  - Music: \"Pop music\"
  - Movie: \"Popular movies\"
  - Fashion: \"Casual streetwear\"
- If destination isn't mentioned, use: \"Tokyo\"
- If days aren't mentioned, use: 1
- Return ONLY valid JSON in this exact format:
{{
  "music": "...",
  "movie": "...",
  "fashion": "...",
  "destination": "...",
  "days": 1
}}
"""
    try:
        response = model.generate_content(prompt, generation_config=genai.types.GenerationConfig(temperature=0.5, max_output_tokens=256))
        text = response.text.strip()
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```")[1].strip()
        data = json.loads(text)
        preferences = f"{data.get('music', 'Pop music')}, {data.get('movie', 'Popular movies')}, {data.get('fashion', 'Casual streetwear')}"
        return preferences, data.get('destination', 'Tokyo'), int(data.get('days', 1))
    except Exception as e:
        print(f"AI parsing failed: {e}")
        return "Pop music, Popular movies, Casual streetwear", "Tokyo", 1

def extract_preferences_from_parsed(preferences_string):
    prefs = [p.strip() for p in preferences_string.split(',')]
    defaults = ["Pop music", "Popular movies", "Casual streetwear"]
    while len(prefs) < 3:
        prefs.append(defaults[len(prefs)])
    return prefs[0], prefs[1], prefs[2]

async def get_entity_and_recs(client, preference, domain, entity_type):
    eid = await get_entity_id_async(client, preference, entity_type)
    recs = await get_recommendations_async(client, eid, domain) if eid else ["No recommendations found"]
    return preference, recs

async def get_entity_id_async(client, name, entity_type):
    url = "https://hackathon.api.qloo.com/search"
    headers = {"accept": "application/json", "x-api-key": QLOO_API_KEY}
    params = {"query": name, "types": entity_type}
    r = await client.get(url, headers=headers, params=params)
    if r.status_code == 200:
        data = r.json()
        results = data.get("results", [])
        if results:
            return results[0].get("entity", {}).get("id") or results[0].get("id")
    return None

async def get_recommendations_async(client, entity_id, domain):
    url = f"https://hackathon.api.qloo.com/recommendations/{domain}"
    headers = {"accept": "application/json", "x-api-key": QLOO_API_KEY, "Content-Type": "application/json"}
    payload = {"ids": [entity_id], "count": 5}
    r = await client.post(url, headers=headers, json=payload)
    if r.status_code == 200:
        return [rec["name"] for rec in r.json().get("recommendations", [])]
    return []

async def get_all_recommendations(preferences):
    async with httpx.AsyncClient() as client:
        tasks = [get_entity_and_recs(client, pref, domain, etype) for pref, domain, etype in preferences]
        results = await asyncio.gather(*tasks)
        return dict(results)

def get_google_maps_link(location_name, city):
    return f"https://www.google.com/maps/search/{location_name.replace(' ', '+')}+{city.replace(' ', '+')}"

def get_place_details(location_name, city, use_api=False):
    if not use_api or not GOOGLE_MAPS_API_KEY:
        return {
            "name": location_name,
            "maps_link": get_google_maps_link(location_name, city),
            "address": f"Search for {location_name} in {city}"
        }
    try:
        url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
        params = {
            "input": f"{location_name} {city}",
            "inputtype": "textquery",
            "fields": "place_id,name,formatted_address",
            "key": GOOGLE_MAPS_API_KEY
        }
        r = requests.get(url, params=params)
        if r.status_code == 200:
            candidates = r.json().get("candidates", [])
            if candidates:
                place = candidates[0]
                pid = place.get("place_id")
                return {
                    "name": place.get("name", location_name),
                    "address": place.get("formatted_address", f"{location_name}, {city}"),
                    "maps_link": f"https://www.google.com/maps/place/?q=place_id:{pid}" if pid else get_google_maps_link(location_name, city)
                }
    except Exception as e:
        print(f"Maps API error: {e}")
    return {
        "name": location_name,
        "maps_link": get_google_maps_link(location_name, city),
        "address": f"Search for {location_name} in {city}"
    }

def generate_travel_image_url(destination, preferences):
    return f"https://picsum.photos/1200/800?random={random.randint(1, 1000)}"

def format_itinerary_with_maps(data, city, prefs=""):
    itin = data.get("itinerary", {})
    image = generate_travel_image_url(city, prefs)
    output = {
        "status": "success",
        "travel_plan": {
            "destination": itin.get('destination', city),
            "duration_days": itin.get('duration', 1),
            "travel_image": image,
            "summary": f"{itin.get('duration', 1)}-day cultural itinerary for {itin.get('destination', city)}",
            "days": []
        }
    }
    for day in itin.get("days", []):
        activities = []
        for a in day.get("activities", []):
            info = get_place_details(a.get("location", "Unknown"), city)
            activities.append({
                "time": a.get("time", "TBD"),
                "location": info,
                "category": a.get("category", "general"),
                "description": a.get("description", ""),
                "cultural_connection": a.get("cultural_connection", ""),
                "category_icon": {
                    "music": "🎵", "film": "🎬", "fashion": "👗", "dining": "🍽️", "hidden_gem": "💎"
                }.get(a.get("category", "general"), "📍")
            })
        output["travel_plan"]["days"].append({
            "day_number": day.get("day", 1),
            "theme": day.get("theme", "Culture"),
            "activities": activities
        })
    return output

def generate_fallback_itinerary(user_input, prefs, dest, days):
    music, movie, fashion = extract_preferences_from_parsed(prefs)
    image = generate_travel_image_url(dest, prefs)
    result = {
        "status": "success",
        "travel_plan": {
            "destination": dest,
            "duration_days": days,
            "travel_image": image,
            "summary": f"{days}-day cultural itinerary for {dest}",
            "preferences": {"music": music, "movie": movie, "fashion": fashion},
            "days": []
        }
    }
    for d in range(1, days+1):
        result["travel_plan"]["days"].append({
            "day_number": d,
            "theme": f"Cultural exploration - Day {d}",
            "activities": [
                {
                    "time": "10:00",
                    "location": get_place_details("music venue", dest),
                    "category": "music",
                    "description": f"Explore music inspired by {music}",
                    "cultural_connection": f"Reflects your taste in {music}",
                    "category_icon": "🎵"
                }
            ]
        })
    return result

def generate_structured_itinerary(user_input, prefs, dest, days):
    music, movie, fashion = extract_preferences_from_parsed(prefs)
    taste_types = [
        (music, "music", "urn:entity:artist"),
        (movie, "movies", "urn:entity:movie"),
        (fashion, "fashion", "urn:entity:brand")
    ]
    try:
        recs = asyncio.run(get_all_recommendations(taste_types))
        prompt = f"""
You are a cultural travel expert. Generate a JSON itinerary.
User: \"{user_input}\"
Destination: {dest}, Duration: {days} day(s)
Preferences:
- Music: {music} -> {recs[music]}
- Movie: {movie} -> {recs[movie]}
- Fashion: {fashion} -> {recs[fashion]}
Return JSON with fields: day, theme, time, location, category, description, cultural_connection
"""
        res = model.generate_content(prompt, generation_config=genai.types.GenerationConfig(temperature=0.6, max_output_tokens=1024))
        text = res.text.strip()
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```", 1)[1].strip()
        itinerary_data = json.loads(text)
        return format_itinerary_with_maps(itinerary_data, dest, prefs)
    except Exception as e:
        print(f"Itinerary generation failed: {e}")
        return generate_fallback_itinerary(user_input, prefs, dest, days)
