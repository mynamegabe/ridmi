from typing import Annotated
from sqlmodel import Field, Session, SQLModel, create_engine, select, Relationship
from sqlalchemy.dialects.mysql import LONGTEXT
from config import DB_HOST, DB_NAME, DB_PASSWORD, DB_USERNAME


    
class Organisation(SQLModel, table=True):
    id: str | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    org_code: str = Field(index=True)
    users: list["User"] = Relationship(back_populates="organisation")
    
    
class User(SQLModel, table=True):
    id: str | None = Field(default=None, primary_key=True)
    first_name: str
    last_name: str
    email: str
    password: str
    org_id: str = Field(default=None, foreign_key="organisation.id")
    organisation: Organisation | None = Relationship(back_populates="users")
    

# mysql
db_url = f"mysql+pymysql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"

# connect_args = {"check_same_thread": False}
engine = create_engine(db_url)  # , connect_args=connect_args)


def create_db_and_tables():
    SQLModel.metadata.create_all(engine)


def get_session():
    with Session(engine) as session:
        yield session
