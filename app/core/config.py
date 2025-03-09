from typing import List, Union, Optional, Any
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    API_V1_STR: str = "/api/v1"
    PROJECT_NAME: str = "Sistema de Licencias"
    
    # JWT
    SECRET_KEY: str = "your-secret-key-please-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 8
    
    # CORS
    BACKEND_CORS_ORIGINS: List[AnyHttpUrl] = []

    @field_validator("BACKEND_CORS_ORIGINS")
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",")]
        elif isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    POSTGRES_SERVER: str = "db"
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "postgres"
    POSTGRES_DB: str = "license_db"
    POSTGRES_PORT: int = 5432
    
    SQLALCHEMY_DATABASE_URI: str = "postgresql+asyncpg://postgres:postgres@db:5432/license_db"
    
    CLIENT_DB_SERVER: str = "client-db"
    CLIENT_DB_USER: str = "postgres"
    CLIENT_DB_PASSWORD: str = "nest-crud-2005"
    CLIENT_DB_PORT: int = 5432

    class Config:
        case_sensitive = True
        env_file = ".env"

settings = Settings()