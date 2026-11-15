print("[MASTER] Script loaded.")

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local MASTER_NAME = "TORGINFEDBRATZE"

if LocalPlayer.Name ~= MASTER_NAME then
    warn("[MASTER] Error: This script is for " .. MASTER_NAME .. " only. Your name: " .. LocalPlayer.Name)
    return
end

print("[MASTER] User verified: " .. MASTER_NAME)

local OWNER = "WareSploit"
local REPO = "Bot-Controller"
local TOKEN = "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"
local FILE_PATH = "command.json"
local BASE_URL = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/contents/" .. FILE_PATH

local function makeRequest(url, method, headers, body)
    local reqFunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
    if reqFunc then
        local res = reqFunc({
            Url = url,
            Method = method,
            Headers = headers,
            Body = body
        })
        return res.Success, res.StatusCode, res.Body
    else
        local ok, res = pcall(function()
            return HttpService:RequestAsync({
                Url = url,
                Method = method,
                Headers = headers,
                Body = body
            })
        end)
        if ok then
            return res.Success, res.StatusCode, res.Body
        else
            warn("[MASTER] Error: No HTTP request method available and HttpService is blocked.")
            return false, 0, ""
        end
    end
end

local function getHeaders()
    return {
        ["Authorization"] = "Bearer " .. TOKEN,
        ["Accept"] = "application/vnd.github+json",
        ["X-GitHub-Api-Version"] = "2022-11-28",
        ["Content-Type"] = "application/json"
    }
end

local function sendCommand(action)
    print("[MASTER] Initiating command sequence: " .. action)
    
    local successGet, statusGet, bodyGet = makeRequest(BASE_URL, "GET", getHeaders(), nil)
    local currentSha = nil
    
    if statusGet == 200 then
        local getData = HttpService:JSONDecode(bodyGet)
        currentSha = getData.sha
        print("[MASTER] SHA retrieved successfully.")
    elseif statusGet == 404 then
        print("[MASTER] File not found (404). It will be created automatically.")
    else
        warn("[MASTER] Error: Failed to fetch SHA. Status: " .. tostring(statusGet))
        return
    end
    
    local bodyData = {
        message = "Command: " .. action,
        content = HttpService:Base64Encode(HttpService:JSONEncode({action = action}))
    }
    
    if currentSha then
        bodyData.sha = currentSha
    end
    
    local successPut, statusPut, bodyPut = makeRequest(BASE_URL, "PUT", getHeaders(), HttpService:JSONEncode(bodyData))
    
    if not successPut then
        warn("[MASTER] Error: Failed to send command. Status: " .. tostring(statusPut))
    else
        print("[MASTER] Success! Command '" .. action .. "' sent to GitHub.")
    end
end

local menuGui = Instance.new("ScreenGui")
menuGui.Name = "MasterMenu"
menuGui.IgnoreGuiInset = true
menuGui.ResetOnSpawn = false
menuGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.fromOffset(200, 100)
mainFrame.Position = UDim2.fromOffset(50, 50)
mainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = menuGui

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new(Color3.fromRGB(20, 20, 20), Color3.fromRGB(6, 6, 6))
mainGradient.Rotation = 90
mainGradient.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(70, 70, 70)
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
mainStroke.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 26)
titleBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleGradient = Instance.new("UIGradient")
titleGradient.Color = ColorSequence.new(Color3.fromRGB(38, 38, 38), Color3.fromRGB(12, 12, 12))
titleGradient.Rotation = 90
titleGradient.Parent = titleBar

local titleStroke = Instance.new("UIStroke")
titleStroke.Color = Color3.fromRGB(95, 95, 95)
titleStroke.Thickness = 1
titleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
titleStroke.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -16, 1, 0)
titleLabel.Position = UDim2.fromOffset(8, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "BOT MASTER"
titleLabel.TextColor3 = Color3.fromRGB(235, 235, 235)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextSize = 13
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = titleBar

local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(1, -16, 0, 40)
jumpBtn.Position = UDim2.fromOffset(8, 36)
jumpBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.BorderSizePixel = 0
jumpBtn.Text = "JUMP"
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.Font = Enum.Font.GothamBold
jumpBtn.TextSize = 14
jumpBtn.AutoButtonColor = false
jumpBtn.Parent = mainFrame

local btnGradient = Instance.new("UIGradient")
btnGradient.Color = ColorSequence.new(Color3.fromRGB(40, 200, 80), Color3.fromRGB(20, 120, 45))
btnGradient.Rotation = 90
btnGradient.Parent = jumpBtn

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(70, 70, 70)
btnStroke.Thickness = 1
btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
btnStroke.Parent = jumpBtn

jumpBtn.MouseButton1Click:Connect(function()
    print("[MASTER] JUMP button clicked.")
    sendCommand("jump")
end)

local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

print("[MASTER] GUI loaded and ready.")
