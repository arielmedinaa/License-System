import uuid
import enum
from datetime import datetime
from sqlalchemy import Column, String, Boolean, Integer, DateTime, Enum as SQLAlchemyEnum
from sqlalchemy.dialects.postgresql import UUID

# Este modelo NO se crea en la base de datos principal, sino que es la estructura
# que se usará para crear las tablas en las bases de datos de los clientes

class UserRole(str, enum.Enum):
    ADMIN = "admin"
    CASHIER = "cajero"

class UserModel:
    """
    Definición del modelo de usuario para generar tablas en bases de datos de clientes.
    No está vinculado directamente a la base de datos principal.
    """
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    nombre = Column(String(100), nullable=False)
    email = Column(String(100), nullable=False, unique=True)
    phone = Column(String(20), nullable=True)
    isActive = Column(Boolean, default=True)
    address = Column(String, nullable=True)
    age = Column(Integer, nullable=True)
    password = Column(String(100), nullable=False)
    createdAt = Column(DateTime, default=datetime.utcnow, name='created_at')
    updatedAt = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, name='updated_at')
    role = Column(SQLAlchemyEnum(UserRole), default=UserRole.ADMIN)
    
    @staticmethod
    def get_create_table_sql(table_name):
        return f"""
        CREATE TABLE IF NOT EXISTS {table_name} (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            nombre VARCHAR(100) NOT NULL,
            email VARCHAR(100) NOT NULL UNIQUE,
            phone VARCHAR(20),
            "isActive" BOOLEAN DEFAULT TRUE,
            address TEXT,
            age INTEGER,
            password VARCHAR(100) NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
            role VARCHAR(10) DEFAULT 'admin' CHECK (role IN ('admin', 'cajero'))
        )
        """