import google.generativeai as genai
import os
from backend.models import ChatResponse, ReportResponse

from dotenv import load_dotenv

load_dotenv()

# Gemini 설정
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)

# 실존하는 모델명으로 수정
PRIMARY_MODEL = 'gemini-1.5-flash'
FALLBACK_MODEL = 'gemini-1.5-pro'

class AIService:
    @staticmethod
    async def get_chat_response(message: str, lat: float = None, lng: float = None):
        base_prompt = "당신은 의료 상담 AI 'Life & Care'입니다. 증상을 분석하고 상담하세요."
        if lat and lng:
            base_prompt += f" 현재 위치: 위도 {lat}, 경도 {lng}"
        base_prompt += "\n반드시 답변 끝에 [HOSPITAL:추천진료과] 형식의 태그를 포함하세요. 위급 상황 시 [EMERGENCY]를 붙이세요."

        models_to_try = [PRIMARY_MODEL, FALLBACK_MODEL]
        last_error = None
        
        for model_name in models_to_try:
            try:
                model = genai.GenerativeModel(model_name)
                response = model.generate_content([base_prompt, message])
                content = response.text
                
                msg_type = "text"
                if "[EMERGENCY]" in content:
                    msg_type = "emergency"
                elif "[LOCATION:" in content:
                    msg_type = "map_card"
                elif "[HOSPITAL:" in content:
                    msg_type = "hospital_card"
                    
                return ChatResponse(content=content, message_type=msg_type)
            except Exception as e:
                last_error = e
                # 429 에러(할당량 초과)가 아닐 경우에만 Fallback 시도 기회 (API 에러 등)
                continue

        # 모든 모델 실패 시 (특히 할당량 초과 시)
        if "429" in str(last_error) or "quota" in str(last_error).lower():
            return ChatResponse(
                content="현재 AI 서비스 사용량이 많아 잠시 후 다시 시도해 주세요. [HOSPITAL:내과]",
                message_type="hospital_card"
            )
        
        raise last_error

    @staticmethod
    async def generate_report(history: str):
        if not history.strip():
            return ReportResponse(summary="분석할 대화 기록이 부족합니다.")
            
        system_prompt = "다음 대화 기록을 기반으로 사용자 건강 분석 보고서를 작성하세요. 전문적이면서 따뜻한 어조로 작성하세요."
        try:
            model = genai.GenerativeModel(PRIMARY_MODEL)
            response = model.generate_content([system_prompt, history])
            return ReportResponse(summary=response.text)
        except Exception as e:
            if "429" in str(e) or "quota" in str(e).lower():
                return ReportResponse(summary="[할당량 초과] 현재 분석 시스템이 일시적으로 제한되었습니다. 나중에 다시 시도해 주세요.")
            raise e

    @staticmethod
    async def summarize_condition(user_msg: str, ai_msg: str):
        system_prompt = """
        당신은 사용자 건강 상태 위험도 평가원입니다.
        사용자와 AI의 대화 내용을 분석하여 다음 두 가지를 반환하세요:
        1. 상태 코드 (status): 
           - "1" (위험): 가슴 통증, 호흡 곤란, 의식 저하, 마비, 대량 출혈, 심한 외상 등 즉각적인 응급 처치가 필요한 경우.
           - "0" (일반): 단순 감기, 근육통, 가벼운 찰과상 등 응급 상황이 아닌 경우.
        2. 증상 요약 (summary): 핵심 증상을 10자 이내로 요약.

        출력 형식: [상태코드] 요약문
        예: [1] 심한 가슴 통증
        예: [0] 가벼운 두통
        """
        try:
            model = genai.GenerativeModel(PRIMARY_MODEL)
            prompt = f"사용자: {user_msg}\nAI: {ai_msg}"
            response = model.generate_content([system_prompt, prompt])
            raw_text = response.text.strip()
            
            status_code = "0"
            summary_text = raw_text
            if "[" in raw_text and "]" in raw_text:
                status_code = raw_text.split("]")[0].replace("[", "").strip()
                summary_text = raw_text.split("]")[1].strip()
            return SummaryResponse(status=status_code, summary=summary_text)
        except Exception as e:
            print(f"Error in summarize_condition: {e}")
            return SummaryResponse(status="0", summary="분석 중")

    @staticmethod
    async def summarize_session(history: str):
        system_prompt = """
        당신은 건강 상담 세션 요약 전문가입니다.
        사용자와의 긴 상담 기록을 바탕으로 다음 정보를 한 줄(약 20~30자 내외)로 요약해 주세요:
        - 주된 증상
        - 권장된 진료과 또는 조치
        예: "두통 및 발열 호소, 내과 방문 권장"
        답변은 요약된 문장만 반환해야 합니다. 한국어로 답변하세요.
        """
        try:
            model = genai.GenerativeModel(PRIMARY_MODEL)
            response = model.generate_content([system_prompt, history])
            note_text = response.text.replace("\n", " ").strip()
            return SummarySessionResponse(note=note_text)
        except Exception as e:
            print(f"Error in summarize_session: {e}")
            return SummarySessionResponse(note="상담 요약 데이터 (저장 불가)")
