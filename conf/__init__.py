import os
from typing import Union

from fastapi import FastAPI

UVICORN_ROOT_PATH = os.environ.get('UVICORN_ROOT_PATH')

if UVICORN_ROOT_PATH and len(UVICORN_ROOT_PATH) > 0 and UVICORN_ROOT_PATH != '/':
    app = FastAPI(root_path=UVICORN_ROOT_PATH)
else:
    app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/items/{item_id}")
def read_item(item_id: int, q: Union[str, None] = None):
    return {"item_id": item_id, "q": q}