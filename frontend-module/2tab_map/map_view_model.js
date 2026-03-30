/**
 * @module MapViewModel
 * @description 1번 탭(지도)의 핵심 비즈니스 로직 및 렌더링 조율 전담.
 * MapViewAdapter(또는 MapAdapter)와 연동하여 동작합니다.
 */
class MapViewModel {
    constructor() {
        // MapViewAdapter는 map_adapter.js에 정의되어 활성화됩니다.
        this.adapter = new MapViewAdapter('map');
        this.map = null;
        this.userMarker = null;
        this.currentPolyline = null;
        this.markers = [];
        this.mapType = 'naver';
        this.state = { center: { lat: 37.5665, lng: 126.9780 }, zoom: 15 };
        this.initRetryCount = 0;
        
        window.addEventListener('map-auth-fail', () => {
            console.warn("[MapVM] Map auth failed. Using Leaflet fallback...");
            this.fallback();
        });
    }

    async init() {
        const container = document.getElementById('map');
        console.log(`[MapVM] initializing Container height: ${container?.clientHeight}px`);
        if (!container || container.clientHeight === 0) {
            if (this.initRetryCount < 10) {
                this.initRetryCount++;
                return setTimeout(() => this.init(), 600);
            } else {
                console.warn("[MapVM] Container still height 0 after 10 retried. Forcing Fallback.");
                this.fallback();
                return;
            }
        }
        this.initRetryCount = 0;

        // Naver SDK 가용성 체크
        this.mapType = (window.naver && window.naver.maps) ? 'naver' : 'leaflet';
        
        const result = await this.adapter.init(this.mapType, this.state.center);
        if (result) {
            this.map = result.map;
            this.userMarker = result.marker;
            this.bindEvents();
        }
    }

    bindEvents() {
        // [RECOVERED] Search interaction
        const mapSearch = document.getElementById('map-search-input');
        if (mapSearch) mapSearch.onkeydown = (e) => { if (e.key === 'Enter') this.searchHospitals(e.target.value); };

        document.querySelectorAll('.map-chip').forEach(chip => {
            chip.onclick = () => { if (chip.getAttribute('data-keyword')) this.searchHospitals(chip.getAttribute('data-keyword')); };
        });
        
        // Recenter Btn with Loading State
        const recenterBtn = document.getElementById('recenter-btn');
        if (recenterBtn) {
            recenterBtn.onclick = async () => {
                const original = recenterBtn.innerHTML;
                recenterBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
                // Trigger global location update
                if (window.app && window.app.startLocationTracking) await window.app.startLocationTracking();
                this.recenter();
                setTimeout(() => recenterBtn.innerHTML = original, 1000);
            };
        }
    }

    updateUserLocation(loc) {
        this.state.center = loc;
        if (this.mapType === 'naver' && this.userMarker) this.userMarker.setPosition(new naver.maps.LatLng(loc.lat, loc.lng));
        else if (this.userMarker) this.userMarker.setLatLng([loc.lat, loc.lng]);
    }

    recenter() {
        if (this.mapType === 'naver' && this.map) this.map.setCenter(new naver.maps.LatLng(this.state.center.lat, this.state.center.lng));
        else if (this.map) this.map.setView([this.state.center.lat, this.state.center.lng], this.state.zoom);
    }

    onActivate() {
        // [CRITICAL] Ensures map occupies full slot on tab reveal
        if (this.mapType === 'naver' && this.map) {
            this.map.autoResize();
            this.map.setCenter(new naver.maps.LatLng(this.state.center.lat, this.state.center.lng));
        } else if (this.map) {
            this.map.invalidateSize();
        }
    }

    async searchHospitals(keyword) {
        if (!keyword) return;
        try {
            const resp = await fetch(`/hospitals?lat=${this.state.center.lat}&lng=${this.state.center.lng}&query=${encodeURIComponent(keyword)}`);
            const hospitals = await resp.json();
            // Clear Prev
            if (this.mapType === 'naver') this.markers.forEach(m => m.setMap(null));
            else this.markers.forEach(m => this.map.removeLayer(m));
            
            // Render Via Adapter
            this.markers = this.adapter.renderMarkers(this.map, hospitals, this.mapType);
        } catch (e) { console.error("[MapViewModel] Hospital search failed", e); }
    }

    async drawRoute(dest) {
        try {
            if (this.currentPolyline) {
                if (this.mapType === 'naver') this.currentPolyline.setMap(null);
                else this.map.removeLayer(this.currentPolyline);
            }
            const url = `/map-proxy/route?start=${this.state.center.lng},${this.state.center.lat}&goal=${dest.lng},${dest.lat}`;
            const resp = await fetch(url);
            const data = await resp.json();
            if (data.route && data.route.trafast) {
                const path = data.route.trafast[0].path;
                const coords = path.map(p => this.mapType === 'naver' ? new naver.maps.LatLng(p[1], p[0]) : [p[1], p[0]]);
                this.currentPolyline = this.adapter.renderRoute(this.map, coords, this.mapType);
            }
        } catch (e) { console.error("[MapViewModel] Route failed", e); }
    }

    fallback() {
        this.mapType = 'leaflet';
        const container = document.getElementById('map');
        if (container) { 
            container.innerHTML = ''; 
            if (container._leaflet_id) delete container._leaflet_id; 
        }
        this.init();
    }
}

window.MapViewModel = MapViewModel;
