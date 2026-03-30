import os
import httpx
import google.generativeai as genai
from dotenv import load_dotenv
import asyncio

load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

async def test_gemini():
    key = os.getenv("GEMINI_API_KEY")
    if not key or "your_" in key:
        return "[ERROR] Missing or Default Key"
    try:
        genai.configure(api_key=key)
        model = genai.GenerativeModel('gemini-2.0-flash')
        response = model.generate_content("Hello, this is a diagnostic test. Reply 'OK'.")
        return f"[OK] Success: {response.text.strip()}"
    except Exception as e:
        return f"[ERROR] Failed: {str(e)}"

async def test_hira():
    key = os.getenv("HIRA_API_KEY")
    if not key or "your_" in key:
        return "[ERROR] Missing or Default Key"
    url = "http://apis.data.go.kr/B551182/hospInfoServicev2/getHospBasisList"
    params = {"serviceKey": key, "numOfRows": 1, "_type": "json"}
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(url, params=params, timeout=5.0)
            return f"[OK] Success (Status: {resp.status_code})"
        except Exception as e:
            return f"[ERROR] Failed: {str(e)}"

async def test_egen():
    key = os.getenv("EGEN_API_KEY")
    if not key or "your_" in key:
        return "[ERROR] Missing or Default Key"
    url = "http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire"
    params = {"serviceKey": key, "numOfRows": 1}
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(url, params=params, timeout=5.0)
            return f"[OK] Success (Status: {resp.status_code})"
        except Exception as e:
            return f"[ERROR] Failed: {str(e)}"

async def test_naver():
    cid = os.getenv("NAVER_MAP_CLIENT_ID")
    sec = os.getenv("NAVER_MAP_CLIENT_SECRET")
    if not cid or not sec or "your_" in cid:
        return "[ERROR] Missing or Default Keys"
    url = "https://maps.apigw.ntruss.com/map-direction/v1/driving"
    params = {"start": "127.1058,37.3595", "goal": "127.1086,37.3614"}
    headers = {"x-ncp-apigw-api-key-id": cid, "x-ncp-apigw-api-key": sec}
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(url, params=params, headers=headers, timeout=5.0)
            if resp.status_code == 200:
                return f"[OK] Success (Status: {resp.status_code})"
            else:
                return f"[FAIL] Error (Status: {resp.status_code}, Body: {resp.text[:100]})"
        except Exception as e:
            return f"[ERROR] Failed: {str(e)}"

async def run_all():
    print("=== API Connectivity Diagnostic ===")
    results = await asyncio.gather(
        test_gemini(),
        test_hira(),
        test_egen(),
        test_naver()
    )
    print(f"1. Gemini API: {results[0]}")
    print(f"2. HIRA API:   {results[1]}")
    print(f"3. E-Gen API:  {results[2]}")
    print(f"4. Naver Maps: {results[3]}")
    print("===================================")

if __name__ == "__main__":
    asyncio.run(run_all())
