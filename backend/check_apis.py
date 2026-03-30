import os
import httpx
import xml.etree.ElementTree as ET
from dotenv import load_dotenv

load_dotenv()

def test_hira():
    print("--- Testing HIRA API (Hospital Search) ---")
    key = os.getenv("HIRA_API_KEY")
    if not key:
        print("[FAIL] HIRA_API_KEY not found in .env")
        return

    url = "http://apis.data.go.kr/B551182/hospInfoServicev2/getHospBasisList"
    params = {
        "serviceKey": key,
        "xPos": 126.9780,
        "yPos": 37.5665,
        "radius": 1000,
        "_type": "json"
    }
    
    try:
        # Use a fresh client without proxy for direct test
        with httpx.Client() as client:
            resp = client.get(url, params=params, timeout=10.0)
            print(f"Status Code: {resp.status_code}")
            
            if resp.status_code == 200:
                # Common issue: 200 OK but XML error inside (Auth failure)
                content = resp.text
                if "<SERVICE ERROR>" in content or "<error" in content:
                    print(f"[FAIL] API returned an error message: {content}")
                else:
                    print("[SUCCESS] HIRA API seems to be working.")
                    try:
                        data = resp.json()
                        count = data.get("response", {}).get("body", {}).get("totalCount", 0)
                        print(f"Results found: {count}")
                    except:
                        print(f"Data Sample: {content[:100]}...")
            else:
                print(f"[FAIL] HTTP Error: {resp.text}")
    except Exception as e:
        print(f"[ERROR] Exception during HIRA test: {str(e)}")

def test_naver():
    print("\n--- Testing Naver Directions API (Route) ---")
    client_id = os.getenv("NAVER_MAP_CLIENT_ID")
    client_secret = os.getenv("NAVER_MAP_CLIENT_SECRET")
    
    if not client_id or not client_secret:
        print("[FAIL] Naver Map credentials missing in .env")
        return

    url = "https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving"
    params = {
        "start": "126.9780,37.5665",
        "goal": "126.9800,37.5670",
        "option": "trafast"
    }
    headers = {
        "X-NCP-APIGW-API-KEY-ID": client_id,
        "X-NCP-APIGW-API-KEY": client_secret
    }
    
    try:
        with httpx.Client() as client:
            resp = client.get(url, params=params, headers=headers)
            print(f"Status Code: {resp.status_code}")
            if resp.status_code == 200:
                print("[SUCCESS] Naver Directions API is working.")
            else:
                print(f"[FAIL] Naver API Error: {resp.text}")
    except Exception as e:
        print(f"[ERROR] Exception during Naver test: {str(e)}")

if __name__ == "__main__":
    test_hira()
    test_naver()
