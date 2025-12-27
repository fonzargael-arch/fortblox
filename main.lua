--[[
    ═══════════════════════════════════════
    🎯 FORTBLOX ESP & HITBOX EXPANDER
    ═══════════════════════════════════════
    Created by: Gael Fonzar
    Game: Fortblox
    Features: ESP, Circular Hitbox, Aimbot
    ═══════════════════════════════════════
]]

-- Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Load UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Variables
local espEnabled = false
local hitboxEnabled = false
local tracersEnabled = false
local teamCheckEnabled = true
local hitboxSize = 10
local hitboxTransparency = 0.7
local espConnections = {}
local hitboxParts = {}

-- ESP Settings
local espSettings = {
    ShowNames = true,
    ShowDistance = true,
    ShowHealth = true,
    ShowBoxes = true,
    ShowTracers = true,
    TeamCheck = true,
    MaxDistance = 2000
}

-- Colors
local enemyColor = Color3.fromRGB(255, 0, 0)
local teamColor = Color3.fromRGB(0, 255, 0)

-- ═══════════════════════════════════════
-- 👁️ ESP FUNCTIONS
-- ═══════════════════════════════════════

local function isEnemy(targetPlayer)
    if not espSettings.TeamCheck then return true end
    if not targetPlayer.Team or not player.Team then return true end
    return targetPlayer.Team ~= player.Team
end

local function createESP(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local humanoid = char:FindFirstChild("Humanoid")
    
    if not hrp or not head then return end
    
    -- Remove old ESP
    if hrp:FindFirstChild("ESP_BILLBOARD") then
        hrp.ESP_BILLBOARD:Destroy()
    end
    
    -- Create Billboard GUI
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
    
    -- Name Label
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
    
    -- Distance Label
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
    
    -- Health Label
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
        
        -- Update health color based on HP
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
    
    -- Create Box ESP
    if espSettings.ShowBoxes then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_HIGHLIGHT"
        highlight.Parent = char
        highlight.FillTransparency = 0.7
        highlight.OutlineTransparency = 0
        highlight.FillColor = isEnemy(targetPlayer) and enemyColor or teamColor
        highlight.OutlineColor = isEnemy(targetPlayer) and enemyColor or teamColor
    end
    
    -- Update distance
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
            
            -- Hide if too far
            if distance > espSettings.MaxDistance then
                billboard.Enabled = false
            else
                billboard.Enabled = true
            end
        end
    end)
    
    table.insert(espConnections, updateConnection)
end

local function createTracers(targetPlayer)
    if not espSettings.ShowTracers then return end
    
    local char = targetPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Create tracer line
    local beam = Instance.new("Beam")
    beam.Name = "ESP_TRACER"
    beam.FaceCamera = true
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.Color = ColorSequence.new(isEnemy(targetPlayer) and enemyColor or teamColor)
    beam.Transparency = NumberSequence.new(0.5)
    
    local att0 = Instance.new("Attachment")
    att0.Parent = Camera
    
    local att1 = Instance.new("Attachment")
    att1.Parent = hrp
    
    beam.Attachment0 = att0
    beam.Attachment1 = att1
    beam.Parent = hrp
end

local function enableESP()
    espEnabled = true
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer ~= player then
            if targetPlayer.Character then
                createESP(targetPlayer)
                if tracersEnabled then
                    createTracers(targetPlayer)
                end
            end
            
            targetPlayer.CharacterAdded:Connect(function()
                wait(0.5)
                if espEnabled then
                    createESP(targetPlayer)
                    if tracersEnabled then
                        createTracers(targetPlayer)
                    end
                end
            end)
        end
    end
    
    table.insert(espConnections, Players.PlayerAdded:Connect(function(targetPlayer)
        if targetPlayer ~= player then
            targetPlayer.CharacterAdded:Connect(function()
                wait(0.5)
                if espEnabled then
                    createESP(targetPlayer)
                    if tracersEnabled then
                        createTracers(targetPlayer)
                    end
                end
            end)
        end
    end))
end

