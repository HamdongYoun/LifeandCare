import google.generativeai as genai
import os
from .models import ChatResponse

# --- 1. HARNESS: Strict Key Loading ---
# 표준 영문 변수명(GEMINI_API_KEY)으로 복구
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if GEMINI_API_KEY:
    # Always re-configure to ensure latest environment key is used
    genai.configure(api_key=GEMINI_API_KEY)

# --- 2. Model Parameters (Official v2.5 Flash-Lite) ---
PRIMARY_MODEL = 'gemini-2.5-flash-lite'
SECONDARY_MODEL = 'gemini-2.5-flash'
FALLBACK_MODEL = 'gemini-1.5-pro'

class ChatService:
    @staticmethod
    async def get_chat_response(message: str, lat: float = None, lng: float = None):
        if not message.strip():
            return ChatResponse(content="증상을 입력해주세요.", message_type="text")

        base_prompt = """
        당신은 전문 의료 로봇 'Life & Care'입니다. 
        사용자의 증상을 분석하고 친절하게 상담하세요. 
        규칙:
        1. 무조건 한글로 답변하세요.
        2. 답변 끝에 반드시 [HOSPITAL:추천진료과] 형식의 태그를 포함하세요 (예: [HOSPITAL:내과]).
        3. 심각한 위급 상황으로 판단되면 [EMERGENCY] 태그를 붙이세요.
        """
        
        if lat and lng:
            base_prompt += f"\n현재 위치: 위도 {lat}, 경도 {lng}"

        models_to_try = [PRIMARY_MODEL, SECONDARY_MODEL, FALLBACK_MODEL]
        last_error = None
        
        for model_name in models_to_try:
            try:
                # 최신 SDK 규격: Client와 함께 system_instruction 활용 (Official Guide)
                model = genai.GenerativeModel(
                    model_name=model_name,
                    system_instruction="당신은 전문 의료 로봇 'Life & Care'입니다. 사용자의 증상을 분석하고 친절하게 상담하세요. 1. 무조건 한글로 답변하세요. 2. 답변 끝에 반드시 [HOSPITAL:추천진료과] 형식의 태그를 포함하세요. 3. 심각한 위급 상황으로 판단되면 [EMERGENCY] 태그를 붙이세요."
                )
                response = model.generate_content(message)
                
                if not response or not response.text:
                    raise ValueError("Empty AI Response")
                    
                content = response.text
                
                # Determine message type from AI flags
                msg_type = "text"
                if "[EMERGENCY]" in content:
                    msg_type = "emergency"
                elif "[HOSPITAL:" in content:
                    msg_type = "hospital_card"
                    
                return ChatResponse(content=content, message_type=msg_type)
                
            except Exception as e:
                last_error = e
                print(f"[Gemini Try Fail] Model: {model_name}, Error: {e}")
                # Try next model unless it's a quota issue
                if "429" in str(e) or "quota" in str(e).lower():
                    break
                continue

        # --- 3. Robust Error Fallback ---
        error_msg = str(last_error).lower() if last_error else ""
        if "429" in error_msg or "quota" in error_msg:
            return ChatResponse(
                content="죄송합니다. 현재 AI 서버 접속이 많아 지연되고 있습니다. 잠시 후 시도해 주세요. [HOSPITAL:내과]",
                message_type="hospital_card"
            )
        elif "api key not valid" in error_msg:
            return ChatResponse(
                content="시스템 키 인증 오류가 발생했습니다. (API Key Invalid). [HOSPITAL:내과]",
                message_type="text"
            )
        
        # Generic Fail
        return ChatResponse(
            content="일시적인 통신 장애가 발생했습니다. 잠시 후 다시 증상을 말씀해주세요.",
            message_type="text"
        )
