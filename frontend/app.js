/**
 * LifeCareApp - Central Management for Life & Care Platform
 * Handles Tab navigation, Chat logic, and Naver/Leaflet Map integration.
 */
class LifeCareApp {
    constructor() {
        // --- DOM Elements ---
        this.chatHistory = document.getElementById('chat-history');
        this.userInput = document.getElementById('user-input');
        this.sendBtn = document.getElementById('send-btn');
        this.navItems = document.querySelectorAll('.nav-item');
        this.tabs = document.querySelectorAll('.tab-content');
        this.mapSearchInput = document.getElementById('map-search-input');
        this.recenterBtn = document.getElementById('recenter-btn');
        this.mapLinkBtn = document.getElementById('map-link-btn');

        // Drawer
        this.historyDrawer = document.getElementById('history-drawer');
        this.historyOverlay = document.getElementById('drawer-overlay');
        this.historyMenuBtn = document.getElementById('history-menu-btn');
        this.closeDrawerBtn = document.getElementById('close-drawer-btn');

        // Status Indicators (Settings)
        this.locStatusDot = document.getElementById('location-status-indicator');
        this.locStatusText = document.getElementById('location-status-text');

        // --- State ---
        this.map = null;
        this.naverMap = null;
        this.mapType = 'leaflet';
        this.markers = [];
        this.naverMarkers = [];
        this.userMarker = null;
        this.currentPolyline = null;
        this.messageHistory = [];
        this.userLocation = { lat: 37.5665, lng: 126.9780 };
        this.isLocationFixed = false;
        this.lastPosId = null;
        this.isInitializing = false; // Flag to prevent multiple init calls

        // --- Init ---
        this.init();
    }

    async init() {
        console.log("LifeCareApp Initializing...");
        await this.loadMapConfig();
        this.bindEvents();
        this.updateLocation(); // Initial location fetch

        // Shared interface for modules
        window.messageHistory = this.messageHistory;
        window.clearSession = () => this.clearChat();
        window.drawRoute = (lat, lng) => this.drawRoute(lat, lng);
        window.searchMap = (keyword) => this.searchMap(keyword);
    }

