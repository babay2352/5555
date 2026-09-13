-- Инжектор для Pull a Lucky Fish
-- Запусти этот скрипт в своем эксплоите
-- Этот скрипт загружает NeverLose UI и основной чит для игры

local function LoadAndExecute(url, name)
    local success, result = pcall(function()
        local code = game:HttpGet(url)
        local func = loadstring(code)
        if func then
            func()
            print("[Injector] " .. name .. " loaded successfully!")
        else
            warn("Failed to load " .. name .. ": Invalid code")
        end
    end)
    if not success then
        warn("Failed to load " .. name .. ": " .. tostring(result))
    end
    return success
end

print("========================================")
print("     Pull a Lucky Fish - Injector")
print("========================================")

-- Шаг 1: Загружаем библиотеку NeverLose
print("[1/2] Loading NeverLose UI Library...")
local libLoaded = LoadAndExecute(
    "https://raw.githubusercontent.com/4lpaca-pin/NeverLose/refs/heads/main/source.luau", 
    "NeverLose"
)

if not libLoaded then
    warn("[ERROR] Failed to load NeverLose library. Cheat may not work properly.")
end

-- Шаг 2: Загружаем основной скрипт чита
print("[2/2] Loading Fish Cheat Script...")
LoadAndExecute(
    "https://raw.githubusercontent.com/babay2352/5555/refs/heads/creating-scripts-in-roblox-52b3f/fish_cheat.lua", 
    "Fish Cheat"
)


print("========================================")
print("     Injection Complete!")
print("     Press INSERT to open menu")
print("========================================")
