import re
import sys

def decode_octal(s):
    """Декодирует строку с восьмеричными экранированными последовательностями."""
    def replace_octal(match):
        oct_val = match.group(1)
        # Проверяем, что это корректное восьмеричное число (цифры 0-7)
        if all(c in '01234567' for c in oct_val):
            return chr(int(oct_val, 8))
        return match.group(0)  # Возвращаем как есть если некорректно
    return re.sub(r'\\(\d{3})', replace_octal, s)

# Читаем файл
with open('/workspace/china.lua', 'r', encoding='utf-8', errors='ignore') as f:
    content = f.read()

# Ищем начало таблицы I
# Паттерн: local I={"...", "...", ...}
match = re.search(r'local\s+I\s*=\s*\{(.*?)\}', content, re.DOTALL)
if not match:
    print("Не удалось найти таблицу I")
    sys.exit(1)

table_content = match.group(1)

# Извлекаем все строки из таблицы
strings = []
for m in re.finditer(r'"((?:[^"\\]|\\.)*)"', table_content):
    raw_str = m.group(1)
    decoded = decode_octal(raw_str)
    strings.append(decoded)

print(f"Найдено строк: {len(strings)}")
print("\nПервые 20 декодированных строк:")
for i, s in enumerate(strings[:20]):
    # Ограничиваем длину для вывода
    display_s = s if len(s) <= 50 else s[:47] + "..."
    print(f"{i}: {repr(display_s)}")

# Сохраняем все строки в файл для дальнейшего анализа
with open('/workspace/decoded_strings.txt', 'w', encoding='utf-8') as f:
    for i, s in enumerate(strings):
        f.write(f"{i}: {s}\n")

print("\nВсе строки сохранены в decoded_strings.txt")
