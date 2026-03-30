/**
 * 3tab_health.js - Health Tab Module (Refactored & Logic Recovered)
 * Handles session notes, persistence via IndexedDB, and AI report generation.
 * Features: Manual Summary, Delete Note, AI Report Caching, Status Monitoring.
 */

import { addNote, getAllNotes, deleteNote } from '../shared-logic/db_provider.js';

class HealthModule {
    /**
     * @constructor
     * Initializes DOM references and state for the health module.
     */
    constructor() {
        this.noteList = document.getElementById('note-list'); // Drawer container
        this.reportContent = document.getElementById('report-content');
        this.refreshReportBtn = document.getElementById('refresh-report-btn');
        this.addNoteBtn = document.getElementById('add-note-btn'); 
        
        // --- Critical: Global Registration for Navigation link ---
        window.healthModule = this;
        
        this.init();
    }

    async init() {
        console.log("[HealthModule] Initializing with recovered logic...");
        
        // --- Event Binding (Line-by-line Recovery) ---
        if (this.addNoteBtn) {
            this.addNoteBtn.onclick = () => this.saveSessionAsNote();
        }
        if (this.refreshReportBtn) {
            this.refreshReportBtn.onclick = () => this.generateReport();
        }

        // Initial UI render from IndexedDB
        await this.renderNoteList();

        // Restore cached report from localStorage for quick load
        const cachedReport = localStorage.getItem('healthReport');
        if (cachedReport && this.reportContent) {
            this.reportContent.innerHTML = cachedReport;
        }
    }

    /**
     * Summarizes current chat session and saves it as a persistent note.
     * Proxies to /summarize_session backend endpoint.
     */
    async saveSessionAsNote() {
        // Access shared history from ChatViewModel
        const history = window.app?.chatVM?.messageHistory || [];
        
        if (history.length < 2) {
            alert("요약할 새로운 상담 내역이 없습니다.");
            return;
        }

        this.setLoading(true);

        try {
            const resp = await fetch('/summarize_session', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ history: history.join('\n') })
            });

            if (!resp.ok) throw new Error("AI Summary Request Failed");
            const data = await resp.json();

            if (data.note) {
                const noteObj = { 
                    id: Date.now(), 
                    text: data.note, 
                    date: new Date().toLocaleString(),
                    status: "0" 
                };
                
                // Persistence via IndexedDB
                await addNote(noteObj);
                
                // Update UIs (Drawer and Health Tab)
                await this.renderNoteList();
                
                alert("현재 상담 세션이 건강 기록에 요약 저장되었습니다.");
            }
        } catch (e) {
            console.error("[HealthModule] Session summary exception:", e);
            alert("노트 생성 중 오류가 발생했습니다.");
        } finally {
            this.setLoading(false);
        }
    }

    /**
     * Renders notes from IndexedDB to the History Drawer with DELETE support.
     */
    async renderNoteList() {
        const container = this.noteList;
        if (!container) return;

        const notes = await getAllNotes();
        
        container.innerHTML = '';
        
        if (notes.length === 0) {
            container.innerHTML = '<div class="empty-msg">아직 저장된 건강 기록이 없습니다.</div>';
            return;
        }

        // Sort by ID (Newest First)
        notes.sort((a, b) => (b.id) - (a.id)).forEach(note => {
            const dateStr = note.date;
            const text = note.text;
            const isDanger = note.status === "1";

            const noteDiv = document.createElement('div');
            noteDiv.className = `note-item ${isDanger ? 'pulse-danger' : ''}`;
            noteDiv.innerHTML = `
                <div class="note-body">
                    <div class="note-header">
                        <i class="fa-solid ${isDanger ? 'fa-triangle-exclamation' : 'fa-notes-medical'}"></i>
                        <span class="note-date">${dateStr}</span>
                        <button class="delete-note-btn" data-id="${note.id}" title="삭제">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>
                    </div>
                    <div class="note-text">${text}</div>
                </div>
            `;
            
            const deleteBtn = noteDiv.querySelector('.delete-note-btn');
            deleteBtn.onclick = async (e) => {
                e.stopPropagation();
                if (confirm("이 건강 기록을 영구 삭제하시겠습니까?")) {
                    await deleteNote(note.id);
                    await this.renderNoteList();
                }
            };

            container.appendChild(noteDiv);
        });
    }

    /**
     * Aggregates all notes and generates a robust AI health report.
     */
    async generateReport() {
        const notes = await getAllNotes();
        if (notes.length === 0) {
            alert("기록된 상담 데이터가 부족하여 리포트를 생성할 수 없습니다.");
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

            if (!response.ok) throw new Error("HealthReport API Exception");
            const data = await response.json();

            if (data.summary) {
                this.reportContent.innerHTML = data.summary; 
                localStorage.setItem('healthReport', data.summary);
            }
        } catch (e) {
            console.error("[HealthModule] Report generation crash:", e);
            alert("리포트 생성 중 통신 장애가 발생했습니다.");
        } finally {
            if (this.refreshReportBtn) this.refreshReportBtn.classList.remove('loading');
        }
    }

    setLoading(active) {
        if (!this.addNoteBtn) return;
        if (active) {
            this.addNoteBtn.disabled = true;
            this.addNoteBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> 분석 중...';
        } else {
            this.addNoteBtn.disabled = false;
            this.addNoteBtn.innerHTML = '<i class="fa-solid fa-plus"></i> 최근 상담 요약 저장';
        }
    }
}

// Export singleton initialization function
export function initHealth() {
    new HealthModule();
}
