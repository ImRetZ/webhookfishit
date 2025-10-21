--!strict1111
-- Pastikan Rayfield sudah di-inject
local Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()

--// Variables
local webhookURL = ""
local discordTag = ""
local sendWebhook = false
local selectedTiers = {Common = true, Uncommon = true, Rare = true, Epic = true, Legendary = true, Secret = true}

--// Utility function: Kirim webhook
local function sendFishWebhook(fishData)
    if not sendWebhook then return end
    if not selectedTiers[fishData.Tier] then return end

    local payload = {
        username = "Fish It Logger",
        embeds = {{
            title = fishData.Name,
            description = string.format(
                "Rarity: %s\nTier: %s\nWeight: %.2f\nSell Price: %d\nCatch Date: %s\nTotal Caught: %d\nInventory Size: %d\nTotal Coin: %d\nRod Name: %s\nPlay Time: %s", 
                fishData.Rarity, fishData.Tier, fishData.Weight, fishData.SellPrice, os.date("%c", fishData.CatchTime), fishData.TotalCaught, fishData.InventorySize, fishData.TotalCoin, fishData.RodName, fishData.PlayTime
            ),
            image = {url = fishData.ImageURL},
            footer = {text = "Caught by "..discordTag}
        }}
    }

    local httpService = game:GetService("HttpService")
    local ok, err = pcall(function()
        httpService:PostAsync(webhookURL, httpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
    if not ok then warn("Webhook failed:", err) end
end

--// Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Fish It Webhook Logger",
    LoadingTitle = "Fish It Logger",
    LoadingSubtitle = "By Adrian",
    ConfigurationSaving = { Enabled = true, FolderName = "FishItWebhookConfigs", FileName = "Config" }
})

-- Webhook Input
Window:CreateInput({Name = "Webhook URL", PlaceholderText = "Enter your Discord Webhook URL", RemoveTextAfterFocusLost = false, Callback = function(value) webhookURL = value end})
-- Discord Tag Input
Window:CreateInput({Name = "Discord Tag", PlaceholderText = "Ex: Adrian#1234", RemoveTextAfterFocusLost = false, Callback = function(value) discordTag = value end})
-- Toggle Webhook
Window:CreateToggle({Name = "Enable Webhook", CurrentValue = false, Callback = function(value) sendWebhook = value end})

-- Tier Selection
for _, tier in ipairs({"Common","Uncommon","Rare","Epic","Legendary","Secret"}) do
    Window:CreateToggle({Name = "Send "..tier.." Fish", CurrentValue = true, Callback = function(value) selectedTiers[tier] = value end})
end

-- Test Webhook
Window:CreateButton({Name = "Test Webhook", Callback = function()
    sendFishWebhook({
        Name = "Test Fish",
        Rarity = "Common",
        Tier = "Common",
        Weight = 1.0,
        SellPrice = 10,
        CatchTime = os.time(),
        TotalCaught = 1,
        InventorySize = 10,
        TotalCoin = 100,
        RodName = "Test Rod",
        PlayTime = "00:05:23",
        ImageURL = "https://i.imgur.com/6Y1Z5OJ.png"
    })
end})

-- Save Config
Window:CreateButton({Name = "Save Config", Callback = function() Rayfield:SaveConfiguration() end})

--// Auto detect fish catch
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Gunakan RemoteEvent FishCaught
local catchEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FishCaught")

catchEvent.OnClientEvent:Connect(function(fish)
    -- Debug: tampilkan data diterima
    print("Fish caught event:", fish)

    local fishData = {
        Name = fish.Name or fish.FishName or "Unknown",
        Rarity = fish.Rarity or "Unknown",
        Tier = fish.Tier or "Common",
        Weight = fish.Weight or 0,
        SellPrice = fish.SellPrice or 0,
        CatchTime = os.time(),
        TotalCaught = fish.TotalCaught or 0,
        InventorySize = fish.InventorySize or 0,
        TotalCoin = fish.TotalCoin or 0,
        RodName = fish.Rod or "Unknown",
        PlayTime = fish.PlayTime or "00:00:00",
        ImageURL = fish.ImageURL or ""
    }

    sendFishWebhook(fishData)
end)
