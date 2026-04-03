import httpx
import os
import xml.etree.ElementTree as ET
import math

# 공식 문서 기준 엔드포인트
NAVER_DIRECTIONS_URL = "https://maps.apigw.ntruss.com/map-direction/v1/driving"
EGEN_API_URL = "http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire"

class MapService:
    @staticmethod
    def haversine(lat1, lon1, lat2, lon2):
        R = 6371  # 지구 반지름 (km)
        dLat = math.radians(lat2 - lat1)
        dLon = math.radians(lon2 - lon1)
        a = math.sin(dLat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dLon / 2) ** 2
        c = 2 * math.asin(math.sqrt(a))
        return R * c

    @staticmethod
    async def get_route(startLats: float, startLngs: float, endLats: float, endLngs: float):
        client_id = os.getenv("NAVER_MAP_CLIENT_ID")
        client_secret = os.getenv("NAVER_MAP_CLIENT_SECRET")
        
        if not client_id or not client_secret:
            return {"error": "Naver Maps API keys missing"}
            
        params = {
            "start": f"{startLngs},{startLats}",
            "goal": f"{endLngs},{endLats}",
            "option": "trafast"
        }
        # 공식 문서 권장: 소문자 헤더
        headers = {
            "x-ncp-apigw-api-key-id": client_id,
            "x-ncp-apigw-api-key": client_secret
        }
        
        async with httpx.AsyncClient() as client:
            resp = await client.get(NAVER_DIRECTIONS_URL, params=params, headers=headers)
            res_data = resp.json()
            
            if resp.status_code == 200 and res_data.get("code") == 0:
                # Directions 5 응답 평탄화 (Frontend 호환)
                route = res_data.get("route", {})
                option_key = params["option"]
                
                if option_key in route and len(route[option_key]) > 0:
                    path = route[option_key][0].get("path", [])
                    raw_summary = route[option_key][0].get("summary", {})
                    # Flatten summary for frontend convenience
                    summary = {
                        "distance": raw_summary.get("distance", 0), # meters
                        "duration": raw_summary.get("duration", 0), # milliseconds
                        "departureTime": raw_summary.get("departureTime"),
                        "bbox": raw_summary.get("bbox") # [minLng, minLat, maxLng, maxLat] for camera fit
                    }
                    return {"path": path, "summary": summary}
                
                return {"error": "Path not found in route response", "raw": res_data}
            else:
                return {
                    "error": "Naver API Auth or Permission Denied",
                    "status": resp.status_code,
                    "code": res_data.get("code"),
                    "message": res_data.get("message")
                }

    @staticmethod
    async def get_emergency_beds(egen_key: str):
        # 실시간 응급실 가용 병상 정보 조회
        if not egen_key or "your_" in egen_key:
            return {}
            
        params = {"serviceKey": egen_key, "numOfRows": 100}
        async with httpx.AsyncClient() as client:
            er_resp = await client.get(EGEN_API_URL, params=params, timeout=5.0)
            if er_resp.status_code == 200:
                try:
                    root = ET.fromstring(er_resp.content)
                    er_data = {}
                    for er_item in root.findall(".//item"):
                        name = er_item.findtext("dutyName")
                        hvec = er_item.findtext("hvec")
                        if name:
                            er_data[name] = hvec
                    return er_data
                except:
                    return {}
        return {}
