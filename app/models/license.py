import uuid
import enum
from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, DateTime, Enum as SQLAlchemyEnum
from sqlalchemy.dialects.postgresql import UUID

from app.core.database import Base

class LicenseType(str, enum.Enum):
    BASIC = "basic"
    STANDARD = "standard"
    PREMIUM = "premium"
    ENTERPRISE = "enterprise"

class ClientType(str, enum.Enum):
    ADMINISTRATOR = "administrador"
    DEMO = "demo"

class License(Base):
    __tablename__ = "licenses"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    ruc = Column(String, unique=True, index=True, nullable=False)
    nombre = Column(String, nullable=False)
    mail = Column(String, unique=True, index=True, nullable=False)
    password_user = Column(String, nullable=False)
    
    ip = Column(String, default="localhost")
    database_name = Column(String, nullable=False)
    pass_database = Column(String, nullable=False)
    port = Column(String, nullable=False)
    
    tipo = Column(SQLAlchemyEnum(ClientType), nullable=False)
    licencia = Column(SQLAlchemyEnum(LicenseType), nullable=False)
    
    is_active = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None))
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc).replace(tzinfo=None), 
                        onupdate=lambda: datetime.now(timezone.utc).replace(tzinfo=None))
    expiration_date = Column(DateTime, nullable=False)