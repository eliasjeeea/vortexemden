local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "JeeeaHub",
    LoadingTitle = "JeeeaHub",
    LoadingSubtitle = "Load GUI...",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "JeeeaHubConfig"
    },
    Discord = {
        Enabled = false,
        Invite = "DiscordInviteCode",
        RememberJoins = true
    },
    KeySystem = false
})

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local isSlowingFall = false
local stateChangedConnection
local characterAddedConnection

local function activateAntiFallDamage()
    if stateChangedConnection or characterAddedConnection then return end 

    local function slowFall()
        if isSlowingFall then return end 
        isSlowingFall = true

        while humanoid:GetState() == Enum.HumanoidStateType.Freefall do
            rootPart.Velocity = Vector3.new(rootPart.Velocity.X, math.max(rootPart.Velocity.Y, -10), rootPart.Velocity.Z)
            wait(0.1) 
        end

        isSlowingFall = false
    end

    stateChangedConnection = humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Freefall then
            slowFall()
        end
    end)

    characterAddedConnection = player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid")
        rootPart = character:WaitForChild("HumanoidRootPart")
    end)
end

local function deactivateAntiFallDamage()
    if stateChangedConnection then
        stateChangedConnection:Disconnect()
        stateChangedConnection = nil
    end

    if characterAddedConnection then
        characterAddedConnection:Disconnect()
        characterAddedConnection = nil
    end

    isSlowingFall = false
    print("Anti Fall Damage deaktiviert")
end

local PlayerTab = Window:CreateTab("Player", 4483362458)

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local userInputService = game:GetService("UserInputService")
local runService = game:GetService("RunService")

local flying = false
local speed = 50
local moveDirection = Vector3.zero 
local bodyVelocity = nil
local activeKeys = {} 

local function startFlying()
    if flying then return end
    flying = true
    moveDirection = Vector3.zero 
    activeKeys = {} 

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(500000, 500000, 500000) 
    bodyVelocity.Velocity = Vector3.zero 
    bodyVelocity.Parent = humanoidRootPart
end

-- Funktion: Fliegen stoppen
local function stopFlying()
    if not flying then return end
    flying = false

    moveDirection = Vector3.zero
    activeKeys = {} 
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end
end

local function updateMoveDirection()
    moveDirection = Vector3.zero
    if activeKeys["W"] then
        moveDirection = moveDirection + Vector3.new(0, 0, 1)
    end
    if activeKeys["S"] then
        moveDirection = moveDirection + Vector3.new(0, 0, -1)
    end
    if activeKeys["A"] then
        moveDirection = moveDirection + Vector3.new(-1, 0, 0)
    end
    if activeKeys["D"] then
        moveDirection = moveDirection + Vector3.new(1, 0, 0)
    end
    if activeKeys["Space"] then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if activeKeys["LeftControl"] then
        moveDirection = moveDirection + Vector3.new(0, -1, 0)
    end
end

userInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == Enum.KeyCode.V then
        if flying then
            stopFlying()
        else
            startFlying()
        end
    end

    if flying then
        local keyName = input.KeyCode.Name
        activeKeys[keyName] = true
        updateMoveDirection()
    end
end)

userInputService.InputEnded:Connect(function(input)
    if flying then
        local keyName = input.KeyCode.Name
        activeKeys[keyName] = nil
        updateMoveDirection()
    end
end)

runService.Heartbeat:Connect(function()
    if flying and bodyVelocity then
        
        local cameraLookVector = camera.CFrame.LookVector 
        local cameraRightVector = camera.CFrame.RightVector 
        local cameraUpVector = camera.CFrame.UpVector
        
        local move = (cameraLookVector * moveDirection.Z + cameraRightVector * moveDirection.X + cameraUpVector * moveDirection.Y) * speed

        bodyVelocity.Velocity = move
    end
end)


PlayerTab:CreateToggle({
    Name = "Fliegen (V zum Aktivieren/Deaktivieren)",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            startFlying()
        else
            stopFlying()
        end
    end
})

