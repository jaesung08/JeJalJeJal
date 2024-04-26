# FastAPI 애플리케이션 및 라우팅 정의
from fastapi import FastAPI
from app.translate_router import translate_router

app = FastAPI()

app.include_router(translate_router)