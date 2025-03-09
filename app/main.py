import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.router import api_router
from app.core.config import settings
from app.core.database import Base, engine  # Importar Base y engine

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title=settings.PROJECT_NAME,
    openapi_url=f"{settings.API_V1_STR}/openapi.json"
)

# Configurar CORS middleware
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Incluir API router
app.include_router(api_router, prefix=settings.API_V1_STR)

@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    
    logger.info("Tablas de base de datos creadas")

@app.on_event("shutdown")
async def shutdown():
    # Cerrar conexiones a la base de datos
    await engine.dispose()
    logger.info("Conexiones a base de datos cerradas")

@app.get("/")
async def root():
    return {
        "message": "Bienvenido al Sistema de Gestión de Licencias API",
        "docs_url": "/docs",
        "version": "1.0.0"
    }

@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "version": "1.0.0",
        "database_config": {
            "server": settings.POSTGRES_SERVER,
            "port": settings.POSTGRES_PORT,
            "db": settings.POSTGRES_DB,
            "uri": settings.SQLALCHEMY_DATABASE_URI
        }
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)