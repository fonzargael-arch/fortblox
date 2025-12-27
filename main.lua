--[[
    ═══════════════════════════════════════
    🎯 FORTBLOX ULTIMATE HUB
    ═══════════════════════════════════════
    Created by: Gael Fonzar
    Features: ESP, Hitbox, Auto Loot, Chest Finder
    ═══════════════════════════════════════
]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer

-- Load UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local espEnabled = false
local hitboxEnabled = false
local chestESPEnabled = false
local weaponESPEnabled = false
local materialESPEnabled = false
local autoOpenChestsEnabled = false
local autoPickupWeaponsEnabled = false
local flyEnabled = false
local noClipEnabled = false

local hitboxSize = 15
local hitboxTransparency = 0.5
local espConnections = {}
local hitboxParts = {}
local chestMarkers = {}
local weaponMarkers = {}
local materialMarkers = {}

-- Colors
local enemyColor = Color3.fromRGB(255, 0, 0)
local teamColor = Color3.fromRGB(0, 255, 0)
local chestColor = Color3.fromRGB(255, 215, 0)
local weaponColor = Color3.fromRGB(138, 43, 226)
local materialColor = Color3.fromRGB(0, 191, 255)

-- ESP Settings
local espSettings = {
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowBoxes = true,
    TeamCheck = true,
    MaxDistance = 2000
}

-- ═══════════════════════════════════════
-- 👁️ PLAYER ESP
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
    
    if hrp:FindFirstChild("ESP_BILLBOARD") then
        hrp.ESP_BILLBOARD:Destroy()
    end
    
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
    
    if espSettings.ShowBoxes then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_HIGHLIGHT"
        highlight.Parent = char
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.FillColor = isEnemy(targetPlayer) and enemyColor or teamColor
        highlight.OutlineColor = isEnemy(targetPlayer) and enemyColor or teamColor
    end
    
    local updateConnection
    updateConnection = RunService.RenderStepped:Connect(function()
        if not char or not char.Parent or not hrp.Parent then
            updateConnection:Disconnect()
            return
        end
        
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
            local distLabel = frame:FindFirstChild("DistanceLabel")
            if distLabel then
                distLabel.Text = math.floor(distance) .. "m"
            end
            
            if distance > espSettings.MaxDistance then
                billboard.Enabled = false
            else
                billboard.Enabled = true
            end
        end
    end)
    
    table.insert(espConnections, updateConnection)
end

local function enablePlayerESP()
    espEnabled = true
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            if targetPlayer.Character then
                createPlayerESP(targetPlayer)
            end
            
            targetPlayer.CharacterAdded:Connect(function()
                wait(0.5)
                if espEnabled then
                    createPlayerESP(targetPlayer)
                end
            end)
        end
    end
    
    table.insert(espConnections, Players.PlayerAdded:Connect(function(targetPlayer)
        if targetPlayer ~= player then
            targetPlayer.CharacterAdded:Connect(function()
                wait(0.5)
                if espEnabled then
                    createPlayerESP(targetPlayer)
                end
            end)
        end
    end))
end

local function disablePlayerESP()
    espEnabled = false
    
    for _, connection in pairs(espConnections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    espConnections = {}
    
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
-- 🎯 CIRCULAR HITBOX
-- ═══════════════════════════════════════

local function createCircularHitbox(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if hrp:FindFirstChild("HITBOX_PART") then
        hrp.HITBOX_PART:Destroy()
    end
    
    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hrp.Transparency = 1
    hrp.CanCollide = false
    hrp.Massless = true
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "HITBOX_PART"
    hitbox.Parent = hrp
    hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hitbox.Shape = Enum.PartType.Ball
    hitbox.Transparency = hitboxTransparency
    hitbox.Color = isEnemy(targetPlayer) and enemyColor or teamColor
    hitbox.Material = Enum.Material.Neon
    hitbox.CanCollide = false
    hitbox.Anchored = false
    hitbox.Massless = true
    hitbox.CFrame = hrp.CFrame
    
    local weld = Instance.new("Weld")
    weld.Name = "HitboxWeld"
    weld.Parent = hitbox
    weld.Part0 = hrp
    weld.Part1 = hitbox
    weld.C0 = CFrame.new(0, 0, 0)
    weld.C1 = CFrame.new(0, 0, 0)
    
    table.insert(hitboxParts, hitbox)
    
    local updateConn
    updateConn = RunService.Heartbeat:Connect(function()
        if hitbox and hitbox.Parent and hrp and hrp.Parent then
            hitbox.CFrame = hrp.CFrame
        else
            updateConn:Disconnect()
        end
    end)
    
    table.insert(espConnections, updateConn)
end

local function enableHitbox()
    hitboxEnabled = true
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            if targetPlayer.Character then
                createCircularHitbox(targetPlayer)
            end
            
            targetPlayer.CharacterAdded:Connect(function()
                wait(0.5)
                if hitboxEnabled then
                    createCircularHitbox(targetPlayer)
                end
            end)
        end
    end
end

local function disableHitbox()
    hitboxEnabled = false
    
    for _, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
    end
    hitboxParts = {}
    
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
-- 📦 CHEST ESP & AUTO OPEN
-- ═══════════════════════════════════════

local function createChestMarker(chest)
    if chest:FindFirstChild("CHEST_MARKER") then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "CHEST_MARKER"
    highlight.Parent = chest
    highlight.FillColor = chestColor
    highlight.OutlineColor = chestColor
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "CHEST_BILLBOARD"
    billboard.Parent = chest
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 150, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    
    local label = Instance.new("TextLabel")
    label.Parent = billboard
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = chestColor
    label.TextStrokeTransparency = 0
    label.Font = Enum.Font.GothamBold
    label.TextSize = 16
    label.Text = "📦 CHEST"
    
    table.insert(chestMarkers, {chest = chest, highlight = highlight, billboard = billboard})
end

local function scanChests()
    for _, obj in pairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        if obj:IsA("Model") or obj:IsA("Part") then
            if name:find("chest") or name:find("loot") or name:find("crate") or name:find("box") then
                local isOpen = obj:FindFirstChild("Opened") or obj:GetAttribute("Opened")
                if not isOpen then
                    createChestMarker(obj)
                end
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
    
    for _, data in pairs(chestMarkers) do
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
    end
    chestMarkers = {}
end

-- Auto Open Chests
task.spawn(function()
    while task.wait(0.5) do
        if autoOpenChestsEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            
            for _, obj in pairs(Workspace:GetDescendants()) do
                local name = obj.Name:lower()
                if (obj:IsA("Model") or obj:IsA("Part")) and (name:find("chest") or name:find("loot") or name:find("crate")) then
                    if obj:IsA("Model") and obj.PrimaryPart then
                        local dist = (obj.PrimaryPart.Position - hrp.Position).Magnitude
                        if dist < 20 then
                            local clickDetector = obj:FindFirstChildOfClass("ClickDetector", true)
                            if clickDetector and fireclickdetector then
                                fireclickdetector(clickDetector)
                            end
                            
                            local proximityPrompt = obj:FindFirstChildOfClass("ProximityPrompt", true)
                            if proximityPrompt and fireproximityprompt then
                                fireproximityprompt(proximityPrompt)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ═══════════════════════════════════════
-- 🚁 FLY & NOCLIP
-- ═══════════════════════════════════════

local flySpeed = 50
local flying = false

local function startFly()
    flying = true
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local bv = Instance.new("BodyVelocity")
    bv.Name = "FlyVelocity"
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.Parent = hrp
    
    local bg = Instance.new("BodyGyro")
    bg.Name = "FlyGyro"
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.Parent = hrp
    
    local flyConn
    flyConn = RunService.Heartbeat:Connect(function()
        if not flying or not char or not hrp then
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            flyConn:Disconnect()
            return
        end
        
        local cam = Camera
        local speed = flySpeed
        
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            speed = speed * 2
        end
        
        local velocity = Vector3.new(0, 0, 0)
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            velocity = velocity + cam.CFrame.LookVector * speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            velocity = velocity - cam.CFrame.LookVector * speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            velocity = velocity - cam.CFrame.RightVector * speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            velocity = velocity + cam.CFrame.RightVector * speed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            velocity = velocity + Vector3.new(0, speed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            velocity = velocity - Vector3.new(0, speed, 0)
        end
        
        bv.Velocity = velocity
        bg.CFrame = cam.CFrame
    end)
end

local function stopFly()
    flying = false
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("FlyVelocity")
            local bg = hrp:FindFirstChild("FlyGyro")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
    end
end

-- NoClip
local noClipConn
local function enableNoClip()
    local char = player.Character
    if not char then return end
    
    noClipConn = RunService.Stepped:Connect(function()
        if noClipEnabled and char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoClip()
    if noClipConn then
        noClipConn:Disconnect()
    end
    
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

-- ═══════════════════════════════════════
-- 🎨 CREATE GUI
-- ═══════════════════════════════════════

local Window = Rayfield:CreateWindow({
    Name = "🎯 Fortblox Ultimate Hub",
    LoadingTitle = "Loading Fortblox Hub...",
    LoadingSubtitle = "by Gael Fonzar",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FortbloxUltimate",
        FileName = "FortbloxConfig"
    },
    KeySystem = false
})

-- ═══════════════════════════════════════
-- COMBAT TAB
-- ═══════════════════════════════════════

local CombatTab = Window:CreateTab("⚔️ Combat", 4483362458)

CombatTab:CreateSection("Player ESP")

CombatTab:CreateToggle({
    Name = "👁️ Enable Player ESP",
    CurrentValue = false,
    Callback = function(v)
        if v then
            enablePlayerESP()
            Rayfield:Notify({Title = "👁️ ESP ON", Content = "Player ESP enabled", Duration = 3})
        else
            disablePlayerESP()
        end
    end
})

CombatTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Callback = function(v) espSettings.ShowNames = v end
})

CombatTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Callback = function(v) espSettings.ShowDistance = v end
})

CombatTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Callback = function(v) espSettings.ShowHealth = v end
})

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v) espSettings.TeamCheck = v end
})

