--[[
    ═══════════════════════════════════════
    🎯 FORTBLOX HUB - ULTRA OPTIMIZADO
    ═══════════════════════════════════════
    Hitbox + ESP + Chest ESP
    Sin lag, máximo rendimiento
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

local hitboxSize = 15
local hitboxTransparency = 1 -- Invisible por defecto
local espConnections = {}
local hitboxParts = {}
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
    ShowDistance = true
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
    if hrp:FindFirstChild("ESP_BILLBOARD") then
        hrp.ESP_BILLBOARD:Destroy()
    end
    
    -- Crear Billboard
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_BILLBOARD"
    billboard.Parent = hrp
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 200, 0, 100)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local frame = Instance.new("Frame")
    frame.Parent = billboard
    frame.BackgroundTransparency = 1
    frame.Size = UDim2.new(1, 0, 1, 0)
    
    -- Name
    if espSettings.ShowNames then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Parent = frame
        nameLabel.BackgroundTransparency = 1
        nameLabel.Size = UDim2.new(1, 0, 0.3, 0)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 14
        nameLabel.TextColor3 = isEnemy(targetPlayer) and enemyColor or teamColor
        nameLabel.TextStrokeTransparency = 0
        nameLabel.Text = targetPlayer.Name
    end
    
    -- Distance
    if espSettings.ShowDistance then
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistanceLabel"
        distLabel.Parent = frame
        distLabel.BackgroundTransparency = 1
        distLabel.Size = UDim2.new(1, 0, 0.3, 0)
        distLabel.Position = UDim2.new(0, 0, 0.35, 0)
        distLabel.Font = Enum.Font.Gotham
        distLabel.TextSize = 12
        distLabel.TextColor3 = Color3.new(1, 1, 1)
        distLabel.TextStrokeTransparency = 0
    end
    
    -- Health
    if espSettings.ShowHealth and humanoid then
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Name = "HealthLabel"
        healthLabel.Parent = frame
        healthLabel.BackgroundTransparency = 1
        healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.7, 0)
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextSize = 12
        healthLabel.TextStrokeTransparency = 0
        
        local function updateHealth()
            if humanoid and healthLabel then
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
    
    -- Highlight
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_HIGHLIGHT"
    highlight.Parent = char
    highlight.FillTransparency = 0.7
    highlight.OutlineTransparency = 0
    highlight.FillColor = isEnemy(targetPlayer) and enemyColor or teamColor
    highlight.OutlineColor = isEnemy(targetPlayer) and enemyColor or teamColor
    
    -- Update loop OPTIMIZADO (cada 0.5s en vez de RenderStepped)
    local updateConn
    updateConn = task.spawn(function()
        while char and char.Parent and hrp.Parent do
            task.wait(0.5) -- Actualizar cada medio segundo
            
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
                local distLabel = frame:FindFirstChild("DistanceLabel")
                
                if distLabel then
                    distLabel.Text = math.floor(distance) .. "m"
                end
                
                billboard.Enabled = distance <= espSettings.MaxDistance
            end
        end
    end)
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
    
    Players.PlayerAdded:Connect(function(targetPlayer)
        targetPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if espEnabled then
                createPlayerESP(targetPlayer)
            end
        end)
    end)
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
-- 🎯 HITBOX - ULTRA OPTIMIZADO (SIN LAG)
-- ═══════════════════════════════════════

