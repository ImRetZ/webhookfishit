-- // Fish It Webhook Notifier GUI (dengan Disconnect Alert) // --
-- By ChatGPT (GPT-5) --

-- Library GUI (Kavo UI)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Fish It - Webhook Notifier", "Ocean")

-- Variabel utama
local webhookURL = ""
local discordID = ""
local running = false

local rarityFilter = {
    ["Common"] = false,
    ["Uncommon"] = false,
    ["Rare"] = false,
    ["Epic"] = false,
    ["Legendary"] = false,
    ["Mythic"] = false,
    ["Secret"] = false
}

local http = http_request or syn and syn.request or http and http.request
local fishEvent = game.ReplicatedStorage:FindFirstChild("FishCaught") or game.ReplicatedStorage:FindFirstChild("CatchFish")
local HttpService = game:GetService("HttpService")

-------------------------------------------------
-- Fungsi utama untuk kirim webhook
-------------------------------------------------
local function safeRequest(body)
    if not http then
        warn("Executor tidak mendukung HTTP Request.")
        return false
    end

    local success, result = pcall(function()
        return http({
            Url = webhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(body)
        })
    end)

    if not success then
        warn("Gagal mengirim ke webhook: " .. tostring(result))
        return false
    end

    return true
end

local function sendWebhook(content)
    if webhookURL == "" then return end
    safeRequest({["content"] = content})
end

-------------------------------------------------
-- Kirim pesan utama
-------------------------------------------------
local function sendCatch(fishName, rarity, weight)
    local mention = discordID ~= "" and ("<@" .. discordID .. ">") or ""
    local msg = string.format("%s 🎣 **Menangkap Ikan!**\n> Nama: %s\n> Rarity: %s\n> Berat: %s kg", mention, fishName, rarity, tostring(weight))
    sendWebhook(msg)
end

local function sendStatus(msg)
    sendWebhook("📡 **[Fish It Notifier]** " .. msg)
end

-------------------------------------------------
-- GUI Bagian Utama
-------------------------------------------------
local mainTab = Window:NewTab("Main")
local mainSection = mainTab:NewSection("Pengaturan Webhook")

mainSection:NewTextBox("Webhook URL", "Masukkan URL webhook Discord", function(txt)
    webhookURL = txt
end)

mainSection:NewTextBox("ID Discord (opsional)", "Masukkan ID untuk tag", function(txt)
    discordID = txt
end)

mainSection:NewButton("🔔 Test Webhook", "Kirim pesan percobaan ke webhook", function()
    if webhookURL == "" then
        Library:Notify("Masukkan Webhook URL dulu!", 3)
        return
    end
    sendWebhook("✅ **Webhook Test Berhasil!** 🎣 Fish It Notifier siap digunakan.")
    Library:Notify("Pesan test webhook dikirim!", 3)
end)

-------------------------------------------------
-- Filter Rarity
-------------------------------------------------
local rarityTab = Window:NewTab("Rarity Filter")
local raritySection = rarityTab:NewSection("Pilih Rarity yang Akan Dikirim")

for rarity, _ in pairs(rarityFilter) do
    raritySection:NewToggle(rarity, "Kirim kalau dapat " .. rarity, function(state)
        rarityFilter[rarity] = state
    end)
end

-------------------------------------------------
-- Kontrol Script
-------------------------------------------------
local controlTab = Window:NewTab("Control")
local controlSection = controlTab:NewSection("Kontrol Script")

controlSection:NewButton("▶️ Mulai Deteksi", "Mulai memantau ikan yang ditangkap", function()
    if webhookURL == "" then
        Library:Notify("Masukkan Webhook URL dulu!", 3)
        return
    end
    if not fishEvent then
        Library:Notify("Event tangkapan tidak ditemukan!", 3)
        return
    end
    if running then
        Library:Notify("Script sudah berjalan!", 3)
        return
    end

    running = true
    sendStatus("✅ Script aktif dan memantau ikan sekarang.")
    Library:Notify("🎣 Webhook Notifier aktif!", 3)

    -- Deteksi tangkapan
    fishEvent.OnClientEvent:Connect(function(fishData)
        if not running then return end
        local name = fishData.Name or "Unknown"
        local rarity = fishData.Rarity or "Common"
        local weight = fishData.Weight or 0

        if rarityFilter[rarity] then
            sendCatch(name, rarity, weight)
        end
    end)

    -- Tangani disconnect / executor berhenti
    game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
        if running then
            sendStatus("⚠️ Script terhenti karena teleport / disconnect.")
            running = false
        end
    end)

    -- Tangkap error atau penutupan mendadak
    game:BindToClose(function()
        if running then
            sendStatus("❌ Script berhenti secara mendadak (executor tertutup atau game shutdown).")
            running = false
        end
    end)
end)

controlSection:NewButton("⛔ Hentikan Script", "Berhenti memantau ikan", function()
    if running then
        running = false
        sendStatus("❌ Script Fish It Notifier telah dihentikan secara manual.")
        Library:Notify("Script dihentikan & notifikasi dikirim!", 3)
    else
        Library:Notify("Script belum dijalankan.", 3)
    end
end)
