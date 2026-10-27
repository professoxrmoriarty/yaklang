import os
import re
import time
import json
from deep_translator import GoogleTranslator

translator = GoogleTranslator(source='zh-CN', target='en')
zh_char_re = re.compile(r'[\u4e00-\u9fff]')
go_string_re = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*[\u4e00-\u9fff]+[^"\\]*(?:\\.[^"\\]*)*)"')

CACHE_FILE = ".i18n_go_cache.json"
cache = {}
if os.path.exists(CACHE_FILE):
    try:
        with open(CACHE_FILE, 'r', encoding='utf-8') as f:
            cache = json.load(f)
    except:
        pass

def chunk_list(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

print("Scanning for Chinese strings...")
strings_to_translate = set()
for root, _, files in os.walk("."):
    if "vendor" in root or ".git" in root or "node_modules" in root:
        continue
    for f in files:
        if f.endswith(".go") and not f.endswith("_test.go"):
            filepath = os.path.join(root, f)
            
            # Windows Defender ပိတ်ထားသော ဖိုင်များအတွက် Error Handling
            try:
                with open(filepath, "r", encoding="utf-8") as file:
                    content = file.read()
            except OSError as e:
                print(f"⚠️ Skipping file (AV Blocked or Access Denied): {filepath}")
                continue
            except Exception as e:
                continue

            if zh_char_re.search(content):
                for match in go_string_re.finditer(content):
                    text = match.group(1)
                    if len(text) <= 300 and text not in cache:
                        strings_to_translate.add(text)

strings_list = list(strings_to_translate)
print(f"Found {len(strings_list)} new strings to translate locally.")

if strings_list:
    print("Starting translation...")
    for chunk in chunk_list(strings_list, 15):
        try:
            translations = translator.translate_batch(chunk)
            for orig, trans in zip(chunk, translations):
                cache[orig] = trans if trans else orig
            
            with open(CACHE_FILE, "w", encoding="utf-8") as f:
                json.dump(cache, f, ensure_ascii=False, indent=2)
            
            print(f"Translated a batch of 15 strings... (Waiting 1.5 seconds)")
            time.sleep(1.5) 
        except Exception as e:
            print(f"Error: {e}. Waiting 5 seconds before retrying...")
            time.sleep(5)

print("Local Translation Completed! You can now commit .i18n_go_cache.json")
