from pydantic import BaseModel
from typing import List, Optional

class HospitalResponse(BaseModel):
    id: str
    name: str
    address: str
    category: str
    lat: float
    lng: float
    distance: Optional[float] = None

class HospitalListResponse(BaseModel):
    count: int
    hospitals: List[HospitalResponse]
