import sqlite3
import urllib.request
import json
import os
import time

def build_db():
    db_path = 'assets/db/gita.db'
    os.makedirs(os.path.dirname(db_path), exist_ok=True)
    
    if os.path.exists(db_path):
        os.remove(db_path)
        
    print(f"Creating database at {db_path}")
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()
    
    cur.execute('''
        CREATE TABLE verses (
            id INTEGER PRIMARY KEY,
            chapter_number INTEGER NOT NULL,
            verse_number INTEGER NOT NULL,
            text_devanagari TEXT,
            text_transliteration TEXT,
            text_english TEXT,
            purport TEXT,
            is_bookmarked INTEGER DEFAULT 0
        )
    ''')
    
    cur.execute('''
        CREATE VIRTUAL TABLE verses_fts USING fts5(
            text_devanagari,
            text_transliteration,
            text_english,
            purport,
            content='verses',
            content_rowid='id'
        )
    ''')
    
    cur.execute('''
        CREATE TRIGGER verses_ai AFTER INSERT ON verses BEGIN
            INSERT INTO verses_fts(rowid, text_devanagari, text_transliteration, text_english, purport)
            VALUES (new.id, new.text_devanagari, new.text_transliteration, new.text_english, new.purport);
        END;
    ''')
    
    for chapter_num in range(1, 19):
        print(f"Fetching Chapter {chapter_num}...")
        try:
            req = urllib.request.Request(f'https://bhagavadgitaapi.in/chapter/{chapter_num}', headers={'User-Agent': 'Mozilla/5.0'})
            res = urllib.request.urlopen(req)
            chapter_data = json.loads(res.read())
            verses_count = chapter_data.get('verses_count', 0)
            
            for verse_num in range(1, verses_count + 1):
                verse_url = f'https://bhagavadgitaapi.in/slok/{chapter_num}/{verse_num}'
                retries = 3
                verse_data = None
                while retries > 0:
                    try:
                        v_req = urllib.request.Request(verse_url, headers={'User-Agent': 'Mozilla/5.0'})
                        v_res = urllib.request.urlopen(v_req)
                        verse_data = json.loads(v_res.read())
                        break
                    except Exception as e:
                        retries -= 1
                        print(f"Retrying Ch{chapter_num}:V{verse_num}...")
                        time.sleep(1)
                
                if verse_data is None:
                    print(f"Failed Ch{chapter_num}:V{verse_num}")
                    verse_data = {'slok': '', 'transliteration': '', 'siva': {'et': '', 'ec': ''}}
                    
                devanagari = verse_data.get('slok', '')
                transliteration = verse_data.get('transliteration', '')
                
                siva = verse_data.get('siva', {})
                english_text = siva.get('et', '') if isinstance(siva, dict) else ''
                purport_text = siva.get('ec', '') if isinstance(siva, dict) else ''
                
                vid = (chapter_num * 1000) + verse_num
                
                cur.execute('''
                    INSERT INTO verses (id, chapter_number, verse_number, text_devanagari, text_transliteration, text_english, purport, is_bookmarked)
                    VALUES (?, ?, ?, ?, ?, ?, ?, 0)
                ''', (vid, chapter_num, verse_num, devanagari, transliteration, english_text, purport_text))
                
        except Exception as e:
            print(f"Error chapter {chapter_num}: {e}")
            
        conn.commit()
        print(f"Finished Chapter {chapter_num}.")
        
    print("Database built successfully.")
    conn.close()

if __name__ == '__main__':
    build_db()