PlayerTab:CreateToggle({
    Name = "Anti Fall Damage",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            activateAntiFallDamage()
            print("Anti Fall Damage aktiviert")
        else
            deactivateAntiFallDamage()
        end
    end
})

local espEnabled = false
local showName = false
local showDistance = false
local showTeam = false
local showHealth = false

local function createESP(player)
    local esp = Instance.new("BillboardGui", player.Character)
    esp.Name = "CustomESP"
    esp.Size = UDim2.new(0, 200, 0, 50)
    esp.AlwaysOnTop = true

    local espText = Instance.new("TextLabel", esp)
    espText.Size = UDim2.new(1, 0, 1, 0)
    espText.BackgroundTransparency = 1
    espText.TextColor3 = Color3.new(1, 1, 1)
    espText.TextStrokeTransparency = 0
    espText.Font = Enum.Font.Gotham
    espText.TextSize = 14

    game:GetService("RunService").RenderStepped:Connect(function()
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local text = ""

            if showName then
                text = text .. "Name: " .. player.Name .. "\n"
            end

            if showDistance then
                local distance = (player.Character.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                text = text .. "Distance: " .. math.floor(distance) .. " studs\n"
            end

            if showTeam and player.Team then
                text = text .. "Team: " .. player.Team.Name .. "\n"
            end

            if showHealth and player.Character:FindFirstChild("Humanoid") then
                local health = player.Character.Humanoid.Health
                local maxHealth = player.Character.Humanoid.MaxHealth
                text = text .. "Health: " .. math.floor(health) .. "/" .. math.floor(maxHealth) .. "\n"
            end

            espText.Text = text
        else
            esp:Destroy()
        end
    end)
end

local function toggleESP(enabled)
    espEnabled = enabled

    for _, player in pairs(game.Players:GetPlayers()) do
        if enabled then
            createESP(player)
        else
            if player.Character and player.Character:FindFirstChild("CustomESP") then
                player.Character.CustomESP:Destroy()
            end
        end
    end
end

local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateToggle({
    Name = "ESP Aktivieren",
    CurrentValue = false,
    Callback = function(Value)
        toggleESP(Value)
    end
})

VisualsTab:CreateToggle({
    Name = "Name anzeigen",
    CurrentValue = false,
    Callback = function(Value)
        showName = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Entfernung anzeigen",
    CurrentValue = false,
    Callback = function(Value)
        showDistance = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Job anzeigen",
    CurrentValue = false,
    Callback = function(Value)
        showTeam = Value
    end
})

VisualsTab:CreateToggle({
    Name = "Gesundheit anzeigen",
    CurrentValue = false,
    Callback = function(Value)
        showHealth = Value
    end
})

local function teleportTo(position)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
    else
        warn("HumanoidRootPart not Fround")
    end
end


local TeleportTab = Window:CreateTab("Teleport", 4483362458)

TeleportTab:CreateButton({
    Name = "Polizei",
    Callback = function()
        teleportTo(Vector3.new(-78, 80, 783)) 
    end
})

TeleportTab:CreateButton({
    Name = "Feuerwehr",
    Callback = function()
        teleportTo(Vector3.new(-1749, 47, 394)) 
    end
})

TeleportTab:CreateButton({
    Name = "Medic",
    Callback = function()
        teleportTo(Vector3.new(442, 45, -1724)) 
    end
})

TeleportTab:CreateButton({
    Name = "ADAC",
    Callback = function()
        teleportTo(Vector3.new(300, 10, 300)) 
    end
})

TeleportTab:CreateButton({
    Name = "Dealer 1",
    Callback = function()
        teleportTo(Vector3.new(400, 10, 400)) 
    end
})

TeleportTab:CreateButton({
    Name = "Dealer 2",
    Callback = function()
        teleportTo(Vector3.new(500, 10, 500)) 
    end
})

local MiscTab = Window:CreateTab("Misc", 4483362458)

MiscTab:CreateButton({
    Name = "Serverhop",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer

        local function serverHop()
            local placeId = game.PlaceId
            TeleportService:Teleport(placeId, player)
        end

        serverHop()
    end
})
