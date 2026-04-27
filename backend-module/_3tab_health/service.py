import os
import json
import sys
from datetime import datetime
from pathlib import Path
import google.generativeai as genai
from dotenv import load_dotenv

# --- 프롬프트 경로 최적화 (공통 폴더의 prompts.py를 찾기 위함) ---
BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.append(str(BACKEND_DIR))

try:
    import prompts
except ImportError:
    from . import prompts

# 환경 변수 및 AI 설정
load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

def get_available_models():
    """요약용 가용 모델 스캔"""
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
        # 스캔 실패 시 기본 모델 반환
        return ['models/gemini-3-flash-preview']

REPORT_MODELS = get_available_models()

def generate_summary(chat_history):
    """상담 내역 요약 생성"""
    formatted_history = "\n".join([f"{'사용자' if i%2==0 else 'AI'}: {msg}" for i, msg in enumerate(chat_history)])
    full_prompt = f"다음 상담 내용을 요약 지침에 맞춰 정리해줘:\n{formatted_history}"

    for model_name in REPORT_MODELS:
        try:
            model = genai.GenerativeModel(
                model_name=model_name,
                system_instruction=prompts.SYSTEM_PROMPT_REPORT
            )
            response = model.generate_content(full_prompt)
            return response.text.strip(), model_name
        except Exception:
            continue
    return "요약 생성에 실패했습니다.", "none"

def save_report(user_input, ai_response, stage):
    """리포트 파일 저장 로직"""
    # STAGE 4(위기)인 경우 저장 차단 규칙 적용
    if stage == 4:
        return {"status": "blocked", "message": "위기 상황 리포트는 보안 정책상 저장할 수 없습니다."}

    try:
        summary_text, used_model = generate_summary([user_input, ai_response])
        
        report_data = {
            "id": datetime.지금().strftime("%Y%m%d%H%M%S"),
            "date": datetime.지금().strftime("%Y-%m-%d %H:%M:%S"),
            "stage": stage,
            "summary": summary_text,
            "raw_data": {"user": user_input, "ai": ai_response},
            "meta": {"model_used": used_model}
        }

        # reports 폴더 생성 (main.py 실행 위치 기준)
        if not os.path.exists('reports'):
            os.makedirs('reports')
            
        file_path = f"reports/report_{report_data['id']}.json"
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, ensure_ascii=False, indent=4)
            
        return {"status": "success", "file": file_path, "summary": summary_text}
    except Exception as e:
        return {"status": "error", "message": str(e)}

def get_all_reports():
    """저장된 모든 리포트 목록 불러오기"""
    reports = []
    # reports 폴더가 없으면 빈 리스트 반환
    if not os.path.exists('reports'):
        return reports
    
    try:
        for filename in sorted(os.listdir('reports'), reverse=True):
            if filename.endswith(".json"):
                with open(f"reports/{filename}", 'r', encoding='utf-8') as f:
                    reports.append(json.load(f))
    except Exception as e:
        print(f"Report Load Error: {e}")
        
    return reports
