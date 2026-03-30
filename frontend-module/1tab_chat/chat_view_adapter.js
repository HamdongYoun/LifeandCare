/**
 * ChatViewAdapter - Pure UI/DOM manipulation for Chat Module
 * Handles message bubbles, scroll, and loading states.
 */
class ChatViewAdapter {
    /**
     * @param {string} historyId - DOM ID for chat history container
     * @param {string} inputId - DOM ID for user input textarea
     */
    constructor(historyId, inputId) {
        this.history = document.getElementById(historyId);
        this.input = document.getElementById(inputId);
    }

    /**
     * @param {string} text - Message content
     * @param {string} type - 'user', 'bot', 'error'
     * @param {object} options - { subType, isDanger }
     */
    renderMessage(text, type, options = {}) {
        const { subType = '', isDanger = false } = options;
        const msgDiv = document.createElement('div');
        msgDiv.className = `msg ${type} ${subType} ${isDanger ? 'danger-mode' : ''}`;

        if (isDanger && type === 'bot') {
            const badge = document.createElement('div');
            badge.className = 'danger-badge';
            badge.innerHTML = '<i class="fa-solid fa-circle-exclamation"></i> 긴급 제언';
            msgDiv.appendChild(badge);
        }

        const contentSpan = document.createElement('span');
        contentSpan.innerText = text;
        msgDiv.appendChild(contentSpan);

        this.history.appendChild(msgDiv);
        this.scrollBottom();
    }

    showLoading() {
        const id = 'loading-' + Date.now();
        const html = `<div id="${id}" class="msg bot loading"><div class="dots"><span></span><span></span><span></span></div></div>`;
        this.history.insertAdjacentHTML('beforeend', html);
        this.scrollBottom();
        return id;
    }

    removeLoading(id) {
        const el = document.getElementById(id);
        if (el) el.remove();
    }

    scrollBottom() {
        this.history.scrollTop = this.history.scrollHeight;
    }

    clearInput() {
        this.input.value = '';
        this.input.style.height = 'auto';
    }

    /**
     * @param {boolean} isDanger - Status flag
     * @param {string} summary - Textual summary of health status
     */
    updateHealthBadge(isDanger, summary) {
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
}

window.ChatViewAdapter = ChatViewAdapter;
