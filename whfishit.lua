--// RetZ Fish It Notifier (Rayfield UI)
--// Features: Rayfield UI, Webhook, Rarity, Autosave, Disconnect Notif, Webhook Toggle

-- Config file path
local configFile = "RetZ_FishIt_Config.json"

-- Safe JSON read/write
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

-- Load or default settings
local settings = safeRead(configFile) or {
	webhook = "",
	webhook_enabled = true,
	discord_id = "",
	rarity = {
		Common = false, Uncommon = false, Rare = false,
		Epic = false, Legendary = false, Mythic = false, Secret = false
	}
}

-- Save settings function
local function saveSettings()
	safeWrite(configFile, settings)
end

-- Load Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
	Name = "🎣 RetZ Fish It",
	LoadingTitle = "RetZ Fish It Loading...",
	LoadingSubtitle = "by RetZ",
	ConfigurationSaving = {Enabled = false},
	Discord = {Enabled = false},
	KeySystem = false
})

local TabMain = Window:CreateTab("Main", 4483362458)
local TabRarity = Window:CreateTab("Rarity", 4483362458)
local TabDebug = Window:CreateTab("Debug", 4483362458)

-- Webhook input
TabMain:CreateInput({
	Name = "Webhook URL",
	Info = "Masukkan URL Webhook Discord kamu",
	PlaceholderText = "https://discord.com/api/webhooks/...",
	RemoveTextAfterFocusLost = false,
	CurrentValue = settings.webhook,
	Callback = function(Value)
		settings.webhook = Value
		saveSettings()
	end,
})

-- Webhook toggle
TabMain:CreateToggle({
	Name = "Aktifkan Webhook",
	CurrentValue = settings.webhook_enabled,
	Callback = function(Value)
		settings.webhook_enabled = Value
		saveSettings()
		Rayfield:Notify({
			Title = "Webhook Status",
			Content = Value and "✅ Webhook diaktifkan" or "🛑 Webhook dimatikan",
			Duration = 4
		})
	end,
})

-- Discord ID input
TabMain:CreateInput({
	Name = "Discord ID (untuk Tag)",
	PlaceholderText = "contoh: 123456789012345678",
	RemoveTextAfterFocusLost = false,
	CurrentValue = settings.discord_id,
	Callback = function(Value)
		settings.discord_id = Value
		saveSettings()
	end,
})

-- Rarity toggles
for _, rarity in ipairs({"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}) do
	TabRarity:CreateToggle({
		Name = rarity,
		CurrentValue = settings.rarity[rarity],
		Callback = function(Value)
			settings.rarity[rarity] = Value
			saveSettings()
		end,
	})
end

-- Test webhook button
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
				Content = "Webhook sedang dimatikan.",
				Duration = 4
			})
			return
		end

		syn.request({
			Url = settings.webhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({
				content = "🧪 Test berhasil! Script aktif di: **" ..
					game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "**"
			})
		})

		Rayfield:Notify({
			Title = "Berhasil!",
			Content = "Pesan test webhook dikirim.",
			Duration = 4
		})
	end
})

-- Simulate disconnect button
TabDebug:CreateButton({
	Name = "🔌 Simulasi Disconnect",
	Callback = function()
		if settings.webhook == "" or not settings.webhook_enabled then return end
		syn.request({
			Url = settings.webhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({
				content = "⚠️ Script Fish It Notifier **disconnect manual** oleh pengguna!"
			})
		})
		Rayfield:Notify({
			Title = "Notif Dikirim",
			Content = "Simulasi disconnect terkirim ke webhook.",
			Duration = 4
		})
	end
})

-- Disconnect notif saat game tutup
game:BindToClose(function()
	if settings.webhook ~= "" and settings.webhook_enabled then
		syn.request({
			Url = settings.webhook,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode({
				content = "❌ RetZ Fish It script **disconnect** (game closed atau crash)"
			})
		})
	end
end)

Rayfield:Notify({
	Title = "✅ RetZ Fish It Aktif",
	Content = "Autosave, webhook toggle & notifikasi siap digunakan.",
	Duration = 6
})
