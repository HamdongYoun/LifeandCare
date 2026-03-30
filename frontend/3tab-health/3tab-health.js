/**
 * 3tab-health.js - Health Tab Module
 * Handles session notes, persistence via IndexedDB, and AI report generation.
 */

import { addNote, getAllNotes, deleteNote } from '../db.js';

class HealthModule {
    constructor() {
        this.noteList = document.getElementById('note-list'); // Drawer container
        this.reportContent = document.getElementById('report-content');
        this.refreshReportBtn = document.getElementById('refresh-report-btn');
        
        this.init();
    }

    async init() {
        console.log("Health Module Initializing...");
        if (this.addNoteBtn) {
            this.addNoteBtn.addEventListener('click', () => this.saveSessionAsNote());
        }
        if (this.refreshReportBtn) {
            this.refreshReportBtn.addEventListener('click', () => this.generateReport());
        }

        // Initial render
        await this.renderNoteList();

        // Restore cached report from localStorage (if any)
        const cachedReport = localStorage.getItem('healthReport');
        if (cachedReport && this.reportContent) {
            this.reportContent.innerHTML = cachedReport;
        }
    }

    /**
     * Summarizes current chat session and saves it as a persistent note.
     */
    async saveSessionAsNote() {
        // We need messageHistory from the main app. 
        // In a real modular app, messageHistory would be in a shared store.
        // For now, we access it from window.messageHistory if available.
        const history = window.messageHistory || [];
        
        if (history.length < 2) {
            alert("요약할 상담 내역이 없습니다.");
            return;
        }

        this.setLoading(true);

        try {
            const response = await fetch('/summarize_session', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ history: history.join('\n') })
            });

            if (!response.ok) throw new Error("API Error");
            const data = await response.json();

            if (data.note) {
                const noteObj = { 
                    id: Date.now(), 
                    text: data.note, 
                    date: new Date().toLocaleString() 
                };
                
                // Save to IndexedDB
                await addNote(noteObj);
                
                // Update UI
                await this.renderNoteList();
                
                // Clear current session history to start fresh
                if (window.clearSession) window.clearSession();
                
                alert("상담 세션이 건강 노트에 저장되었습니다.");
            }
        } catch (e) {
            console.error(e);
            alert("노트 생성 중 오류가 발생했습니다. AI 할당량을 확인하세요.");
        } finally {
            this.setLoading(false);
        }
    }

    /**
     * Renders the linear note list from IndexedDB to the History Drawer.
     */
    async renderNoteList() {
        const container = this.noteList;
        const notes = await getAllNotes();
        
        if (!container) return;
        container.innerHTML = '';
        
        if (notes.length === 0) {
            container.innerHTML = '<div class="empty-msg">아직 저장된 건강 기록이 없습니다.</div>';
            return;
        }

        // Sort by ID (timestamp) descending
        notes.sort((a, b) => b.id - a.id).forEach(note => {
            const noteDiv = document.createElement('div');
            noteDiv.className = 'note-item';
            noteDiv.innerHTML = `
                <div class="note-body">
                    <div class="note-header">
                        <i class="fa-solid fa-notes-medical"></i>
                        <span class="note-date">${note.date}</span>
                        <button class="delete-note-btn" data-id="${note.id}" title="삭제">
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                    </div>
                    <div class="note-text">${note.text}</div>
                </div>
            `;
            
            const deleteBtn = noteDiv.querySelector('.delete-note-btn');
            deleteBtn.onclick = async (e) => {
                e.stopPropagation();
                if (confirm("이 건강 노트를 삭제하시겠습니까?")) {
                    await deleteNote(note.id);
                    await this.renderNoteList();
                }
            };

            container.appendChild(noteDiv);
        });
    }

    /**
     * Aggregates all notes and generates a comprehensive AI health report.
     */
    async generateReport() {
        const notes = await getAllNotes();
        
        if (notes.length === 0) {
            alert("저장된 상담 기록이 없어 리포트를 생성할 수 없습니다.");
            return;
        }

        if (this.refreshReportBtn) this.refreshReportBtn.classList.add('loading');
        
        try {
            const aggregateHistory = notes.map(n => n.text).join('\n');
            const response = await fetch('/report', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ history: aggregateHistory })
            });

            if (!response.ok) throw new Error("API Error");
            const data = await response.json();

            if (data.summary) {
                // Ensure the summary is wrapped correctly for the .report-card style
                this.reportContent.innerHTML = data.summary; 
                localStorage.setItem('healthReport', this.reportContent.innerHTML);
            }
        } catch (e) {
            console.error(e);
            alert("리포트 생성 중 오류가 발생했습니다.");
        } finally {
            if (this.refreshReportBtn) this.refreshReportBtn.classList.remove('loading');
        }
    }

    setLoading(active) {
        if (!this.addNoteBtn) return;
        if (active) {
            this.addNoteBtn.disabled = true;
            this.addNoteBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> 요약 중...';
        } else {
            this.addNoteBtn.disabled = false;
            this.addNoteBtn.innerHTML = '<i class="fa-solid fa-plus"></i> 노트 추가';
        }
    }
}

// Export initialization function
export function initHealth() {
    window.healthModule = new HealthModule();
}
