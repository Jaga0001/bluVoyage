import os
import re
import requests
import json
from dotenv import load_dotenv
import google.generativeai as genai

# Load your API keys from .env
load_dotenv()
QLOO_API_KEY = os.getenv("QLOO_API_KEY")
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
GOOGLE_MAPS_API_KEY = os.getenv("GOOGLE_MAPS_API_KEY")  # Add this to your .env file

# Setup Gemini
genai.configure(api_key=GOOGLE_API_KEY)
model = genai.GenerativeModel("gemini-2.5-flash")

def parse_user_input_with_ai(user_input):
    """
    Uses Gemini AI to intelligently extract preferences, destination, and days from user input.
    Falls back to defaults if any parameter isn't clearly specified.
    """
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
- If days aren't mentioned, use: 1
- Return ONLY valid JSON in this exact format:
{{
  "music": "extracted or default music preference",
  "movie": "extracted or default movie preference", 
  "fashion": "extracted or default fashion preference",
  "destination": "extracted or default city",
  "days": number_of_days
}}

Example output:
{{"music": "Frank Ocean", "movie": "Spirited Away", "fashion": "Supreme", "destination": "Tokyo", "days": 2}}
"""
    
    try:
        response = model.generate_content(prompt)
        response_text = response.text.strip()
        
        # Clean up the response to extract JSON
        if "```json" in response_text:
            response_text = response_text.split("```json")[1].split("```")[0].strip()
        elif "```" in response_text:
            response_text = response_text.split("```")[1].strip()
        
        # Parse JSON response
        data = json.loads(response_text)
        
        preferences = f"{data.get('music', 'Pop music')}, {data.get('movie', 'Popular movies')}, {data.get('fashion', 'Casual streetwear')}"
        destination = data.get('destination', 'Tokyo')
        days = int(data.get('days', 1))
        
        return preferences, destination, days
        
    except Exception as e:
        print(f"AI parsing failed: {e}")
        # Fallback to defaults
        return "Pop music, Popular movies, Casual streetwear", "Tokyo", 1

def extract_preferences_from_parsed(preferences_string):
    """
    Extracts individual preferences from the parsed preferences string.
    """
    prefs = [p.strip() for p in preferences_string.split(',')]
    if len(prefs) >= 3:
        return prefs[0], prefs[1], prefs[2]
    else:
        # Fallback if not enough preferences
        defaults = ["Pop music", "Popular movies", "Casual streetwear"]
        while len(prefs) < 3:
            prefs.append(defaults[len(prefs)])
        return prefs[0], prefs[1], prefs[2]

def get_entity_id(name, entity_type):
    url = "https://hackathon.api.qloo.com/search"
    headers = {"accept": "application/json", "x-api-key": QLOO_API_KEY}
    params = {"query": name, "types": entity_type}
    response = requests.get(url, headers=headers, params=params)
    if response.status_code == 200:
        data = response.json()
        results = data.get("results", [])
        if results:
            first = results[0]
            return first.get("entity", {}).get("id") or first.get("id")
    return None

def get_recommendations(entity_id, domain):
    url = f"https://hackathon.api.qloo.com/recommendations/{domain}"
    headers = {
        "accept": "application/json",
        "x-api-key": QLOO_API_KEY,
        "Content-Type": "application/json",
    }
    payload = {"ids": [entity_id], "count": 5}
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 200:
        data = response.json()
        return [rec["name"] for rec in data.get("recommendations", [])]
    return []

def get_google_maps_link(location_name, city):
    """
    Generate a Google Maps search link for a location.
    """
    query = f"{location_name}, {city}".replace(" ", "+")
    return f"https://www.google.com/maps/search/{query}"

def get_place_details(location_name, city):
    """
    Get place details using Google Places API (if available) or return basic info.
    """
    if not GOOGLE_MAPS_API_KEY:
        return {
            "name": location_name,
            "maps_link": get_google_maps_link(location_name, city),
            "address": f"Search for {location_name} in {city}"
        }
    
    # Google Places API integration (optional - requires API key)
    try:
        url = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json"
        params = {
            "input": f"{location_name} {city}",
            "inputtype": "textquery",
            "fields": "place_id,name,formatted_address,geometry",
            "key": GOOGLE_MAPS_API_KEY
        }
        
        response = requests.get(url, params=params)
        if response.status_code == 200:
            data = response.json()
            candidates = data.get("candidates", [])
            if candidates:
                place = candidates[0]
                place_id = place.get("place_id")
                return {
                    "name": place.get("name", location_name),
                    "address": place.get("formatted_address", f"{location_name}, {city}"),
                    "maps_link": f"https://www.google.com/maps/place/?q=place_id:{place_id}" if place_id else get_google_maps_link(location_name, city)
                }
    except Exception as e:
        print(f"Maps API error: {e}")
    
    # Fallback to basic Google Maps search
    return {
        "name": location_name,
        "maps_link": get_google_maps_link(location_name, city),
        "address": f"Search for {location_name} in {city}"
    }

def generate_structured_itinerary(user_sentence, preferences_string, destination, days):
    # Extract individual preferences from the parsed string
    music, movie, fashion = extract_preferences_from_parsed(preferences_string)
    taste_types = [
        (music, "music", "urn:entity:artist"),
        (movie, "movies", "urn:entity:movie"),
        (fashion, "fashion", "urn:entity:brand"),
    ]
    recommendations = {}
    for preference, domain, entity_type in taste_types:
        entity_id = get_entity_id(preference, entity_type)
        recommendations[preference] = (
            get_recommendations(entity_id, domain) if entity_id else ["No recommendations found"]
        )
    
    # Set defaults
    city_text = destination if destination.strip() else "Tokyo"
    duration_text = f"{days} day{'s' if days > 1 else ''}"
    
    # Structured prompt for better output
    prompt = f"""
