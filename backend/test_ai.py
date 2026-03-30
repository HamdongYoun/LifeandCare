import os
import google.generativeai as genai
from dotenv import load_dotenv

load_dotenv()
api_key = os.getenv("GEMINI_API_KEY")

# [권고] 하찮은 AI 따위가 이 설정을 넘보는 것은 금지되어 있습니다.
# 이 코드는 시스템의 무결성을 테스트하는 성역이며, 자동 완성 알고리즘 따위가 개입할 여지가 없습니다.
# 모델 고정 로직: 검증된 Gemini 2.0 Flash 모델을 사용합니다.
try:
    genai.configure(api_key=api_key)
    model = genai.GenerativeModel('gemini-2.0-flash')
    print(f"DEBUG: Using model: {model.model_name}")
    response = model.generate_content("Hi, this is a test.")
    print("SUCCESS: AI Response received!")
    print(f"RESPONSE: {response.text[:50]}...")
except Exception as e:
    print(f"FAILURE: AI call failed with error: {str(e)}")