CombatTab:CreateSection("Hitbox Expander")

CombatTab:CreateToggle({
    Name = "🎯 Enable Circular Hitbox",
    CurrentValue = false,
    Callback = function(v)
        if v then
            enableHitbox()
            Rayfield:Notify({Title = "🎯 Hitbox ON", Content = "Circular hitboxes enabled", Duration = 3})
        else
            disableHitbox()
        end
    end
})

CombatTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(v)
        hitboxSize = v
        if hitboxEnabled then
            disableHitbox()
            wait(0.1)
            enableHitbox()
        end
    end
})

CombatTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.5,
    Callback = function(v)
        hitboxTransparency = v
        for _, hitbox in pairs(hitboxParts) do
            if hitbox and hitbox.Parent then
                hitbox.Transparency = v
            end
        end
    end
})

-- ═══════════════════════════════════════
-- LOOT TAB
-- ═══════════════════════════════════════

local LootTab = Window:CreateTab("📦 Loot", 4483362458)

LootTab:CreateSection("Chest Finder")

LootTab:CreateToggle({
    Name = "📦 Chest ESP",
    CurrentValue = false,
    Callback = function(v)
        if v then
            enableChestESP()
            Rayfield:Notify({Title = "📦 Chest ESP", Content = "Chest ESP enabled", Duration = 3})
        else
            disableChestESP()
        end
    end
})