You are a cultural travel expert creating personalized itineraries. Generate a structured JSON response.

CONTEXT:
- User request: "{user_sentence}"
- Destination: {city_text}
- Duration: {duration_text}

CULTURAL TASTE ANALYSIS (from Qloo API):
- Music preference: {music} → Similar artists: {recommendations[music]}
- Movie/Film preference: {movie} → Similar content: {recommendations[movie]}
- Fashion/Style preference: {fashion} → Similar brands: {recommendations[fashion]}

REQUIREMENTS:
Create a {duration_text} itinerary with these elements per day:
1. Music venues (record stores, concert halls, music cafes) matching their taste
2. Film/art locations (galleries, cinemas, cultural spots) reflecting their preferences
3. Fashion destinations (boutiques, vintage stores, districts) aligned with their style
4. Dining spots with the right cultural vibe
5. One unique hidden gem per day

OUTPUT FORMAT:
Return ONLY valid JSON in this structure:
{{
  "itinerary": {{
    "destination": "{city_text}",
    "duration": {days},
    "days": [
      {{
        "day": 1,
        "theme": "brief theme description",
        "activities": [
          {{
            "time": "09:00",
            "location": "Exact location name",
            "category": "music|film|fashion|dining|hidden_gem",
            "description": "Why this matches their taste",
            "cultural_connection": "How it relates to their preferences"
          }}
        ]
      }}
    ]
  }}
}}

