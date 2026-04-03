from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional
from database import get_db

router = APIRouter()

# 1. HARNESS: Auth Structures
class LoginRequest(BaseModel):
    provider: str # 'kakao' or 'naver'
    provider_id: str
    nickname: Optional[str] = None
    profile_image: Optional[str] = None

class LoginResponse(BaseModel):
    user_id: int
    message: str

@router.post("/login", response_model=LoginResponse)
async def login(req: LoginRequest):
    if req.provider not in ["kakao", "naver"]:
        raise HTTPException(status_code=400, detail="Unsupported provider")
        
    with get_db() as db:
        cursor = db.cursor()
        
        column = "kakao_id" if req.provider == "kakao" else "naver_id"
        
        # Check if user exists
        cursor.execute(f"SELECT id FROM users WHERE {column} = ?", (req.provider_id,))
        row = cursor.fetchone()
        
        if row:
            user_id = row['id']
            # Update profile info if provided
            if req.nickname or req.profile_image:
                cursor.execute(f"UPDATE users SET nickname = COALESCE(?, nickname), profile_image = COALESCE(?, profile_image) WHERE id = ?", 
                               (req.nickname, req.profile_image, user_id))
        else:
            # Create new user
            cursor.execute(f"INSERT INTO users ({column}, nickname, profile_image) VALUES (?, ?, ?)", 
                           (req.provider_id, req.nickname, req.profile_image))
            user_id = cursor.lastrowid
            
        db.commit()
        return LoginResponse(user_id=user_id, message="Login successful")