local function createCircularHitbox(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Limpiar hitbox anterior
    if hrp:FindFirstChild("HITBOX_PART") then
        hrp.HITBOX_PART:Destroy()
    end
    
    -- Solo expandir HumanoidRootPart (invisible)
    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.Massless = true
    
    -- Solo crear visual si transparency < 1
    if hitboxTransparency < 1 then
        local hitbox = Instance.new("Part")
        hitbox.Name = "HITBOX_PART"
        hitbox.Parent = hrp
        hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        hitbox.Shape = Enum.PartType.Ball
        hitbox.Transparency = hitboxTransparency
        hitbox.Color = isEnemy(targetPlayer) and enemyColor or teamColor
        hitbox.Material = Enum.Material.ForceField
        hitbox.CanCollide = false
        hitbox.Anchored = false
        hitbox.Massless = true
        hitbox.CFrame = hrp.CFrame
        
        -- Weld simple
        local weld = Instance.new("Weld")
        weld.Parent = hitbox
        weld.Part0 = hrp
        weld.Part1 = hitbox
        weld.C0 = CFrame.new(0, 0, 0)
        weld.C1 = CFrame.new(0, 0, 0)
        
        table.insert(hitboxParts, hitbox)
    end
end

local function enableHitbox()
    hitboxEnabled = true
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player and targetPlayer.Character then
            createCircularHitbox(targetPlayer)
        end
        
        targetPlayer.CharacterAdded:Connect(function()
            task.wait(0.5)
            if hitboxEnabled then
                createCircularHitbox(targetPlayer)
            end
        end)
    end
end

local function disableHitbox()
    hitboxEnabled = false
    
    -- Limpiar hitboxes visuales
    for _, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
    end
    hitboxParts = {}
    
    -- Restaurar tamaño original
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer.Character then
            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(2, 2, 1)
                hrp.Transparency = 1
                
                if hrp:FindFirstChild("HITBOX_PART") then
                    hrp.HITBOX_PART:Destroy()
                end
            end
        end
    end
end

-- ═══════════════════════════════════════
-- 📦 CHEST ESP - OPTIMIZADO
-- ═══════════════════════════════════════

local function createChestMarker(chest)
    if chest:FindFirstChild("CHEST_MARKER") then return end
    
    -- Highlight
    if chestESPSettings.ShowHighlight then
        local highlight = Instance.new("Highlight")
        highlight.Name = "CHEST_MARKER"
        highlight.Parent = chest
        highlight.FillColor = chestColor
        highlight.OutlineColor = chestColor
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
    end
    
    -- Distance (opcional)
    if chestESPSettings.ShowDistance then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "CHEST_BILLBOARD"
        billboard.Parent = chest
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 100, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        
        local distLabel = Instance.new("TextLabel")
        distLabel.Name = "DistanceLabel"
        distLabel.Parent = billboard
        distLabel.Size = UDim2.new(1, 0, 1, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.TextColor3 = Color3.new(1, 1, 1)
        distLabel.TextStrokeTransparency = 0
        distLabel.Font = Enum.Font.GothamBold
        distLabel.TextSize = 12
        
        -- Update loop optimizado
        task.spawn(function()
            while distLabel and distLabel.Parent and chest and chest.Parent do
                task.wait(1) -- Cada segundo
                
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local chestPos
                    if chest:IsA("Model") and chest.PrimaryPart then
                        chestPos = chest.PrimaryPart.Position
                    elseif chest:IsA("Part") then
                        chestPos = chest.Position
                    end
                    
                    if chestPos then
                        local dist = (chestPos - player.Character.HumanoidRootPart.Position).Magnitude
                        distLabel.Text = math.floor(dist) .. "m"
                    end
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
    task.wait(0.3)
    if chestESPEnabled then
        enableChestESP()
    end
end

-- ═══════════════════════════════════════
-- 🎨 GUI - MINIMALISTA Y EDITABLE
-- ═══════════════════════════════════════

local Window = Rayfield:CreateWindow({
    Name = "🎯 Fortblox Hub",
    LoadingTitle = "Cargando...",
    LoadingSubtitle = "by Gael Fonzar",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FortbloxHub",
        FileName = "Config"
    },
    KeySystem = false
})

-- ═══════════════════════════════════════
-- ESP TAB
-- ═══════════════════════════════════════

local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "👁️ Enable Player ESP",
    CurrentValue = false,
    Flag = "PlayerESP",
    Callback = function(v)
        if v then
            enablePlayerESP()
            Rayfield:Notify({Title = "ESP", Content = "Player ESP activado", Duration = 2})
        else
            disablePlayerESP()
        end
    end
})

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Flag = "ESPNames",
    Callback = function(v)
        espSettings.ShowNames = v
    end
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Flag = "ESPDistance",
    Callback = function(v)
        espSettings.ShowDistance = v
    end
})

ESPTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Flag = "ESPHealth",
    Callback = function(v)
        espSettings.ShowHealth = v
    end
})

ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "ESPTeamCheck",
    Callback = function(v)
        espSettings.TeamCheck = v
    end
})

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {500, 5000},
    Increment = 100,
    CurrentValue = 2000,
    Flag = "ESPMaxDist",
    Callback = function(v)
        espSettings.MaxDistance = v
    end
})

-- ═══════════════════════════════════════
-- HITBOX TAB
-- ═══════════════════════════════════════

local HitboxTab = Window:CreateTab("🎯 Hitbox", 4483362458)

HitboxTab:CreateToggle({
    Name = "🎯 Enable Hitbox",
    CurrentValue = false,
    Flag = "Hitbox",
    Callback = function(v)
        if v then
            enableHitbox()
            Rayfield:Notify({Title = "Hitbox", Content = "Hitbox activado", Duration = 2})
        else
            disableHitbox()
        end
    end
})

HitboxTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 15,
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

HitboxTab:CreateSlider({
    Name = "Visual Transparency (1=Invisible)",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 1,
    Flag = "HitboxTrans",
    Callback = function(v)
        hitboxTransparency = v
        if hitboxEnabled then
            disableHitbox()
            task.wait(0.1)
            enableHitbox()
        end
    end
})

HitboxTab:CreateLabel("💡 Tip: Usar transparency=1 para mejor rendimiento")

-- ═══════════════════════════════════════
-- CHEST TAB
-- ═══════════════════════════════════════

local ChestTab = Window:CreateTab("📦 Chest", 4483362458)

ChestTab:CreateToggle({
    Name = "📦 Enable Chest ESP",
    CurrentValue = false,
    Flag = "ChestESP",
    Callback = function(v)
        if v then
            enableChestESP()
            Rayfield:Notify({Title = "Chest ESP", Content = "Chest ESP activado", Duration = 2})
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
    CurrentValue = true,
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
        task.wait(0.5)
        enableChestESP()
        Rayfield:Notify({Title = "Refreshed", Content = "Chest scan actualizado", Duration = 2})
    end
})

-- ═══════════════════════════════════════
-- MISC TAB
-- ═══════════════════════════════════════

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

-- Success
Rayfield:Notify({
    Title = "✅ Loaded!",
    Content = "Fortblox Hub - Optimizado",
    Duration = 5
})

print("✅ Fortblox Hub loaded!")
