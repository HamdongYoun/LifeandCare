from fastapi import APIRouter
import os
import httpx
import asyncio
from typing import List
from .models import MapHospitalResponse
from .service import MapService

router = APIRouter()

@router.get("/hospitals")
async def get_hospitals(lat: float, lng: float, query: str = None):
    # HIRA API (병원 조회) + E-Gen (실시간 응급실) 결합
    hira_key = os.getenv("HIRA_API_KEY")
    egen_key = os.getenv("EGEN_API_KEY")
    
    if not hira_key or "your_" in hira_key:
        return []

    # 1. HIRA 주변 병원 검색
    url = "http://apis.data.go.kr/B551182/hospInfoServicev2/getHospBasisList"
    params = {
        "serviceKey": hira_key, "xPos": lng, "yPos": lat,
        "radius": 3000, "numOfRows": 15, "_type": "json"
    }
    
    result = []
    async with httpx.AsyncClient() as client:
        # 병렬 조회를 위한 E-Gen 호출 (MapService 활용)
        er_data_task = MapService.get_emergency_beds(egen_key)
        hira_resp_task = client.get(url, params=params, timeout=5.0)
        
        # 병렬 처리
        er_data, hira_resp = await asyncio.gather(er_data_task, hira_resp_task)

        if hira_resp.status_code == 200:
            hira_json = hira_resp.json()
            items = hira_json.get("response", {}).get("body", {}).get("items", {}).get("item", [])
            if isinstance(items, dict): items = [items]
            
            for item in items:
                h_lat = float(item.get("YPos", 0))
                h_lng = float(item.get("XPos", 0))
                name = item.get("yadmNm")
                
                # [OPTIONAL] Client-side Query Filtering
                if query and query not in name and query not in item.get("addr", ""):
                    continue

                result.append({
                    "name": name, "lat": h_lat, "lng": h_lng,
                    "addr": item.get("addr"), "tel": item.get("telno"),
                    "dist_value": MapService.haversine(lat, lng, h_lat, h_lng),
                    "er_beds": er_data.get(name, "정보 없음")
                })
                
    return sorted(result, key=lambda x: x["dist_value"])

@router.get("/route")
async def get_route(startLats: float, startLngs: float, endLats: float, endLngs: float):
    return await MapService.get_route(startLats, startLngs, endLats, endLngs)
