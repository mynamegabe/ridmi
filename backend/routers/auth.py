from fastapi import APIRouter, Depends, HTTPException
import schemas
from typing import Annotated
from sqlmodel import select
from datetime import timedelta

from utils.common import create_access_token, get_current_user, Token, hash_password
from utils.db import Session, get_session, User, Organisation
from schemas import UserCreate
from config import ACCESS_TOKEN_EXPIRE_MINUTES

SessionDep = Annotated[Session, Depends(get_session)]

router = APIRouter(
    prefix="/auth",
    tags=["auth"],
    # dependencies=[Depends(get_token_header)],
    responses={404: {"description": "Not found"}},
)


@router.post("/register")
async def register(user: schemas.RegisterSchema, session: SessionDep):
    if session.exec(select(Organisation).filter_by(org_code=user.org_code)).first() is None:
        raise HTTPException(status_code=404, detail="Organisation not found")
    user.password = hash_password(user.password)
    session.add(User(**user.model_dump()))
    session.commit()
    return user


@router.post("/login")
async def login(data: schemas.LoginSchema, session: SessionDep):
    user = session.exec(select(User).filter_by(email=data.email)).first()
    if not user:
        raise HTTPException(status_code=403, detail="Unauthorized")
    if hash_password(data.password) != user.password:
        raise HTTPException(status_code=403, detail="Unauthorized")
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.id}, expires_delta=access_token_expires
    )
    return Token(access_token=access_token, token_type="bearer")


# @router.put(
#     "/{item_id}",
#     tags=["custom"],
#     responses={403: {"description": "Operation forbidden"}},
# )
# async def update_item(item_id: str):
#     if item_id != "plumbus":
#         raise HTTPException(
#             status_code=403, detail="You can only update the item: plumbus"
#         )
#     return {"item_id": item_id, "name": "The great Plumbus"}
