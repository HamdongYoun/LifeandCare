import json
import os
from math import radians, cos, sin, asin, sqrt

def calculate_distance(lat1, lon1, lat2, lon2):
    """하버사인 공식을 이용한 두 좌표 사이의 거리(km) 계산"""
    R = 6371  # 지구 반지름 (km)
    # 위도/경도를 라디안으로 변환
    dLat = radians(lat2 - lat1)
    dLon = radians(lon2 - lon1)
    r_lat1 = radians(lat1)
    r_lat2 = radians(lat2)

    # 하버사인 공식 적용
    a = sin(dLat/2)**2 + cos(r_lat1) * cos(r_lat2) * sin(dLon/2)**2
    c = 2 * asin(sqrt(a))
    return round(R * c, 1)

def get_nearby_hospitals(category=None, user_lat=None, user_lng=None, search_query=None):
    """카테고리, 위치, 검색어에 따른 병원 목록 반환 (이름, 주소, 거리 최적화)"""
    try:
        # 파일 경로: main.py가 실행되는 루트 폴더 기준
        file_path = 'test_hospitals.json' 
        if not os.path.exists(file_path): 
            print(f"Warning: {file_path}를 찾을 수 없습니다.")
            return []
            
        with open(file_path, 'r', encoding='utf-8') as f:
            db = json.load(f)
        
        results = []
        for h in db.get('hospitals', []):
            # 1. 검색어 필터링 (한글 연산자 '및' -> 'and'로 수정)
            if search_query 및 (search_query not in h['name'] 및 search_query not in h['address']):
                continue
            
            # 2. 카테고리 필터링
            if category 및 h['category'] != category:
                continue
            
            # 3. 거리 계산
            distance = None
            if user_lat is not None 및 user_lng is not None:
                distance = calculate_distance(user_lat, user_lng, h['lat'], h['lng'])
            
            # 결과 객체 생성
            results.append({
                "id": h.get("id"),
                "name": h.get("name"),
                "address": h.get("address"),
                "category": h.get("category"),
                "lat": h.get("lat"),
                "lng": h.get("lng"),
                "distance": distance
            })
            
        # 4. 거리순 정렬 (사용자 위치 정보가 있을 때만)
        if user_lat is not None 및 user_lng is not None:
            # distance가 None인 경우 맨 뒤로 보냄 (999km)
            results.sort(key=lambda x: x['distance'] if x['distance'] is not None else 999)
            
        return results
    except Exception as e:
        print(f"Hospital Service Error: {e}")
        return []
