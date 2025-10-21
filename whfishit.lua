--// RetZ Fish It Notifier (Rayfield UI)
--// by ChatGPT x Adrian W
--// Features: Rayfield UI, Webhook Toggle, Autosave, Disconnect Notif, Safe Callback

-- Konfigurasi file
local configFile = "RetZ_FishIt_Config.json"

-- JSON aman
local HttpService = game:GetService("HttpService")
local function safeRead(path)
    if isfile and isfile(path) then
        return HttpService:JSONDecode(readfile(path))
    end
    return nil
end
local function safeWrite(path, data)
    if writefile then
        writefile(path, HttpService:JSONEncode(data))
    end
end

-- Load config
local settings = safeRead(configFile) or {
    webhook = "",
    discord_id = "",
    webhook_enabled = true,
    rarity = {Common=false, Uncommon=false, Rare=false, Epic=false, Legendary=false, Mythic=false, Secret=false}
}

local function saveSettings()
    safeWrite(configFile, settings)
end

-- Deteksi request function
local request = syn and syn.request or http_request or request or http and http.request

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "🎣 RetZ Fish It",
    LoadingTitle = "RetZ Fish It Loading...",
    LoadingSubtitle = "by ChatGPT x Adrian W",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local TabMain = Window:CreateTab("Main", 4483362458)
local TabRarity = Window:CreateTab("Rarity", 4483362458)
local TabDebug = Window:CreateTab("Debug", 4483362458)

-- Webhook toggle
TabMain:CreateToggle({
    Name = "Aktifkan Webhook",
    CurrentValue = settings.webhook_enabled,
    Callback = function(Value)
        settings.webhook_enabled = Value
        saveSettings()
    end
})

-- Input webhook
TabMain:CreateInput({
    Name = "Webhook URL",
    Info = "Masukkan URL Webhook Discord kamu",
    PlaceholderText = "https://discord.com/api/webhooks/...",
    RemoveTextAfterFocusLost = false,
    CurrentValue = settings.webhook,
    Callback = function(Value)
        settings.webhook = Value
        saveSettings()
    end
})

-- Input Discord ID
TabMain:CreateInput({
    Name = "Discord ID (untuk Tag)",
    PlaceholderText = "contoh: 123456789012345678",
    RemoveTextAfterFocusLost = false,
    CurrentValue = settings.discord_id,
    Callback = function(Value)
        settings.discord_id = Value
        saveSettings()
    end
})

-- Rarity toggles
for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}) do
    TabRarity:CreateToggle({
        Name = rarity,
        CurrentValue = settings.rarity[rarity],
        Callback = function(Value)
            settings.rarity[rarity] = Value
            saveSettings()
        end
    })
end

-- Tombol test webhook
TabMain:CreateButton({
    Name = "🧪 Test Webhook",
    Callback = function()
        if settings.webhook == "" then
            Rayfield:Notify({
                Title = "Gagal!",
                Content = "Webhook belum diisi.",
                Duration = 4
            })
            return
        end

        if not settings.webhook_enabled then
            Rayfield:Notify({
                Title = "Nonaktif!",
                Content = "Webhook saat ini dimatikan.",
                Duration = 4
            })
            return
        end

        local success, err = pcall(function()
            request({
                Url = settings.webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = "🧪 Test berhasil! Script aktif di: **" ..
                        game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "**"
                })
            })
        end)

        if success then
            Rayfield:Notify({
                Title = "Berhasil!",
                Content = "Pesan test webhook dikirim.",
                Duration = 4
            })
        else
            Rayfield:Notify({
                Title = "Error!",
                Content = "Webhook gagal: " .. tostring(err),
                Duration = 6
            })
        end
    end
})

-- Tombol simulasi disconnect
TabDebug:CreateButton({
    Name = "🔌 Simulasi Disconnect",
    Callback = function()
        if settings.webhook == "" or not settings.webhook_enabled then return end

        pcall(function()
            request({
                Url = settings.webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = "⚠️ Script Fish It Notifier **disconnect manual** oleh pengguna!"
                })
            })
        end)

        Rayfield:Notify({
            Title = "Notif Dikirim",
            Content = "Simulasi disconnect terkirim ke webhook.",
            Duration = 4
        })
    end
})

-- Notif disconnect otomatis
game:BindToClose(function()
    if settings.webhook ~= "" and settings.webhook_enabled then
        pcall(function()
            request({
                Url = settings.webhook,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode({
                    content = "❌ RetZ Fish It script **disconnect** (game closed atau crash)"
                })
            })
        end)
    end
end)

Rayfield:Notify({
    Title = "✅ RetZ Fish It Aktif",
    Content = "Autosave & Webhook siap digunakan.",
    Duration = 6
})
