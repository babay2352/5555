-- Загружаем обфусцированный файл и выполняем его для получения декодированного кода
local chunk = loadfile("/workspace/china.lua")
if not chunk then
    print("Ошибка загрузки файла")
    return
end

-- Пытаемся перехватить вывод или получить результат
local result = chunk()
if type(result) == "string" then
    print("-- Декодированный код:")
    print(result)
elseif type(result) == "function" then
    print("-- Результат - функция, пытаемся получить её дамп")
    print(string.dump(result))
else
    print("-- Результат:", type(result))
    -- Печатаем первые несколько строк исходного файла для анализа структуры
    local f = io.open("/workspace/china.lua", "r")
    if f then
        local content = f:read("*a")
        f:close()
        -- Ищем основную функцию деобфускации
        local start_pos = content:find("return%(function%(I%)")
        if start_pos then
            print("\n-- Найдена функция деобфускации, позиция:", start_pos)
        end
    end
end
