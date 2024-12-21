from pydantic import BaseModel
from typing import Optional, List


class UserBase(BaseModel):
    username: str
    avatar_url: str


class UserProfile(BaseModel):
    first_name: str
    last_name: str
    email: str
    org_name: str


class UserCreate(UserBase):
    github_access_token: str
    pass


class User(UserBase):
    id: int

    class Config:
        from_attributes = True

class LoginSchema(BaseModel):
    email: str
    password: str
    
    
class RegisterSchema(BaseModel):
    email: str
    password: str
    first_name: str
    last_name: str
    org_code: str