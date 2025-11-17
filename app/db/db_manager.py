import os
import logging
import secrets
import string
import socket
from typing import Dict, Any
from sqlalchemy.ext.asyncio import create_async_engine
from sqlalchemy import text
from app.core.config import settings
from app.models.user import UserModel
from tenacity import retry, stop_after_attempt, wait_fixed, retry_if_exception_type
from passlib.context import CryptContext

logger = logging.getLogger(__name__)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# --------------------------
#  UTILIDADES DE PASSWORD
# --------------------------

def truncate_password(password: str) -> str:
    """
    Bcrypt solo permite 72 bytes.
    Truncamos silenciosamente el exceso.
    """
    return password.encode("utf-8")[:72].decode("utf-8", errors="ignore")

def hash_password(password: str) -> str:
    password = truncate_password(password)
    return pwd_context.hash(password)

# --------------------------

def generate_password(length=12):
    alphabet = string.ascii_letters + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def is_running_locally():
    try:
        socket.gethostbyname('client-db')
        return False
    except socket.gaierror:
        return True

db_host = 'localhost' if is_running_locally() else settings.CLIENT_DB_SERVER
db_port = settings.CLIENT_DB_PORT

logger.info(f"Usando DB_HOST: {db_host}, DB_PORT: {db_port}")

class ClientDBManager:
    def __init__(self):
        self.admin_engine = create_async_engine(
            f"postgresql+asyncpg://{settings.CLIENT_DB_USER}:{settings.CLIENT_DB_PASSWORD}"
            f"@{db_host}:{db_port}/postgres",
            isolation_level="AUTOCOMMIT",
        )

        self.client_engines = {}
    
    @retry(
        stop=stop_after_attempt(5),
        wait=wait_fixed(1),
        retry=retry_if_exception_type(Exception)
    )
    
    async def create_client_database(self, ruc: str, client_type: str) -> Dict[str, Any]:
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
        script_path = os.path.join(os.path.dirname(__file__), "script", "script.sql")
        with open(script_path, "r", encoding="utf-8") as f:
            script = f.read()
        
        client_engine = create_async_engine(
            f"postgresql+asyncpg://{settings.CLIENT_DB_USER}:{settings.CLIENT_DB_PASSWORD}"
            f"@{db_host}:{db_port}/{db_name}"
        )
        
        self.client_engines[db_name] = client_engine
        create_users_table_sql = UserModel.get_create_table_sql(table_name)
        
        try:
            async with client_engine.begin() as conn:
                await conn.execute(text("CREATE EXTENSION IF NOT EXISTS pgcrypto"))
                await conn.execute(text(create_users_table_sql))
                statements = self._parse_sql_statements(script)
                for stmt in statements:
                    if stmt.strip():
                        await conn.execute(text(stmt))
                    
            logger.info(f"Esquema inicializado correctamente para {db_name}.{table_name}")
        except Exception as e:
            logger.error(f"Error inicializando esquema para {db_name}.{table_name}: {e}")
            raise
    
    def _parse_sql_statements(self, script: str) -> list:
        statements = []
        current_statement = ""
        in_dollar_quote = False
        dollar_tag = ""
        i = 0
        
        while i < len(script):
            char = script[i]
            current_statement += char
            if char == '$' and not in_dollar_quote:
                tag_start = i + 1
                tag_end = tag_start
                while tag_end < len(script) and script[tag_end] != '$':
                    tag_end += 1
                
                if tag_end < len(script):
                    dollar_tag = script[tag_start:tag_end]
                    in_dollar_quote = True
                    current_statement += script[tag_start:tag_end + 1]
                    i = tag_end + 1
                    continue
            
            elif char == '$' and in_dollar_quote:
                tag_start = i + 1
                tag_end = tag_start + len(dollar_tag)
                if (tag_end < len(script) and 
                    script[tag_start:tag_end] == dollar_tag and 
                    tag_end < len(script) and 
                    script[tag_end] == '$'):
                    current_statement += script[tag_start:tag_end + 1]
                    in_dollar_quote = False
                    dollar_tag = ""
                    i = tag_end + 1
                    continue
            
            elif char == ';' and not in_dollar_quote:
                stmt = current_statement.strip()
                if stmt:
                    statements.append(stmt)
                current_statement = ""
            
            i += 1
        
        stmt = current_statement.strip()
        if stmt:
            statements.append(stmt)
        
        return statements
    
    async def get_client_engine(self, db_name: str):
        if db_name not in self.client_engines:
            self.client_engines[db_name] = create_async_engine(
                f"postgresql+asyncpg://{settings.CLIENT_DB_USER}:{settings.CLIENT_DB_PASSWORD}"
                f"@{db_host}:{db_port}/{db_name}"
            )
            
        return self.client_engines[db_name]
    
    async def create_admin_user(self, db_name: str, table_name: str, user_data: dict) -> bool:
        engine = await self.get_client_engine(db_name)

        # -----------------------------
        #  🔥 FIX CRÍTICO AQUÍ
        # -----------------------------
        # Hash + truncate del password
        if "password" in user_data:
            user_data["password"] = hash_password(user_data["password"])
        # -----------------------------

        insert_query = f"""
        INSERT INTO {table_name} (
            nombre, email, phone, "isActive", address, age, password, role
        ) VALUES (
            :nombre, :email, :phone, :isActive, :address, :age, :password, :role
        ) RETURNING id
        """
        
        try:
            async with engine.begin() as conn:
                result = await conn.execute(text(insert_query), user_data)
                user_id = result.scalar()
                logger.info(f"Usuario administrador creado con ID: {user_id}")
                return True
        except Exception as e:
            logger.error(f"Error creando usuario administrador: {e}")
            raise

client_db_manager = ClientDBManager()
