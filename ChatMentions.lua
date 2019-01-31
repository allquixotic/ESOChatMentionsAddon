--[[
Copyright 2018-2019 Sean McNamara <smcnam@gmail.com>.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

]]

local LCHAT = LibStub("libChat-1.0")
local LAM = LibStub("LibAddonMenu-2.0")

local cm_name = "ChatMentions"
local cm_playerName = GetUnitName("player")
local cm_lplayerName = string.lower(cm_playerName)
local cm_playerAt = GetUnitDisplayName("player")
local cm_lplayerAt = string.lower(cm_playerAt)
local cm_regexes = {}
local cm_savedVarsName = "ChatMentionsDB"
local cm_panelData = {
	type = "panel",
	name = cm_name,
	displayName = cm_name,
	author = "@Coorbin",
	version = "1.0",
	slashCommand = "/cmset",
	registerForRefresh = false,
	registerForDefaults = false,
	website = "https://github.com/allquixotic/ESOChatMentionsAddon",
}
local cm_savedVariables = {}
local cm_tempNames = {}
local function cm_nocase (s)
	s = string.gsub(s, "%a", function (c)
		  return string.format("[%s%s]", string.lower(c), string.upper(c))
		end)
	return s
end
local function cm_yo()
	GetAddOnManager():RequestAddOnSavedVariablesPrioritySave(cm_savedVarsName)
end
-- Turn a ([0,1])^3 RGB colour to "ABCDEF" form. We could use ZO_ColorDef, but we have so many colors so we don't do it.
local function cm_convertRGBToHex(r, g, b)
	return string.format("%.2x%.2x%.2x", zo_floor(r * 255), zo_floor(g * 255), zo_floor(b * 255))
end

-- Convert a colour from "ABCDEF" form to [0,1] RGB form.
local function cm_convertHexToRGBA(colourString)
	local r=tonumber(string.sub(colourString, 3-2, 4-2), 16) or 255
	local g=tonumber(string.sub(colourString, 5-2, 6-2), 16) or 255
	local b=tonumber(string.sub(colourString, 7-2, 8-2), 16) or 255
	return r/255, g/255, b/255, 1
end

local function cm_convertHexToRGBAPacked(colourString)
	local r, g, b, a = cm_convertHexToRGBA(colourString)
	return {r = r, g = g, b = b, a = a}
end