    bindEvents() {
        // Tab Navigation
        this.navItems.forEach(item => {
            item.addEventListener('click', () => this.switchTab(item.getAttribute('data-tab')));
        });

        // Chat
        this.sendBtn.addEventListener('click', () => this.sendMessage());
        this.userInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                this.sendMessage();
            }
        });
        this.userInput.addEventListener('input', (e) => {
            e.target.style.height = 'auto';
            e.target.style.height = Math.min(e.target.scrollHeight, 100) + 'px';
        });

        // Map Search (Restored lost logic)
        if (this.mapSearchInput) {
            this.mapSearchInput.addEventListener('keydown', (e) => {
                if (e.key === 'Enter') {
                    this.searchMap(e.target.value);
                }
            });
        }

        // Map Category Chips
        document.querySelectorAll('.map-chip').forEach(chip => {
            chip.addEventListener('click', () => {
                const keyword = chip.getAttribute('data-keyword');
                if (keyword) this.searchMap(keyword);
            });
        });

        // Recenter
        if (this.recenterBtn) {
            this.recenterBtn.onclick = async () => {
                this.recenterBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> 위치확인...';
                await this.updateLocation();
                this.recenterBtn.innerHTML = '<i class="fa-solid fa-crosshairs"></i> 현재위치';
                this.recenterMap();
            };
        }

        // Drawer
        if (this.historyMenuBtn) this.historyMenuBtn.onclick = () => this.toggleDrawer(true);
        if (this.closeDrawerBtn) this.closeDrawerBtn.onclick = () => this.toggleDrawer(false);
        if (this.historyOverlay) this.historyOverlay.onclick = () => this.toggleDrawer(false);
    }

    // --- Tab / UI Logic ---
    switchTab(targetTab, keyword = '') {
        this.navItems.forEach(i => {
            const isActive = i.getAttribute('data-tab') === targetTab;
            i.classList.toggle('active', isActive);
        });

        this.tabs.forEach(tab => {
            const isActive = tab.id === `tab-${targetTab}`;
            tab.classList.toggle('active', isActive);
        });

        if (targetTab === 'map') {
            if (keyword) {
                // If a keyword is provided (e.g. from AI), initialize and search
                this.initMap();
                setTimeout(() => this.searchMap(keyword), 500);
            } else {
                this.initMap();
            }
        } else if (targetTab === 'settings') {
            this.updateLocationUI(this.isLocationFixed);
        }
    }

    toggleDrawer(open) {
        this.historyDrawer.classList.toggle('open', open);
        this.historyOverlay.classList.toggle('visible', open);
        if (open && window.healthModule) {
            window.healthModule.renderNoteList();
        }
    }

    clearChat() {
        this.messageHistory.length = 0;
        this.chatHistory.innerHTML = '';
        localStorage.removeItem('healthReport'); // RESTORED: Sync cache reset
        if (window.healthModule) {
            window.healthModule.reportContent.innerHTML = `
                <button id="refresh-report-btn" class="refresh-btn" title="리포트 갱신">
                    <i class="fa-solid fa-arrows-rotate"></i>
                </button>최근 상담 내역이 없습니다. 증상을 먼저 말씀해주세요.최근 상담을 기반으로 AI 건강 리포트가 생성됩니다.
            `;
        }
    }


    // --- Map Logic ---
    async loadMapConfig() {
        // SDK is now loaded directly in main.html <script> tag (official Naver recommended approach)
        // No dynamic injection needed - just check if it loaded successfully
        if (window.naver && window.naver.maps) {
            this.mapType = 'naver';
            console.log('[Naver Maps] SDK ready via static HTML tag.');
        } else {
            // Naver failed to load (auth error etc.) - fall back to Leaflet
            console.warn('[Naver Maps] SDK not available, falling back to Leaflet.');
            this.mapType = 'leaflet';
        }
    }


    initMap() {
        const container = document.getElementById('map');
        
        // 1. Check if container is ready and visible
        if (!container || container.clientHeight === 0) {
            console.log("[Map] Container not ready, retrying...");
            if (!this.initRetryCount) this.initRetryCount = 0;
            if (this.initRetryCount < 10) {
                this.initRetryCount++;
                setTimeout(() => this.initMap(), 300);
            }
            return;
        }
        this.initRetryCount = 0;

        // 2. Prevent concurrent initialization
        if (this.isInitializing) return;
        
        // 3. Prevent double-init (if already created)
        if (this.mapType === 'naver' && this.naverMap) return;
        if (this.mapType !== 'naver' && this.map) return;

        this.isInitializing = true;
        console.log(`[Map] Initializing ${this.mapType} map...`);

        // Clean up previous state if engine switched
        if (container._leaflet_id) { container.innerHTML = ''; this.map = null; }

        if (this.mapType === 'naver' && window.naver) {
            try {
                this.naverMap = new naver.maps.Map(container, {
                    center: new naver.maps.LatLng(this.userLocation.lat, this.userLocation.lng),
                    zoom: 15,
                    mapDataControl: false,
                    scaleControl: false
                });

                // 1.5초 후 인증 실패 텍스트 감지 (Naver 인증 오류는 보통 즉시 혹은 1초 내에 표시됨)
                setTimeout(() => {
                    const text = container.innerText || "";
                    if (text.includes('인증') || text.includes('Client ID') || text.includes('fail')) {
                        console.warn('[Naver Maps] Auth failed detected → Auto fallback to Leaflet');
                        this.fallbackToLeaflet(container);
                    }
                }, 1500);

                naver.maps.Event.addListener(this.naverMap, 'error', (e) => {
                    console.error("Naver Map Error Event:", e);
                    this.fallbackToLeaflet(container);
                });

                this.userMarker = new naver.maps.Marker({
                    position: new naver.maps.LatLng(this.userLocation.lat, this.userLocation.lng),
                    map: this.naverMap,
                    icon: { content: '<div class="user-pulse"></div>', anchor: new naver.maps.Point(10, 10) }
                });
            } catch (err) {
                console.error("Naver Maps init failed:", err);
                this.fallbackToLeaflet(container);
            }
        } else {
            this.map = L.map(container, { zoomControl: false, attributionControl: false })
                .setView([this.userLocation.lat, this.userLocation.lng], 15);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(this.map);
            this.userMarker = L.circleMarker([this.userLocation.lat, this.userLocation.lng], {
                radius: 8, fillColor: "#007AFF", color: "#fff", weight: 3, opacity: 1, fillOpacity: 1
            }).addTo(this.map);
        }
        
        this.isInitializing = false;
    }

    fallbackToLeaflet(container) {
        console.warn("Falling back to Leaflet engine.");
        this.naverMap = null;
        this.mapType = 'leaflet';
        container.innerHTML = '';
        delete container._leaflet_id;
        this.isInitializing = false;
        this.initMap();
    }

    recenterMap() {
        if (this.mapType === 'naver' && this.naverMap) {
            this.naverMap.setCenter(new naver.maps.LatLng(this.userLocation.lat, this.userLocation.lng));
            if (this.userMarker) this.userMarker.setPosition(new naver.maps.LatLng(this.userLocation.lat, this.userLocation.lng));
        } else if (this.map) {
            this.map.setView([this.userLocation.lat, this.userLocation.lng], 15);
            if (this.userMarker) this.userMarker.setLatLng([this.userLocation.lat, this.userLocation.lng]);
        }
    }

    async searchMap(keyword) {
        if (!keyword) return;

        // Update Chips UI
        document.querySelectorAll('.map-chip').forEach(chip => {
            chip.classList.toggle('active', chip.innerText.includes(keyword));
        });

        this.initMap();
        if (this.mapLinkBtn) this.mapLinkBtn.href = `https://m.map.naver.com/search2/search.naver?query=${encodeURIComponent(keyword)}`;

        try {
            const response = await fetch(`/hospitals?lat=${this.userLocation.lat}&lng=${this.userLocation.lng}&query=${encodeURIComponent(keyword)}`);
            const hospitals = await response.json();
            this.renderMarkers(hospitals);
        } catch (e) { console.error("Search failed:", e); }
    }

    renderMarkers(hospitals) {
        if (this.mapType === 'naver' && this.naverMap) {
            this.naverMarkers.forEach(m => m.setMap(null));
            this.naverMarkers = [];
            const bounds = new naver.maps.LatLngBounds();
            hospitals.forEach(h => {
                const marker = new naver.maps.Marker({
                    position: new naver.maps.LatLng(h.lat, h.lng),
                    map: this.naverMap,
                    icon: {
                        content: `<div style="background:white; padding:5px 12px; border-radius:20px; border:1px solid var(--primary); font-weight:bold; font-size:11px; box-shadow:var(--shadow); color:var(--primary);">${h.name}</div>`,
                        anchor: new naver.maps.Point(40, 20)
                    }
                });
                naver.maps.Event.addListener(marker, 'click', () => this.showInfoWindow(h, marker));
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
                    .bindPopup(`${h.name}<br><button onclick="window.drawRoute(${h.lat}, ${h.lng})">길찾기</button>`);
                this.markers.push(marker);
                bounds.push([h.lat, h.lng]);
            });
            if (bounds.length > 0) this.map.fitBounds(bounds);
        }
    }

    showInfoWindow(h, marker) {
        const infoWindow = new naver.maps.InfoWindow({
            content: `<div style="padding:10px; font-size:0.8rem;">
                <strong>${h.name}</strong><br>${h.addr}<br>
                <button onclick="window.drawRoute(${h.lat}, ${h.lng})" style="width:100%; padding:6px; margin-top:8px; background:var(--primary); color:white; border:none; border-radius:4px;">길찾기</button>
            </div>`
        });
        infoWindow.open(this.naverMap, marker);
    }

    async drawRoute(destLat, destLng) {
        if (this.currentPolyline) {
            if (this.mapType === 'naver') this.currentPolyline.setMap(null);
            else this.map.removeLayer(this.currentPolyline);
        }

        try {
            const url = `/route?startLats=${this.userLocation.lat}&startLngs=${this.userLocation.lng}&endLats=${destLat}&endLngs=${destLng}`;
            const resp = await fetch(url);
            const data = await resp.json();

            if (data.path) {
                const coords = data.path.map(p => this.mapType === 'naver' ? new naver.maps.LatLng(p[1], p[0]) : [p[1], p[0]]);
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
        } catch (e) { alert("경로 탐색 실패"); }
    }

    // --- Chat Logic ---
    async sendMessage() {
        const message = this.userInput.value.trim();
        if (!message) return;

        this.addMessageUI(message, 'user');
        this.messageHistory.push(`사용자: ${message}`);
        this.userInput.value = '';
        this.userInput.style.height = 'auto';

        try {
            const loadingId = 'loading-' + Date.now();
            this.chatHistory.innerHTML += `<div id="${loadingId}" class="msg bot loading"><div class="dots"><span></span><span></span><span></span></div></div>`;
            this.chatHistory.scrollTop = this.chatHistory.scrollHeight;

            await this.updateLocation();

            const response = await fetch('/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message, lat: this.userLocation.lat, lng: this.userLocation.lng })
            });

            document.getElementById(loadingId)?.remove();
            const data = await response.json();
            
            // --- NEW: Real-time Status Analysis ---
            let isDanger = false;
            try {
                const summaryResp = await fetch('/summarize', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ user_msg: message, ai_msg: data.content })
                });
                const summaryData = await summaryResp.json();
                isDanger = summaryData.status === "1";
                this.updateHealthStatusUI(isDanger, summaryData.summary);
            } catch (sumErr) { console.warn("Summary failed", sumErr); }

            this.addMessageUI(data.content, 'bot', data.message_type, isDanger);
            this.messageHistory.push(`AI: ${data.content}`);
        } catch (e) { this.addMessageUI('오류가 발생했습니다.', 'error'); }
    }

    updateHealthStatusUI(isDanger, summary) {
        const badge = document.getElementById('health-status-badge');
        if (!badge) return;
        
        if (isDanger) {
            badge.className = 'health-badge danger';
            badge.innerHTML = `<i class="fa-solid fa-triangle-exclamation"></i> <span>위험 (${summary})</span>`;
        } else {
            badge.className = 'health-badge normal';
            badge.innerHTML = `<i class="fa-solid fa-heart"></i> <span>정상</span>`;
        }
    }

    addMessageUI(text, type, subType = '', isDanger = false) {
        const msgDiv = document.createElement('div');
        msgDiv.className = `msg ${type} ${subType} ${isDanger ? 'danger-mode' : ''}`;

        let mainContent = text;

        if (isDanger && type === 'bot') {
            const badge = document.createElement('div');
            badge.className = 'danger-badge';
            badge.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> 긴급 제언';
            msgDiv.appendChild(badge);
        }

        const hospMatch = text.match(/\[HOSPITAL:([^\]]+)\]/);
        if (hospMatch && type === 'bot') {
            const keyword = hospMatch[1];
            mainContent = text.replace(/\[HOSPITAL:[^\]]+\]/g, '').trim();
            setTimeout(() => this.switchTab('map', keyword), 1000);
        }

        mainContent = mainContent.replace(/\[LOCATION:[^\]]+\]/g, '').trim();

        const contentSpan = document.createElement('span');
        contentSpan.innerText = mainContent;
        msgDiv.appendChild(contentSpan);

        this.chatHistory.appendChild(msgDiv);
        this.chatHistory.scrollTop = this.chatHistory.scrollHeight;
    }

    // --- Location Logic ---
    /**
     * Continuous Geolocation Tracking (watchPosition)
     * Keeps the user's location updated in real-time for an 'alive' map experience.
     */
    async updateLocation() {
        if (!navigator.geolocation) {
            this.updateLocationUI(false);
            return;
        }

        const options = { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 };

        // Clear any existing watch to avoid duplicates
        if (this.lastPosId !== null) {
            navigator.geolocation.clearWatch(this.lastPosId);
        }

        this.lastPosId = navigator.geolocation.watchPosition(
            (pos) => {
                this.userLocation.lat = pos.coords.latitude;
                this.userLocation.lng = pos.coords.longitude;
                this.isLocationFixed = true;

                // Update markers on the fly if map is initialized
                if (this.mapType === 'naver' && this.userMarker) {
                    this.userMarker.setPosition(new naver.maps.LatLng(this.userLocation.lat, this.userLocation.lng));
                } else if (this.map && this.userMarker) {
                    this.userMarker.setLatLng([this.userLocation.lat, this.userLocation.lng]);
                }

                this.updateLocationUI(true);
                console.log("Live position updated:", this.userLocation);
            },
            (err) => {
                console.error("Geolocation error:", err);
                this.updateLocationUI(false);
            },
            options
        );
    }

    updateLocationUI(success) {
        if (!this.locStatusDot || !this.locStatusText) return;
        this.locStatusDot.className = `status-dot ${success ? 'green' : 'red'}`;
        this.locStatusText.innerText = success ? '실시간 위치 수신 중' : '위치 접근 불가';
    }
}

// Start the App
window.addEventListener('DOMContentLoaded', () => {
    window.app = new LifeCareApp();
});
