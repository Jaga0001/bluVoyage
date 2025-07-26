from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from planner import generate_itinerary_response
import uvicorn
import os
import time

app = FastAPI(
    title="Cultural Travel Planner API",
    version="2.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.middleware("http")
async def add_timing_header(request: Request, call_next):
    start = time.time()
    response = await call_next(request)
    duration = round(time.time() - start, 3)
    response.headers["X-Process-Time"] = str(duration)
    return response

class ItineraryRequest(BaseModel):
    user_input: str

@app.post("/generate-itinerary")
async def generate_itinerary(request: ItineraryRequest):
    return await generate_itinerary_response(request.user_input)

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=int(os.getenv("PORT", 10000)), reload=True)
