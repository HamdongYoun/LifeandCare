import os
import httpx
from dotenv import load_dotenv
import asyncio

load_dotenv(os.path.join("..", "backend", ".env"))

async def test_egen():
    key = os.getenv("HIRA_API_KEY")
    url = "http://apis.data.go.kr/B552657/HsptlAsembySearchService/getEmrrmRltmUsefulSckbdInfoInqire"
    params = {"serviceKey": key, "numOfRows": 1}
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(url, params=params, timeout=5.0)
            if resp.status_code == 200 and "SERVICE ERROR" not in resp.text:
                print(f"[OK] HIRA Key works for E-Gen!")
            else:
                print(f"[FAIL] HIRA Key does not work for E-Gen. Body: {resp.text[:200]}")
        except Exception as e:
            print(f"[ERROR] E-Gen Exception: {e}")

asyncio.run(test_egen())
