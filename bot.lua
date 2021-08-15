-- Modules
local discordia = require('discordia')
local client = discordia.Client()
local json = require('json')
local coro = require('coro-http')

-- config.json file setup
settings = io.open("config.json", "r")
if not settings then
	print("Config.json not found. Please check the github repo again and re-download. Bot will stop now!1!!")
	client:stop()
	return true
end
config = json.parse(settings:read())
settings:close()

-- Some Variables
discordia.extensions()
token = config.token
prefix = config.prefix
if token == "YOUR_BOT_TOKEN" then
	print("Open config.json and replace YOUR_BOT_TOKEN with your Discord Bot Token. Visit https://discord.com/developers/applications")
	client:stop()
	return true
end
cd = ":white_check_mark: Please wait while I get the data!"

-- Bot Functions
client:on('ready', function() -- on ready
	print('Logged in as '.. client.user.username)
	client:setGame{
		name = prefix.."help | made by Adib23704#8947",
		type = 3 -- 0 - playing, 2 - listening, 3 - watching | Using 1 or higher than 3 (e.g: 4, 5) will not appear.
	}
end)

client:on("buttonPressed", function (type, buttonid, member, message, values)
    
end)

client:on('messageCreate', function(message)
	local content = message.content
	local member = message.member
	local memberid = message.member.id
	if memberid == client.user.id then return end
	local args = split(content, " ")
	local content = string.lower(content)
	if content:find(prefix..'latest') then -- `latest` command
		getLatest(message)
	end
	if content:find(prefix..'list') then
		if (table.count(args) <= 1) then
			getList(1, message)
		elseif (tostring(args[2]) >= '4') then
			message:reply(":x: Invalid Page number. Only available from 1 to 3.")
		else
			getList(tonumber(args[2]), message)
		end
	end
	if content:find(prefix..'region') then
		if (table.count(args) <= 1) then
			message:reply(':x: Incorrect Usage\n```\nUsage: '..prefix..'region <Region Name>\nExample: '..prefix..'region Bangladesh\n```')
		else
			getRegion(tostring(args[2]), message)
		end
	end
	if content:find(prefix..'today') then
		if (table.count(args) <= 1) then
			message:reply(':x: Incorrect Usage\n```\nUsage: '..prefix..'today <Region Name>\nExample: '..prefix..'today Bangladesh\n```')
		else
			getToday(tostring(args[2]), message)
		end
	end
	if content:find(prefix..'help') then
		help(message)
	end
end)

function help(message)
	local member = message.member
	message:reply {
		embed = {
			title = "CoronaBot Commands",
			color = discordia.Color.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)).value,
			description = "This bot is an open-source discord bot and made by Adib23704#8947",
			author = {
				name = member.username,
				icon_url = member.avatarURL
			},
			fields = {
				{
					name = "`"..prefix.."latest`",
					value = "Get latest status of Covid-19",
					inline = false,
				},
				{
					name = "`"..prefix.."region`",
					value = "Get latest status of Covid-19 of a specific region/country",
					inline = false,
				},
				{
					name = "`"..prefix.."list`",
					value = "Get the list of countries infected with Covid-19",
					inline = false,
				},
			},
			footer = {
				text = "CoronaBot | https://adib23704.github.io"
			},
		},
		components = {
		    {
		        type = 1,
		        components = {
		            {
		                type = 2,
		                label = "Bot's Github",
		                style = 5,
		                url = "https://github.com/Adib23704/CoronaBot"
		            },
		            {
		                type = 2,
		                label = "Visit Author",
		                style = 5,
		                url = "https://adib23704.github.io"
		            }
		        },
		    },
		},
	}
end

function getList(arg, message) -- `latest` command
	local list = {}
	local member = message.member
	local wait = message:reply(cd)
	local url = "https://api.quarantine.country/api/v1/regions"
	local result, body = coro.request("GET", url)
	local final = json.parse(body)
	if arg == 1 then
		for i = 1, 80 do
			--local i = tonumber(i-1)
			local key = final.data[i].name
			table.insert(list, key)
		end
	elseif arg == 2 then
		for i = 81, 158 do
			--local i = tonumber(i-1)
			local key = final.data[i].name
			table.insert(list, key)
		end
	elseif arg == 3 then
		for i = 159, 238 do
			--local i = tonumber(i-1)
			local key = final.data[i].name
			table.insert(list, key)
		end
	end
	message:reply {
		embed = {
			title = "List of countries infected with Covid-19",
			color = discordia.Color.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)).value,
			description = table.concat(list, "\n"),
			author = {
				name = member.username,
				icon_url = member.avatarURL
			},
			footer = {
				text = "Use "..prefix.."list <page number> for more | CoronaBot | https://quarantine.country"
			},
		},
	}
	wait:delete()
