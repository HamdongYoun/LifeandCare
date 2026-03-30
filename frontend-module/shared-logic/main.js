/**
 * @module MainEntry
 * @description 애플리케이션의 공식 진입점.
 * 설정 로드, 컨트롤러 및 내비게이션 초기화, 모든 서브모듈의 부팅 체인을 복구합니다.
 */
import { NavigationModule } from './navigation.js';
import { initHealth } from '../3tab_health/3tab_health.js';

class MainApp {
    constructor() {
        this.currentTab = 'chat';
        this.userLocation = { lat: 37.5665, lng: 126.9780 };
        this.lastPosId = null;

        // ViewModels initialized synchronously
        this.mapVM = new MapViewModel();
        this.chatVM = new ChatViewModel('chat-history', 'user-input');
        
        this.isMapInitialized = false;
        
        // Navigation Module Integration
        this.navModule = new NavigationModule(this);

        this.init();
    }

    async init() {
        console.log("[MainApp] Unified Boot Sequence Initiated...");
        
        // 1. 설정 로드 (백엔드 프록시 설정 등)
        await this.loadConfig();
        
        // 2. 위치 추적 시작
        await this.startLocationTracking();
        
        // 3. 서브모듈 초기화 라이프사이클
        await this.chatVM.init();
        initHealth(); // 글로벌 healthModule 인스턴스화

        // 4. 기타 UI 요소 바인딩
        this.bindEvents();

        // 5. 전역 접근성 확보
        window.app = this;
    }

    async loadConfig() {
        try {
            const resp = await fetch('/config');
            const config = await resp.json();
            window.config = config;
            console.log("[MainApp] Config loaded successfully.");
        } catch (e) {
            console.error("[MainApp] Failed to load config.", e);
        }
    }

    bindEvents() {
        // Global UI events that don't belong to a specific VM can stay here (e.g. general notifications)
    }

    /**
     * @description NavigationModule에서 탭 전환 시 호출되는 콜백
     * @param {string} targetTab - 바뀐 탭 ID
     * @param {string} keyword - 검색 키워드
     */
    onTabChanged(targetTab, keyword = '') {
        this.currentTab = targetTab;
        
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
                if (this.mapVM) this.mapVM.updateUserLocation(this.userLocation);
                if (this.chatVM) this.chatVM.updateLocation(this.userLocation);

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
}

// Entry Point
document.addEventListener('DOMContentLoaded', () => {
    new MainApp();
});
