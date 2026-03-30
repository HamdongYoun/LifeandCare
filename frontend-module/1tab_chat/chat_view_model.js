/**
 * @module ChatViewModel
 * @description 2번 탭(상담)의 핵심 비즈니스 로직 및 AI 메시지 렌더링을 담당함.
 * MapViewModel과 분리되어 순수 상담 기능에 집중합니다.
 */
class ChatViewModel {
    /**
     * @constructor
     * @param {string} historyId - 채팅 내역 컨테이너 ID
     * @param {string} inputId - 사용자 입력창 ID
     */
    constructor(historyId, inputId) {
        this.chatUI = new ChatViewAdapter(historyId, inputId);
        this.messageHistory = [];
        this.userLocation = { lat: 37.5665, lng: 126.9780 };
    }

    /**
     * @returns {Promise<void>}
     */
    async init() {
        console.log("[ChatViewModel] AI Chat Service Booting...");
        this.bindEvents();
    }

    bindEvents() {
        const sendBtn = document.getElementById('send-btn');
        if (sendBtn) sendBtn.onclick = () => this.handleSendMessage();

        const addNoteBtn = document.getElementById('add-note-btn');
        if (addNoteBtn) {
            addNoteBtn.onclick = () => {
                if (window.healthModule) {
                    window.healthModule.saveSessionAsNote();
                } else {
                    console.warn("[ChatVM] HealthModule not ready for summary.");
                    alert("시스템이 준비 중입니다. 잠시 후 다시 시도해주세요.");
                }
            };
        }
        
        const userInput = document.getElementById('user-input');
        if (userInput) {
            userInput.onkeydown = (e) => {
                if (e.key === 'Enter' && !e.shiftKey) {
                    e.preventDefault();
                    this.handleSendMessage();
                }
            };
        }
    }

    /**
     * @param {object} loc - {lat, lng} updated user location
     */
    updateLocation(loc) {
        this.userLocation = loc;
    }

    /**
     * @returns {Promise<void>}
     */
    async handleSendMessage() {
        const message = document.getElementById('user-input').value.trim();
        if (!message) return;

        this.chatUI.renderMessage(message, 'user');
        this.chatUI.clearInput();
        this.messageHistory.push(`사용자: ${message}`);

        const loadingId = this.chatUI.showLoading();
        try {
            const response = await fetch('/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message, ...this.userLocation })
            });
            const data = await response.json();
            this.chatUI.removeLoading(loadingId);

            // [LOGIC RECOVERY] Health Status Summarization
            let isDanger = data.message_type === 'emergency';
            try {
                const sumResp = await fetch('/summarize', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ user_msg: message, ai_msg: data.content })
                });
                const sumData = await sumResp.json();
                if (sumData.status === "1") isDanger = true;
                this.chatUI.updateHealthBadge(isDanger, sumData.summary || '상태분석완료');
            } catch (e) { console.warn("Summary integration failed", e); }

            // AI Logic Recovery: Parsing flags
            const hospMatch = data.content.match(/\[HOSPITAL:([^\]]+)\]/);
            this.chatUI.renderMessage(data.content.replace(/\[HOSPITAL:[^\]]+\]/g, ''), 'bot', { isDanger });
            this.messageHistory.push(`AI: ${data.content}`);

            // [LOGIC RECOVERY] IndexedDB Sync
            if (window.dbManager) {
                await window.dbManager.addEntry(message, data.content, isDanger ? '1' : '0');
            }

            // [ROUTING] If hospital suggested, notify Global App to switch tab and search
            if (hospMatch && window.app) {
                setTimeout(() => window.app.switchTab('map', hospMatch[1]), 1500);
            }
        } catch (e) {
            this.chatUI.removeLoading(loadingId);
            this.chatUI.renderMessage('상담 중 오류가 발생했습니다. (NetworkException)', 'error');
        }
    }
}

// Global Export
window.ChatViewModel = ChatViewModel;
