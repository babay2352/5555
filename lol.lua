local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local Window = OrionLib:MakeWindow({Name = "SkinChanger | TS", HidePremium = true,IntroEnabled = false, SaveConfig = true, ConfigFolder = "TSSkin"})

-- Переменные
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")

local HandModels = ReplicatedStorage:WaitForChild("HandModels")
local Cache = ReplicatedFirst:WaitForChild("Cache")

local selectedWeapon = nil
local selectedSkin = nil

-- Таб
local SkinChangerTab = Window:MakeTab({
	Name = "SkinChanger",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Список оружия
local weapons = {
	"Blunderbuss","Bow","AR15","C9","CrossBow","GaussRifle","Hmar","Hammer","IronHammer","StoneHammer",
	"M4A1","LeverActionRifle","PipePistol","PipeSMG","PumpShotgun","SCAR","SVD","SteelHammer","USP9","UZI"
}

-- Список скинов
local skins = {
	"AmongUs","Asylum","Banana","BlackAndWhite","Bones","Bree","Checkerboard","Corruption","CyberNet","Danger","Eyes",
	"Floral","ForestCamo","Frost","FrostCamo","Frozen","Galaxy","Golden","Grass","GreenWebbed","Groovy","GunCamo",
	"Imperial","Jack","Magma","Matrix","Melon","Obsidian","PinkCamo","RadioActive","Rainbow","Scale","Slate",
	"SpongeBob","Steff","Studs","Trippy","Troll","Universe","Void","Water","Webbed","Woodland"
}

-- Функция копирования текстур/материалов/мешей
local function ApplyTextures(sourceModel, targetModel)
	for _, sourcePart in ipairs(sourceModel:GetDescendants()) do
		if sourcePart:IsA("BasePart") then
			local targetPart = targetModel:FindFirstChild(sourcePart.Name, true)
			if targetPart and targetPart:IsA("BasePart") then
				targetPart.Color = sourcePart.Color
				targetPart.Material = sourcePart.Material

				-- SurfaceAppearance
				for _, oldSA in ipairs(targetPart:GetChildren()) do
					if oldSA:IsA("SurfaceAppearance") then oldSA:Destroy() end
				end
				for _, sourceSA in ipairs(sourcePart:GetChildren()) do
					if sourceSA:IsA("SurfaceAppearance") then
						sourceSA:Clone().Parent = targetPart
					end
				end

				-- Mesh
				for _, oldMesh in ipairs(targetPart:GetChildren()) do
					if oldMesh:IsA("SpecialMesh") then oldMesh:Destroy() end
				end
				for _, sourceMesh in ipairs(sourcePart:GetChildren()) do
					if sourceMesh:IsA("SpecialMesh") then
						sourceMesh:Clone().Parent = targetPart
					end
				end

				-- Decal / Texture
				for _, oldDecal in ipairs(targetPart:GetChildren()) do
					if oldDecal:IsA("Decal") or oldDecal:IsA("Texture") then
						oldDecal:Destroy()
					end
				end
				for _, sourceDecal in ipairs(sourcePart:GetChildren()) do
					if sourceDecal:IsA("Decal") or sourceDecal:IsA("Texture") then
						sourceDecal:Clone().Parent = targetPart
					end
				end
			end
		end
	end
end

-- Применение скина
local function ApplySkin()
	if not selectedWeapon or not selectedSkin then return end

	local modelName = selectedWeapon .. "_" .. selectedSkin
	local skinModel = Cache:FindFirstChild(modelName)

	if skinModel and skinModel:FindFirstChild(selectedWeapon) then
		local targetWeapon = HandModels:FindFirstChild(selectedWeapon)
		if targetWeapon then
			ApplyTextures(skinModel[selectedWeapon], targetWeapon)
			print("[SkinChanger] Скин применён: " .. modelName)
			selectedWeapon = nil
			selectedSkin = nil
		else
			warn("[SkinChanger] Оружие " .. selectedWeapon .. " не найдено в HandModels!")
		end
	else
		warn("[SkinChanger] Модель " .. modelName .. " не найдена в Cache!")
	end
end

-- Создаём dropdown для каждого оружия
for _, weapon in ipairs(weapons) do
	SkinChangerTab:AddDropdown({
		Name = weapon,
		Default = "Выбери скин",
        Flag = "mode",
        Save = true,
		Options = skins,
		Callback = function(skin)
			selectedWeapon = weapon
			selectedSkin = skin
			ApplySkin()
		end
	})
end

-- ===== Оптимизированная анимация текстур =====
local ignorePath = Workspace:WaitForChild("Const"):WaitForChild("Ignore")
local fpsArmsFolder = ignorePath:WaitForChild("FPSArms") -- добавляем FPSArms
local textureSpeedU = 0.0002
local textureSpeedV = 0.0002
local animatedModels = {}
local allTextures = {}
local animationEnabled = false -- управление включением/выключением

local function findMeshPartsWithTextures(model)
    local meshParts = {}
    for _, obj in pairs(model:GetDescendants()) do
        if obj:IsA("MeshPart") then
            for _, child in pairs(obj:GetChildren()) do
                if child:IsA("Texture") then
                    table.insert(meshParts, {meshPart = obj, texture = child})
                end
            end
        end
    end
    return meshParts
end

-- Обработка модели и всех её потомков
local function handleModelRecursively(model)
    if animatedModels[model] then return end
    local meshPartsWithTextures = findMeshPartsWithTextures(model)
    if #meshPartsWithTextures > 0 then
        for _, entry in ipairs(meshPartsWithTextures) do
            table.insert(allTextures, entry)
        end
        animatedModels[model] = true
    end
    for _, child in ipairs(model:GetChildren()) do
        handleModelRecursively(child)
    end
end

-- Подключение к событиям появления новых объектов в Ignore и FPSArms
ignorePath.ChildAdded:Connect(function(child)
    if child.Name == "Hammer" or child.Name == "FPSArms" then
        handleModelRecursively(child)
    end
end)

fpsArmsFolder.ChildAdded:Connect(function(child)
    if child:IsA("Model") then
        handleModelRecursively(child)
    end
end)

-- Инициализация для уже существующих моделей при старте
for _, child in ipairs(ignorePath:GetChildren()) do
    if child.Name == "Hammer" or child.Name == "FPSArms" then
        handleModelRecursively(child)
    end
end
for _, child in ipairs(fpsArmsFolder:GetChildren()) do
    if child:IsA("Model") then
        handleModelRecursively(child)
    end
end

-- Heartbeat для анимации текстур
RunService.Heartbeat:Connect(function()
    if not animationEnabled then return end
    for _, entry in ipairs(allTextures) do
        local texture = entry.texture
        texture.OffsetStudsU = (texture.OffsetStudsU + textureSpeedU) % texture.StudsPerTileU
        texture.OffsetStudsV = (texture.OffsetStudsV + textureSpeedV) % texture.StudsPerTileV
    end
end)


-- Toggle для включения/выключения анимации текстур
SkinChangerTab:AddToggle({
    Name = "Анимация текстур",
    Default = false,
    Callback = function(value)
        animationEnabled = value
        if animationEnabled then
            print("[SkinChanger] Анимация текстур включена!")
        else
            print("[SkinChanger] Анимация текстур выключена!")
        end
    end
})

local Misc = Window:MakeTab({
	Name = "Misc",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

Misc:AddToggle({
	Name = "Убрать туман",
	Default = false,
	Callback = function(Value)
		if Value then
			-- Fog
			Lighting.FogEnd = 9e9
			Lighting.FogStart = 9e9
			Lighting.FogColor = Color3.fromRGB(255, 255, 255)

			-- Shadows / Environment
			Lighting.GlobalShadows = false
			Lighting.EnvironmentDiffuseScale = 0
			Lighting.EnvironmentSpecularScale = 0

			-- Удаляем эффекты
			for _, effect in pairs({"Atmosphere", "Bloom", "ColorCorrection", "SunRays", "DepthOfField"}) do
				if Lighting:FindFirstChild(effect) then
					Lighting[effect]:Destroy()
				end
			end

			-- Частицы
			for _, v in pairs(Workspace:GetDescendants()) do
				if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") then
					v.Enabled = false
				end
			end

			print("[Misc] Туман и эффекты отключены")
		else
			-- Здесь можно добавить восстановление, если нужно
			print("[Misc] Туман и эффекты восстановление не реализовано")
		end
	end    
})

Misc:AddToggle({
	Name = "Убрать траву",
	Default = false,
	Callback = function(Value)
		sethiddenproperty(Workspace.Terrain, "Decoration", not Value)
		print("[Misc] Трава убрана/восстановлена")
	end    
})

Misc:AddToggle({
	Name = "Убрать листья деревьев",
	Default = false,
	Callback = function(Value)
		local objectsToRemove = {
			"Fir3_Leaves",
			"Elm1_Leaves", 
			"Palm1_Leaves", 
			"Birch1_Leaves", 
		}

		local function removeObject(objectName)
			for _, descendant in pairs(Workspace:GetDescendants()) do
				if descendant.Name == objectName then
					descendant:Destroy()
				end
			end
			for _, descendant in pairs(ReplicatedStorage:GetDescendants()) do
				if descendant.Name == objectName then
					descendant:Destroy()
				end
			end
			for _, descendant in pairs(ServerStorage:GetDescendants()) do
				if descendant.Name == objectName then
					descendant:Destroy()
				end
			end
		end

		if Value then
			for _, objectName in ipairs(objectsToRemove) do
				removeObject(objectName)
			end
			print("[Misc] Листья деревьев удалены")
		else
			print("[Misc] Восстановление деревьев не реализовано")
		end
	end    
})

Misc:AddButton({
	Name = "Поставить день",
	Callback = function()
        -- Устанавливаем время на 14:00
        Lighting.ClockTime = 14
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

        print("[Misc] Время установлено на 14:00 (день)")
	end    
})


OrionLib:Init()
