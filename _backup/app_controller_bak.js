/**
 * @module LifeCareController
 * @description 전역 애플리케이션 상태 및 탭 내비게이션, 위치 추적을 총괄하는 중앙 컨트롤러.
 * 1tab(지도)과 2tab(상담)의 ViewModel을 조율하며 클린 아키텍처의 의존성 역전 원칙을 준수합니다.
 */
class LifeCareController {
    constructor() {
        this.currentTab = 'chat';
        this.userLocation = { lat: 37.5665, lng: 126.9780 };
        this.lastPosId = null;

        this.mapVM = new MapViewModel();
        this.chatVM = new ChatViewModel('chat-history', 'user-input');
        
        this.isMapInitialized = false;

        this.init();
    }

    async init() {
        console.log("[GlobalController] Unified Boot Sequence Initiated...");
        
        this.bindEvents();
        await this.startLocationTracking();
        
        // Initialize sub-modules
        await this.chatVM.init();
        // mapVM.init() is now lazy-loaded in switchTab

        // Register global instance for cross-module access
        window.app = this;
    }

    bindEvents() {
        // Tab Navigation
        document.querySelectorAll('.nav-item').forEach(item => {
            item.onclick = () => this.switchTab(item.getAttribute('data-tab'));
        });

        // Drawer
        const historyBtn = document.getElementById('history-menu-btn');
        if (historyBtn) historyBtn.onclick = () => this.toggleDrawer(true);
        const closeBtn = document.getElementById('close-drawer-btn');
        if (closeBtn) closeBtn.onclick = () => this.toggleDrawer(false);
        const overlay = document.getElementById('drawer-overlay');
        if (overlay) overlay.onclick = () => this.toggleDrawer(false);

        // Recenter Btn
        const recenterBtn = document.getElementById('recenter-btn');
        if (recenterBtn) {
            recenterBtn.onclick = async () => {
                const original = recenterBtn.innerHTML;
                recenterBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
                await this.startLocationTracking();
                setTimeout(() => recenterBtn.innerHTML = original, 1000);
                this.mapVM.recenter();
            };
        }
    }

    /**
     * @param {string} targetTab - 'chat', 'map', 'health', 'settings'
     * @param {string} keyword - Optional search keyword for map
     */
    switchTab(targetTab, keyword = '') {
        console.log(`[Navigation] Switching to ${targetTab}`);
        this.currentTab = targetTab;

        document.querySelectorAll('.nav-item, .tab-content').forEach(el => {
            const id = el.id || el.getAttribute('data-tab');
            const isActive = id === targetTab || id === `tab-${targetTab}`;
            el.classList.toggle('active', isActive);
        });

        // Lifecycle Hooks for ViewModels
        if (targetTab === 'map') {
            if (!this.isMapInitialized) {
                this.isMapInitialized = true;
                this.mapVM.init();
            } else {
                this.mapVM.onActivate();
            }
            
            if (keyword) {
                setTimeout(() => this.mapVM.searchHospitals(keyword), 300);
            }
        }
    }

    async startLocationTracking() {
        if (!navigator.geolocation) return;

        if (this.lastPosId !== null) navigator.geolocation.clearWatch(this.lastPosId);

        this.lastPosId = navigator.geolocation.watchPosition(
            (pos) => {
                this.userLocation = { lat: pos.coords.latitude, lng: pos.coords.longitude };
                
                // Propagate to ViewModels
                this.mapVM.updateUserLocation(this.userLocation);
                this.chatVM.updateLocation(this.userLocation);

                // Update common UI
                const dot = document.getElementById('location-status-indicator');
                const text = document.getElementById('location-status-text');
                if (dot) dot.className = 'status-dot green';
                if (text) text.innerText = '실시간 위치 수신 중';
            },
            (err) => {
                console.warn("[Location] Failed to fetch position", err);
                const dot = document.getElementById('location-status-indicator');
                if (dot) dot.className = 'status-dot red';
            },
            { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
        );
    }

    toggleDrawer(open) {
        document.getElementById('history-drawer')?.classList.toggle('open', open);
        document.getElementById('drawer-overlay')?.classList.toggle('visible', open);
        if (open && window.healthModule) {
            window.healthModule.renderNoteList();
        }
    }
}

// Entry Point
document.addEventListener('DOMContentLoaded', () => {
    new LifeCareController();
});
