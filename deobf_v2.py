#!/usr/bin/env python3
import re

def decode_lua_string(s):
    """Декодирует Lua-строку с восьмеричными escape-последовательностями."""
    # В исходном файле строки имеют вид "\\055" (два бэкслэша)
    # Сначала заменим двойные бэкслэши на одинарные
    s = s.replace('\\\\', '\\')
    
    def replace_octal(match):
        oct_val = match.group(1)
        if all(c in '01234567' for c in oct_val):
            try:
                return chr(int(oct_val, 8))
            except:
                return match.group(0)
        return match.group(0)
    
    return re.sub(r'\\(\d{3})', replace_octal, s)

# Читаем файл
with open('/workspace/china.lua', 'r') as f:
    content = f.read()

# Находим таблицу I
match = re.search(r'local\s+I\s*=\s*\{(.*?)\}', content, re.DOTALL)
if not match:
    print("Не найдена таблица I")
    exit(1)

table_content = match.group(1)

# Извлекаем строки - теперь правильно обрабатываем экранирование
strings = []
for m in re.finditer(r'"((?:[^"\\]|\\.)*)"', table_content):
    raw_str = m.group(1)
    decoded = decode_lua_string(raw_str)
    strings.append(decoded)

print(f"Найдено строк: {len(strings)}")

# Ищем строки с кодом Lua
print("\n=== Поиск Lua-кода ===")
lua_keywords = ['function', 'end', 'local', 'return', 'if', 'then', 'else', 'for', 'while', 'do']

for i, s in enumerate(strings):
    # Проверяем наличие ключевых слов Lua
    matches = sum(1 for kw in lua_keywords if kw in s)
    if matches >= 2 and len(s) > 50:
        print(f"\n[{i}] (совпадений: {matches}, длина: {len(s)}):")
        print(s[:300] + "..." if len(s) > 300 else s)

# Сохраняем все декодированные строки
with open('/workspace/decoded_all.txt', 'w', encoding='utf-8') as f:
    for i, s in enumerate(strings):
        f.write(f"=== [{i}] (len={len(s)}) ===\n{s}\n\n")

print("\nВсе строки сохранены в decoded_all.txt")

# Также сохраняем только строки с потенциальным кодом
code_strings = []
for i, s in enumerate(strings):
    matches = sum(1 for kw in lua_keywords if kw in s)
    if matches >= 2:
        code_strings.append((i, s))

with open('/workspace/code_candidates.txt', 'w', encoding='utf-8') as f:
    for i, s in code_strings:
        f.write(f"=== [{i}] (len={len(s)}) ===\n{s}\n\n")

print(f"Найдено {len(code_strings)} кандидатов на код, сохранено в code_candidates.txt")
