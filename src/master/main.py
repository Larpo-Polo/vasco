import requests
from datetime import datetime, timezone
import sys
import json 
from fastapi import FastAPI

from master.database import init_db

async def lifespan(app: FastAPI):
    init_db()    
    yield

# Master got me working
app = FastAPI(title="Vasco Master", lifespan=lifespan)

@app.get("/health")
def health():
    return {"status": "ok"}