import os
import json
import aiohttp
import asyncio
import re
from dotenv import load_dotenv
from functools import lru_cache
import google.generativeai as genai

load_dotenv()

QLOO_API_KEY = os.getenv("QLOO_API_KEY")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

genai.configure(api_key=GOOGLE_API_KEY)
model = genai.GenerativeModel("gemini-2.5-flash")

@lru_cache(maxsize=128)
def get_google_maps_link(location, city):
    query = f"{location}, {city}".replace(" ", "+")
    return f"https://www.google.com/maps/search/{query}"

async def fetch(session, method, url, **kwargs):
    async with session.request(method, url, **kwargs) as response:
        return await response.json()

async def get_entity_id(session, name, entity_type):
    url = "https://hackathon.api.qloo.com/search"
    headers = {"x-api-key": QLOO_API_KEY}
    params = {"query": name, "types": entity_type}
    data = await fetch(session, "GET", url, headers=headers, params=params)
    results = data.get("results", [])
    if results:
        return results[0].get("entity", {}).get("id") or results[0].get("id")
    return None

async def get_recommendations(session, entity_id, domain):
    if not entity_id:
        return ["No recommendations found"]
    url = f"https://hackathon.api.qloo.com/recommendations/{domain}"
    headers = {"x-api-key": QLOO_API_KEY, "Content-Type": "application/json"}
    payload = {"ids": [entity_id], "count": 5}
    data = await fetch(session, "POST", url, headers=headers, json=payload)
    return [r["name"] for r in data.get("recommendations", [])]

async def gather_preferences(music, movie, fashion):
    async with aiohttp.ClientSession() as session:
        ids = await asyncio.gather(
            get_entity_id(session, music, "urn:entity:artist"),
            get_entity_id(session, movie, "urn:entity:movie"),
            get_entity_id(session, fashion, "urn:entity:brand"),
        )
        recs = await asyncio.gather(
            get_recommendations(session, ids[0], "music"),
            get_recommendations(session, ids[1], "movies"),
            get_recommendations(session, ids[2], "fashion"),
        )
        return {"music": recs[0], "movie": recs[1], "fashion": recs[2]}

def build_prompt(user_input, recs, city="Tokyo", days=2):
    return f"""
User said: "{user_input}"
Plan a {days}-day cultural itinerary in {city}.

Tastes:
- Music: {', '.join(recs['music'])}
- Film: {', '.join(recs['movie'])}
- Fashion: {', '.join(recs['fashion'])}

Include 5 items per day: music, film, fashion, dining, hidden gem.

Output valid JSON:
{{
  "itinerary": {{
    "destination": "{city}",
    "duration": {days},
    "days": [...]
  }}
}}
"""

async def generate_itinerary_response(user_input):
    # Static preferences for simplicity (can extract later from input)
    music, movie, fashion = "Pop", "Anime", "Streetwear"
    city, days = "Tokyo", 2
    recs = await gather_preferences(music, movie, fashion)
    prompt = build_prompt(user_input, recs, city, days)

    # Generate Gemini content with streaming
    response = model.generate_content(prompt)
    streamed = "".join(part.text for part in response)

    # ✅ Extract valid JSON only
    json_match = re.search(r'\{[\s\S]*\}', streamed)
    if json_match:
        try:
            raw_json = json_match.group(0)
            parsed = json.loads(raw_json)
            return await enrich_with_maps(parsed)
        except Exception as e:
            return {"error": f"JSON parse failed: {str(e)}", "raw_response": raw_json}
    else:
        return {"error": "No valid JSON found", "raw_response": streamed[:300]}

async def enrich_with_maps(parsed_data):
    itinerary = parsed_data.get("itinerary", {})
    city = itinerary.get("destination", "Tokyo")
    duration = itinerary.get("duration", 1)
    image_url = f"https://picsum.photos/seed/{city}/1200/800"

    response = {
        "status": "success",
        "travel_plan": {
            "destination": city,
            "duration_days": duration,
            "summary": f"{duration}-day cultural itinerary for {city}",
            "travel_image": image_url,
            "days": []
        }
    }

    for day in itinerary.get("days", []):
        activities = []
        for act in day.get("activities", day.get("items", [])):
            location = act.get("location") or act.get("name", "Unknown")
            activities.append({
                "time": act.get("time", "TBD"),
                "location": {
                    "name": location,
                    "maps_link": get_google_maps_link(location, city),
                    "address": f"{location}, {city}"
                },
                "category": act.get("category", "general"),
                "description": act.get("description", act.get("name", "")),
                "cultural_connection": act.get("cultural_connection", ""),
                "category_icon": {
                    "music": "🎵", "film": "🎬", "fashion": "👗",
                    "dining": "🍽️", "hidden_gem": "💎"
                }.get(act.get("category", ""), "📍")
            })
        response["travel_plan"]["days"].append({
            "day_number": day.get("day", 1),
            "theme": day.get("theme", "Cultural day"),
            "activities": activities
        })
    return response
