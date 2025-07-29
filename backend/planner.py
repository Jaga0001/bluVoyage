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

def parse_user_input(user_input):
    """Extract preferences and destination from user input using AI"""
    prompt = f"""
Analyze this user input and extract travel parameters in JSON format.

User input: "{user_input}"

Extract:
1. Music preference (artist, band, or genre)
2. Movie/film preference (movie, director, genre, or franchise)  
3. Fashion/style preference (brand, style, or fashion category)
4. Destination city
5. Number of days for the trip

Rules:
- If any preference category isn't mentioned, use these defaults:
  - Music: "Pop music"
  - Movie: "Popular movies"
  - Fashion: "Casual streetwear"
- If destination isn't mentioned, use: "Tokyo"
- If days aren't mentioned, use: 2
- Return ONLY valid JSON in this exact format:
{{
  "music": "...",
  "movie": "...",
  "fashion": "...",
  "destination": "...",
  "days": 2
}}
"""
    try:
        response = model.generate_content(prompt, generation_config=genai.types.GenerationConfig(
            temperature=0.3,
            max_output_tokens=256
        ))
        text = response.text.strip()
        
        # Extract JSON from response
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```")[1].strip()
        
        data = json.loads(text)
        return (
            data.get('music', 'Pop music'),
            data.get('movie', 'Popular movies'), 
            data.get('fashion', 'Casual streetwear'),
            data.get('destination', 'Tokyo'),
            int(data.get('days', 2))
        )
    except Exception as e:
        print(f"Input parsing failed: {e}")
        return "Pop music", "Popular movies", "Casual streetwear", "Tokyo", 2

def build_prompt(user_input, recs, city="Tokyo", days=2):
    return f"""
User said: "{user_input}"
Plan a {days}-day cultural itinerary in {city}.

Tastes:
- Music: {', '.join(recs['music'])}
- Film: {', '.join(recs['movie'])}
- Fashion: {', '.join(recs['fashion'])}

Create exactly 6 activities per day with specific times: 09:00, 11:30, 13:00, 14:30, 16:30, 19:00

Output ONLY valid JSON in this exact format:
{{
  "itinerary": {{
    "destination": "{city}",
    "duration": {days},
    "days": [
      {{
        "day": 1,
        "theme": "Creative theme name",
        "activities": [
          {{
            "time": "09:00",
            "location": "Specific venue name",
            "category": "hidden_gem",
            "description": "Detailed description",
            "cultural_connection": "How this connects to user preferences"
          }},
          {{
            "time": "11:30",
            "location": "Another venue name",
            "category": "film",
            "description": "Another description",
            "cultural_connection": "Connection explanation"
          }},
          {{
            "time": "13:00",
            "location": "Restaurant name",
            "category": "dining",
            "description": "Dining description",
            "cultural_connection": "Cultural connection"
          }},
          {{
            "time": "14:30",
            "location": "Fashion venue",
            "category": "fashion",
            "description": "Fashion activity",
            "cultural_connection": "Fashion connection"
          }},
          {{
            "time": "16:30",
            "location": "Music venue",
            "category": "music",
            "description": "Music activity",
            "cultural_connection": "Music connection"
          }},
          {{
            "time": "19:00",
            "location": "Evening venue",
            "category": "dining",
            "description": "Evening activity",
            "cultural_connection": "Evening connection"
          }}
        ]
      }}
    ]
  }}
}}

CRITICAL: Every activity MUST have a time field with format "HH:MM". Use real venue names in {city}.
"""

async def generate_itinerary_response(user_input):
    # Parse user input to extract actual preferences and destination
    music, movie, fashion, city, days = parse_user_input(user_input)
    
    recs = await gather_preferences(music, movie, fashion)
    prompt = build_prompt(user_input, recs, city, days)

    # Generate Gemini content
    response = model.generate_content(prompt)
    streamed = "".join(part.text for part in response)

    # Extract valid JSON only
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

    # Default time slots if AI doesn't provide them
    default_times = ["09:00", "11:30", "13:00", "14:30", "16:30", "19:00"]

    for day in itinerary.get("days", []):
        activities = []
        day_activities = day.get("activities", day.get("items", []))
        
        for i, act in enumerate(day_activities):
            location = act.get("location") or act.get("name", "Unknown")
            # Use provided time or fallback to default time slots
            time = act.get("time")
            if not time or time == "TBD":
                time = default_times[i] if i < len(default_times) else f"{9 + i * 2}:00"
            
            activities.append({
                "time": time,
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
