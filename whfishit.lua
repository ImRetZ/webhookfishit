--// Fish It Notifier GUI v2 (By ChatGPT)
--// Fitur: GUI + Webhook + Rarity Filter + Disconnect Notif + AutoSave Setting

-- Lokasi penyimpanan config
local configFile = "FishItNotifier_Settings.json"

-- Fungsi aman untuk baca & tulis file
local function safeRead(path)
    if isfile and isfile(path) then
        return game:GetService("HttpService"):JSONDecode(readfile(path))
    end
    return nil
end

local function safeWrite(path, data)
    if writefile then
        writefile(path, game:GetService("HttpService"):JSONEncode(data))
    end
end

-- Muat config
local settings = safeRead(configFile) or {
    webhook = "",
    discord_id = "",
    rarity = {Common=false, Uncommon=false, Rare=false, Epic=false, Legendary=false, Mythic=false, Secret=false}
}

-- Simpan config
local function saveSettings()
    safeWrite(configFile, settings)
end

-- GUI Library (Simple)
local ScreenGui = Instance.new("ScreenGui")
local Frame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local WebhookInput = Instance.new("TextBox")
local IDInput = Instance.new("TextBox")
local SaveBtn = Instance.new("TextButton")
local TestBtn = Instance.new("TextButton")
local DisconnectBtn = Instance.new("TextButton")
local ScrollingFrame = Instance.new("ScrollingFrame")

ScreenGui.Name = "FishItNotifier"
ScreenGui.Parent = game.CoreGui

Frame.Parent = ScreenGui
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Position = UDim2.new(0.35, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 320, 0, 400)
Frame.Active = true
Frame.Draggable = true

Title.Parent = Frame
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "🎣 Fish It Notifier"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 20

WebhookInput.Parent = Frame
WebhookInput.PlaceholderText = "Masukkan Webhook Discord"
WebhookInput.Text = settings.webhook
WebhookInput.Position = UDim2.new(0.05, 0, 0.1, 0)
WebhookInput.Size = UDim2.new(0.9, 0, 0, 30)

IDInput.Parent = Frame
IDInput.PlaceholderText = "Masukkan ID Discord untuk Tag"
IDInput.Text = settings.discord_id
IDInput.Position = UDim2.new(0.05, 0, 0.2, 0)
IDInput.Size = UDim2.new(0.9, 0, 0, 30)

ScrollingFrame.Parent = Frame
ScrollingFrame.Position = UDim2.new(0.05, 0, 0.32, 0)
ScrollingFrame.Size = UDim2.new(0.9, 0, 0, 180)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 200)

local rarities = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
local rarityButtons = {}

for i, name in ipairs(rarities) do
    local btn = Instance.new("TextButton")
    btn.Parent = ScrollingFrame
    btn.Size = UDim2.new(1, 0, 0, 25)
    btn.Position = UDim2.new(0, 0, 0, (i - 1) * 30)
    btn.Text = (settings.rarity[name] and "✅ " or "❌ ") .. name
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.MouseButton1Click:Connect(function()
        settings.rarity[name] = not settings.rarity[name]
        btn.Text = (settings.rarity[name] and "✅ " or "❌ ") .. name
        saveSettings()
    end)
    rarityButtons[name] = btn
end

SaveBtn.Parent = Frame
SaveBtn.Text = "💾 Simpan Setting"
SaveBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
SaveBtn.Size = UDim2.new(0.4, 0, 0, 30)
SaveBtn.MouseButton1Click:Connect(function()
    settings.webhook = WebhookInput.Text
    settings.discord_id = IDInput.Text
    saveSettings()
end)

TestBtn.Parent = Frame
TestBtn.Text = "🧪 Test Webhook"
TestBtn.Position = UDim2.new(0.55, 0, 0.78, 0)
TestBtn.Size = UDim2.new(0.4, 0, 0, 30)
TestBtn.MouseButton1Click:Connect(function()
    if settings.webhook == "" then
        warn("Webhook belum diisi!")
        return
    end
    syn.request({
        Url = settings.webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode({
            content = "🧪 Test Webhook berhasil! Script aktif di game: **" .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "**"
        })
    })
end)

DisconnectBtn.Parent = Frame
DisconnectBtn.Text = "🔌 Simulasi Disconnect"
DisconnectBtn.Position = UDim2.new(0.05, 0, 0.87, 0)
DisconnectBtn.Size = UDim2.new(0.9, 0, 0, 30)
DisconnectBtn.MouseButton1Click:Connect(function()
    syn.request({
        Url = settings.webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = game:GetService("HttpService"):JSONEncode({
            content = "⚠️ Script Fish It Notifier telah **disconnect** di akun ini!"
        })
    })
end)

-- Auto kirim notif saat script berhenti
game:BindToClose(function()
    if settings.webhook ~= "" then
        syn.request({
            Url = settings.webhook,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = game:GetService("HttpService"):JSONEncode({
                content = "❌ Script Fish It Notifier **disconnect** (game closed atau crash)"
            })
        })
    end
end)

print("[✅] Fish It Notifier GUI aktif dengan autosave.")
