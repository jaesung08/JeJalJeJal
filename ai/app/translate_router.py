from fastapi import APIRouter
from model import translate_jeju_to_standard

translate_router = APIRouter(
    prefix="/translate",
)

@translate_router.post("/detail", tags=["translate"], summary="제주 방언을 표준어로 번역합니다")
async def translate(text: str):
    translation = translate_jeju_to_standard(text)
    return translation