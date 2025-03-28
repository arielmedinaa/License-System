import uuid
from datetime import datetime, timedelta
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, field_validator

from app.models.license import ClientType, LicenseType

class LicenseBase(BaseModel):
    ruc: str
    nombre: str
    mail: EmailStr
    tipo: ClientType
    licencia: LicenseType
    ip: Optional[str] = "localhost"
    port: Optional[str] = "5432"
    is_active: Optional[bool] = True
    expiration_date: Optional[datetime] = None
    
    @field_validator('expiration_date')
    def set_expiration_date(cls, v):
        if v is None:
            return datetime.utcnow().replace(tzinfo=None) + timedelta(days=365)
        if hasattr(v, 'tzinfo') and v.tzinfo is not None:
            return v.replace(tzinfo=None)
        return v

class LicenseCreate(LicenseBase):
    password: str = Field(..., min_length=3)
    
    @field_validator('password')
    def validate_password(cls, v):
        if len(v) < 3:
            raise ValueError('La contraseña debe tener al menos 3 caracteres')
        return v

class LicenseInDB(LicenseBase):
    id: uuid.UUID
    database_name: str
    pass_database: str
    password_user: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class LicenseUpdate(BaseModel):
    nombre: Optional[str] = None
    mail: Optional[EmailStr] = None
    password: Optional[str] = None
    ip: Optional[str] = None
    port: Optional[str] = None
    tipo: Optional[ClientType] = None
    licencia: Optional[LicenseType] = None
    is_active: Optional[bool] = None
    expiration_date: Optional[datetime] = None
    
    @field_validator('password')
    def validate_password(cls, v):
        if v is not None and len(v) < 3:
            raise ValueError('La contraseña debe tener al menos 3 caracteres')
        return v

class LicenseResponse(LicenseBase):
    id: uuid.UUID
    database_name: str
    pass_database: str
    created_at: datetime
    updated_at: datetime
    expiration_date: datetime
    access_token: Optional[str] = None
    token_type: Optional[str] = None

    class Config:
        from_attributes = True
        
class UserInfo(BaseModel):
    id: uuid.UUID
    email: EmailStr

class TokenLicenseResponse(BaseModel):
    access_token: str
    token_type: str
    user: UserInfo

    class Config:
        from_attributes = True