from fastapi import (
    Depends,
    FastAPI,
    HTTPException,
    Query,
    Form,
    File,
    UploadFile,
    Request,
    Response,
)
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import select
from typing import Annotated, Optional, List
from routers import users, auth, webhooks
from utils.common import hash_password, random_string
from utils.db import Session, get_session, User, Organisation, create_db_and_tables
from utils.common import get_current_active_user
from config import *
from werkzeug.utils import secure_filename
import uvicorn
from schemas import Repo, Commit, GetCommits, GetCommit, CommitRef, CommitsResponse
import requests
from datetime import datetime

SessionDep = Annotated[Session, Depends(get_session)]

app = FastAPI()

origins = [
    "http://localhost:5173",
    "http://localhost:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users.router)
app.include_router(auth.router)


@app.on_event("startup")
def on_startup():
    create_db_and_tables()
    
    org_id = random_string(32)
    
    # create test organisation
    session = next(get_session())
    org = Organisation(
        id=org_id,
        name="RIDMI", org_code="ridmi123")
    session.add(org)
    session.commit()
    
    # create test user
    uid = random_string(32)
    user = User(
        id=uid,
        first_name="John",
        last_name="Doe",
        email="johndoe@ridmi.org"
        password=hash_password("password"),
        organisation_id=org_id,
    )
    session.add(user)
    session.commit()
    session.close()
    

@app.get("/")
def read_root():
    return {"Hello": "World"}

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=80, reload=True)
