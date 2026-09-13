-- Pull a Lucky Fish - Cheat Script
-- Использует NeverLose UI Library

-- Проверка, загружена ли библиотека
if not getgenv().NeverLoseLoaded then
    warn("NeverLose library not loaded! Please run inject.lua first or combine scripts.")
    -- Пытаемся загрузить библиотеку напрямую, если она еще не загружена
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/NeverLose/refs/heads/main/source.luau"))()
        getgenv().NeverLoseLoaded = true
    end)
end

local NeverLose = getgenv().NeverLose or loadstring(game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/NeverLose/refs/heads/main/source.luau"))()

local Notification = NeverLose:CreateNotification()
local Logging = NeverLose:CreateLogger()
local Indicator = NeverLose:CreateIndicator()

local window = NeverLose:CreateWindow({
    Logo = NeverLose.GlobalLogo,
    Name = "Lucky Fish",
    Content = "Pull a Lucky Fish",
    Size = NeverLose.Scales.Default,
    ConfigFolder = "LuckyFishConfigs",
    Enable3DRenderer = false,
    Keybind = "Insert"
})

local Watermark = window:Watermark()

-- Индикатор статуса
local StatusIndicator = Indicator.new({
    Name = "Status",
    Icon = 'fish',
    Color = 'Green',
})

window:AddTabLabel('FISHING')

local ping = Watermark:AddBlock("chart-four-vertical-bars", "0MS")
local UITogg = Watermark:AddBlock("cube-vertexes", "LuckyFish")

UITogg:Input(function()
    window:ToggleInterface()
end)

task.spawn(function()
    while true do 
        task.wait(1)
        ping:SetText(tostring(math.random(10, 50)) .. 'MS')
    end
end)

-- Вкладки
local Fishing = window:AddTab({
    Icon = 'fish',
    Name = "Fishing"
})

local Auto = window:AddTab({
    Icon = 'auto-fix',
    Name = "Auto"
})

local Visuals = window:AddTab({
    Icon = 'eye',
    Name = "Visuals"
})

local Misc = window:AddTab({
    Icon = 'settings',
    Name = "Misc"
})

-- Секции вкладки Fishing
local Main = Fishing:AddSection({
    Name = "MAIN"
})

local Filters = Fishing:AddSection({
    Name = "FILTERS",
    Position = 'left'
})

local Info = Fishing:AddSection({
    Name = "INFO",
    Position = 'right'
})

-- Секции вкладки Auto
local AutoCatch = Auto:AddSection({
    Name = "AUTO CATCH"
})

local AutoCast = Auto:AddSection({
    Name = "AUTO CAST",
    Position = 'left'
})

-- Секции вкладки Visuals
local ESP = Visuals:AddSection({
    Name = "ESP"
})

local Chams = Visuals:AddSection({
    Name = "CHAMS",
    Position = 'left'
})

-- Секции вкладки Misc
local Player = Misc:AddSection({
    Name = "PLAYER"
})

local World = Misc:AddSection({
    Name = "WORLD",
    Position = 'left'
})

-- ==================== FISHING TAB ====================

Main:AddLabel('Script Enabled'):AddToggle({
    Default = false,
    Callback = function(state)
        if state then
            Notification.new({
                Title = "Lucky Fish",
                Content = "Script activated!",
                Duration = 3,
            })
            Logging.new("fish", "Fishing script started", 10)
        else
            Logging.new("fish", "Fishing script stopped", 10)
        end
    end,
    Flag = "script_enabled"
})

Main:AddLabel('Instant Catch'):AddToggle({
    Default = false,
    Flag = "instant_catch"
})

Main:AddLabel('No Minigame'):AddToggle({
    Default = false,
    Flag = "no_minigame"
})

Main:AddLabel('Perfect Timing'):AddToggle({
    Default = false,
    Flag = "perfect_timing"
})

Main:AddLabel('Luck Boost'):AddSlider({
    Min = 0,
    Max = 100,
    Default = 0,
    Type = "%",
    Flag = "luck_boost"
})

-- Фильтры рыбы
Filters:AddLabel('Rarity Filter'):AddDropdown({
    Default = 'All',
    Values = {'All', 'Common Only', 'Rare+', 'Legendary Only'},
    Flag = "rarity_filter"
})

Filters:AddLabel('Min Size (cm)'):AddSlider({
    Min = 0,
    Max = 500,
    Default = 0,
    Flag = "min_size"
})

Filters:AddLabel('Max Size (cm)'):AddSlider({
    Min = 0,
    Max = 500,
    Default = 500,
    Flag = "max_size"
})

Filters:AddLabel('Target Fish'):AddDropdown({
    Default = 'Any',
    Multi = true,
    Values = {'Trout', 'Salmon', 'Tuna', 'Shark', 'Whale', 'Golden Fish', 'Treasure'},
    Flag = "target_fish"
})

-- Информация
Info:AddLabel('Status'):AddLabel('Inactive')
Info:AddLabel('Fish Caught: 0')
Info:AddLabel('Best Catch: None')

-- ==================== AUTO TAB ====================

AutoCatch:AddLabel('Auto Catch'):AddToggle({
    Default = false,
    Flag = "auto_catch"
})

AutoCatch:AddLabel('Catch Delay (ms)'):AddSlider({
    Min = 0,
    Max = 2000,
    Default = 100,
    Flag = "catch_delay"
})

AutoCast:AddLabel('Auto Cast'):AddToggle({
    Default = false,
    Flag = "auto_cast"
})

AutoCast:AddLabel('Cast Delay (ms)'):AddSlider({
    Min = 0,
    Max = 5000,
    Default = 500,
    Flag = "cast_delay"
})

AutoCast:AddLabel('Optimal Spot'):AddToggle({
    Default = false,
    Flag = "optimal_spot"
})

-- ==================== VISUALS TAB ====================

ESP:AddLabel('Fish ESP'):AddToggle({
    Default = false,
    Flag = "fish_esp"
})

ESP:AddLabel('Show Distance'):AddToggle({
    Default = true,
    Flag = "show_distance"
})

ESP:AddLabel('Show Rarity'):AddToggle({
    Default = true,
    Flag = "show_rarity"
})

ESP:AddLabel('ESP Color'):AddColorPicker({
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "esp_color"
})

Chams:AddLabel('Fish Chams'):AddToggle({
    Default = false,
    Flag = "fish_chams"
})

Chams:AddLabel('Chams Color'):AddColorPicker({
    Default = Color3.fromRGB(0, 150, 255),
    Flag = "chams_color"
})

Chams:AddLabel('Wallhack'):AddToggle({
    Default = false,
    Flag = "wallhack"
})

-- ==================== MISC TAB ====================

Player:AddLabel('Speed Boost'):AddSlider({
    Min = 0,
    Max = 500,
    Default = 100,
    Type = "%",
    Flag = "speed_boost"
})

Player:AddLabel('Jump Power'):AddSlider({
    Min = 0,
    Max = 200,
    Default = 50,
    Flag = "jump_power"
})

Player:AddLabel('No Clip'):AddToggle({
    Default = false,
    Flag = "noclip"
})

World:AddLabel('Time of Day'):AddDropdown({
    Default = 'Current',
    Values = {'Current', 'Day', 'Night', 'Sunset'},
    Flag = "time_of_day"
})

World:AddLabel('Weather'):AddDropdown({
    Default = 'Current',
    Values = {'Current', 'Clear', 'Rain', 'Storm'},
    Flag = "weather"
})

World:AddLabel('Remove Fog'):AddToggle({
    Default = false,
    Flag = "remove_fog"
})

-- ==================== MENU SETTINGS ====================

window.UserSettings:AddLabel("Menu Keybind"):AddKeybind({
    Default = 'Insert',
    Callback = function(v)
        window.Keybind = v
        Logging.new("keyboard", 'Changed UI keybind to ' .. tostring(v), 5)
    end,
})

window.UserSettings:AddLabel('Menu Scale'):AddDropdown({
    Default = "Default",
    Values = {"Default", 'Large', 'Mobile', 'Small'},
    Callback = function(v)
        window:SetSize(NeverLose.Scales[v])
        Logging.new("crop", 'Changed UI size to ' .. tostring(v), 5)
    end,
})

window.UserSettings:AddLabel('3D Menu'):AddToggle({
    Default = false,
    Callback = function(v)
        window:Set3DRender(v)
    end,
})

-- Уведомления при запуске
Notification.new({
    Title = "Lucky Fish",
    Content = "Script loaded successfully!",
    Duration = 5,
})

Logging.new("fish", "Pull a Lucky Fish cheat initialized", 10)

-- Обновление статуса
task.spawn(function()
    local fishCaught = 0
    local bestCatch = "None"
    
    while true do
        task.wait(2)
        
        -- Здесь должна быть логика обновления статистики
        -- Это пример, реальная логика будет добавлена позже
        
        StatusIndicator:SetRender(true)
        StatusIndicator:SetText("Active")
        StatusIndicator:SetColor('Green')
        
        task.wait(3)
        
        -- Можно добавить мигание или изменение статуса
    end
end)

print("[Lucky Fish] Script initialized successfully!")
