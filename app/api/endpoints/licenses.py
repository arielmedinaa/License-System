from datetime import timezone
import uuid
from typing import Any, Dict, List
from fastapi import APIRouter, Body, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from app import crud
from app.crud.license import create_access_token
from app.schemas.license import LicenseCreate, LicenseUpdate, LicenseResponse, TokenLicenseResponse
from app.core.database import get_db

router = APIRouter()

@router.post("/", response_model=LicenseResponse, status_code=status.HTTP_201_CREATED)
async def create_license(
    *,
    db: AsyncSession = Depends(get_db),
    license_in: LicenseCreate
) -> Any:
    existing_ruc = await crud.get_by_ruc(db, ruc=license_in.ruc)
    print(LicenseResponse)
    if existing_ruc:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Ya existe una licencia para el RUC {license_in.ruc}"
        )
    
    existing_email = await crud.get_by_email(db, email=license_in.mail)
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Ya existe una licencia para el email {license_in.mail}"
        )
    
    try:
        license = await crud.create(db, obj_in=license_in)
        return license
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error al crear la licencia: {str(e)}"
        )

@router.get("/", response_model=List[LicenseResponse])
async def read_licenses(
    db: AsyncSession = Depends(get_db),
    skip: int = 0,
    limit: int = 100
) -> Any:
    licenses = await crud.get_multi(db, skip=skip, limit=limit)
    return licenses

@router.get("/active", response_model=List[LicenseResponse])
async def read_active_licenses(
    db: AsyncSession = Depends(get_db)
) -> Any:
    licenses = await crud.get_active_licenses(db)
    return licenses

@router.get("/{license_id}", response_model=LicenseResponse)
async def read_license(
    *,
    db: AsyncSession = Depends(get_db),
    license_id: uuid.UUID
) -> Any:
    license = await crud.get(db, id=license_id)
    if not license:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Licencia no encontrada"
        )
    return license

@router.get("/ruc/{ruc}", response_model=LicenseResponse)
async def read_license_by_ruc(
    *,
    db: AsyncSession = Depends(get_db),
    ruc: str
) -> Any:
    license = await crud.get_by_ruc(db, ruc=ruc)
    if not license:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"No se encontró licencia para el RUC {ruc}"
        )
    return license

@router.put("/{license_id}", response_model=LicenseResponse)
async def update_license(
    *,
    db: AsyncSession = Depends(get_db),
    license_id: uuid.UUID,
    license_in: LicenseUpdate
) -> Any:
    license = await crud.get(db, id=license_id)
    if not license:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Licencia no encontrada"
        )
    
    if license_in.mail is not None and license_in.mail != license.mail:
        existing_license = await crud.get_by_email(db, email=license_in.mail)
        if existing_license:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Ya existe una licencia con el email {license_in.mail}"
            )
    
    license = await crud.update(db, db_obj=license, obj_in=license_in)
    return license

@router.delete("/{license_id}", response_model=LicenseResponse)
async def delete_license(
    *,
    db: AsyncSession = Depends(get_db),
    license_id: uuid.UUID
) -> Any:
    license = await crud.get(db, id=license_id)
    if not license:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Licencia no encontrada"
        )
    
    license = await crud.remove(db, id=license_id)
    return license

@router.post("/{license_id}/deactivate", response_model=LicenseResponse)
async def deactivate_license(
    *,
    db: AsyncSession = Depends(get_db),
    license_id: uuid.UUID
) -> Any:
    license = await crud.get(db, id=license_id)
    if not license:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Licencia no encontrada"
        )
    
    if not license.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La licencia ya está inactiva"
        )
    
    license = await crud.deactivate(db, id=license_id)
    return license

@router.get("/types/count", response_model=Dict[str, int])
async def get_license_types_count(
    db: AsyncSession = Depends(get_db),
):
    return await crud.get_licenses_by_type(db)

@router.post("/validate", response_model=LicenseResponse)
async def validate_license(
    *,
    db: AsyncSession = Depends(get_db),
    data: dict = Body(...)
) -> Any:
    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email y password son requeridos"
        )

    license = await crud.get_by_email_and_password(db, email=email, password=password)

    if not license:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Credenciales inválidas"
        )

    token_data = {
        "sub": str(license.id),
        "email": license.mail,
        "license_id": str(license.id),
        "license_type": license.licencia.value if hasattr(license.licencia, 'value') else license.licencia,
        "database_name": license.database_name,
        "db_host": license.ip,
        "db_port": "15432",
        "db_password": license.pass_database
    }
    
    access_token = create_access_token(token_data)    
    setattr(license, "access_token", access_token)
    setattr(license, "token_type", "bearer")

    return license
