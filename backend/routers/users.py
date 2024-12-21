from fastapi import APIRouter, Depends
from utils.db import Session, get_session
from sqlmodel import select
from typing import Annotated
from schemas import UserProfile
from utils.db import User, Organisation
from utils.common import get_current_active_user

router = APIRouter()
SessionDep = Annotated[Session, Depends(get_session)]


@router.get("/users/", tags=["users"])
async def read_users(session: SessionDep):
    users = session.exec(select(User)).all()
    return users


@router.get("/users/me/", response_model=UserProfile)
async def read_users_me(
    current_user: Annotated[User, Depends(get_current_active_user)],
):
    # get user organisation
    org = current_user.organisation
    org_name = org.name if org else None
    return UserProfile(
        first_name=current_user.first_name,
        last_name=current_user.last_name,
        email=current_user.email,
        org_name=org_name,
    )
