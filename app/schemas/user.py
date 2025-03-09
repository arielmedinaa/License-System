import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, EmailStr, Field, validator, conint

from app.models.user import UserRole

class UserBase(BaseModel):
    nombre: str
    email: EmailStr
    phone: Optional[str] = None
    isActive: Optional[bool] = True
    address: Optional[str] = None
    age: Optional[conint(ge=0, le=120)] = None # type: ignore
    role: Optional[UserRole] = UserRole.ADMIN

class UserCreate(UserBase):
    password: str = Field(..., min_length=6)

class UserInDB(UserBase):
    id: uuid.UUID
    password: str
    createdAt: datetime
    updatedAt: datetime
    
    class Config:
        from_attributes = True

class UserUpdate(BaseModel):
    nombre: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    isActive: Optional[bool] = None
    address: Optional[str] = None
    age: Optional[conint(ge=0, le=120)] = None # type: ignore
    password: Optional[str] = None
    role: Optional[UserRole] = None
    
    @validator('password')
    def password_min_length(cls, v):
        if v is not None and len(v) < 6:
            raise ValueError('La contraseña debe tener al menos 6 caracteres')
        return v

class UserResponse(UserBase):
    id: uuid.UUID
    createdAt: datetime
    updatedAt: datetime
    
    class Config:
        from_attributes = True