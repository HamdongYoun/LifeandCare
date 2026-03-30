# Technical Specification: Location & Map Service

This document describes the implementation details of the location tracking and hospital mapping service in the Life & Care application.

## 1. Geolocation Logic (Frontend)

The application uses the browser's native `navigator.geolocation` API to identify the user's current coordinates.

### Implementation Detail
- **Method**: `navigator.geolocation.getCurrentPosition`
- **Synchronization**: Wrapped in a `Promise` with a 5-second timeout to ensure coordinates are available before API calls (Chat or Hospital Search).
- **Fallback**: If location access is denied or times out, the system defaults to Seoul City Hall coordinates (`37.5665, 126.9780`).
- **UI Interaction**: A "Current Location" (현재위치) button is provided on the map tab to force-refresh and re-center the view.

## 2. Map Rendering Engine

Due to `X-Frame-Options` restrictions on commercial map providers like Naver/Kakao, the application uses **Leaflet.js** for embedded map display.

### Components
- **Library**: [Leaflet.js](https://leafletjs.com/) (v1.9.4)
- **Tile Provider**: OpenStreetMap (Standard Layer)
- **Markers**: Dynamic markers generated from backend hospital data.
- **Auto-Fit**: `map.fitBounds()` is called after fetching hospitals to ensure all results are visible in the viewport.

## 3. Hospital Search API (Backend)

The server acts as a proxy for the Health Insurance Review and Assessment Service (HIRA) API.

### Endpoint: `GET /hospitals`
- **Parameters**:
  - `lat` (float): User's latitude.
  - `lng` (float): User's longitude.
  - `query` (string, optional): Search keyword (e.g., clinic type).
- **External API**: `http://apis.data.go.kr/B551182/hospInfoServicev2/getHospBasisList`
- **Processing**:
  - Distance calculation is handled by the HIRA server based on the `xPos` and `yPos` parameters.
  - XML/JSON response from HIRA is normalized into a standard JSON format for the frontend.

## 4. Navigation Handover

For detailed turn-by-turn navigation, the app provides a "Handover" link.
- **Target**: Naver Maps Mobile Search.
- **URL Pattern**: `https://m.map.naver.com/search2/search.naver?query={keyword}`
- **Security**: Opened in a new browser tab (`_blank`) to comply with security headers.
