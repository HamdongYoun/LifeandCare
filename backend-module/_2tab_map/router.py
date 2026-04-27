from fastapi import APIRouter, HTTPException
from typing import Optional
from .models import HospitalListResponse
from .service import get_nearby_hospitals

router = APIRouter()

@router.get("/hospitals", response_model=HospitalListResponse)
async def hospitals_endpoint(
    category: Optional[str] = None, 
    lat: Optional[float] = None, 
    lng: Optional[float] = None,
    query: Optional[str] = None
):
    try:
        results = get_nearby_hospitals(category, lat, lng, query)
        return {"count": len(results), "hospitals": results}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
