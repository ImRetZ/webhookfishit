-- RetZ Metadata Logger (Fish It)
-- Kirim Metadata ikan yang tertangkap ke Discord Webhook

-- 🪝 Ganti link ini dengan link webhook kamu
local WEBHOOK_URL = "https://discord.com/api/webhooks/1430077249813741618/KHW_vR_0oDaVym9iNmNNVILktB4R8hjHr5sSSUyMWK5VOlk6L3xEeYBINSLOGFO7ofvU"

local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Event yang memicu saat ikan baru ditangkap
local event = ReplicatedStorage:WaitForChild("Packages")
	:WaitForChild("_Index")
	:WaitForChild("ytrev_replion@2.0.0-rc.3")
	:WaitForChild("replion")
	:WaitForChild("Remotes")
	:WaitForChild("ArrayUpdate")

local function sendToWebhook(tbl)
	local data = {
		content = "🎣 **Metadata ikan baru!**\n```json\n" .. HttpService:JSONEncode(tbl) .. "\n```"
	}
	HttpService:PostAsync(WEBHOOK_URL, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
end

event.OnClientEvent:Connect(function(arg1, arg2, arg3, arg4)
	if typeof(arg4) == "table" and arg4.Metadata then
		sendToWebhook(arg4.Metadata)
	end
end)

print("[✅ RetZ Metadata Logger aktif] Tangkap ikan dan cek webhook kamu!")
