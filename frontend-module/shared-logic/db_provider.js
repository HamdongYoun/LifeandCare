// Life & Care - IndexedDB History Module
const DB_NAME = 'LifeCareDB';
const DB_VERSION = 2;
const STORE_NAME = 'history';
const NOTES_STORE = 'notes';

function openDB() {
    return new Promise((resolve, reject) => {
        const request = indexedDB.open(DB_NAME, DB_VERSION);
        
        request.onupgradeneeded = (event) => {
            const db = event.target.result;
            if (!db.objectStoreNames.contains(STORE_NAME)) {
                db.createObjectStore(STORE_NAME, { keyPath: 'id', autoIncrement: true });
            }
            if (!db.objectStoreNames.contains(NOTES_STORE)) {
                db.createObjectStore(NOTES_STORE, { keyPath: 'id', autoIncrement: true });
            }
        };
        
        request.onsuccess = (event) => resolve(event.target.result);
        request.onerror = (event) => reject(event.target.error);
    });
}

export const dbManager = {
    async addEntry(userMsg, aiMsg, status) {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const transaction = db.transaction([STORE_NAME], 'readwrite');
            const store = transaction.objectStore(STORE_NAME);
            const entry = {
                userMsg,
                aiMsg,
                status,
                timestamp: new Date().toISOString()
            };
            const request = store.add(entry);
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    },

    /**
     * Saves a summarized note object to the database.
     * @param {Object} noteObj - { id, text, date }
     */
    async addNote(noteObj) {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const transaction = db.transaction([NOTES_STORE], 'readwrite');
            const store = transaction.objectStore(NOTES_STORE);
            // Ensure we use the object directly as it has a keyPath 'id'
            const request = store.add(noteObj);
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    },

    async getAllNotes() {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const transaction = db.transaction([NOTES_STORE], 'readonly');
            const store = transaction.objectStore(NOTES_STORE);
            const request = store.getAll();
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    },

    async getAllEntries() {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const transaction = db.transaction([STORE_NAME], 'readonly');
            const store = transaction.objectStore(STORE_NAME);
            const request = store.getAll();
            request.onsuccess = () => resolve(request.result);
            request.onerror = () => reject(request.error);
        });
    },

    async clearHistory() {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const transaction = db.transaction([STORE_NAME], 'readwrite');
            const store = transaction.objectStore(STORE_NAME);
            const request = store.clear();
            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    },

    async deleteNote(id) {
        const db = await openDB();
        return new Promise((resolve, reject) => {
            const transaction = db.transaction([NOTES_STORE], 'readwrite');
            const store = transaction.objectStore(NOTES_STORE);
            const request = store.delete(Number(id));
            request.onsuccess = () => resolve();
            request.onerror = () => reject(request.error);
        });
    }
};

// Shorthand exports for module usage
export const addNote = dbManager.addNote.bind(dbManager);
export const getAllNotes = dbManager.getAllNotes.bind(dbManager);
export const deleteNote = dbManager.deleteNote.bind(dbManager);

window.dbManager = dbManager;
