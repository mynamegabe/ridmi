from typing import Annotated
from sqlmodel import Field, Session, SQLModel, create_engine, select
from sqlalchemy.dialects.mysql import LONGTEXT
from config import DB_HOST, DB_NAME, DB_PASSWORD, DB_USERNAME


class User(SQLModel, table=True):
    id: str | None = Field(default=None, primary_key=True)
    first_name: str
    last_name: str
    email: str
    password: str
    organisation_id: int = Field(foreign_key="organisation.id")
    
    
class Organisation(SQLModel, table=True):
    id: str | None = Field(default=None, primary_key=True)
    name: str = Field(index=True)
    users: Annotated[list[User], Field(foreign_key="user.organisation_id")]
    org_code: str = Field(index=True)

# mysql
db_url = f"mysql+pymysql://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"

# connect_args = {"check_same_thread": False}
engine = create_engine(db_url)  # , connect_args=connect_args)


def create_db_and_tables():
    SQLModel.metadata.create_all(engine)


def get_session():
    with Session(engine) as session:
        yield session
