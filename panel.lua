-- =====================================================
-- PAINEL PRINCIPAL - ESP + AIMBOT + SISTEMA SHOW
-- =====================================================

-- ============ CARREGAR RAYFIELD UI ============
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Painel Ilha Bela",
    LoadingTitle = "Carregando...",
    LoadingSubtitle = "by SeuNome",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "IlhaBelaPanel",
        FileName = "Config"
    },
    KeySystem = false
})

-- ============ SERVIÇOS ============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============ CONFIGURAÇÕES GLOBAIS ============
local Config = {
    ESP = {
        Line = false,
        Box = false,
        HealthBar = false,
        Name = false,
        Distance = false,
        TeamCheck = true
    },
    RageAimbot = {
        Enabled = false,
        HitPart = "Head",
        FOV = 200,
        ShowFOV = false,
        TeamCheck = true
    },
    LegitAimbot = {
        Enabled = false,
        HitPart = "Head",
        FOV = 100,
        Smoothness = 0.15,
        ShowFOV = false,
        TeamCheck = true
    }
}

-- ============ ARMAZENAMENTO DE ESP ============
local ESPObjects = {}

-- ============ CÍRCULO DE FOV ============
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Radius = Config.RageAimbot.FOV
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- ============ FUNÇÃO: CRIAR ESP ============
local function createESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local data = {}

    local box = Drawing.new("Square")
    box.Visible = false
    box.Color = Color3.fromRGB(255, 255, 255)
    box.Thickness = 1
    box.Filled = false
    box.Transparency = 1
    data.Box = box

    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1
    line.Transparency = 1
    data.Line = line

    local healthBarBg = Drawing.new("Square")
    healthBarBg.Visible = false
    healthBarBg.Color = Color3.fromRGB(0, 0, 0)
    healthBarBg.Thickness = 1
    healthBarBg.Filled = true
    healthBarBg.Transparency = 1
    data.HealthBarBg = healthBarBg

    local healthBar = Drawing.new("Square")
    healthBar.Visible = false
    healthBar.Color = Color3.fromRGB(0, 255, 0)
    healthBar.Thickness = 1
    healthBar.Filled = true
    healthBar.Transparency = 1
    data.HealthBar = healthBar

    local nameText = Drawing.new("Text")
    nameText.Visible = false
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 14
    data.Name = nameText

    local distText = Drawing.new("Text")
    distText.Visible = false
    distText.Center = true
    distText.Outline = true
    distText.Color = Color3.fromRGB(255, 255, 255)
    distText.Size = 12
    data.Distance = distText

    ESPObjects[player] = data
end

local function removeESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            if obj and obj.Remove then obj:Remove() end
        end
        ESPObjects[player] = nil
    end
end

local function isEnemy(player)
    if not Config.ESP.TeamCheck then return true end
    return player.Team ~= LocalPlayer.Team
end

