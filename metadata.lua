-- LocalScript (Letakkan di StarterPlayerScripts)

-- Ganti dengan URL Webhook Discord kamu
local WEBHOOK_URL = "https://discord.com/api/webhooks/1430077249813741618/KHW_vR_0oDaVym9iNmNNVILktB4R8hjHr5sSSUyMWK5VOlk6L3xEeYBINSLOGFO7ofvU"

local HttpService = game:GetService("HttpService")
local player = game.Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Fungsi untuk mengirim data ke Webhook
local function sendWebhook(data)
    local payload = HttpService:JSONEncode({
        content = "",
        embeds = {{
            title = "🎣 Ikan Ditangkap!",
            color = 65280,
            fields = {
                {name = "Nama Ikan", value = data.name, inline = true},
                {name = "Rarity", value = data.rarity, inline = true},
                {name = "Tier", value = data.tier, inline = true},
                {name = "Berat (kg)", value = tostring(data.weight), inline = true},
                {name = "Harga Jual (Coin)", value = tostring(data.sellPrice), inline = true},
                {name = "Tanggal Ditangkap", value = data.catchDate, inline = false},
                {name = "Total Ditangkap", value = tostring(data.totalCaught), inline = true},
                {name = "Ukuran Inventaris", value = tostring(data.inventorySize), inline = true},
                {name = "Total Coin", value = tostring(data.totalCoin), inline = true},
                {name = "Nama Rod", value = data.rodName, inline = true},
                {name = "Waktu Bermain", value = data.playTime, inline = true},
            }
        }}
    })
    
    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, payload, Enum.HttpContentType.ApplicationJson)
    end)
    if not success then
        warn("Gagal mengirim Webhook:", err)
    end
end

-- Fungsi untuk mendeteksi variabel yang ada pada player
local function getPlayerStats()
    local stats = {
        totalCaught = player:FindFirstChild("TotalCaught") and player.TotalCaught.Value or 0,
        inventorySize = player:FindFirstChild("InventorySize") and player.InventorySize.Value or 0,
        totalCoin = player:FindFirstChild("Coins") and player.Coins.Value or 0,
        rodName = player:FindFirstChild("RodName") and player.RodName.Value or "Tidak Diketahui",
        playTime = math.floor(player.TotalPlayTime.Value / 60).." menit"
    }
    return stats
end

-- Fungsi untuk menangani event penangkapan ikan
local function onFishCaught(fishData)
    local stats = getPlayerStats()
    local data = {
        name = fishData.name or "Tidak Diketahui",
        rarity = fishData.rarity or "Tidak Diketahui",
        tier = fishData.tier or "Tidak Diketahui",
        weight = fishData.weight or 0,
        sellPrice = fishData.sellPrice or 0,
        catchDate = os.date("%Y-%m-%d %H:%M:%S"),
        totalCaught = stats.totalCaught,
        inventorySize = stats.inventorySize,
        totalCoin = stats.totalCoin,
        rodName = stats.rodName,
        playTime = stats.playTime
    }
    sendWebhook(data)
end

-- Menunggu RemoteEvent "FishCaught" dari ReplicatedStorage
local fishEvent = ReplicatedStorage:WaitForChild("FishCaught")
fishEvent.OnClientEvent:Connect(onFishCaught)
