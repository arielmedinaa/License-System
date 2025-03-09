from fastapi import APIRouter

from app.api.endpoints import licenses

api_router = APIRouter()

api_router.include_router(licenses.router, prefix="/licenses", tags=["licenses"])