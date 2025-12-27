--[[
    ═══════════════════════════════════════
    🎯 FORTBLOX HUB - HITBOX FIXED
    ═══════════════════════════════════════
    Hitbox invisible + ESP + Chest ESP
    ✅ ARREGLADO: Ya no se congelan los enemigos
    by Gael Fonzar
    ═══════════════════════════════════════
]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- Load UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local espEnabled = false
local hitboxEnabled = false
local chestESPEnabled = false

local hitboxSize = 10
local hitboxParts = {} -- Guardar las partes invisibles
local chestMarkers = {}

-- Colors
local enemyColor = Color3.fromRGB(255, 0, 0)
local teamColor = Color3.fromRGB(0, 255, 0)
local chestColor = Color3.fromRGB(255, 215, 0)

-- ESP Settings
local espSettings = {
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    TeamCheck = true,
    MaxDistance = 2000
}

-- Chest ESP Settings
local chestESPSettings = {
    ShowHighlight = true,
    ShowDistance = false
}

-- ═══════════════════════════════════════
-- 👁️ PLAYER ESP - OPTIMIZADO
-- ═══════════════════════════════════════

local function isEnemy(targetPlayer)
    if not espSettings.TeamCheck then return true end
    if not targetPlayer.Team or not player.Team then return true end
    return targetPlayer.Team ~= player.Team
end

local function createPlayerESP(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if not hrp then return end
    
    -- Limpiar ESP anterior
    for _, obj in pairs(char:GetChildren()) do
        if obj.Name == "ESP_BILLBOARD" or obj.Name == "ESP_HIGHLIGHT" then
            obj:Destroy()
        end
    end
    
    -- Highlight simple
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_HIGHLIGHT"
    highlight.Parent = char
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = isEnemy(targetPlayer) and enemyColor or teamColor
    highlight.OutlineColor = isEnemy(targetPlayer) and enemyColor or teamColor
    
    -- Billboard solo si se necesita
    if espSettings.ShowNames or espSettings.ShowDistance or espSettings.ShowHealth then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_BILLBOARD"
        billboard.Parent = hrp
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 200, 0, 80)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        
        local frame = Instance.new("Frame")
        frame.Parent = billboard
        frame.BackgroundTransparency = 1
        frame.Size = UDim2.new(1, 0, 1, 0)
        
        local yPos = 0
        
        -- Name
        if espSettings.ShowNames then
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Parent = frame
            nameLabel.BackgroundTransparency = 1
            nameLabel.Size = UDim2.new(1, 0, 0.33, 0)
            nameLabel.Position = UDim2.new(0, 0, yPos, 0)
            nameLabel.Font = Enum.Font.GothamBold
            nameLabel.TextSize = 14
            nameLabel.TextColor3 = isEnemy(targetPlayer) and enemyColor or teamColor
            nameLabel.TextStrokeTransparency = 0
            nameLabel.Text = targetPlayer.Name
            yPos = yPos + 0.33
        end
        
        -- Distance
        if espSettings.ShowDistance then
            local distLabel = Instance.new("TextLabel")
            distLabel.Name = "DistLabel"
            distLabel.Parent = frame
            distLabel.BackgroundTransparency = 1
            distLabel.Size = UDim2.new(1, 0, 0.33, 0)
            distLabel.Position = UDim2.new(0, 0, yPos, 0)
            distLabel.Font = Enum.Font.Gotham
            distLabel.TextSize = 12
            distLabel.TextColor3 = Color3.new(1, 1, 1)
            distLabel.TextStrokeTransparency = 0
            
            -- Update optimizado
            task.spawn(function()
                while distLabel.Parent and hrp.Parent do
                    task.wait(0.5)
                    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        distLabel.Text = math.floor(dist) .. "m"
                        billboard.Enabled = dist <= espSettings.MaxDistance
                    end
                end
            end)
            
            yPos = yPos + 0.33
        end
        
        -- Health
        if espSettings.ShowHealth and humanoid then
            local healthLabel = Instance.new("TextLabel")
            healthLabel.Name = "HealthLabel"
            healthLabel.Parent = frame
            healthLabel.BackgroundTransparency = 1
            healthLabel.Size = UDim2.new(1, 0, 0.33, 0)
            healthLabel.Position = UDim2.new(0, 0, yPos, 0)
            healthLabel.Font = Enum.Font.Gotham
            healthLabel.TextSize = 12
            healthLabel.TextStrokeTransparency = 0
            
            local function updateHealth()
                if humanoid and healthLabel.Parent then
                    local hp = math.floor(humanoid.Health)
                    local maxHp = math.floor(humanoid.MaxHealth)
                    healthLabel.Text = "HP: " .. hp .. "/" .. maxHp
                    
                    local hpPercent = hp / maxHp
                    if hpPercent > 0.6 then
                        healthLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    elseif hpPercent > 0.3 then
                        healthLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    else
                        healthLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
            
            updateHealth()
            humanoid.HealthChanged:Connect(updateHealth)
        end
    end
end

local function enablePlayerESP()
    espEnabled = true
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            createPlayerESP(targetPlayer)
        end
        
        targetPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if espEnabled then
                createPlayerESP(targetPlayer)
            end
        end)
    end
