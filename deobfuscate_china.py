#!/usr/bin/env python3
"""
Деобфускатор для Lua-скриптов, обфусцированных WeAreDevs obfuscator.
Этот скрипт пытается извлечь и декодировать содержимое таблицы строк,
а затем восстановить оригинальный код.
"""

import re
import sys

def decode_octal(s):
    """Декодирует строку с восьмеричными экранированными последовательностями."""
    def replace_octal(match):
        oct_val = match.group(1)
        if all(c in '01234567' for c in oct_val):
            return chr(int(oct_val, 8))
        return match.group(0)
    return re.sub(r'\\(\d{3})', replace_octal, s)

def extract_strings(content):
    """Извлекает все строки из таблицы I."""
    match = re.search(r'local\s+I\s*=\s*\{(.*?)\}', content, re.DOTALL)
    if not match:
        return None
    
    table_content = match.group(1)
    strings = []
    
    for m in re.finditer(r'"((?:[^"\\]|\\.)*)"', table_content):
        raw_str = m.group(1)
        decoded = decode_octal(raw_str)
        strings.append(decoded)
    
    return strings

def find_main_code(content):
    """Ищет основной закодированный код в конце файла."""
    # Ищем паттерн возврата функции
    match = re.search(r'\]\]\)(.*)$', content, re.DOTALL)
    if match:
        return match.group(1)
    return None

def main():
    with open('/workspace/china.lua', 'r', encoding='utf-8', errors='ignore') as f:
        content = f.read()
    
    print("Анализ структуры файла...")
    
    # Извлекаем строки
    strings = extract_strings(content)
    if strings:
        print(f"Найдено {len(strings)} строк в таблице I")
        
        # Ищем строки, которые могут содержать код
        code_candidates = []
        for i, s in enumerate(strings):
            if len(s) > 100 and ('function' in s or 'end' in s or 'local' in s or 'return' in s):
                code_candidates.append((i, s))
        
        if code_candidates:
            print(f"\nНайдено {len(code_candidates)} кандидатов на код:")
            for idx, code in code_candidates[:5]:
                print(f"\n--- Строка {idx} (первые 500 символов) ---")
                print(code[:500])
        else:
            print("\nНе найдено явных кандидатов на код в строках")
            
        # Сохраняем все строки для анализа
        with open('/workspace/all_strings.txt', 'w', encoding='utf-8') as f:
            for i, s in enumerate(strings):
                f.write(f"=== [{i}] (len={len(s)}) ===\n")
                f.write(s[:1000] + "\n\n" if len(s) > 1000 else s + "\n\n")
        print("\nВсе строки сохранены в all_strings.txt")
    
    # Ищем основной код после ]]
    main_code = find_main_code(content)
    if main_code:
        print(f"\nНайден основной код после ]] (длина: {len(main_code)})")
        with open('/workspace/main_code_section.txt', 'w', encoding='utf-8') as f:
            f.write(main_code)
        print("Сохранено в main_code_section.txt")
    
    # Анализируем структуру обфускации
    print("\n=== Анализ структуры ===")
    # Проверяем наличие виртуальной машины
    if 'function(I,l)' in content or 'function(I,L)' in content:
        print("Обнаружена структура виртуальной машины Lua")
    
    # Ищем ключевые функции
    patterns = [
        (r'function\(I\)', "Функция с одним параметром"),
        (r'function\(I,l\)', "Функция с двумя параметрами"),
        (r'getfenv', "Использование getfenv"),
        (r'_ENV', "Использование _ENV"),
        (r'loadstring|load', "Использование load/loadstring"),
    ]
    
    for pattern, desc in patterns:
        if re.search(pattern, content):
            print(f"- {desc}: найдено")

if __name__ == '__main__':
    main()
