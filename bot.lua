local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- СПИСОК БОТОВ (можно добавить W2nd_Bot и т.д.)
local ALLOWED_BOTS = {
    ["W1nd_Bot"] = true,
}
local OWNER = "WareSploit"
local REPO = "Bot-Controller"
local TOKEN = "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"
local FILE_PATH = "command.json"
local BASE_URL = "https://api.github.com/repos/" .. OWNER .. "/" .. REPO .. "/contents/" .. FILE_PATH
local POLL_INTERVAL = 2

if not ALLOWED_BOTS[LocalPlayer.Name] then
    warn("[BOT] Этот скрипт только для ботов! Твой ник: " .. LocalPlayer.Name)
    return
end
print("[BOT] Привет, " .. LocalPlayer.Name .. "! Бот запущен и слушает команды.")

local function makeRequest(url, method, headers)
    local reqFunc = syn and syn.request or http and http.request or http_request or request
    if reqFunc then
        local ok, res = pcall(reqFunc, {Url = url, Method = method, Headers = headers})
        if ok then return res.Success, res.StatusCode, res.Body end
    end
    local ok, res = pcall(function()
        return HttpService:RequestAsync({Url = url, Method = method, Headers = headers})
    end)
    if ok then return res.Success, res.StatusCode, res.Body end
    return false, 0, ""
end

local function getHeaders()
    return {
        ["Authorization"] = "Bearer " .. TOKEN,
        ["Accept"] = "application/vnd.github+json",
        ["X-GitHub-Api-Version"] = "2022-11-28",
    }
end

local function executeCommand(action)
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end

    if action == "jump" then
        hum.Jump = true
        print("[BOT] Прыжок!")
    elseif action == "move_forward" then
        hum:MoveTo(root.Position + root.CFrame.LookVector * 10)
        print("[BOT] Иду вперед")
    elseif action == "move_back" then
        hum:MoveTo(root.Position - root.CFrame.LookVector * 10)
        print("[BOT] Иду назад")
    elseif action == "stop" then
        hum:MoveTo(root.Position)
        print("[BOT] Стою")
    elseif action == "reset" then
        hum.Health = 0
        print("[BOT] Респавн")
    end
end

local lastCommandId = "0"

task.spawn(function()
    while true do
        local success, status, body = makeRequest(BASE_URL, "GET", getHeaders())
        if success and status == 200 then
            local decoded = HttpService:JSONDecode(body)
            local contentStr = HttpService:Base64Decode(decoded.content)
            local cmdData = HttpService:JSONDecode(contentStr)
            
            if cmdData.id and cmdData.id ~= lastCommandId then
                lastCommandId = cmdData.id
                print("[BOT] Новая команда: " .. tostring(cmdData.action))
                executeCommand(cmdData.action)
            end
        end
        task.wait(POLL_INTERVAL)
    end
end)
