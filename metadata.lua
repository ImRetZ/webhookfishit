--// RetZ Fish It Discord Notifier (Embed)
--// by ChatGPT x Adrian W
--// Features: Embed Discord, Metadata, Rarity Filter

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- CONFIG
local WEBHOOK_URL = "https://discord.com/api/webhooks/1430077249813741618/KHW_vR_0oDaVym9iNmNNVILktB4R8hjHr5sSSUyMWK5VOlk6L3xEeYBINSLOGFO7ofvU"
local webhook_enabled = true
local rarity_filter = {Common=true, Uncommon=true, Rare=true, Epic=true, Legendary=true, Mythic=true, Secret=true}

-- Fungsi request kompatibel executor
local request = (syn and syn.request) or (http and http.request) or (http_request) or request
if not request then warn("[❌] Executor tidak mendukung HTTP request") return end

-- Helper: format embed
local function sendEmbed(fish, player)
    if not webhook_enabled then return end
    if not rarity_filter[fish.Rarity] then return end

    local embed = {
        username = "RetZ Fish It",
        avatar_url = "https://i.ibb.co/7C1tZ4D/fishit.png",
        embeds = {{
            color = 0x1abc9c,
            title = string.format("%s just caught a %s fish!", player.Name, fish.Rarity),
            fields = {
                {name = "🐟 Fish Name", value = fish.Name or "Unknown", inline = true},
                {name = "Weight 💎", value = tostring(fish.Weight or 0) .. "kg", inline = true},
                {name = "Rarity", value = fish.Rarity or "Unknown", inline = true},
                {name = "💰 Sell Price", value = tostring(fish.SellPrice or 0), inline = true},
                {name = "📅 Catch Date", value = os.date("%Y-%m-%d %H:%M:%S"), inline = false},
                {name = "🎯 Total Caught", value = tostring(fish.TotalCaught or 0), inline = true},
                {name = "🎒 Inventory Size", value = tostring(fish.Inventory or "0/0"), inline = true},
                {name = "💵 Total Coin", value = tostring(fish.TotalCoin or 0), inline = true},
                {name = "🎣 Rod Name", value = fish.RodName or "Unknown", inline = true},
                {name = "⏱ Play Time", value = fish.PlayTime or "Unknown", inline = true},
            },
            image = {url = fish.Image or "https://i.ibb.co/7C1tZ4D/fishit.png"},
            footer = {text = "Fishing isn't a hobby, it's a lifestyle. ~RetZ | Executor: Delta"}
        }}
    }

    pcall(function()
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(embed)
        })
    end)
end

-- Event Fish It
local event = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("ytrev_replion@2.0.0-rc.3")
    :WaitForChild("replion")
    :WaitForChild("Remotes")
    :WaitForChild("ArrayUpdate")

event.OnClientEvent:Connect(function(_, _, _, arg4)
    if typeof(arg4) == "table" and arg4.Metadata then
        local meta = arg4.Metadata
        local player = Players.LocalPlayer
        local fish = {
            Name = meta.Name or "Unknown",
            Rarity = meta.Rarity or "Unknown",
            Weight = meta.Weight or 0,
            SellPrice = meta.SellPrice or 0,
            TotalCaught = meta.TotalCaught or 0,
            Inventory = meta.InventorySize or "0/0",
            TotalCoin = meta.TotalCoin or 0,
            RodName = meta.RodName or "Unknown",
            PlayTime = meta.PlayTime or "Unknown",
            Image = meta.ImageUrl or "https://i.ibb.co/7C1tZ4D/fishit.png"
        }
        sendEmbed(fish, player)
    end
end)

print("[✅] RetZ Fish It Discord Notifier aktif!")
