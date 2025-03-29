import uuid
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
import jwt
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from passlib.context import CryptContext
from app.errors.exceptions_manage import sneaky_throws
from app.models.license import License
from app.schemas.license import LicenseCreate, LicenseUpdate
from app.db.db_manager import client_db_manager
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)

@sneaky_throws()
async def create(db: AsyncSession, *, obj_in: LicenseCreate) -> License:
    db_info = await client_db_manager.create_client_database(
        ruc=obj_in.ruc,
        client_type=obj_in.tipo.value
    )
    
    license_data = obj_in.dict(exclude={"password"})
    license_data["password_user"] = get_password_hash(obj_in.password)
    license_data["database_name"] = db_info["database_name"]
    license_data["pass_database"] = db_info["pass_database"]
    
    if 'expiration_date' in license_data and license_data['expiration_date'] is not None:
        if hasattr(license_data['expiration_date'], 'tzinfo') and license_data['expiration_date'].tzinfo is not None:
            license_data['expiration_date'] = license_data['expiration_date'].replace(tzinfo=None)
    
    db_obj = License(**license_data)
    
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    
    try:
        user_data = {
            "nombre": obj_in.nombre,
            "email": obj_in.mail,
            "phone": None,
            "isActive": True,
            "address": None,
            "age": None,
            "password": get_password_hash(obj_in.password),
            "role": "admin"
        }
        
        await client_db_manager.create_admin_user(
            db_name=db_info["database_name"],
            table_name=db_info["table_name"],
            user_data=user_data
        )
    except Exception as e:
        print(f"Error al crear usuario administrador: {e}")
    
    return db_obj

async def get(db: AsyncSession, id: uuid.UUID) -> Optional[License]:
    result = await db.execute(select(License).where(License.id == id))
    return result.scalars().first()

async def get_by_ruc(db: AsyncSession, ruc: str) -> Optional[License]:
    result = await db.execute(select(License).where(License.ruc == ruc))
    return result.scalars().first()

async def get_by_email_and_password(db: AsyncSession, email: str, password: str) -> Optional[License]:
    result = await db.execute(
        select(License).where(License.mail == email)
    )
    user = result.scalars().first()
    if user and verify_password(password, user.password_user):
        return user
    
    return None

def create_access_token(data: Dict[str, Any]) -> str:
    to_encode = data.copy()
    
    if settings.ACCESS_TOKEN_EXPIRE_MINUTES > 0:
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(
        to_encode, 
        settings.SECRET_KEY, 
        algorithm=settings.ALGORITHM
    )
    return encoded_jwt

async def authenticate_user_and_get_token(db: AsyncSession, email: str, password: str) -> Optional[Dict[str, Any]]:
    user = await get_by_email_and_password(db, email, password)
    
    if not user:
        return None
    
    token_data = {
        "sub": str(user.id),
        "email": user.mail,
        "license_id": str(user.license_id) if hasattr(user, 'license_id') else None,
        "license_type": user.license_type if hasattr(user, 'license_type') else None,
    }
    
    access_token = create_access_token(token_data)
    
    user_data = {
        "id": user.id,
        "email": user.mail,
    }
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": user_data
    }

def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)

async def get_by_email(db: AsyncSession, email: str) -> Optional[License]:
    result = await db.execute(select(License).where(License.mail == email))
    return result.scalars().first()

async def get_multi(
    db: AsyncSession, *, skip: int = 0, limit: int = 100
) -> List[License]:
    result = await db.execute(
        select(License).offset(skip).limit(limit)
    )
    return result.scalars().all()

async def update(
    db: AsyncSession, *, db_obj: License, obj_in: LicenseUpdate
) -> License:
    update_data = obj_in.dict(exclude_unset=True)
    
    if "password" in update_data:
        password = update_data.pop("password")
        update_data["password_user"] = get_password_hash(password)
    
    for field, value in update_data.items():
        setattr(db_obj, field, value)
    
    db.add(db_obj)
    await db.commit()
    await db.refresh(db_obj)
    return db_obj

async def remove(db: AsyncSession, *, id: uuid.UUID) -> Optional[License]:
    license = await get(db, id)
    if license:
        await db.delete(license)
        await db.commit()
    return license

async def deactivate(db: AsyncSession, *, id: uuid.UUID) -> Optional[License]:
    license = await get(db, id)
    if license:
        license.is_active = False
        db.add(license)
        await db.commit()
        await db.refresh(license)
    return license

async def get_active_licenses(db: AsyncSession) -> List[License]:
    now = datetime.utcnow()
    result = await db.execute(
        select(License)
        .where(License.is_active == True)
        .where(License.expiration_date > now)
    )
    return result.scalars().all()