-- ============ LOOP ESP ============
RunService.RenderStepped:Connect(function()
    for player, data in pairs(ESPObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local humanoid = char and char:FindFirstChild("Humanoid")

        if not (hrp and head and humanoid) or humanoid.Health <= 0 or not isEnemy(player) then
            for _, obj in pairs(data) do
                if obj and obj.Visible ~= nil then obj.Visible = false end
            end
            continue
        end

        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
        local rootPos, rootOnScreen = Camera:WorldToViewportPoint(hrp.Position)

        if Config.ESP.Box and headOnScreen then
            local height = math.abs(headPos.Y - rootPos.Y) * 2
            local width = height / 2
            data.Box.Size = Vector2.new(width, height)
            data.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
            data.Box.Visible = true
        else
            data.Box.Visible = false
        end

        if Config.ESP.Line and headOnScreen then
            data.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            data.Line.To = Vector2.new(headPos.X, headPos.Y)
            data.Line.Visible = true
        else
            data.Line.Visible = false
        end

        if Config.ESP.HealthBar and headOnScreen then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local height = math.abs(headPos.Y - rootPos.Y) * 2
            local barHeight = height
            local barWidth = 2
            local xOffset = (height / 4) + 4

            data.HealthBarBg.Size = Vector2.new(barWidth, barHeight)
            data.HealthBarBg.Position = Vector2.new(headPos.X - xOffset, headPos.Y)
            data.HealthBarBg.Visible = true

            data.HealthBar.Size = Vector2.new(barWidth, barHeight * healthPercent)
            data.HealthBar.Position = Vector2.new(
                headPos.X - xOffset,
                headPos.Y + barHeight * (1 - healthPercent)
            )
            data.HealthBar.Color = Color3.fromRGB(
                math.floor(255 * (1 - healthPercent)),
                math.floor(255 * healthPercent),
                0
            )
            data.HealthBar.Visible = true
        else
            data.HealthBarBg.Visible = false
            data.HealthBar.Visible = false
        end

        if Config.ESP.Name and headOnScreen then
            data.Name.Text = player.Name
            data.Name.Position = Vector2.new(headPos.X, headPos.Y - 20)
            data.Name.Visible = true
        else
            data.Name.Visible = false
        end

        if Config.ESP.Distance and headOnScreen then
            local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
            data.Distance.Text = dist .. "m"
            data.Distance.Position = Vector2.new(headPos.X, headPos.Y + math.abs(headPos.Y - rootPos.Y) * 2 + 5)
            data.Distance.Visible = true
        else
            data.Distance.Visible = false
        end
    end
end)

-- ============ FUNÇÃO: PEGAR ALVO ============
local function getTarget(aimbotConfig)
    local closest = nil
    local shortestDist = aimbotConfig.FOV

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(aimbotConfig.HitPart)
            local humanoid = player.Character:FindFirstChild("Humanoid")

            if part and humanoid and humanoid.Health > 0 then
                if aimbotConfig.TeamCheck and player.Team == LocalPlayer.Team then
                    continue
                end

                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = part
                    end
                end
            end
        end
    end
    return closest
end

-- ============ LOOP AIMBOT ============
RunService.RenderStepped:Connect(function()
    if Config.RageAimbot.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Config.RageAimbot.FOV
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Color = Color3.fromRGB(255, 50, 50)
    elseif Config.LegitAimbot.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Radius = Config.LegitAimbot.FOV
        FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y)
        FOVCircle.Color = Color3.fromRGB(50, 255, 50)
    else
        FOVCircle.Visible = false
    end

    if Config.RageAimbot.Enabled then
        local target = getTarget(Config.RageAimbot)
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    if Config.LegitAimbot.Enabled then
        local target = getTarget(Config.LegitAimbot)
        if target then
            local currentCFrame = Camera.CFrame
            local targetCFrame = CFrame.new(currentCFrame.Position, target.Position)
            Camera.CFrame = currentCFrame:Lerp(targetCFrame, Config.LegitAimbot.Smoothness)
        end
    end
end)

-- ============ CONECTAR PLAYERS ============
for _, player in pairs(Players:GetPlayers()) do
    createESP(player)
end

Players.PlayerAdded:Connect(function(player)
    createESP(player)
end)

Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- ============ ABA: ESP ============
local ESPTab = Window:CreateTab("ESP", 4483362458)

ESPTab:CreateToggle({
    Name = "ESP Linha (Tracer)",
    CurrentValue = false,
    Flag = "ESPLinha",
    Callback = function(Value) Config.ESP.Line = Value end,
})

ESPTab:CreateToggle({
    Name = "ESP Box",
    CurrentValue = false,
    Flag = "ESPBox",
    Callback = function(Value) Config.ESP.Box = Value end,
})

ESPTab:CreateToggle({
    Name = "Barra de Vida",
    CurrentValue = false,
    Flag = "HealthBar",
    Callback = function(Value) Config.ESP.HealthBar = Value end,
})

ESPTab:CreateToggle({
    Name = "Nome do Player",
    CurrentValue = false,
    Flag = "ESPName",
    Callback = function(Value) Config.ESP.Name = Value end,
})

ESPTab:CreateToggle({
    Name = "Distância",
    CurrentValue = false,
    Flag = "ESPDistance",
    Callback = function(Value) Config.ESP.Distance = Value end,
})

ESPTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = true,
    Flag = "ESPTeamCheck",
    Callback = function(Value) Config.ESP.TeamCheck = Value end,
})

-- ============ ABA: AIMBOT ============
local AimbotTab = Window:CreateTab("Aimbot", 4483362458)

AimbotTab:CreateSection("🔴 Rage Aimbot")

AimbotTab:CreateToggle({
    Name = "Rage Aimbot",
    CurrentValue = false,
    Flag = "RageAimbot",
    Callback = function(Value)
        Config.RageAimbot.Enabled = Value
        if Value then Config.LegitAimbot.Enabled = false end
    end,
})

AimbotTab:CreateToggle({
    Name = "Mostrar FOV (Rage)",
    CurrentValue = false,
    Flag = "RageFOVShow",
    Callback = function(Value) Config.RageAimbot.ShowFOV = Value end,
})

