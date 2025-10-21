--// Fish It Detector (Webhook Version)
-- by ChatGPT x Adrian W
-- Tujuan: Mendeteksi event ikan via Discord webhook

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Ganti dengan webhook kamu
local WEBHOOK_URL = "https://discord.com/api/webhooks/1430077249813741618/KHW_vR_0oDaVym9iNmNNVILktB4R8hjHr5sSSUyMWK5VOlk6L3xEeYBINSLOGFO7ofvU"

local function sendWebhook(msg)
    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({content = msg})
        })
    end)
end

sendWebhook("🟢 **Fish It Detector aktif!** Tangkap 1 ikan, hasil event akan dikirim ke sini.")

local function safeConnect(signal, name)
    local success, err = pcall(function()
        signal:Connect(function(...)
            local args = {...}
            local log = "**Event:** " .. name .. "\n"
            for i, v in ipairs(args) do
                log = log .. "Arg["..i.."]: " .. tostring(v) .. "\n"
                if typeof(v) == "table" then
                    for k2, v2 in pairs(v) do
                        log = log .. "  → " .. tostring(k2) .. ": " .. tostring(v2) .. "\n"
                    end
                end
            end
            sendWebhook("🎣 **Fish It Event Terdeteksi!**\n" .. log)
        end)
    end)
    if not success then
        warn("Gagal konek ke:", name, err)
    end
end

for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("BindableEvent") then
        safeConnect(obj.OnClientEvent, obj:GetFullName())
    end
end

for _, obj in pairs(LocalPlayer:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("BindableEvent") then
        safeConnect(obj.OnClientEvent, obj:GetFullName())
    end
end

for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("BindableEvent") then
        safeConnect(obj.OnClientEvent, obj:GetFullName())
    end
end

sendWebhook("✅ **Detektor siap. Tangkap ikan sekarang!**")
