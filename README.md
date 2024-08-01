# roblox-to-discord
This is how you can send messages from ingame Roblox to Discord using AWS lambda functions and Discord Webhooks!

Want to make your own NPC’s where you build their background and then respond as the person you want them to be? In this tutorial I’ll show you how!

Go to https://platform.openai.com/playground/assistants 5 make an account and create an assistant. To call this API it will cause an extremely small amount of money per the tokens you use so you’ll need to put money into your account.

Select your model. I would recommend going with any 3.5 turbo model, it will be quick but it will be cheaper. The more advanced the version you pick, the better the responses are going to be to the bio you give.

Give it a name. I gave it the name “Bob the medieval guy”

Give it a description under instructions, the more details you give the better. I said: You’re bob, a medieval peasant who doesn’t know much. You have the education of a kindergartener and all you do is farm your entire life. You have a hard time speaking good english and your speech is broken and barely understandable. You can ask it questions in the browser to see how it responds before you use it.

Under your NPC name, copy the assistant id, will look something like asst_awwbdhwbibawdhbwaudwndwd and add it into the module script where it says local assistantId = ‘asst_’

Click settings, click your profile, click user API keys, create an API key, and copy it and add it in where it says local apiKey = ‘’

Put the module script where you want it and call is like this:

local gpt = require(game.ServerScriptService.AskGPT)
gpt.ask("what color is the sky?")
The response it gave me was: Sky blue! Sky always blue, sometimes grey. Sky pretty, like flowers!
(remember this particular peasant is a medieval npc)

Module script:

local apiKey = -- Replace with your API key
local assistantId = 

local HttpService = game:GetService("HttpService")
local function httpPost(url, data, headers)
	local response = HttpService:RequestAsync({
		Url = url,
		Method = "POST",
		Headers = headers,
		Body = HttpService:JSONEncode(data)
	})
	return response
end

-- Function to make HTTP GET request
local function httpGet(url, headers)
	local response = HttpService:RequestAsync({
		Url = url,
		Method = "GET",
		Headers = headers
	})
	return response
end

local function waitForRunCompletion(threadId, runId, apiKey, timeout)
	timeout = timeout or 50
	local startTime = tick()

	while tick() - startTime < timeout do
		local statusResponse = httpGet(
			"https://api.openai.com/v1/threads/" .. threadId .. "/runs/" .. runId,
			{["Authorization"] = "Bearer " .. apiKey,
				["Content-Type"] = "application/json",
				["OpenAI-Beta"] = "assistants=v1"}
		)
		local runStatus = HttpService:JSONDecode(statusResponse.Body).status

		print(runStatus)

		if runStatus == 'completed' then
			return statusResponse
		elseif runStatus == 'failed' then
			error("Run failed.")
			break
		end

		wait(1)  -- Delay before the next status check
	end

	error("Run did not complete within the specified timeout.")
end


local agpt = {}

function agpt.ask(question)
	local threadResponse = httpPost(
		"https://api.openai.com/v1/threads",
		{messages = {{["role"] = "user", ["content"] = question}}},
		{["Authorization"] = "Bearer " .. apiKey,
			["Content-Type"] = "application/json",
			["OpenAI-Beta"] = "assistants=v1"}
	)
	local thread = HttpService:JSONDecode(threadResponse.Body)
	print(thread)
	-- Create run
	local runResponse = httpPost(
		"https://api.openai.com/v1/threads/" .. thread.id .. "/runs",
		{assistant_id = assistantId},
		{["Authorization"] = "Bearer " .. apiKey,
			["Content-Type"] = "application/json",
			["OpenAI-Beta"] = "assistants=v1"}
	)
	local run = HttpService:JSONDecode(runResponse.Body)

	-- Wait for completion
	local completedRun = waitForRunCompletion(thread.id, run.id, apiKey, 60)

	-- Retrieve messages
	local messagesResponse = httpGet(
		"https://api.openai.com/v1/threads/" .. thread.id .. "/messages",
		{["Authorization"] = "Bearer " .. apiKey,
			["Content-Type"] = "application/json",
			["OpenAI-Beta"] = "assistants=v1"}
	)
	local messages = HttpService:JSONDecode(messagesResponse.Body)

	-- Log messages
	print(messages.data[1].content[1].text.value)
end
return agpt

That’s the tutorial, be careful with your usage, You don’t want to use it where it would be spammed, unless you make a lot of money from the game you use it in. Thanks for reading!
