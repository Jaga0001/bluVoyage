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
model = genai.GenerativeModel("gemini-2.5-flash-lite")

@lru_cache(maxsize=256)
def get_google_maps_link(location, city):
    query = f"{location}, {city}".replace(" ", "+")
    return f"https://www.google.com/maps/search/{query}"

# Simple cache dictionaries for entity IDs and recommendations
entity_id_cache = {}
recommendations_cache = {}

async def fetch(session, method, url, **kwargs):
    timeout = aiohttp.ClientTimeout(total=5)
    async with session.request(method, url, timeout=timeout, **kwargs) as response:
        response.raise_for_status()
        return await response.json()

async def get_entity_id(session, name, entity_type):
    key = (name.lower(), entity_type)
    if key in entity_id_cache:
        return entity_id_cache[key]
    url = "https://hackathon.api.qloo.com/search"
    headers = {"x-api-key": QLOO_API_KEY}
    params = {"query": name, "types": entity_type}
    try:
        data = await fetch(session, "GET", url, headers=headers, params=params)
        results = data.get("results", [])
        entity_id = results[0].get("entity", {}).get("id") or results[0].get("id") if results else None
        entity_id_cache[key] = entity_id
        return entity_id
    except Exception:
        return None

async def get_recommendations(session, entity_id, domain):
    if not entity_id:
        return []
    key = (entity_id, domain)
    if key in recommendations_cache:
        return recommendations_cache[key]
    url = f"https://hackathon.api.qloo.com/recommendations/{domain}"
    headers = {"x-api-key": QLOO_API_KEY, "Content-Type": "application/json"}
    payload = {"ids": [entity_id], "count": 5}
    try:
        data = await fetch(session, "POST", url, headers=headers, json=payload)
        recs = [r["name"] for r in data.get("recommendations", [])]
        recommendations_cache[key] = recs
        return recs
    except Exception:
        return []

async def gather_preferences(music, movie, fashion):
    connector = aiohttp.TCPConnector(limit=20)  # Tuned for concurrency
    async with aiohttp.ClientSession(connector=connector) as session:
        # Run entity id fetches concurrently
        ids = await asyncio.gather(
            get_entity_id(session, music, "urn:entity:artist"),
            get_entity_id(session, movie, "urn:entity:movie"),
            get_entity_id(session, fashion, "urn:entity:brand"),
        )
        # Run recommendation fetches concurrently
        recs = await asyncio.gather(
            get_recommendations(session, ids[0], "music"),
            get_recommendations(session, ids[1], "movies"),
            get_recommendations(session, ids[2], "fashion"),
        )
        return {"music": recs[0] or [music], "movie": recs[1] or [movie], "fashion": recs[2] or [fashion]}

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
    music, movie, fashion = "Pop", "Anime", "Streetwear"
    city, days = "Tokyo", 2

    recs = await gather_preferences(music, movie, fashion)
    prompt = build_prompt(user_input, recs, city, days)

    loop = asyncio.get_running_loop()

    # Run model generation in executor if blocking
    response = await loop.run_in_executor(None, lambda: model.generate_content(prompt))

    streamed = "".join(part.text for part in response)

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

async def enrich_activity(act, city):
    location = act.get("location") or act.get("name", "Unknown")
    return {
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
    }

async def enrich_day_activities(day, city):
    activities = day.get("activities", day.get("items", []))
    enriched_activities = await asyncio.gather(*(enrich_activity(act, city) for act in activities))
    return {
        "day_number": day.get("day", 1),
        "theme": day.get("theme", "Cultural day"),
        "activities": enriched_activities
    }

async def enrich_with_maps(parsed_data):
    itinerary = parsed_data.get("itinerary", {})
    city = itinerary.get("destination", "Tokyo")
    duration = itinerary.get("duration", 1)
    image_url = f"https://picsum.photos/seed/{city}/1200/800"

    days = itinerary.get("days", [])
    enriched_days = await asyncio.gather(*(enrich_day_activities(day, city) for day in days))

    return {
        "status": "success",
        "travel_plan": {
            "destination": city,
            "duration_days": duration,
            "summary": f"{duration}-day cultural itinerary for {city}",
            "travel_image": image_url,
            "days": enriched_days
        }
    }