AimbotTab:CreateSlider({
    Name = "FOV Rage",
    Range = {10, 800},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 200,
    Flag = "RageFOV",
    Callback = function(Value) Config.RageAimbot.FOV = Value end,
})

AimbotTab:CreateDropdown({
    Name = "Hit Part (Rage)",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    Flag = "RageHitPart",
    Callback = function(Option) Config.RageAimbot.HitPart = Option[1] end,
})

AimbotTab:CreateToggle({
    Name = "Team Check (Rage)",
    CurrentValue = true,
    Flag = "RageTeamCheck",
    Callback = function(Value) Config.RageAimbot.TeamCheck = Value end,
})

AimbotTab:CreateSection("🟢 Legit Aimbot")

AimbotTab:CreateToggle({
    Name = "Legit Aimbot",
    CurrentValue = false,
    Flag = "LegitAimbot",
    Callback = function(Value)
        Config.LegitAimbot.Enabled = Value
        if Value then Config.RageAimbot.Enabled = false end
    end,
})

AimbotTab:CreateToggle({
    Name = "Mostrar FOV (Legit)",
    CurrentValue = false,
    Flag = "LegitFOVShow",
    Callback = function(Value) Config.LegitAimbot.ShowFOV = Value end,
})

AimbotTab:CreateSlider({
    Name = "FOV Legit",
    Range = {10, 400},
    Increment = 5,
    Suffix = "px",
    CurrentValue = 100,
    Flag = "LegitFOV",
    Callback = function(Value) Config.LegitAimbot.FOV = Value end,
})

AimbotTab:CreateSlider({
    Name = "Suavidade (Smoothness)",
    Range = {1, 100},
    Increment = 1,
    Suffix = "%",
    CurrentValue = 15,
    Flag = "LegitSmooth",
    Callback = function(Value) Config.LegitAimbot.Smoothness = Value / 100 end,
})

AimbotTab:CreateDropdown({
    Name = "Hit Part (Legit)",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    Flag = "LegitHitPart",
    Callback = function(Option) Config.LegitAimbot.HitPart = Option[1] end,
})

AimbotTab:CreateToggle({
    Name = "Team Check (Legit)",
    CurrentValue = true,
    Flag = "LegitTeamCheck",
    Callback = function(Value) Config.LegitAimbot.TeamCheck = Value end,
})

-- ============ ABA: CONFIG ============
local ConfigTab = Window:CreateTab("Config", 4483362458)

ConfigTab:CreateButton({
    Name = "Destruir Painel",
    Callback = function()
        Rayfield:Destroy()
        for _, data in pairs(ESPObjects) do
            for _, obj in pairs(data) do
                if obj and obj.Remove then obj:Remove() end
            end
        end
        FOVCircle:Remove()
    end,
})

-- =====================================================
-- SISTEMA SHOW (MINIMIZAR/MAXIMIZAR)
-- =====================================================

local SAVE_FOLDER = "IlhaBelaPanel"
local SAVE_FILE = "showbutton_pos.json"

local function savePosition(position)
    pcall(function()
        if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end
        writefile(SAVE_FOLDER .. "/" .. SAVE_FILE, HttpService:JSONEncode({
            x = position.X.Offset,
            y = position.Y.Offset
        }))
    end)
end

local function loadPosition()
    local success, data = pcall(function()
        if isfile(SAVE_FOLDER .. "/" .. SAVE_FILE) then
            return HttpService:JSONDecode(readfile(SAVE_FOLDER .. "/" .. SAVE_FILE))
        end
        return nil
    end)
    if success and data then
        return UDim2.new(0, data.x, 0, data.y)
    end
    return UDim2.new(0, 20, 0.5, -20)
end

local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "FloatToggle"
FloatGui.ResetOnSpawn = false
FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatGui.Parent = CoreGui

local ShowButton = Instance.new("TextButton")
ShowButton.Name = "ShowButton"
ShowButton.Size = UDim2.new(0, 110, 0, 44)
ShowButton.Position = loadPosition()
ShowButton.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
ShowButton.BorderSizePixel = 0
ShowButton.Text = ""
ShowButton.AutoButtonColor = false
ShowButton.Active = true
ShowButton.Visible = false
ShowButton.Parent = FloatGui

local ShowCorner = Instance.new("UICorner")
ShowCorner.CornerRadius = UDim.new(0, 10)
ShowCorner.Parent = ShowButton

local ShowStroke = Instance.new("UIStroke")
ShowStroke.Color = Color3.fromRGB(80, 130, 200)
ShowStroke.Thickness = 1.5
ShowStroke.Parent = ShowButton