local function cm_split(text)
	local spat, epat, buf, quoted = [=[^(['"])]=], [=[(['"])$]=]
	local retval = {}
	for str in text:gmatch("%S+") do
		local squoted = str:match(spat)
		local equoted = str:match(epat)
		local escaped = str:match([=[(\*)['"]$]=])
		if squoted and not quoted and not equoted then
			buf, quoted = str, squoted
		elseif buf and equoted == quoted and #escaped % 2 == 0 then
			str, buf, quoted = buf .. ' ' .. str, nil, nil
		elseif buf then
			buf = buf .. ' ' .. str
		end
		if not buf then table.insert(retval, (str:gsub(spat,""):gsub(epat,""))) end
	end
	if buf then 
		return { [1] = "Missing matching quote for "..buf } 
	else
		return retval
	end
end

local function cm_list()
	local splitted = {}
	if cm_savedVariables.selfchar == true then
		splitted = cm_split(cm_playerName)
	end
	if cm_savedVariables.extras ~= nil then
		for line in cm_savedVariables.extras:gmatch("[^\r\n]+") do
			table.insert(splitted, line)
		end
	end
	for p,q in pairs(cm_tempNames) do
		table.insert(splitted, q)
	end
	return splitted
end

local function cm_print_list()
	d(cm_list())
end

local function cm_loadRegexes()
	local splitted = cm_list()
	cm_regexes = {}
	for k,v in pairs(splitted) do
		local keyBuild = {}
		if cm_savedVariables["excl"] == true then
			table.insert(keyBuild, "|t100%%:100%%:ChatMentions/dds/excl3.dds|t")
		end
		if pChat == nil and cm_savedVariables["underline"] == true then
			table.insert(keyBuild, "|l0:1:1:0:1:000000|l")
		end
		if cm_savedVariables["changeColor"] == true then
			table.insert(keyBuild, "|c")
			table.insert(keyBuild, cm_savedVariables["color"])
		end
		if cm_savedVariables["capitalize"] == true then
			table.insert(keyBuild, string.upper(v))
		else
			table.insert(keyBuild, v)
		end
		if cm_savedVariables["changeColor"] == true then
			table.insert(keyBuild, "|r")
		end
		if pChat == nil and cm_savedVariables["underline"] == true then
			table.insert(keyBuild, "|l")
		end
		cm_regexes[table.concat(keyBuild, "")] = cm_nocase(v)
	end
end

local function cm_getUnderlineOption()
	if pChat ~= nil then
		return 
		{
			type = "checkbox",
			name = "Underline text? (BROKEN BY pChat)",
			getFunc = function() 
				return false
			end,
			setFunc = function(var) 
				cm_savedVariables.underline = var
				cm_yo()
				cm_loadRegexes()
			end,
			tooltip = "DISABLE PCHAT TO UNLOCK THIS FEATURE. Until I can figure out a workaround, this feature is disabled while pChat is enabled.",
			default = false,
			disabled = function()
				return true
			end,
			width = "full",
		}
	else
		return 
		{
			type = "checkbox",
			name = "Underline text?",
			getFunc = function() 
				return cm_savedVariables.underline
			end,
			setFunc = function(var) 
				cm_savedVariables.underline = var
				cm_yo()
				cm_loadRegexes()
			end,
			tooltip = "Whether or not to underline your name when your name is mentioned.",
			default = false,
			disabled = function()
				return false
			end,
			width = "full",
		}
	end
end

local cm_optionsData = {
	{
		type = "checkbox",
		name = "Change color of text when your name is mentioned?",
		getFunc = function() 
			return cm_savedVariables.changeColor
		end,
		setFunc = function(var) 
			cm_savedVariables.changeColor = var
			cm_yo()
			cm_loadRegexes()
		end,
		tooltip = "Whether or not to change the text color when your name is mentioned.",
		default = true,
		width = "full",
	},
	{
		type = "colorpicker",
		name = "Color of your name when mentioned",
		getFunc = function() 
			return cm_convertHexToRGBA(cm_savedVariables.color) 
		end,
		setFunc = function(r, g, b) 
			cm_savedVariables.color = cm_convertRGBToHex(r, g, b) 
			cm_yo()
			cm_loadRegexes()
		end,
		disabled = function()
			return not cm_savedVariables.changeColor
		end,
		default = function()
			return cm_convertHexToRGBAPacked(cm_defaultVars.color)
		end,
	},
	cm_getUnderlineOption(),
	{
		type = "checkbox",
		name = "Add exclamation icon?",
		getFunc = function() 
			return cm_savedVariables.excl
		end,
		setFunc = function(var) 
			cm_savedVariables.excl = var
			cm_yo()
			cm_loadRegexes()
		end,
		tooltip = "Whether or not to add an exclamation point icon at the beginning when your name is mentioned.",
		default = true,
		width = "full",
	},
	{
		type = "checkbox",
		name = "ALL CAPS your name?",
		getFunc = function() 
			return cm_savedVariables.capitalize
		end,
		setFunc = function(var) 
			cm_savedVariables.capitalize = var
			cm_yo()
			cm_loadRegexes()
		end,
		tooltip = "Whether or not to ALL CAPS your name when your name is mentioned.",
		default = true,
		width = "full",
	},
	{
		type = "editbox",
		name = "Extra names to ping on (newline per name)",
		tooltip = "A newline-separated list of additional names to ping you on. Press ENTER to make new lines.",
		getFunc = function()
			return cm_savedVariables.extras
		end,
		setFunc = function(var)
			cm_savedVariables.extras = var
			cm_yo()
			cm_loadRegexes()
		end,
		isMultiline = true,
		isExtraWide = true,
		width = "full",
		default = "",
	},
	{
		type = "checkbox",
		name = "Apply to messages YOU send?",
		getFunc = function() 
			return cm_savedVariables.selfsend
		end,
		setFunc = function(var) 
			cm_savedVariables.selfsend = var
			cm_yo()
		end,
		tooltip = "Whether or not to apply formatting to messages YOU send.",
		default = false,
		width = "full",
	},
	{
		type = "checkbox",
		name = "Ding sound?",
		getFunc = function() 
			return cm_savedVariables.ding
		end,
		setFunc = function(var) 
			cm_savedVariables.ding = var
			cm_yo()
		end,
		tooltip = "Whether or not to play a ding sound when your name is mentioned.",
		default = true,
		width = "full",
	},
	{
		type = "checkbox",
		name = "Apply to your character names?",
		getFunc = function() 
			return cm_savedVariables.selfchar
		end,
		setFunc = function(var) 
			cm_savedVariables.selfchar = var
			cm_yo()
			cm_loadRegexes()
		end,
		tooltip = "Whether or not to apply formatting to each name in your character name. Disable if you use a very common name like 'Me' in your character name.",
		default = true,
		width = "full",
	},
}
local cm_defaultVars = {
	excl = true,
	underline = false,
	changeColor = true,
	color = "3af47e",
	capitalize = true,
	extras = "",
	selfsend = false,
	ding = true,
	selfchar = true,
}

local function cm_onChatMessage(channelID, from, text, isCustomerService, fromDisplayName)
	local lfrom = string.lower(from)
	if isCustomerService == false then
		if cm_savedVariables.selfsend or lfrom == cm_lplayerAt or lfrom == cm_lplayerName then
			local origtext = text
			for k,v in pairs(cm_regexes) do
				text = string.gsub(text, v, k)
				if origtext ~= text then
					if cm_savedVariables.ding == true then
						PlaySound(SOUNDS.NEW_NOTIFICATION)
					end
					return text
				end
			end
		end
	end
	return text
end

local function cm_add(argu)
	table.insert(cm_tempNames, argu)
	cm_loadRegexes()
	d("ChatMentions added " .. argu .. " to temporary list of names to ping on.")
end

local function cm_del(argu)
	local keyToRemove = nil
	local valueRemoved = nil
	argu = string.lower(argu)
	for k, v in pairs(cm_tempNames) do
		local lcharName = string.lower(v)
		if lcharName == argu then
			valueRemoved = v
			keyToRemove = k
		end
	end
	if keyToRemove ~= nil then
		table.remove(cm_tempNames, keyToRemove)
		cm_loadRegexes()
		d("ChatMentions removed " .. argu .. " from temporary list of names to ping on.")
	else
		d("ChatMentions didn't find " .. argu .. " in the list of temporary names to ping on.")
	end
end

local function cm_OnAddOnLoaded(event, addonName)
	if addonName == cm_name then
		EVENT_MANAGER:UnregisterForEvent(cm_name, EVENT_ADD_ON_LOADED)
		cm_savedVariables = ZO_SavedVars:NewAccountWide(cm_savedVarsName, 15, nil, cm_defaultVars)
		LAM:RegisterAddonPanel(addonName, cm_panelData)
		LAM:RegisterOptionControls(addonName, cm_optionsData)	

		--ChatMentions-specific init
		cm_loadRegexes()
		SLASH_COMMANDS["/cmadd"] = cm_add
		SLASH_COMMANDS["/cmdel"] = cm_del
		SLASH_COMMANDS["/cmlist"] = cm_print_list
		LCHAT:registerText(cm_onChatMessage, cm_name)
	end
end

EVENT_MANAGER:RegisterForEvent(cm_name, EVENT_ADD_ON_LOADED, cm_OnAddOnLoaded)