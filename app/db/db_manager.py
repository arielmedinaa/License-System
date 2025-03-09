import asyncio
import logging
import secrets
import string
from typing import Dict, Any, Optional
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from app.core.config import settings
from app.models.user import UserModel
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type

logger = logging.getLogger(__name__)

def generate_password(length=12):
    """Genera una contraseña segura para la base de datos del cliente"""
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))

class ClientDBManager:
    """
    Manager para crear y gestionar bases de datos específicas de clientes
    """
    
    def __init__(self):
        self.admin_engine = create_async_engine(
            f"postgresql+asyncpg://{settings.CLIENT_DB_USER}:{settings.CLIENT_DB_PASSWORD}"
            f"@{settings.CLIENT_DB_SERVER}:{settings.CLIENT_DB_PORT}/postgres",
            isolation_level="AUTOCOMMIT",
        )
        
        self.client_engines = {}
    
    @retry(
        stop=stop_after_attempt(5),
        wait=wait_fixed(1),
        retry=retry_if_exception_type(Exception)
    )
    async def create_client_database(self, ruc: str, client_type: str) -> Dict[str, Any]:
        """
        Crea una nueva base de datos para un cliente basada en su RUC
        
        Args:
            ruc: RUC del cliente
            client_type: Tipo de cliente (administrador o demo)
            
        Returns:
            Dict con información de la base de datos creada (nombre, contraseña)
        """
        if client_type == "demo":
            db_name = "demo"
            table_name = f"client_{ruc.replace('-', '_')}"
        else:
            db_name = f"client_{ruc.replace('-', '_')}"
            table_name = "users"
        
        db_password = generate_password()
        
        try:
            if client_type == "administrador":
                async with self.admin_engine.begin() as conn:
                    result = await conn.execute(
                        text(f"SELECT 1 FROM pg_database WHERE datname = '{db_name}'")
                    )
                    if result.scalar():
                        logger.info(f"Base de datos {db_name} ya existe")
                    else:
                        logger.info(f"Creando base de datos {db_name} para cliente {ruc}")
                        await conn.execute(text(f'CREATE DATABASE "{db_name}"'))
            
            await self._initialize_client_schema(db_name, table_name)
            
            return {
                "database_name": db_name,
                "pass_database": db_password,
                "table_name": table_name
            }
            
        except Exception as e:
            logger.error(f"Error creando base de datos para cliente: {e}")
            raise
    
    async def _initialize_client_schema(self, db_name: str, table_name: str) -> None:
        """
        Inicializa el esquema para la base de datos de un cliente con tablas predefinidas
        
        Args:
            db_name: Nombre de la base de datos
            table_name: Nombre de la tabla de usuarios para este cliente
        """
        client_engine = create_async_engine(
            f"postgresql+asyncpg://{settings.CLIENT_DB_USER}:{settings.CLIENT_DB_PASSWORD}"
            f"@{settings.CLIENT_DB_SERVER}:{settings.CLIENT_DB_PORT}/{db_name}"
        )
        
        self.client_engines[db_name] = client_engine
        
        create_users_table_sql = UserModel.get_create_table_sql(table_name)
        
        try:
            async with client_engine.begin() as conn:
                await conn.execute(text("CREATE EXTENSION IF NOT EXISTS pgcrypto"))
                await conn.execute(text(create_users_table_sql))
                    
            logger.info(f"Esquema inicializado correctamente para {db_name}.{table_name}")
        except Exception as e:
            logger.error(f"Error inicializando esquema para {db_name}.{table_name}: {e}")
            raise
    
    async def get_client_engine(self, db_name: str):
        """
        Obtiene o crea un engine para la base de datos de un cliente
        
        Args:
            db_name: Nombre de la base de datos del cliente
            
        Returns:
            SQLAlchemy AsyncEngine para la base de datos
        """
        if db_name not in self.client_engines:
            self.client_engines[db_name] = create_async_engine(
                f"postgresql+asyncpg://{settings.CLIENT_DB_USER}:{settings.CLIENT_DB_PASSWORD}"
                f"@{settings.CLIENT_DB_SERVER}:{settings.CLIENT_DB_PORT}/{db_name}"
            )
            
        return self.client_engines[db_name]
    
    async def create_admin_user(self, db_name: str, table_name: str, user_data: dict) -> bool:
        """
        Crea un usuario administrador en la base de datos del cliente
        
        Args:
            db_name: Nombre de la base de datos
            table_name: Nombre de la tabla de usuarios
            user_data: Datos del usuario a crear
            
        Returns:
            True si la creación fue exitosa
        """
        engine = await self.get_client_engine(db_name)
        
        insert_query = f"""
        INSERT INTO {table_name} (
            nombre, email, phone, "isActive", address, age, password, role
        ) VALUES (
            :nombre, :email, :phone, :isActive, :address, :age, :password, :role
        ) RETURNING id
        """
        
        try:
            async with engine.begin() as conn:
                result = await conn.execute(
                    text(insert_query),
                    user_data
                )
                user_id = result.scalar()
                logger.info(f"Usuario administrador creado con ID: {user_id}")
                return True
        except Exception as e:
            logger.error(f"Error creando usuario administrador: {e}")
            raise

client_db_manager = ClientDBManager()