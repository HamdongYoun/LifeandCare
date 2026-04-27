from pydantic import BaseModel

class ChatRequest(BaseModel):
    user_input: str
     
class ChatResponse(BaseModel): 
    stage: int
    message: str
    show_emergency_btn: bool
    is_save_blocked: bool
    model: str