local function disableESP()
    espEnabled = false
    
    for _, connection in pairs(espConnections) do
        if typeof(connection) == "RBXScriptConnection" then
            connection:Disconnect()
        end
    end
    espConnections = {}
    
    for _, targetPlayer in pairs(Players:GetPlayers()) do
        if targetPlayer.Character then
            local char = targetPlayer.Character
            
            for _, obj in pairs(char:GetDescendants()) do
                if obj.Name == "ESP_BILLBOARD" or obj.Name == "ESP_HIGHLIGHT" or obj.Name == "ESP_TRACER" then
                    obj:Destroy()
                end
            end
        end
    end
end

-- ═══════════════════════════════════════
-- 🎯 CIRCULAR HITBOX EXPANDER
-- ═══════════════════════════════════════

local function createCircularHitbox(targetPlayer)
    local char = targetPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Remove old hitbox
    if hrp:FindFirstChild("HITBOX_PART") then
        hrp.HITBOX_PART:Destroy()
    end
    
    -- Create circular hitbox
    local hitbox = Instance.new("Part")
    hitbox.Name = "HITBOX_PART"
    hitbox.Parent = hrp
    hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hitbox.Shape = Enum.PartType.Ball -- CIRCULAR
    hitbox.Transparency = hitboxTransparency
    hitbox.Color = isEnemy(targetPlayer) and enemyColor or teamColor
    hitbox.Material = Enum.Material.ForceField
    hitbox.CanCollide = false
    hitbox.Anchored = false
    hitbox.Massless = true
    
    -- Weld to HumanoidRootPart
    local weld = Instance.new("WeldConstraint")
    weld.Parent = hitbox
    weld.Part0 = hitbox
    weld.Part1 = hrp
    
    table.insert(hitboxParts, hitbox)
    
    -- Make the actual HumanoidRootPart bigger for hit detection
    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hrp.Transparency = 1
    hrp.CanCollide = false
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
    
    table.insert(espConnections, Players.PlayerAdded:Connect(function(targetPlayer)
        if targetPlayer ~= player then
            targetPlayer.CharacterAdded:Connect(function()
                wait(0.5)
                if hitboxEnabled then
                    createCircularHitbox(targetPlayer)
                end
            end)
        end
    end))
end

local function disableHitbox()
    hitboxEnabled = false
    
    for _, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
    end
    hitboxParts = {}
    
    -- Reset all HumanoidRootParts
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
-- 🎨 CREATE GUI
-- ═══════════════════════════════════════

local Window = Rayfield:CreateWindow({
    Name = "🎯 Fortblox ESP & Hitbox",
    LoadingTitle = "Loading Fortblox Hub...",
    LoadingSubtitle = "by Gael Fonzar",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "FortbloxHub",
        FileName = "FortbloxConfig"
    },
    KeySystem = false
})

-- ═══════════════════════════════════════
-- ESP TAB
-- ═══════════════════════════════════════

local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)

ESPTab:CreateSection("ESP Controls")

ESPTab:CreateToggle({
    Name = "🔍 Enable ESP",
    CurrentValue = false,
    Callback = function(v)
        if v then
            enableESP()
            Rayfield:Notify({
                Title = "👁️ ESP Enabled",
                Content = "Showing all players",
                Duration = 3
            })
        else
            disableESP()
        end
    end
})

ESPTab:CreateSection("ESP Settings")

ESPTab:CreateToggle({
    Name = "Show Names",
    CurrentValue = true,
    Callback = function(v)
        espSettings.ShowNames = v
    end
})

ESPTab:CreateToggle({
    Name = "Show Distance",
    CurrentValue = true,
    Callback = function(v)
        espSettings.ShowDistance = v
    end
})

ESPTab:CreateToggle({
    Name = "Show Health",
    CurrentValue = true,
    Callback = function(v)
        espSettings.ShowHealth = v
    end
})

ESPTab:CreateToggle({
    Name = "Show Boxes",
    CurrentValue = true,
    Callback = function(v)
        espSettings.ShowBoxes = v
    end
})

ESPTab:CreateToggle({
    Name = "Show Tracers",
    CurrentValue = true,
    Callback = function(v)
        espSettings.ShowTracers = v
        tracersEnabled = v
    end
})

ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Callback = function(v)
        espSettings.TeamCheck = v
        teamCheckEnabled = v
    end
})

ESPTab:CreateSlider({
    Name = "Max ESP Distance",
    Range = {500, 5000},
    Increment = 100,
    CurrentValue = 2000,
    Callback = function(v)
        espSettings.MaxDistance = v
    end
})