local ShowGradient = Instance.new("UIGradient")
ShowGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 45)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 75))
})
ShowGradient.Rotation = 90
ShowGradient.Parent = ShowButton

local IconLabel = Instance.new("TextLabel")
IconLabel.Size = UDim2.new(0, 26, 0, 26)
IconLabel.Position = UDim2.new(0, 10, 0.5, -13)
IconLabel.BackgroundTransparency = 1
IconLabel.Text = "⚙"
IconLabel.TextColor3 = Color3.fromRGB(100, 180, 255)
IconLabel.Font = Enum.Font.GothamBold
IconLabel.TextSize = 20
IconLabel.Parent = ShowButton

local TextLabel = Instance.new("TextLabel")
TextLabel.Size = UDim2.new(1, -42, 1, 0)
TextLabel.Position = UDim2.new(0, 40, 0, 0)
TextLabel.BackgroundTransparency = 1
TextLabel.Text = "Show"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextSize = 14
TextLabel.TextXAlignment = Enum.TextXAlignment.Left
TextLabel.Parent = ShowButton

local dragging = false
local dragStart = nil
local startPos = nil

local function clampPosition(x, y)
    local viewport = workspace.CurrentCamera.ViewportSize
    local btnWidth = ShowButton.AbsoluteSize.X
    local btnHeight = ShowButton.AbsoluteSize.Y
    x = math.clamp(x, 0, viewport.X - btnWidth)
    y = math.clamp(y, 0, viewport.Y - btnHeight)
    return x, y
end

ShowButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ShowButton.Position
        TweenService:Create(ShowStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(100, 180, 255),
            Thickness = 2
        }):Play()
    end
end)

ShowButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        TweenService:Create(ShowStroke, TweenInfo.new(0.15), {
            Color = Color3.fromRGB(80, 130, 200),
            Thickness = 1.5
        }):Play()
        savePosition(ShowButton.Position)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        local newX = startPos.X.Offset + delta.X
        local newY = startPos.Y.Offset + delta.Y
        newX, newY = clampPosition(newX, newY)
        ShowButton.Position = UDim2.new(0, newX, 0, newY)
    end
end)

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local x, y = clampPosition(ShowButton.Position.X.Offset, ShowButton.Position.Y.Offset)
    ShowButton.Position = UDim2.new(0, x, 0, y)
    savePosition(ShowButton.Position)
end)

task.wait(1)

local rayfieldGui = nil
for _, gui in pairs(CoreGui:GetChildren()) do
    if gui:IsA("ScreenGui") and gui.Name:lower():find("rayfield") then
        rayfieldGui = gui
        break
    end
end

if not rayfieldGui then
    for _, gui in pairs(CoreGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            for _, child in pairs(gui:GetDescendants()) do
                if child.Name == "Rayfield" or child.Name:lower():find("rayfield") then
                    rayfieldGui = gui
                    break
                end
            end
            if rayfieldGui then break end
        end
    end
end

local mainFrame = nil
if rayfieldGui then
    for _, descendant in pairs(rayfieldGui:GetDescendants()) do
        if descendant:IsA("Frame") and descendant.Size.X.Offset > 300 then
            mainFrame = descendant
            break
        end
    end
end

local function fadeIn(guiObject, duration)
    duration = duration or 0.2
    guiObject.Visible = true
    guiObject.GroupTransparency = 1
    TweenService:Create(guiObject, TweenInfo.new(duration), {
        GroupTransparency = 0
    }):Play()
end

local function fadeOut(guiObject, duration, callback)
    duration = duration or 0.2
    local tween = TweenService:Create(guiObject, TweenInfo.new(duration), {
        GroupTransparency = 1
    })
    tween:Play()
    tween.Completed:Connect(function()
        guiObject.Visible = false
        guiObject.GroupTransparency = 0
        if callback then callback() end
    end)
end

if mainFrame then
    mainFrame:GetPropertyChangedSignal("Visible"):Connect(function()
        if mainFrame.Visible then
            ShowButton.Visible = false
        else
            ShowButton.Visible = true
        end
    end)
end

ShowButton.MouseButton1Click:Connect(function()
    if dragging then return end
    if mainFrame then
        fadeOut(ShowButton, 0.15, function()
            fadeIn(mainFrame, 0.2)
        end)
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        if mainFrame then
            if mainFrame.Visible then
                fadeOut(mainFrame, 0.2, function()
                    fadeIn(ShowButton, 0.2)
                end)
            else
                fadeOut(ShowButton, 0.15, function()
                    fadeIn(mainFrame, 0.2)
                end)
            end
        end
    end
end)

Rayfield:LoadConfiguration()