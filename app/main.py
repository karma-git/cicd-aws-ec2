"""
Fast API application
ref: https://fastapi.tiangolo.com/
"""
import os
from socket import gethostname
from datetime import datetime
from uuid import uuid4
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def runtime_info() -> dict:
    return {
        "hostname": gethostname(),
        "timestamp": datetime.now(),
        "uuid": uuid4(),
    }


@app.get("/info")
async def application_info() -> dict:
    return {
        "commit": os.environ.get("CI_COMMIT_SHORT_SHA"),
        "pipeline": os.environ.get("CI_PIPELINE_ID"),
        "tag": os.environ.get("CI_COMMIT_TAG"),
    }

# CI TRIGGER 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17