LootTab:CreateToggle({
    Name = "🤖 Auto Open Chests",
    CurrentValue = false,
    Callback = function(v)
        autoOpenChestsEnabled = v
        Rayfield:Notify({Title = "🤖 Auto Open", Content = v and "Enabled" or "Disabled", Duration = 3})
    end
})

LootTab:CreateButton({
    Name = "🔄 Refresh Chest Scan",
    Callback = function()
        disableChestESP()
        wait(0.5)
        enableChestESP()
        Rayfield:Notify({Title = "🔄 Refreshed", Content = "Chest scan updated", Duration = 2})
    end
})

-- ═══════════════════════════════════════
-- MOVEMENT TAB
-- ═══════════════════════════════════════

local MovementTab = Window:CreateTab("🚀 Movement", 4483362458)

MovementTab:CreateSection("Speed & Jump")

MovementTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = v
        end
    end
})

MovementTab:CreateSlider({
    Name = "JumpPower",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.JumpPower = v
        end
    end
})

MovementTab:CreateSection("Fly & NoClip")

MovementTab:CreateToggle({
    Name = "🚁 Fly (WASD + Space/Ctrl)",
    CurrentValue = false,
    Callback = function(v)
        flyEnabled = v
        if v then
            startFly()
            Rayfield:Notify({Title = "🚁 Fly", Content = "Fly enabled - Use WASD", Duration = 3})
        else
            stopFly()
        end
    end
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        flySpeed = v
    end
})

MovementTab:CreateToggle({
    Name = "👻 NoClip",
    CurrentValue = false,
    Callback = function(v)
        noClipEnabled = v
        if v then
            enableNoClip()
            Rayfield:Notify({Title = "👻 NoClip", Content = "NoClip enabled", Duration = 3})
        else
            disableNoClip()
        end
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

-- Success notification
Rayfield:Notify({
    Title = "✅ Hub Loaded!",
    Content = "Fortblox Ultimate Hub ready",
    Duration = 5
})

print("✅ Fortblox Ultimate Hub loaded successfully!")
