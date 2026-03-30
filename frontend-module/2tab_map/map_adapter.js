/**
 * @module MapViewAdapter
 * @description 지도 엔진(Naver/Leaflet)의 하위 로우레벨 렌더링(마커, 폴리라인, 리사이즈)을 전담함.
 */
class MapViewAdapter {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
    }

    /**
     * @param {string} engine - 'naver' or 'leaflet'
     * @param {object} loc - {lat, lng}
     */
    async init(engine, loc) {
        if (!this.container) return;
        
        if (engine === 'naver') {
            // --- Naver Auth Failure Detection ---
            const authObserver = new MutationObserver(() => {
                if (this.container.innerHTML.includes('인증') || this.container.innerHTML.includes('Authentication')) {
                    console.warn('[Map] Naver Auth failure detected.');
                    authObserver.disconnect();
                    window.dispatchEvent(new CustomEvent('map-auth-fail'));
                }
            });
            authObserver.observe(this.container, { childList: true, subtree: true });
            setTimeout(() => authObserver.disconnect(), 5000);

            const map = new naver.maps.Map(this.container, {
                center: new naver.maps.LatLng(loc.lat, loc.lng),
                zoom: 15,
                mapDataControl: false, scaleControl: false
            });
            const marker = new naver.maps.Marker({
                position: new naver.maps.LatLng(loc.lat, loc.lng),
                map: map,
                icon: { content: '<div class="user-pulse"></div>', anchor: new naver.maps.Point(10, 10) }
            });
            return { map, marker };
        } else {
            const map = L.map(this.container, { zoomControl: false, attributionControl: false })
                .setView([loc.lat, loc.lng], 15);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);
            const marker = L.circleMarker([loc.lat, loc.lng], {
                radius: 8, fillColor: "#007AFF", color: "#fff", weight: 3, opacity: 1, fillOpacity: 1
            }).addTo(map);
            return { map, marker };
        }
    }

    /**
     * @param {object} map 
     * @param {Array} hospitals 
     * @param {string} engine 
     */
    renderMarkers(map, hospitals, engine) {
        const markers = [];
        if (engine === 'naver') {
            const bounds = new naver.maps.LatLngBounds();
            hospitals.forEach(h => {
                const marker = new naver.maps.Marker({
                    position: new naver.maps.LatLng(h.lat, h.lng),
                    map: map,
                    icon: { content: `<div class="map-marker-label">${h.name}</div>`, anchor: new naver.maps.Point(40, 20) }
                });
                markers.push(marker);
                bounds.extend(new naver.maps.LatLng(h.lat, h.lng));
                
                // InfoWindow
                const content = `
                    <div style="padding:10px; font-size:0.8rem; font-family:sans-serif;">
                        <strong>${h.name}</strong><br>${h.addr}<br>
                        <button onclick="window.app.mapVM.drawRoute({lat:${h.lat}, lng:${h.lng}})" 
                            style="width:100%; padding:6px; margin-top:8px; background:var(--primary); color:white; border:none; border-radius:4px;">길찾기</button>
                    </div>`;
                const infoWindow = new naver.maps.InfoWindow({ content });
                naver.maps.Event.addListener(marker, 'click', () => {
                    infoWindow.open(map, marker);
                });
            });
            if (hospitals.length > 0) map.panToBounds(bounds);
        } else {
            const bounds = [];
            hospitals.forEach(h => {
                const marker = L.marker([h.lat, h.lng]).addTo(map)
                    .bindPopup(`<b>${h.name}</b><br>${h.addr}<br><button onclick="window.app.mapVM.drawRoute({lat:${h.lat}, lng:${h.lng}})" style="width:100%; margin-top:5px; background:var(--primary); color:white; border:none; padding:4px; border-radius:4px;">길찾기</button>`);
                markers.push(marker);
                bounds.push([h.lat, h.lng]);
            });
            if (bounds.length > 0) map.fitBounds(bounds);
        }
        return markers;
    }

    renderRoute(map, coords, engine) {
        if (engine === 'naver') {
            const poly = new naver.maps.Polyline({
                map, path: coords, strokeColor: '#007AFF', strokeWeight: 6, strokeOpacity: 0.8
            });
            map.panToBounds(poly.getBounds());
            return poly;
        } else {
            const poly = L.polyline(coords, { color: '#007AFF', weight: 6, opacity: 0.8 }).addTo(map);
            map.fitBounds(poly.getBounds());
            return poly;
        }
    }
}

window.MapViewAdapter = MapViewAdapter;
