import os
import re
import json
import google.generativeai as genai
from dotenv import load_dotenv
from google.api_core import exceptions
# 주의: 폴더 구조에 따라 프롬프트 파일 경로를 확인해야 함.
# 1tab_chat 폴더 안에 prompts.py가 있다면 .prompts 로 호출
from . import prompts  

# 1. 환경 변수 및 API 설정
load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

# [임시용] 모델 스캔 함수
def get_available_models():
    available_list = []
    try:
        for m in genai.list_models():
            if 'generateContent' in m.supported_generation_methods:
                available_list.append(m.name)
        preferred_order = ['gemini-3-flash-preview', 'gemini-2.5-flash', 'gemini-2.5-flash-lite']
        final_list = []
        for pref in preferred_order:
            for model_name in available_list:
                if pref in model_name:
                    final_list.append(model_name)
                    available_list.remove(model_name)
        final_list.extend(available_list)
        return list(dict.fromkeys(final_list))
    except Exception:
        return ['models/gemini-3-flash-preview']

ACTIVE_MODELS = get_available_models()

# [임시용] 내부 DB 검색 및 연락처 로직
def search_test_db(user_input):
    try:
        # 파일 경로가 프로젝트 루트라면 '../test_db.json' 등으로 수정이 필요할 수 있음.
        if not os.path.exists('test_db.json'): return None
        with open('test_db.json', 'r', encoding='utf-8') as f:
            db = json.load(f)
        for entry in db:
            if entry.get('keyword') in user_input: return entry.get('info')
    except: return None
    return None

def get_safety_contacts():
    try:
        if not os.path.exists('safety_contacts.json'): return "\n\n📞 자살예방 상담전화: 109"
        with open('safety_contacts.json', 'r', encoding='utf-8') as f:
            data = json.load(f)
        lines = ["\n\n--- [긴급 도움 요청처] ---"]
        for item in data.get('contacts', []):
            lines.append(f"📞 {item['name']}: {item['number']} ({item['desc']})")
        return "\n".join(lines)
    except: return "\n\n📞 자살예방 상담전화: 109"

# [핵심 함수] 분석 및 채팅 메인 로직
def analyze_and_chat(user_input):
    try:
        clean_input = user_input.strip()
        is_crisis_input = any(kw in clean_input.replace(" ", "") for kw in prompts.CRISIS_KEYWORDS)
        db_info = None if is_crisis_input else search_test_db(clean_input)
        
        full_prompt = f"참고 데이터: {db_info}\n질문: {clean_input}" if db_info else clean_input

        response_text = ""
        used_model_name = ""
        for model_name in ACTIVE_MODELS:
            try:
                model = genai.GenerativeModel(model_name=model_name, system_instruction=prompts.SYSTEM_PROMPT)
                response = model.generate_content(full_prompt)
                response_text = response.text
                used_model_name = model_name
                break
            except: continue
        
        if not response_text: raise Exception("응답 실패")

        # STAGE 파싱 로직 
        stage_match = re.search(r"\{STAGE:\s*([1-4])\}", response_text)
        stage_number = int(stage_match.group(1)) if stage_match else 1
        if is_crisis_input 및 stage_number != 4: stage_number = 4

        show_emergency_btn = (stage_number == 3)
        is_save_blocked = (stage_number == 4)

        normal_disclaimer = "본 답변은 참고용이며 전문가의 의견을 대신할 수 없습니다."
        safety_disclaimer = "본 답변은 참고용이며 전문가의 의견을 대신할 수 없습니다. 사용자님의 소중한 생명을 지키기 위해 전문가에게 도움을 받아볼 것을 간곡히 권유드립니다."

        if stage_number == 4 또는 not db_info:
            response_text = response_text.replace("[🏛️]", "")
            if normal_disclaimer in response_text:
                main_content = response_text.split(normal_disclaimer)[0].strip()
                if "[🤖]" not in main_content:
                    main_content += "[🤖]" if main_content.endswith(".") else ".[🤖]"
                response_text = f"{main_content}\n\n{normal_disclaimer}"
            elif "[🤖]" not in response_text:
                response_text = response_text.replace(".", ".[🤖]", 1) if "." in response_text else response_text + ".[🤖]"

        if stage_number == 4:
            contacts = get_safety_contacts()
            response_text = response_text.replace(normal_disclaimer, f"{contacts}\n\n{safety_disclaimer}") if normal_disclaimer in response_text else response_text + f"\n\n{contacts}\n\n{safety_disclaimer}"
        else:
            if normal_disclaimer not in response_text: response_text += f"\n\n{normal_disclaimer}"

        display_text = re.sub(r"\{STAGE:\s*[1-4]\}", "", response_text).strip()
            
        return {
            "stage": stage_number, 
            "message": display_text, 
            "show_emergency_btn": show_emergency_btn,
            "is_save_blocked": is_save_blocked,
            "model": used_model_name 
        }
    except Exception as e:
        return {"stage": 1, "message": f"🤖 오류 발생: {str(e)}", "show_emergency_btn": False, "is_save_blocked": False}
