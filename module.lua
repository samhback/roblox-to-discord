local HttpService = game:GetService("HttpService")
local CONST_WEBHOOK = "WEBHOOK_URL"
local CONST_AWS = "AWS_APIGATEWAY_URL"
local robloxToDiscord = {}

function robloxToDiscord.webhook(msg)
	local data = {
		message = msg,
		webhook = CONST_WEBHOOK,
		bottitle = "Admin Command Ran"
	}

	local jsonData = HttpService:JSONEncode(data)
	
	local success, response = pcall(function()
		return HttpService:PostAsync(CONST_AWS, jsonData, Enum.HttpContentType.ApplicationJson)
	end)

	if success then
		return "Successfully sent webhook call"
	else
		warn("HTTP request failed: " .. tostring(response))
		return "Failure!"
	end
end

return robloxToDiscord
