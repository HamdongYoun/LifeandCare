import os
import httpx
from dotenv import load_dotenv
import asyncio

load_dotenv(os.path.join("..", "backend", ".env"))

async def debug_hira():
    key = os.getenv("HIRA_API_KEY")
    url = "http://apis.data.go.kr/B551182/hospInfoServicev2/getHospBasisList"
    params = {"serviceKey": key, "numOfRows": 1, "_type": "json"}
    print(f"HIRA Key: {key[:5]}...{key[-5:]}")
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(url, params=params, timeout=5.0)
            print(f"HIRA Status: {resp.status_code}")
            print(f"HIRA Body: {resp.text[:500]}")
        except Exception as e:
            print(f"HIRA Exception: {e}")

async def debug_naver():
    cid = os.getenv("NAVER_MAP_CLIENT_ID")
    sec = os.getenv("NAVER_MAP_CLIENT_SECRET")
    url = "https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving"
    params = {"start": "127.1058,37.3595", "goal": "127.1086,37.3614"}
    headers = {"X-NCP-APIGW-API-KEY-ID": cid, "X-NCP-APIGW-API-KEY": sec}
    print(f"Naver CID: {cid}, Secret: {sec[:3]}...{sec[-3:]}")
    async with httpx.AsyncClient() as client:
        try:
            resp = await client.get(url, params=params, headers=headers, timeout=5.0)
            print(f"Naver Status: {resp.status_code}")
            print(f"Naver Body: {resp.text}")
        except Exception as e:
            print(f"Naver Exception: {e}")

asyncio.run(debug_hira())
asyncio.run(debug_naver())