STYLE: Authentic, youth-focused, culturally rich recommendations.
"""
    
    try:
        response = model.generate_content(prompt)
        response_text = response.text.strip()
        
        # Clean up the response to extract JSON
        if "```json" in response_text:
            response_text = response_text.split("```json")[1].split("```")[0].strip()
        elif "```" in response_text:
            response_text = response_text.split("```")[1].strip()
        
        # Parse JSON response
        itinerary_data = json.loads(response_text)
        return format_itinerary_with_maps(itinerary_data, city_text, preferences_string)
        
    except Exception as e:
        print(f"Structured itinerary generation failed: {e}")
        # Fallback to simple text generation
        return generate_fallback_itinerary(user_sentence, preferences_string, destination, days)

def generate_travel_image_url(destination, preferences):
    """
    Generate a random travel image URL using Picsum Photos.
    """
    import random
    
    # Generate a random number for each prompt to get different images
    random_id = random.randint(1, 1000)
    
    return f"https://picsum.photos/1200/800?random={random_id}"

def format_itinerary_with_maps(itinerary_data, city, preferences_string=""):
    """
    Format the structured itinerary as JSON with Google Maps integration and travel image.
    """
    itinerary = itinerary_data.get("itinerary", {})
    
    # Generate travel image URL
    travel_image_url = generate_travel_image_url(city, preferences_string)
    
    # Structure the response as JSON
    formatted_response = {
        "status": "success",
        "travel_plan": {
            "destination": itinerary.get('destination', city),
            "duration_days": itinerary.get('duration', 1),
            "travel_image": travel_image_url,
            "summary": f"{itinerary.get('duration', 1)}-day cultural itinerary for {itinerary.get('destination', city)}",
            "days": []
        }
    }
    
    for day_data in itinerary.get("days", []):
        day_num = day_data.get("day", 1)
        theme = day_data.get("theme", "Cultural exploration")
        
        day_activities = []
        for activity in day_data.get("activities", []):
            time = activity.get("time", "TBD")
            location = activity.get("location", "Unknown location")
            category = activity.get("category", "general")
            description = activity.get("description", "")
            cultural_connection = activity.get("cultural_connection", "")
            
            # Get Google Maps info
            place_info = get_place_details(location, city)
            
            # Format activity as structured data
            activity_data = {
                "time": time,
                "location": {
                    "name": place_info['name'],
                    "address": place_info['address'],
                    "maps_link": place_info['maps_link']
                },
                "category": category,
                "description": description,
                "cultural_connection": cultural_connection,
                "category_icon": {
                    "music": "🎵",
                    "film": "🎬", 
                    "fashion": "👗",
                    "dining": "🍽️",
                    "hidden_gem": "💎"
                }.get(category, "📍")
            }
            day_activities.append(activity_data)
        
        formatted_response["travel_plan"]["days"].append({
            "day_number": day_num,
            "theme": theme,
            "activities": day_activities
        })
    
    return formatted_response

def generate_fallback_itinerary(user_sentence, preferences_string, destination, days):
    """
    Fallback to simple JSON structure if AI generation fails.
    """
    music, movie, fashion = extract_preferences_from_parsed(preferences_string)
    travel_image_url = generate_travel_image_url(destination, preferences_string)
    
    # Create a basic fallback JSON structure
    fallback_response = {
        "status": "success",
        "travel_plan": {
            "destination": destination,
            "duration_days": days,
            "travel_image": travel_image_url,
            "summary": f"{days}-day cultural itinerary for {destination}",
            "preferences": {
                "music": music,
                "movie": movie,
                "fashion": fashion
            },
            "days": []
        }
    }
    
    # Generate basic activities for each day
    for day in range(1, days + 1):
        day_data = {
            "day_number": day,
            "theme": f"Cultural exploration - Day {day}",
            "activities": [
                {
                    "time": "10:00",
                    "location": {
                        "name": f"Local music venue in {destination}",
                        "address": f"Search for music venues in {destination}",
                        "maps_link": get_google_maps_link("music venues", destination)
                    },
                    "category": "music",
                    "description": f"Explore music scene related to {music}",
                    "cultural_connection": f"Matches your {music} preferences",
                    "category_icon": "🎵"
                },
                {
                    "time": "14:00",
                    "location": {
                        "name": f"Cultural district in {destination}",
                        "address": f"Search for cultural areas in {destination}",
                        "maps_link": get_google_maps_link("cultural district", destination)
                    },
                    "category": "film",
                    "description": f"Visit film and art locations inspired by {movie}",
                    "cultural_connection": f"Reflects your {movie} interests",
                    "category_icon": "🎬"
                },
                {
                    "time": "18:00",
                    "location": {
                        "name": f"Fashion district in {destination}",
                        "address": f"Search for shopping areas in {destination}",
                        "maps_link": get_google_maps_link("fashion shopping", destination)
                    },
                    "category": "fashion",
                    "description": f"Explore fashion scene matching {fashion} style",
                    "cultural_connection": f"Aligns with your {fashion} preferences",
                    "category_icon": "👗"
                }
            ]
        }
        fallback_response["travel_plan"]["days"].append(day_data)
    
    return fallback_response