end

local function disablePlayerESP()
    espEnabled = false
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer.Character then
            for _, obj in pairs(targetPlayer.Character:GetDescendants()) do
                if obj.Name == "ESP_BILLBOARD" or obj.Name == "ESP_HIGHLIGHT" then
                    obj:Destroy()
                end
            end
        end
    end
end

-- ═══════════════════════════════════════
-- 🎯 HITBOX - ARREGLADO (SIN CONGELAR)
-- ═══════════════════════════════════════

local function createHitboxPart(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Limpiar hitbox anterior
    if char:FindFirstChild("HITBOX_PART") then
        char.HITBOX_PART:Destroy()
    end
    
    -- Crear parte invisible que sigue al HRP
    local hitboxPart = Instance.new("Part")
    hitboxPart.Name = "HITBOX_PART"
    hitboxPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hitboxPart.Transparency = 1
    hitboxPart.CanCollide = false
    hitboxPart.Massless = true
    hitboxPart.Anchored = false
    hitboxPart.Parent = char
    
    -- Weld para que siga al HRP sin afectar su tamaño
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = hitboxPart
    weld.Parent = hitboxPart
    
    -- Hacer que esta parte sea la hitbox
    hitboxPart.CanTouch = true
    
    -- Guardar referencia
    hitboxParts[targetPlayer] = hitboxPart
    
    return hitboxPart
end

local function enableHitbox()
    hitboxEnabled = true
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            createHitboxPart(targetPlayer)
        end
        
        -- Para nuevos spawns
        targetPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if hitboxEnabled then
                createHitboxPart(targetPlayer)
            end
        end)
    end
    
    -- Actualizar posiciones (backup por si el weld falla)
    task.spawn(function()
        while hitboxEnabled do
            task.wait(0.1)
            for targetPlayer, hitboxPart in pairs(hitboxParts) do
                if hitboxPart and hitboxPart.Parent and targetPlayer.Character then
                    local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and not hitboxPart:FindFirstChildOfClass("WeldConstraint") then
                        -- Si el weld se rompió, crear uno nuevo
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = hrp
                        weld.Part1 = hitboxPart
                        weld.Parent = hitboxPart
                    end
                end
            end
        end
    end)
end

local function disableHitbox()
    hitboxEnabled = false
    
    -- Eliminar todas las partes de hitbox
    for _, hitboxPart in pairs(hitboxParts) do
        if hitboxPart and hitboxPart.Parent then
            hitboxPart:Destroy()
        end
    end
    
    hitboxParts = {}
end

-- ═══════════════════════════════════════
-- 📦 CHEST ESP - OPTIMIZADO
-- ═══════════════════════════════════════