end

function getLatest(message) -- `latest` command
	local member = message.member
	local wait = message:reply(cd)
	local url = "https://api.quarantine.country/api/v1/summary/latest"
	local result, body = coro.request("GET", url)
	local final = json.parse(body)

	message:reply{
		embed = {
			title = "Current latest data of Covid-19",
			color = discordia.Color.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)).value,
			description = string.format("This data of the whole world and last update %s", os.date("%x", final.data.generated_on)),
			author = {
				name = member.username,
				icon_url = member.avatarURL
			},
			fields = {
				{
					name = "Total Infected",
					value = numWithCommas(final.data.summary.total_cases),
					inline = true
				},
				{
					name = "Active Infected",
					value = numWithCommas(final.data.summary.active_cases),
					inline = true
				},
				{
					name = "Total Deaths",
					value = numWithCommas(final.data.summary.deaths),
					inline = true
				},
				{
					name = "Total Infected Recovered",
					value = numWithCommas(final.data.summary.recovered),
					inline = true
				},
				{
					name = "Total Critical Infections",
					value = numWithCommas(final.data.summary.critical),
					inline = true
				},
				{
					name = "Total Virus Tested",
					value = numWithCommas(final.data.summary.tested),
					inline = true
				},
			},
			footer = {
				text = "CoronaBot | https://quarantine.country"
			},
		},
	}
	wait:delete()
end

function getRegion(name, message)
	local member = message.member
	local wait = message:reply(cd)
	local region = "https://api.quarantine.country/api/v1/summary/region?region="..name
	local result, body = coro.request("GET", region)
	local final = json.parse(body)
	if final.status == 200 then
		message:reply{
			embed = {
				title = "Current Covid-19 data of " .. name,
				color = discordia.Color.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)).value,
				author = {
					name = member.username,
					icon_url = member.avatarURL
				},
				fields = {
					{
						name = "Total Infected",
						value = numWithCommas(final.data.summary.total_cases),
						inline = true
					},
					{
						name = "Active Infected",
						value = numWithCommas(final.data.summary.active_cases),
						inline = true
					},
					{
						name = "Total Deaths",
						value = numWithCommas(final.data.summary.deaths),
						inline = true
					},
					{
						name = "Total Infected Recovered",
						value = numWithCommas(final.data.summary.recovered),
						inline = true
					},
					{
						name = "Total Critical Infections",
						value = numWithCommas(final.data.summary.critical),
						inline = true
					},
					{
						name = "Total Virus Tested",
						value = numWithCommas(final.data.summary.tested),
						inline = true
					},
				},
				footer = {
					text = "CoronaBot | https://quarantine.country"
				},
			},
		}
	else
		message:reply(":x: Error! Wrong Input. " .. final.message .. ".")
	end
	wait:delete()
end

function getToday(name, message)
	local member = message.member
	local wait = message:reply(cd)
	local region = "https://api.quarantine.country/api/v1/spots/week?region="..name
	local result, body = coro.request("GET", region)
	local final = json.parse(body)
	local year = tostring(os.date("%Y"))
	local month = tostring(os.date("%m"))
	local day = tostring(os.date("%d"))
	if month:len() == 1 then
		month = "0"..month
	end
	if day:len() == 1 then
		day = "0"..day
	end
	local date = string.format("%s-%s-%s", year, month, day)
	if final.status == 200 then
		message:reply {
			embed = {
				title = "Today's Covid-19 data of " .. name,
				color = discordia.Color.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255)).value,
				author = {
					name = member.username,
					icon_url = member.avatarURL
				},
				fields = {
					{
						name = "Total Infected",
						value = numWithCommas(final.data[date].total_cases),
						inline = true
					},
					{
						name = "Total Deaths",
						value = numWithCommas(final.data[date].deaths),
						inline = true
					},
					{
						name = "Total Infected Recovered",
						value = numWithCommas(final.data[date].recovered),
						inline = true
					},
					{
						name = "Total Critical Infected",
						value = numWithCommas(final.data[date].critical),
						inline = true
					},
					{
						name = "Total Virus Tested",
						value = numWithCommas(final.data[date].tested),
						inline = true
					},
				},
				footer = {
					text = "CoronaBot | https://quarantine.country"
				},
			},
		}
	else
		message:reply(":x: Error! Wrong Input. " .. final.message .. ".")
	end
	wait:delete()
end

-- External Functions
function numWithCommas(n) -- Thanks to https://stackoverflow.com/a/10990879
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
end

function split(string, pattern) --From "deps/discordia/libs/extensions.lua"
    result = {}
    for match in (string..pattern):gmatch("(.-)"..pattern) do
        table.insert(result, match)
    end
    return result
end

-- Bot Run
client:run('Bot '.. token) 
