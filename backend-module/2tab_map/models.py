from fastapi import APIRouter
from pydantic import BaseModel

class MapHospitalResponse(BaseModel):
    name: str
    lat: float
    lng: float
    addr: str
    tel: str
    dist_value: float
    er_beds: str
