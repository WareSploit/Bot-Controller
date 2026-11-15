local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ПРОВЕРКА НИКА
local MASTER_NAME = "TORGINFEDBRATZE"
if LocalPlayer.Name ~= MASTER_NAME then
    warn("[MASTER] Ошибка: Этот скрипт только для " .. MASTER_NAME .. ". Твой ник: " .. LocalPlayer.Name)
    return
end
print("[MASTER] Привет, " .. MASTER_NAME .. "! Пульт управления запущен.")

-- НАСТРОЙКИ GITHUB
local OWNER = "WareSploit"
local REPO = "Bot-Controller"
local TOKEN = "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"
local FILE_PATH = "command.json"
local BASE_URL = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/contents/" .. FILE_PATH

local function makeRequest(url, method, headers, body)
    local reqFunc = syn and syn.request or http and http.request or http_request or request
    if reqFunc then
        local ok, res = pcall(reqFunc, {Url = url, Method = method, Headers = headers, Body = body})
        if ok then return res.Success, res.StatusCode, res.Body end
    end
    local ok, res = pcall(function()
        return HttpService:RequestAsync({Url = url, Method = method, Headers = headers, Body = body})
    end)
    if ok then return res.Success, res.StatusCode, res.Body end
    return false, 0, ""
end

local function getHeaders()
    return {
        ["Authorization"] = "Bearer " .. TOKEN,
        ["Accept"] = "application/vnd.github+json",
        ["X-GitHub-Api-Version"] = "2022-11-28",
        ["Content-Type"] = "application/json",
    }
end

local function sendCommand(action)
    local id = tostring(tick())
    local payload = {action = action, id = id}
    
    -- Получаем SHA файла (обязательно для обновления)
    local successGet, statusGet, bodyGet = makeRequest(BASE_URL, "GET", getHeaders(), nil)
    local currentSha = nil
    if statusGet == 200 then
        currentSha = HttpService:JSONDecode(bodyGet).sha
    else
        warn("[MASTER] Ошибка получения данных файла: " .. tostring(statusGet))
        return
    end

    local bodyData = {
        message = "Command: " .. action,
        content = HttpService:Base64Encode(HttpService:JSONEncode(payload)),
        sha = currentSha
    }

    local successPut, statusPut = makeRequest(BASE_URL, "PUT", getHeaders(), HttpService:JSONEncode(bodyData))
    if successPut then
        print("[MASTER] ✅ Команда '" .. action .. "' отправлена боту!")
    else
        warn("[MASTER] ❌ Ошибка отправки: " .. tostring(statusPut))
    end
end

-- ===== GUI =====
local playerGui = LocalPlayer:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MasterMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(220, 270)
mainFrame.Position = UDim2.fromOffset(50, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 10)

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.fromOffset(10, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "BOT CONTROLLER"
titleLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

local function makeButton(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.fromOffset(10, y)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = mainFrame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local jumpBtn = makeButton("JUMP", 40, Color3.fromRGB(40, 180, 80))
jumpBtn.MouseButton1Click:Connect(function() sendCommand("jump") end)

local fwdBtn = makeButton("MOVE FORWARD", 85, Color3.fromRGB(60, 120, 200))
fwdBtn.MouseButton1Click:Connect(function() sendCommand("move_forward") end)

local backBtn = makeButton("MOVE BACK", 130, Color3.fromRGB(60, 120, 200))
backBtn.MouseButton1Click:Connect(function() sendCommand("move_back") end)

local stopBtn = makeButton("STOP", 175, Color3.fromRGB(200, 150, 40))
stopBtn.MouseButton1Click:Connect(function() sendCommand("stop") end)

local resetBtn = makeButton("RESET", 220, Color3.fromRGB(200, 60, 60))
resetBtn.MouseButton1Click:Connect(function() sendCommand("reset") end)
