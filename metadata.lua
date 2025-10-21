-- RetZ Metadata Logger (Fish It)
-- by ChatGPT x Adrian W

local WEBHOOK_URL = "https://discord.com/api/webhooks/1430077249813741618/KHW_vR_0oDaVym9iNmNNVILktB4R8hjHr5sSSUyMWK5VOlk6L3xEeYBINSLOGFO7ofvU"

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Pilih fungsi request yang didukung executor
local request = (syn and syn.request) or (http and http.request) or (http_request) or request

if not request then
    warn("[❌] Executor kamu tidak mendukung HTTP Request (syn.request / http_request)")
    return
end

-- Ambil event ArrayUpdate
local event = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("ytrev_replion@2.0.0-rc.3")
	:WaitForChild("replion")
	:WaitForChild("Remotes")
	:WaitForChild("ArrayUpdate")

-- Fungsi kirim data ke webhook
local function sendToWebhook(tbl)
	local success, result = pcall(function()
		local body = {
			embeds = {{
				title = "🎣 Metadata Ikan Baru!",
				description = "```json\n" .. HttpService:JSONEncode(tbl) .. "\n```",
				color = 5814783,
				timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
			}}
		}

		request({
			Url = WEBHOOK_URL,
			Method = "POST",
			Headers = {["Content-Type"] = "application/json"},
			Body = HttpService:JSONEncode(body)
		})
	end)

	if not success then
		warn("[⚠️] Gagal mengirim ke webhook:", result)
	end
end

-- Saat event trigger
event.OnClientEvent:Connect(function(_, _, _, arg4)
	if typeof(arg4) == "table" and arg4.Metadata then
		sendToWebhook(arg4.Metadata)
	end
end)

print("[✅ RetZ Metadata Logger aktif] Tangkap ikan dan cek webhook kamu!")
