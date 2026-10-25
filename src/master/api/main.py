from fastapi import FastAPI, APIRouter

from ..database import URLS

apiRouter = APIRouter(prefix="/api")


@apiRouter.get("/get-work")
def getWork():
    if not URLS:
        return {"url": None}

    return {"url": URLS.pop()}