local function createChestMarker(chest)
    if chest:FindFirstChild("CHEST_MARKER") then return end
    
    -- Solo Highlight (sin billboard para mejor rendimiento)
    if chestESPSettings.ShowHighlight then
        local highlight = Instance.new("Highlight")
        highlight.Name = "CHEST_MARKER"
        highlight.Parent = chest
        highlight.FillColor = chestColor
        highlight.OutlineColor = chestColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
    end
    
    -- Distance opcional
    if chestESPSettings.ShowDistance then
        local chestPart = chest:IsA("Model") and chest.PrimaryPart or chest
        if not chestPart then return end
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CHEST_BILLBOARD"
        billboard.Parent = chestPart
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 80, 0, 25)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Parent = billboard
        distLabel.Size = UDim2.new(1, 0, 1, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.new(1, 1, 1)
        distLabel.TextStrokeTransparency = 0
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        
        -- Update cada 1 segundo
        task.spawn(function()
            while distLabel.Parent and chestPart.Parent do
                task.wait(1)
                
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (chestPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                end
            end
        end)
    end
    
    table.insert(chestMarkers, chest)
end

local function scanChests()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if (obj:IsA("Model") or obj:IsA("Part")) and 
           (name:find("chest") or name:find("loot") or name:find("crate") or name:find("box")) then
            local isOpen = obj:FindFirstChild("Opened") or obj:GetAttribute("Opened")
            if not isOpen then
                createChestMarker(obj)
            end
        end
    end
end

local function enableChestESP()
    chestESPEnabled = true
    scanChests()
end

local function disableChestESP()
    chestESPEnabled = false
    
    for _, chest in pairs(chestMarkers) do
        if chest and chest.Parent then
            local marker = chest:FindFirstChild("CHEST_MARKER")
            local billboard = chest:FindFirstChild("CHEST_BILLBOARD")
            if marker then marker:Destroy() end
            if billboard then billboard:Destroy() end
        end
    end
    chestMarkers = {}
end

local function updateChestESP()
    disableChestESP()
    task.wait(0.2)
    if chestESPEnabled then
        enableChestESP()
    end
end

-- ═══════════════════════════════════════
-- 🎨 GUI
-- ═══════════════════════════════════════

local Window = Rayfield:CreateWindow({
    Name = "🎯 Fortblox Hub - Fixed",
    LoadingTitle = "Cargando...",
    LoadingSubtitle = "by Gael Fonzar",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FortbloxHub",
        FileName = "Config"
    },
    KeySystem = false
})

-- ESP TAB
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "👁️ Enable Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(v)
        if v then
            enablePlayerESP()
            Rayfield:Notify({Title = "ESP", Content = "Activado", Duration = 2})
        else
            disablePlayerESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ESPNames",
    Callback = function(v) espSettings.ShowNames = v end
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ESPDistance",
    Callback = function(v) espSettings.ShowDistance = v end
})

ESPTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function(v) espSettings.ShowHealth = v end
})

ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "ESPTeamCheck",
    Callback = function(v) espSettings.TeamCheck = v end
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {500, 5000},
    Increment = 100,
    CurrentValue = 2000,
    Flag = "ESPMaxDist",
    Callback = function(v) espSettings.MaxDistance = v end
})

-- HITBOX TAB
local HitboxTab = Window:CreateTab("🎯 Hitbox", 4483362458)

HitboxTab:CreateToggle({
    Name = "🎯 Enable Hitbox (Fixed)",
    CurrentValue = false,
    Flag = "Hitbox",
    Callback = function(v)
        if v then
            enableHitbox()
            Rayfield:Notify({Title = "Hitbox", Content = "✅ Activado (Sin congelar)", Duration = 2})
        else
            disableHitbox()
        end
    end
})

HitboxTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 10,
    Flag = "HitboxSize",
    Callback = function(v)
        hitboxSize = v
        if hitboxEnabled then
            disableHitbox()
            task.wait(0.1)
            enableHitbox()
        end
    end
})

HitboxTab:CreateLabel("✅ Hitbox arreglado - Ya no congela")
HitboxTab:CreateLabel("✅ Usa WeldConstraint en vez de Size")
HitboxTab:CreateLabel("✅ 100% invisible y sin lag")

-- CHEST TAB
local ChestTab = Window:CreateTab("📦 Chest", 4483362458)

ChestTab:CreateToggle({
    Name = "📦 Enable Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(v)
        if v then
            enableChestESP()
            Rayfield:Notify({Title = "Chest ESP", Content = "Activado", Duration = 2})
        else
            disableChestESP()
        end
    end
})

ChestTab:CreateToggle({
    Name = "Show Highlight",
    CurrentValue = true,
    Flag = "ChestHighlight",
    Callback = function(v)
        chestESPSettings.ShowHighlight = v
        updateChestESP()
    end
})

ChestTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = false,
    Flag = "ChestDistance",
    Callback = function(v)
        chestESPSettings.ShowDistance = v
        updateChestESP()
    end
})

ChestTab:CreateButton({
    Name = "🔄 Refresh Scan",
    Callback = function()
        disableChestESP()
        task.wait(0.3)
        enableChestESP()
        Rayfield:Notify({Title = "Refreshed", Content = "Actualizado", Duration = 2})
    end
})

-- MISC TAB
local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

MiscTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end
})

MiscTab:CreateButton({
    Name = "🗑️ Destroy GUI",
    Callback = function()
        Rayfield:Destroy()
    end
})

MiscTab:CreateLabel("✅ ARREGLADO: Sin congelamiento")
MiscTab:CreateLabel("🎯 Método: WeldConstraint")
MiscTab:CreateLabel("⚡ Performance: Óptimo")

-- Success
Rayfield:Notify({
    Title = "✅ Loaded!",
    Content = "Hitbox arreglado - Sin congelar",
    Duration = 5
})

print("✅ Fortblox Hub - Hitbox Fixed!")
print("✅ Ya no se congelan los enemigos")
