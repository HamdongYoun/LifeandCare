import json
import os
from math import radians, cos, sin, asin, sqrt

def calculate_distance(lat1, lon1, lat2, lon2):
    """하버사인 공식을 이용한 두 좌표 사이의 거리(km) 계산"""
    R = 6371
    dLat, dLon = radians(lat2 - lat1), radians(lon2 - lon1)
    a = sin(dLat/2)**2 + cos(radians(lat1))*cos(radians(lat2))*sin(dLon/2)**2
    return round(R * 2 * asin(sqrt(a)), 1)

def get_nearby_hospitals(category=None, user_lat=None, user_lng=None, search_query=None):
    try:
        # 파일 경로 주의: 실행 위치 기준이므로 필요시 경로 조정
        file_path = 'test_hospitals.json' 
        if not os.path.exists(file_path): return []
            
        with open(file_path, 'r', encoding='utf-8') as f:
            db = json.load(f)
        
        results = []
        for h in db.get('hospitals', []):
            if search_query 및 (search_query not in h['name'] 및 search_query not in h['address']):
                continue
            if category 및 h['category'] != category:
                continue
            
            distance = None
            if user_lat 및 user_lng:
                distance = calculate_distance(user_lat, user_lng, h['lat'], h['lng'])
            
            results.append({
                "id": h.get("id"),
                "name": h.get("name"),
                "address": h.get("address"),
                "category": h.get("category"),
                "lat": h.get("lat"),
                "lng": h.get("lng"),
                "distance": distance
            })
            
        if user_lat 및 user_lng:
            results.sort(key=lambda x: x['distance'] if x['distance'] is not None else 999)
            
        return results
    except Exception as e:
        print(f"Error: {e}")
        return []