ESPTab:CreateButton({
    Name = "🔄 Refresh ESP",
    Callback = function()
        if espEnabled then
            disableESP()
            wait(0.5)
            enableESP()
            Rayfield:Notify({
                Title = "🔄 Refreshed",
                Content = "ESP updated",
                Duration = 2
            })
        end
    end
})

-- ═══════════════════════════════════════
-- HITBOX TAB
-- ═══════════════════════════════════════

local HitboxTab = Window:CreateTab("🎯 Hitbox", 4483362458)

HitboxTab:CreateSection("Hitbox Expander")

HitboxTab:CreateToggle({
    Name = "🎯 Enable Circular Hitbox",
    CurrentValue = false,
    Callback = function(v)
        if v then
            enableHitbox()
            Rayfield:Notify({
                Title = "🎯 Hitbox Enabled",
                Content = "Circular hitboxes active",
                Duration = 3
            })
        else
            disableHitbox()
        end
    end
})

HitboxTab:CreateSection("Hitbox Settings")

HitboxTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 10,
    Callback = function(v)
        hitboxSize = v
        if hitboxEnabled then
            disableHitbox()
            wait(0.1)
            enableHitbox()
        end
    end
})

HitboxTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.7,
    Callback = function(v)
        hitboxTransparency = v
        for _, hitbox in pairs(hitboxParts) do
            if hitbox and hitbox.Parent then
                hitbox.Transparency = v
            end
        end
    end
})

HitboxTab:CreateButton({
    Name = "🔄 Refresh Hitboxes",
    Callback = function()
        if hitboxEnabled then
            disableHitbox()
            wait(0.5)
            enableHitbox()
            Rayfield:Notify({
                Title = "🔄 Refreshed",
                Content = "Hitboxes updated",
                Duration = 2
            })
        end
    end
})

-- ═══════════════════════════════════════
-- MISC TAB
-- ═══════════════════════════════════════

local MiscTab = Window:CreateTab("⚙️ Misc", 4483362458)

local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")

MiscTab:CreateSection("Movement")

MiscTab:CreateSlider({
    Name = "🏃 WalkSpeed",
    Range = {16, 200},
    Increment = 1,
    CurrentValue = 16,
    Callback = function(v)
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end
})

MiscTab:CreateSlider({
    Name = "🦘 JumpPower",
    Range = {50, 300},
    Increment = 5,
    CurrentValue = 50,
    Callback = function(v)
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = v
        end
    end
})

local infiniteJump = false

MiscTab:CreateToggle({
    Name = "🚀 Infinite Jump",
    CurrentValue = false,
    Callback = function(v)
        infiniteJump = v
    end
})

UserInputService.JumpRequest:Connect(function()
    if infiniteJump and hum then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

MiscTab:CreateSection("Utility")

MiscTab:CreateButton({
    Name = "🔄 Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end
})

MiscTab:CreateButton({
    Name = "🗑️ Clear All ESP/Hitbox",
    Callback = function()
        disableESP()
        disableHitbox()
        Rayfield:Notify({
            Title = "🗑️ Cleared",
            Content = "All ESP and hitboxes removed",
            Duration = 2
        })
    end
})

-- ═══════════════════════════════════════
-- INFO TAB
-- ═══════════════════════════════════════

local InfoTab = Window:CreateTab("ℹ️ Info", 4483362458)

InfoTab:CreateParagraph({
    Title = "🎯 Fortblox ESP & Hitbox",
    Content = [[
Created by: Gael Fonzar

✅ FEATURES:
• Full ESP (Names, Distance, Health)
• Highlight Boxes
• Tracers
• Circular Hitbox Expander
• Team Check
• WalkSpeed/JumpPower
• Infinite Jump

🎯 CIRCULAR HITBOX:
The hitbox is a SPHERE that makes
it easier to hit enemies!

Enjoy! 🚀
    ]]
})

-- ═══════════════════════════════════════
-- STARTUP
-- ═══════════════════════════════════════

Rayfield:Notify({
    Title = "🎯 Fortblox Hub Loaded",
    Content = "Welcome " .. player.Name .. "! ESP & Hitbox ready.",
    Duration = 5
})

print("════════════════════════════════")
print("🎯 Fortblox ESP & Hitbox Loaded!")
print("Created by: Gael Fonzar")
print("════════════════════════════════")
