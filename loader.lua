-- =====================================================
-- LOADER COM KEYAUTH - ILHA BELA PANEL
-- =====================================================

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

-- =====================================================
-- ⚙️ CONFIGURAÇÕES DO KEYAUTH (TROQUE AQUI)
-- =====================================================
local KeyAuthConfig = {
    name = "ILHA BElA SCRIPT",        -- ← Nome do App no KeyAuth
    ownerid = "eQ69xJsRh6",     -- ← Owner ID (Account Settings)
    secret = "ee03ad329bf577a88c690537a7851c6979b06601bc20bc25119aea496c2c847a",        -- ← App Secret (App Credentials)
    version = "1.0",
    apiUrl = "https://keyauth.win/api/1.3/"
}

-- Link do painel protegido (panel.lua hospedado)
local PANEL_URL = "https://raw.githubusercontent.com/thiago19car-commits/Script/main/panel.lua"

-- =====================================================
-- SALVAR KEY (opcional, pra auto-login)
-- =====================================================
local SAVE_FOLDER = "IlhaBelaPanel"
local KEY_FILE = "saved_key.txt"

local function saveKey(key)
    pcall(function()
        if not isfolder(SAVE_FOLDER) then makefolder(SAVE_FOLDER) end
        writefile(SAVE_FOLDER .. "/" .. KEY_FILE, key)
    end)
end

local function loadSavedKey()
    local success, key = pcall(function()
        if isfile(SAVE_FOLDER .. "/" .. KEY_FILE) then
            return readfile(SAVE_FOLDER .. "/" .. KEY_FILE)
        end
        return nil
    end)
    return success and key or nil
end

-- =====================================================
-- API DO KEYAUTH
-- =====================================================
local sessionId = nil

local function keyAuthRequest(params)
    local query = ""
    for k, v in pairs(params) do
        query = query .. "&" .. k .. "=" .. HttpService:UrlEncode(tostring(v))
    end
    local url = KeyAuthConfig.apiUrl .. "?" .. query:sub(2)

    local success, response = pcall(function()
        return game:HttpGet(url)
    end)

    if success then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(response)
        end)
        if ok then return data end
    end
    return nil
end

local function initKeyAuth() 
    local result = keyAuthRequest({
        type = "init",
        ver = KeyAuthConfig.version,
        name = KeyAuthConfig.name,
        ownerid = KeyAuthConfig.ownerid
    })
    if result and result.sessionid then
        sessionId = result.sessionid
        return true
    end
    return false
end

local function validateKey(key)
    if not sessionId then
        if not initKeyAuth() then
            return false, "Erro ao conectar no servidor de auth"
        end
    end

    local result = keyAuthRequest({
        type = "license",
        key = key,
        sessionid = sessionId,
        name = KeyAuthConfig.name,
        ownerid = KeyAuthConfig.ownerid,
        ver = KeyAuthConfig.version
    })

    if result then
        if result.success then
            return true, "Autenticado"
        else
            return false, result.message or "Key inválida"
        end
    end
    return false, "Erro de conexão"
end

-- =====================================================
-- INTERFACE DA TELA DE KEY
-- =====================================================
local AuthGui = Instance.new("ScreenGui")
AuthGui.Name = "KeyAuthScreen"
AuthGui.ResetOnSpawn = false
AuthGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AuthGui.Parent = CoreGui

local AuthFrame = Instance.new("Frame")
AuthFrame.Size = UDim2.new(0, 350, 0, 230)
AuthFrame.Position = UDim2.new(0.5, -175, 0.5, -115)
AuthFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
AuthFrame.BorderSizePixel = 0
AuthFrame.Active = true
AuthFrame.Draggable = true
AuthFrame.Parent = AuthGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = AuthFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(80, 130, 200)
UIStroke.Thickness = 1.5
UIStroke.Parent = AuthFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 50)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🔐 Acesso Restrito"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 18
TitleLabel.Parent = AuthFrame

local SubLabel = Instance.new("TextLabel")
SubLabel.Size = UDim2.new(1, 0, 0, 25)
SubLabel.Position = UDim2.new(0, 0, 0, 45)
SubLabel.BackgroundTransparency = 1
SubLabel.Text = "Insira sua Key para continuar"
SubLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
SubLabel.Font = Enum.Font.Gotham
SubLabel.TextSize = 12
SubLabel.Parent = AuthFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(0.85, 0, 0, 42)
KeyBox.Position = UDim2.new(0.075, 0, 0, 80)
KeyBox.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
KeyBox.BorderSizePixel = 0
KeyBox.PlaceholderText = "Cole sua Key aqui..."
KeyBox.Text = ""
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
KeyBox.Font = Enum.Font.Gotham
KeyBox.TextSize = 14
KeyBox.ClearTextOnFocus = false
KeyBox.Parent = AuthFrame

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 8)
KeyCorner.Parent = KeyBox

local ConfirmBtn = Instance.new("TextButton")
ConfirmBtn.Size = UDim2.new(0.85, 0, 0, 42)
ConfirmBtn.Position = UDim2.new(0.075, 0, 0, 135)
ConfirmBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
ConfirmBtn.BorderSizePixel = 0
ConfirmBtn.Text = "✅ Confirmar Key"
ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmBtn.Font = Enum.Font.GothamBold
ConfirmBtn.TextSize = 14
ConfirmBtn.Parent = AuthFrame

local ConfirmCorner = Instance.new("UICorner")
ConfirmCorner.CornerRadius = UDim.new(0, 8)
ConfirmCorner.Parent = ConfirmBtn

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 20)
StatusLabel.Position = UDim2.new(0, 0, 0, 195)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = AuthFrame

-- =====================================================
-- LÓGICA DE AUTENTICAÇÃO
-- =====================================================
ConfirmBtn.MouseButton1Click:Connect(function()
    local key = KeyBox.Text:gsub("%s+", "")

    if key == "" then
        StatusLabel.Text = "❌ Insira uma key válida"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        return
    end

    StatusLabel.Text = "⏳ Verificando..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    ConfirmBtn.Text = "Verificando..."
    ConfirmBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 100)

    task.wait(0.5)

    local success, message = validateKey(key)

    if success then
        StatusLabel.Text = "✅ Acesso concedido!"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        ConfirmBtn.Text = "Carregando painel..."

        saveKey(key)
        task.wait(0.8)
        AuthGui:Destroy()

        -- Carrega o painel principal
        local ok, err = pcall(function()
            loadstring(game:HttpGet(PANEL_URL))()
        end)
        if not ok then
            warn("Erro ao carregar painel: " .. tostring(err))
        end
    else
        StatusLabel.Text = "❌ " .. message
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        ConfirmBtn.Text = "✅ Confirmar Key"
        ConfirmBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 180)
    end
end)

-- Auto-login (opcional)
local savedKey = loadSavedKey()
if savedKey and savedKey ~= "" then
    KeyBox.Text = savedKey
end

initKeyAuth()
