import requests
from datetime import datetime, timezone
import sys
import json
from fastapi import FastAPI

from master.database import init_db, load_urls
from master.api import apiRouter


async def lifespan(app: FastAPI):
    init_db()
    load_urls()
    yield


# Master got me working
app = FastAPI(title="Vasco Master", lifespan=lifespan)

app.include_router(apiRouter)


@app.get("/health")
def health():
    return {"status": "ok"}
