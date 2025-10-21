--!strict
-- Debug version: pastikan Rayfield muncul dan aman sebelum hubungkan dengan event

-- Load Rayfield dengan pcall untuk menangkap error
local success, RayfieldOrErr = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Rayfield/main/source"))()
end)

if not success then
    warn("Rayfield failed to load:", RayfieldOrErr)
    return
end

local Rayfield = RayfieldOrErr
print("Rayfield loaded successfully!")

--// Variables
local webhookURL = ""
local discordTag = ""
local sendWebhook = false
local selectedTiers = {Common = true, Uncommon = true, Rare = true, Epic = true, Legendary = true, Secret = true}

--// Utility function: Kirim webhook (hanya print di debug)
local function sendFishWebhook(fishData)
    print("Webhook would be sent for fish:")
    for k,v in pairs(fishData) do
        print(k,v)
    end
end

--// Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Fish It Debug Logger",
    LoadingTitle = "Fish It Logger Debug",
    LoadingSubtitle = "By Adrian",
    ConfigurationSaving = { Enabled = true, FolderName = "FishItWebhookDebug", FileName = "Config" }
})

-- Webhook Input
Window:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "Discord Webhook URL",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        webhookURL = value
        print("Webhook URL set:", webhookURL)
    end
})

-- Discord Tag Input
Window:CreateInput({
    Name = "Discord Tag",
    PlaceholderText = "Ex: Adrian#1234",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        discordTag = value
        print("Discord tag set:", discordTag)
    end
})

-- Toggle Webhook
Window:CreateToggle({
    Name = "Enable Webhook",
    CurrentValue = false,
    Callback = function(value)
        sendWebhook = value
        print("Send webhook toggle:", sendWebhook)
    end
})

-- Tier Selection
for _, tier in ipairs({"Common","Uncommon","Rare","Epic","Legendary","Secret"}) do
    Window:CreateToggle({
        Name = "Send "..tier.." Fish",
        CurrentValue = true,
        Callback = function(value)
            selectedTiers[tier] = value
            print("Tier "..tier.." set to", value)
        end
    })
end

-- Test Webhook Button
Window:CreateButton({
    Name = "Test Webhook",
    Callback = function()
        local testFish = {
            Name = "Debug Fish",
            Rarity = "Rare",
            Tier = "Rare",
            Weight = 2.5,
            SellPrice = 500,
            CatchTime = os.time(),
            TotalCaught = 1,
            InventorySize = 10,
            TotalCoin = 1000,
            RodName = "Debug Rod",
            PlayTime = "00:05:00",
            ImageURL = "https://i.imgur.com/6Y1Z5OJ.png"
        }
        sendFishWebhook(testFish)
    end
})

-- Save Config
Window:CreateButton({
    Name = "Save Config",
    Callback = function()
        Rayfield:SaveConfiguration()
        print("Config saved")
    end
})

-- Optional: Minimal test RemoteEvent (hanya debug print)
-- Uncomment jika ingin test event tanpa Fish It
--[[
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local catchEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("FishCaught")

catchEvent.OnClientEvent:Connect(function(fish)
    print("FishCaught event fired! Data:")
    for k,v in pairs(fish) do
        print(k,v)
    end
    sendFishWebhook(fish)
end)
]]

print("Debug Rayfield script loaded successfully! GUI should be visible.")
