--// RetZ Fish It Notifier + Metadata Logger
--// by ChatGPT x Adrian W
--// Features: Discord Embed, Rarity Filter, Autosave, Executor-Compatible

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- CONFIG
local configFile = "RetZ_FishIt_Config.json"
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

local settings = safeRead(configFile) or {
    webhook = "",
    webhook_enabled = true,
    rarity = {Common=true, Uncommon=true, Rare=true, Epic=true, Legendary=true, Mythic=true, Secret=true}
}
local function saveSettings() safeWrite(configFile, settings) end

-- Pilih fungsi request
local request = (syn and syn.request) or (http and http.request) or (http_request) or request
if not request then warn("[❌] Executor tidak mendukung HTTP request") return end

-- Helper: kirim embed ke webhook
local function sendToWebhook(fish)
    if not settings.webhook_enabled or settings.webhook == "https://discord.com/api/webhooks/1430077249813741618/KHW_vR_0oDaVym9iNmNNVILktB4R8hjHr5sSSUyMWK5VOlk6L3xEeYBINSLOGFO7ofvU" then return end
    if not settings.rarity[fish.Rarity] then return end -- filter rarity

    local embed = {
        embeds = {{
            title = "🎣 Ikan Baru Ditangkap!",
            description = string.format(
                "**Name:** %s\n**Rarity:** %s\n**Weight:** %s\n**ID:** %s",
                fish.Name or "Unknown",
                fish.Rarity or "Unknown",
                fish.Weight or 0,
                fish.ID or 0
            ),
            color = 5814783,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }

    pcall(function()
        request({
            Url = settings.webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(embed)
        })
    end)
end

-- Ambil event ArrayUpdate (Fish It)
local event = ReplicatedStorage:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("ytrev_replion@2.0.0-rc.3")
    :WaitForChild("replion")
    :WaitForChild("Remotes")
    :WaitForChild("ArrayUpdate")

event.OnClientEvent:Connect(function(_, _, _, arg4)
    if typeof(arg4) == "table" and arg4.Metadata then
        local meta = arg4.Metadata
        local fish = {
            Name = meta.Name or "Unknown",
            Rarity = meta.Rarity or "Unknown",
            Weight = meta.Weight or 0,
            ID = meta.Id or 0
        }
        sendToWebhook(fish)
    end
end)

print("[✅] RetZ Fish It Metadata Logger aktif!")
