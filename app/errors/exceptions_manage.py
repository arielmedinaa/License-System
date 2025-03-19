import functools
import inspect
import traceback
import sys
import logging
import uuid
import time
from typing import Dict, List, Optional, Any, Type, Callable, Union, Set
from fastapi import Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("api")

class ErrorResponse(BaseModel):
    error: bool = True
    message: str
    error_type: str
    error_id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    location: Optional[str] = None
    line_number: Optional[int] = None
    function: Optional[str] = None
    timestamp: float = Field(default_factory=time.time)
    details: Optional[Dict[str, Any]] = None

class BaseError(Exception):
    status_code: int = 500
    
    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        self.message = message
        self.details = details
        super().__init__(self.message)

class NotFoundError(BaseError):
    status_code = 404

class BadRequestError(BaseError):
    status_code = 400

class ValidationError(BaseError):
    status_code = 422

class UnauthorizedError(BaseError):
    status_code = 401

class ForbiddenError(BaseError):
    status_code = 403

class ConflictError(BaseError):
    status_code = 409

class InternalServerError(BaseError):
    status_code = 500

EXCEPTION_STATUS_CODES = {
    NotFoundError: 404,
    BadRequestError: 400,
    ValidationError: 422,
    UnauthorizedError: 401,
    ForbiddenError: 403,
    ConflictError: 409,
    InternalServerError: 500,
    ValueError: 400,
    TypeError: 400,
    KeyError: 404,
    IndexError: 400,
    AttributeError: 500,
    ZeroDivisionError: 400,
}

def sneaky_throws(*exception_classes, status_code: Optional[int] = None, log_level: int = logging.ERROR):
    target_exceptions = set(exception_classes) if exception_classes else set(EXCEPTION_STATUS_CODES.keys())
    
    def decorator(func):
        @functools.wraps(func)
        async def async_wrapper(*args, **kwargs):
            func_name = func.__name__
            try:
                return await func(*args, **kwargs)
            except Exception as exc:
                if not any(isinstance(exc, exc_type) for exc_type in target_exceptions):
                    raise
                
                return _handle_exception(exc, func_name, status_code, log_level)
        
        @functools.wraps(func)
        def sync_wrapper(*args, **kwargs):
            func_name = func.__name__
            try:
                return func(*args, **kwargs)
            except Exception as exc:
                if not any(isinstance(exc, exc_type) for exc_type in target_exceptions):
                    raise
                
                return _handle_exception(exc, func_name, status_code, log_level)
        
        if inspect.iscoroutinefunction(func):
            return async_wrapper
        return sync_wrapper
    
    return decorator

def _handle_exception(exc, func_name, status_code, log_level):
    exc_status_code = status_code
    
    if hasattr(exc, 'status_code'):
        exc_status_code = exc.status_code
    elif exc_status_code is None:
        for exc_type, code in EXCEPTION_STATUS_CODES.items():
            if isinstance(exc, exc_type):
                exc_status_code = code
                break
        else:
            exc_status_code = 500
    
    tb = traceback.extract_tb(sys.exc_info()[2])
    location = "Unknown"
    line_number = 0
    
    if tb:
        for frame in reversed(tb):
            if frame.name == func_name:
                location = frame.filename
                line_number = frame.lineno
                break
        else:
            last_call = tb[-1]
            location = last_call.filename
            line_number = last_call.lineno
            func_name = last_call.name
    
    error_id = str(uuid.uuid4())
    
    details = getattr(exc, 'details', None)
    
    log_msg = f"Exception | ID: {error_id} | Type: {exc.__class__.__name__} | Function: {func_name} | Message: {str(exc)}"
    logger.log(log_level, log_msg)
    
    error_detail = ErrorResponse(
        message=str(exc),
        error_type=exc.__class__.__name__,
        error_id=error_id,
        location=location,
        line_number=line_number,
        function=func_name,
        details=details
    )
    
    return JSONResponse(
        status_code=exc_status_code,
        content=error_detail.dict()
    )

async def register_exception_handlers(app):
    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception):
        tb = traceback.extract_tb(sys.exc_info()[2])
        location = "Unknown"
        line_number = 0
        function_name = "Unknown"
        
        if tb:
            last_call = tb[-1]
            location = last_call.filename
            line_number = last_call.lineno
            function_name = last_call.name
        
        error_id = str(uuid.uuid4())
        
        details = getattr(exc, 'details', None)
        
        logger.error(
            f"Unhandled Exception | ID: {error_id} | Type: {exc.__class__.__name__} | "
            f"Message: {str(exc)} | Location: {location}:{line_number}"
        )
        
        error_response = ErrorResponse(
            message=str(exc),
            error_type=exc.__class__.__name__,
            error_id=error_id,
            location=location,
            line_number=line_number,
            function=function_name,
            details=details
        )
        
        status_code = 500
        if hasattr(exc, 'status_code'):
            status_code = exc.status_code
        
        return JSONResponse(
            status_code=status_code,
            content=error_response.dict()
        )