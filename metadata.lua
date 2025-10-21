--!strict
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
    pcall(function()
        httpService:PostAsync(webhookURL, httpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
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

-- Cari RemoteEvent Fish It (contoh)
local catchEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CatchFishEvent") -- sesuaikan nama RemoteEvent

catchEvent.OnClientEvent:Connect(function(fish)
    -- fish adalah table dari server, contohnya:
    -- {Name="Golden Carp", Rarity="Rare", Tier="Rare", Weight=2.5, SellPrice=500, Rod="Epic Rod", ImageURL="https://i.imgur.com/...", TotalCaught=5, InventorySize=20, TotalCoin=1000, PlayTime="01:23:45"}
    
    local fishData = {
        Name = fish.Name,
        Rarity = fish.Rarity,
        Tier = fish.Tier,
        Weight = fish.Weight,
        SellPrice = fish.SellPrice,
        CatchTime = os.time(),
        TotalCaught = fish.TotalCaught,
        InventorySize = fish.InventorySize,
        TotalCoin = fish.TotalCoin,
        RodName = fish.Rod,
        PlayTime = fish.PlayTime,
        ImageURL = fish.ImageURL
    }

    sendFishWebhook(fishData)
end)
