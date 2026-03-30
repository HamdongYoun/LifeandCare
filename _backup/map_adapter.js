/**
 * MapAdapter - Naver & Leaflet Unified Mapping Layer
 * Implementation for recovery from '복구할로직.md'
 */
class MapAdapter {
    /**
     * @constructor
     * MapState initialization (Markers, Polylines)
     */
    constructor() {
        this.map = null;
        this.naverMap = null;
        this.mapType = 'leaflet';
        this.markers = [];
        this.naverMarkers = [];
        this.currentPolyline = null;
        this.userMarker = null;
    }

    /**
     * @param {string} containerId - DOM ID for map
     * @param {object} initialLoc - {lat, lng} coordinates
     * @returns {Promise<void>}
     */
    async init(containerId, initialLoc) {
        const container = document.getElementById(containerId);
        if (!container) return;

        if (window.naver && window.naver.maps) {
            this.mapType = 'naver';
            this.naverMap = new naver.maps.Map(container, {
                center: new naver.maps.LatLng(initialLoc.lat, initialLoc.lng),
                zoom: 15
            });
            this.userMarker = new naver.maps.Marker({
                position: new naver.maps.LatLng(initialLoc.lat, initialLoc.lng),
                map: this.naverMap,
                icon: { content: '<div class="user-pulse"></div>', anchor: new naver.maps.Point(10, 10) }
            });
        } else {
            this.mapType = 'leaflet';
            this.map = L.map(container, { zoomControl: false, attributionControl: false })
                .setView([initialLoc.lat, initialLoc.lng], 15);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(this.map);
            this.userMarker = L.circleMarker([initialLoc.lat, initialLoc.lng], {
                radius: 8, fillColor: "#007AFF", color: "#fff", weight: 3
            }).addTo(this.map);
        }
    }

    /**
     * @param {string} keyword - Search term (e.g. '내과')
     * @param {object} loc - {lat, lng}
     * @returns {Promise<Array>} - List of detected hospitals
     */
    async searchHospitals(keyword, loc) {
        if (!keyword) return [];
        try {
            const response = await fetch(`/hospitals?lat=${loc.lat}&lng=${loc.lng}&query=${encodeURIComponent(keyword)}`);
            if (!response.ok) throw new Error("Hospital API Error");
            const hospitals = await response.json();
            this.renderMarkers(hospitals);
            return hospitals;
        } catch (e) {
            console.error("[MapAdapter] Search failed:", e);
            throw e;
        }
    }

    /**
     * @param {Array} hospitals - List of hospital objects
     */
    renderMarkers(hospitals) {
        if (this.mapType === 'naver') {
            this.naverMarkers.forEach(m => m.setMap(null));
            this.naverMarkers = [];
            const bounds = new naver.maps.LatLngBounds();
            hospitals.forEach(h => {
                const marker = new naver.maps.Marker({
                    position: new naver.maps.LatLng(h.lat, h.lng),
                    map: this.naverMap,
                    icon: {
                        content: `<div class="map-marker-label">${h.name}</div>`,
                        anchor: new naver.maps.Point(40, 20)
                    }
                });
                this.naverMarkers.push(marker);
                bounds.extend(new naver.maps.LatLng(h.lat, h.lng));
            });
            if (hospitals.length > 0) this.naverMap.panToBounds(bounds);
        } else if (this.map) {
            this.markers.forEach(m => this.map.removeLayer(m));
            this.markers = [];
            const bounds = [];
            hospitals.forEach(h => {
                const marker = L.marker([h.lat, h.lng]).addTo(this.map)
                    .bindPopup(`<b>${h.name}</b><br><button onclick="window.app.drawRoute(${h.lat}, ${h.lng})">길찾기</button>`);
                this.markers.push(marker);
                bounds.push([h.lat, h.lng]);
            });
            if (bounds.length > 0) this.map.fitBounds(bounds);
        }
    }

    /**
     * @param {object} start - {lat, lng} current location
     * @param {object} end - {lat, lng} destination location
     * @returns {Promise<void>}
     */
    async drawRoute(start, end) {
        if (this.currentPolyline) {
            if (this.mapType === 'naver') this.currentPolyline.setMap(null);
            else this.map.removeLayer(this.currentPolyline);
        }
        try {
            const url = `/map-proxy/route?start=${start.lng},${start.lat}&goal=${end.lng},${end.lat}`;
            const resp = await fetch(url);
            const data = await resp.json();
            if (data.route && data.route.trafast) {
                const path = data.route.trafast[0].path;
                const coords = path.map(p => this.mapType === 'naver' ? new naver.maps.LatLng(p[1], p[0]) : [p[1], p[0]]);
                if (this.mapType === 'naver') {
                    this.currentPolyline = new naver.maps.Polyline({
                        map: this.naverMap, path: coords, strokeColor: '#007AFF', strokeWeight: 6, strokeOpacity: 0.8
                    });
                    this.naverMap.panToBounds(this.currentPolyline.getBounds());
                } else {
                    this.currentPolyline = L.polyline(coords, { color: '#007AFF', weight: 6, opacity: 0.8 }).addTo(this.map);
                    this.map.fitBounds(this.currentPolyline.getBounds());
                }
            }
        } catch (e) {
            console.error("Route tracing failed", e);
            throw new Error("RoutingException: External API mismatch or timeout.");
        }
    }

    /**
     * @param {object} loc - New {lat, lng}
     */
    updateUserMarker(loc) {
        if (this.mapType === 'naver' && this.userMarker) {
            this.userMarker.setPosition(new naver.maps.LatLng(loc.lat, loc.lng));
        } else if (this.userMarker) {
            this.userMarker.setLatLng([loc.lat, loc.lng]);
        }
    }
}

window.MapAdapter = MapAdapter;
