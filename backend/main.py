# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import uvicorn

from planner import generate_structured_itinerary, parse_user_input_with_ai

app = FastAPI(
    title="Cultural Travel Planner API",
    description="Create personalized cultural itineraries based on user tastes",
    version="1.0"
)

# Enable CORS for Flutter Web
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, use your Flutter domain instead of "*"
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request body model
class ItineraryRequest(BaseModel):
    user_input: str

# Endpoint
@app.post("/generate-itinerary")
async def generate_itinerary(request: ItineraryRequest):
    try:
        preferences, destination, days = parse_user_input_with_ai(request.user_input)
        itinerary = generate_structured_itinerary(request.user_input, preferences, destination, days)
        return {
            "preferences": preferences,
            "destination": destination,
            "days": days,
            "itinerary": itinerary
        }
    except Exception as e:
        return {
            "error": str(e),
            "message": "Failed to generate itinerary"
        }

# Local run
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 10000))
    uvicorn.run("main:app", host="0.0.0.0", port=port)
