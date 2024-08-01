# roblox-to-discord
Why?
Sending messages from Roblox to Discord can be useful, specifically for moderation. You can use it to detect cheating and then immediately message your server with the players username. Or you can trigger it for ingame events, to get players excited to hop on.

Why this way?
Discord at some point blocked messages coming from Roblox. This was likely due to a high amount of traffic from Roblox. This method uses a “Proxy” schema, which means it sends the message to a midpoint before forwarding it to Roblox. This way is also good because you only have to add the AWS code once, and then every webhook message you send to it with different URLs can be forwarded.

Discord Side
Inside your Discord server, select a channel you want your bot to post the messages from your roblox game, click the cog and click edit channel.
Click Create Webhook, and then click the bot that was automatically made. Here you can change the name and copy the webhook URL. Save that webhook URL for later.
AWS Side

Log into AWS as root user, click the search bar, and search “Lambda”.
Create a Lambda function. When creating the function, select Python as your language of choice and paste the following code:
import json
import requests

def lambda_handler(event, context):
    body = json.loads(event['body'])
    data = {
    'content': body['message'],  # The message text
    'username': body['bottitle'],  # Custom username for the webhook message
    }
    response = requests.post(body['webhook'], data=json.dumps(data), headers={'Content-Type': 'application/json'})
    return {
        'statusCode': 200,
        'body': json.dumps('success')
    }
Save, and then search API Gateway and make a HTTPs API Gateway function. When creating the API gateway, select Lambda in the dropdown and then select your lambda function that you made earlier.

In the settings/config of the API Gateway that you made, copy the URL.

Roblox Side
Create a module script and paste the following code, be sure to change where it has the aws & discord webhook url.
local HttpService = game:GetService("HttpService")
local CONST_WEBHOOK = "DISCORD_API_WEBHOOK_HERE"
local CONST_AWS = "AWS_API_GATEWAY_URL_HERE"
local robloxToDiscord = {}

function robloxToDiscord.webhook(msg)
	local data = {
		message = msg,
		webhook = CONST_WEBHOOK,
		bottitle = "Admin Command Ran"
	}

	-- Serialize your Lua table to a JSON string
	local jsonData = HttpService:JSONEncode(data)
	
	local success, response = pcall(function()
		return HttpService:PostAsync(CONST_AWS, jsonData, Enum.HttpContentType.ApplicationJson)
	end)

	-- Check if the request was successful and print the response
	if success then
		return "Successfully sent webhook call"
	else
		warn("HTTP request failed: " .. tostring(response))
		return "Failure!"
	end
end

return robloxToDiscord
Call the module like so:
local r2d = require(game.ServerScriptService.RobloxToDiscord)
r2d.webhook(“Ahoy!”)
There you have it, thanks for reading! This should end up being free unless you spam it, because the free tier allots for a lot of calls. I use it to monitor admin command usage.
