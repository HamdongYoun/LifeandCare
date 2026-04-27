import os
import json
from datetime import datetime
import google.generativeai as genai
from dotenv import load_dotenv
# 프롬프트 파일이 1tab_chat과 공유된다면 경로 확인이 필요합니다.
# 일단 같은 폴더 혹은 상위 폴더의 규칙에 맞춰 import 합니다.
from . import prompts 

load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

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

REPORT_MODELS = get_available_models()

def generate_summary(chat_history):
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
    if stage == 4:
        return {"status": "blocked", "message": "위기 상황 리포트는 보안 정책상 저장할 수 없습니다."}

    try:
        summary_text, used_model = generate_summary([user_input, ai_response])
        
        report_data = {
            "id": datetime.now().strftime("%Y%m%d%H%M%S"),
            "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "stage": stage,
            "summary": summary_text,
            "raw_data": {"user": user_input, "ai": ai_response},
            "meta": {"model_used": used_model}
        }

        if not os.path.exists('reports'):
            os.makedirs('reports')
            
        file_path = f"reports/report_{report_data['id']}.json"
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(report_data, f, ensure_ascii=False, indent=4)
            
        return {"status": "success", "file": file_path, "summary": summary_text}
    except Exception as e:
        return {"status": "error", "message": str(e)}

def get_all_reports():
    reports = []
    if not os.path.exists('reports'):
        return reports
    for filename in sorted(os.listdir('reports'), reverse=True):
        if filename.endswith(".json"):
            with open(f"reports/{filename}", 'r', encoding='utf-8') as f:
                reports.append(json.load(f))
    return reports
