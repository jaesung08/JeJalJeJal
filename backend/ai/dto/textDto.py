from pydantic import BaseModel


class TextDto(BaseModel):
    text: str
