/**
 * @module NavigationModule
 * @description 전역 내비게이션 및 탭 전환 관리를 전담하는 모듈.
 * z-index 충돌 방지 및 레이어 상태 관리를 포함합니다.
 */
export class NavigationModule {
    constructor(controller) {
        this.controller = controller;
        this.tabs = ['chat', 'map', 'health', 'settings'];
        this.init();
    }

    init() {
        this.bindEvents();
    }

    bindEvents() {
        // 하단 탭 내비게이션 바인딩
        document.querySelectorAll('.nav-item').forEach(item => {
            item.addEventListener('click', () => {
                const tabId = item.getAttribute('data-tab');
                this.switchTab(tabId);
            });
        });

        // 드로어(상담 기록) 바인딩
        const historyBtn = document.getElementById('history-menu-btn');
        if (historyBtn) historyBtn.onclick = () => this.toggleDrawer(true);
        
        const closeBtn = document.getElementById('close-drawer-btn');
        if (closeBtn) closeBtn.onclick = () => this.toggleDrawer(false);
        
        const overlay = document.getElementById('drawer-overlay');
        if (overlay) overlay.onclick = () => this.toggleDrawer(false);
    }

    /**
     * @param {string} targetTab - 전환할 탭 ID
     * @param {string} keyword - 지도 검색용 키워드 (선택)
     */
    switchTab(targetTab, keyword = '') {
        if (!this.tabs.includes(targetTab)) return;

        console.log(`[Navigation] Switching to ${targetTab}`);
        
        // UI 업데이트
        document.querySelectorAll('.nav-item').forEach(el => {
            el.classList.toggle('active', el.getAttribute('data-tab') === targetTab);
        });

        document.querySelectorAll('.tab-content').forEach(el => {
            el.classList.toggle('active', el.id === `tab-${targetTab}`);
        });

        // 컨트롤러에 통보하여 관련 ViewModel 라이프사이클 처리
        if (this.controller && this.controller.onTabChanged) {
            this.controller.onTabChanged(targetTab, keyword);
        }
    }

    toggleDrawer(open) {
        const drawer = document.getElementById('history-drawer');
        const overlay = document.getElementById('drawer-overlay');
        
        if (drawer) drawer.classList.toggle('open', open);
        if (overlay) overlay.classList.toggle('visible', open);

        if (open && window.healthModule) {
            window.healthModule.renderNoteList();
        }
    }
}
