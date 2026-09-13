#!/usr/bin/env python3
import re

def decode_lua_string(s):
    """Полностью декодирует Lua-строку с восьмеричными escape-последовательностями."""
    def replace_octal(match):
        oct_val = match.group(1)
        if all(c in '01234567' for c in oct_val):
            try:
                return chr(int(oct_val, 8))
            except:
                pass
        return match.group(0)
    
    # Заменяем все восьмеричные последовательности
    result = re.sub(r'\\(\d{3})', replace_octal, s)
    return result

# Читаем файл
with open('/workspace/china.lua', 'r') as f:
    content = f.read()

# Находим таблицу I
match = re.search(r'local\s+I\s*=\s*\{(.*?)\}', content, re.DOTALL)
if not match:
    print("Не найдена таблица I")
    exit(1)

table_content = match.group(1)

# Извлекаем строки
strings = []
for m in re.finditer(r'"((?:[^"\\]|\\.)*)"', table_content):
    raw_str = m.group(1)
    decoded = decode_lua_string(raw_str)
    strings.append(decoded)

print(f"Найдено строк: {len(strings)}")

# Проверяем первые 20 строк
print("\n=== Первые 20 декодированных строк ===")
for i, s in enumerate(strings[:20]):
    print(f"[{i}] (len={len(s)}): {repr(s)}")

# Ищем длинные строки - они могут содержать код
print("\n=== Самые длинные строки ===")
sorted_strings = sorted(enumerate(strings), key=lambda x: len(x[1]), reverse=True)
for i, s in sorted_strings[:10]:
    print(f"[{i}] (len={len(s)}): {s[:100]}...")

# Сохраняем полностью декодированные строки
with open('/workspace/fully_decoded.txt', 'w', encoding='utf-8') as f:
    for i, s in enumerate(strings):
        f.write(f"=== [{i}] (len={len(s)}) ===\n{s}\n\n")

print("\nСохранено в fully_decoded.txt")
