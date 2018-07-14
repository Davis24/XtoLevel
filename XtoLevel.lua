-- Name: XtoLevel
-- Verson: 1.1.5
-- Author: Devisaur
-- Description: Displays information on character leveling.
-- For More Info See Github README (https://github.com/Davis24/XtoLevel)
-------------------------------------------------------------------------------------------------
--  Libraries --
-------------------------------------------------------------------------------------------------
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0")

------------------------------------------------------------------------------------------------
--  Initialize Variables --
------------------------------------------------------------------------------------------------
XtoLevel = {}
XtoLevel.Default = {
	OffSetX = 0,
	OffSetY = 0,
	width = 200,
	height = 175,
	iconSize = 25,
	avgXP = {0,0,0,0,0,0,1}, -- battleground, delve, dolmen, dungeon, monster, quest, overall
	display = "text",
	show = true,
}

local ADDON_NAME = "XtoLevel"
local ADDON_AUTHOR = "Devisaur"
local ADDON_AUTHOR_DISPLAY_NAME = "@Devisaur"
local ADDON_VERSION = "2.0"

--XtoLevel.name = "XtoLevel"
XtoLevel.version = 2

--[[XtoLevel.currentPlayerXP = 0
XtoLevel.XPAMin = 0
XtoLevel.levelXP = 0
XtoLevel.remainingXP = 0
XtoLevel.XPAMin = 0]]--
local currentPlayerXP, XPAMin, levelXP, remainingXP = 0

local avgBattlegroundXP, avgDelveXP, avgDolmenXP, avgDungeonXP, avgMonsterXP, avgQuestXP = 0
local avgXPGained = 1

------------------------------------------------------------------------------------------------
--  Functions --
------------------------------------------------------------------------------------------------

--Loads all the saved variables
function XtoLevel.Initialize(eventCode, addonName)
	if (addonName ~= ADDON_NAME) then
		return
	end
	
	XtoLevel.savedVariables = ZO_SavedVars:New("XtoLevelVars", 2, nil, XtoLevel.Default)
	XtoLevel.CreateSettingsWindow()
	XtoLevelUI:ClearAnchors()
	XtoLevelUI:SetHidden(not XtoLevel.savedVariables.show)
	XtoLevelUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, XtoLevel.savedVariables.OffSetX, XtoLevel.savedVariables.OffSetY)
	XtoLevelUI:SetDimensions(XtoLevel.savedVariables.width, XtoLevel.savedVariables.height)
	avgBattlegroundXP, avgDelveXP, avgDolmenXP, avgDungeonXP, avgMonsterXP, avgQuestXP, avgXPGained = unpack(XtoLevel.savedVariables.avgXP)

	--Check if character is using Champion levels
	if(GetUnitLevel('player') == 50) then
		XtoLevel.SetChampionValues()
	else
		XtoLevel.SetLevelValues()
	
	end
	
	XtoLevel.SetText()

	if(XtoLevel.savedVariables.display == "text") then
		local legend = {text = false, icon = true}
		XtoLevel.SetDisplayLegend(legend)
	else
		local legend = {text = true, icon = false}
		XtoLevel.SetDisplayLegend(legend)
	end
	
	--[[if(XtoLevel.savedVariables.show == true) then
		XtoLevelUI:SetHidden(true)
	end--]]

	EVENT_MANAGER:UnregisterForEvent(ADDON_NAME, EVENT_ADD_ON_LOADED)
end

-------------------------------------------------------------------------------------------------
--  Menu Functions --
-------------------------------------------------------------------------------------------------
function XtoLevel.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "XtoLevel",
		displayName = "XtoLevel",
		author = ADDON_AUTHOR,
		version = ADDON_VERSION,
		slashCommand = "/xtolevel",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("XtoLevel_Panel", panelData)

	local optionsData = {
		[1] = {
			type = "header",
			name = "XtoLevel Settings"
		},
		[2] = {
			type = "description",
			text = "Here you can adjust how XtoLevel Looks."
		},
		[3] = {
			type = "checkbox",
			name = "Show XtoLevel",
			tooltip = "When ON the XtoLevel panel will be visible. When OFF the XtoLevel panel will be show.",
			default = true,
			getFunc = function() return XtoLevel.savedVariables.show end,
			setFunc = function(newValue) 
				XtoLevel.savedVariables.show = newValue
				XtoLevelUI:SetHidden(not newValue)  end,
		},
		[4] = {
			type = "slider",
			name = "Select Width",
			tooltip = "Adjusts the width of the XtoLevel panel.",
			min = 100,
			max = 1000,
			step = 1,
			default = 200,
			getFunc = function() return XtoLevel.savedVariables.width end,
			setFunc = function(newValue) 
						XtoLevel.savedVariables.width = newValue
						XtoLevelUI:SetDimensions(newValue, XtoLevel.savedVariables.height)
						end,
		},
		[5] = {
			type = "slider",
			name = "Select Height",
			tooltip = "Adjusts the height of the XtoLevel panel.",
			min = 100,
			max = 1000,
			step = 1,
			default = 175,
			getFunc = function() return XtoLevel.savedVariables.height end,
			setFunc = function(newValue) 
						XtoLevel.savedVariables.height = newValue
						XtoLevelUI:SetDimensions(XtoLevel.savedVariables.width,newValue)
						end,
		},
		[6] = {
			type = "slider",
			name = "Select Icon Size",
			tooltip = "Adjusts the height of the XtoLevel panel.",
			min = 0,
			max = 100,
			step = 1,
			default = 25,
			getFunc = function() return XtoLevel.savedVariables.iconSize end,
			setFunc = function(newValue) 
						XtoLevel.savedVariables.iconSize = newValue
						XtoLevel.SetIconSize(newValue,newValue)
						end,
		},
		[7] = {
			type = "dropdown",
			name = "Select Display Type",
			tooltip = "Change the way each category is displayed in the XtoLevel panel.",
			choices = {"Text","Icons"},
			default = "Text",
			getFunc = function () return XtoLevel.savedVariables.display end,
			setFunc = function(newValue) 
						XtoLevel.savedVariables.display = newValue
						local legend = nil
						if(newValue == "Text") then
							legend = {text = false, icon = true}
						else
							legend = {text = true, icon = false}
						end
						XtoLevel.SetDisplayLegend(legend)
					end,
		},
	}
	LAM2:RegisterOptionControls("XtoLevel_Panel", optionsData)
end


function XtoLevel.SetIconSize(w,h)
	XtoLevelUIBattlegroundsTexture:SetDimensions(w,h)
	XtoLevelUIDelvesTexture:SetDimensions(w,h)
	XtoLevelUIDolmensTexture:SetDimensions(w,h)
	XtoLevelUIDungeonsTexture:SetDimensions(w,h)
	XtoLevelUIMonstersTexture:SetDimensions(w,h)
	XtoLevelUIQuestsTexture:SetDimensions(w,h)
	XtoLevelUITimeTexture:SetDimensions(w,h)
end

-- Gets called when XP is gained
function XtoLevel.XPUpdate(eventCode, reason, level, previousExperience, currentExperience, championPoints) 
	--[[d("-----------------------")
	d("EVENT_EXPERIENCE_GAIN - XPUpdate Triggered ")
	d("Event Code -"..eventCode)
	d("Reason - "..reason)
	d("Level - "..level)
	d("Previous XP - "..previousExperience)
	d("Current XP - "..currentExperience)
	d("Champion Points" ..championPoints)--]]
	
	local xpGained = 0

	xpGained = currentExperience - previousExperience
	currentPlayerXP = currentExperience 
	remainingXP = levelXP - currentExperience

	if(reason == 0) then -- Kill (i.e monster)		
		avgMonsterXP = (.1 * xpGained) + (.9 * avgMonsterXP)
	elseif(reason == 1) then -- Quest Completed
		avgQuestXP = (.5 * xpGained) + (.5 * avgQuestXP)
	elseif(reason == 2) then -- Complete POI (which should be delves but I believe it also triggers on other things)
		avgDelveXP = (.5 * xpGained) + (.5 * avgDelveXP)
	elseif(reason == 37) then -- Dungeon XP
		avgDungeonXP = (.5 * xpGained) + (.5 * avgDungeonXP)
	elseif(reason == 4) then -- Battleground
		avgBattlegroundXP = (.5 * xpGained) + (.5 * avgBattlegroundXP)
	elseif(reason == 7) then -- Dolmens (big and little ones)
		avgDolmenXP = (.5 * xpGained) + (.5 * avgDolmenXP)
	--else
		--d("Other XP event:" .. reason) -- Comment out before deployment
	end

	XPAMin = XPAMin + xpGained
	XtoLevel.SetText()
	
end

function XtoLevel.ChampionLeveledUp(eventCode, championPointsDelta)
	levelXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) 
	currentPlayerXP = GetPlayerChampionXP()
	remainingXP = levelXP - currentPlayerXP 

	XtoLevel.SetText()
	XtoLevel.AverageTime()
end

-- Called when character level is below 50
function XtoLevel.LeveledUp(eventCode, unitTag, level) 
	if ( unitTag ~= 'player' ) then return end

	initialXP = GetUnitXP('player')
	levelXP = GetNumExperiencePointsInLevel(level) 
	remainingXP = levelXP - currentPlayerXP
	
	XtoLevel.SetText()
	XtoLevel.AverageTime()
end

function XtoLevel.SetChampionValues()
	currentPlayerXP = GetPlayerChampionXP() -- the players XP, updates as XP is gained
	levelXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) -- total level XP
	remainingXP = levelXP - currentPlayerXP --How much XP remaining in the level
end

function XtoLevel.SetLevelValues()
	currentPlayerXP = GetUnitXP('player') -- the players XP, updates as XP is gained
	levelXP = GetNumExperiencePointsInLevel(GetUnitLevel('player')) -- total level XP
	remainingXP = levelXP - currentPlayerXP --How much XP remaining in the level
end

--Sets currentPlayerXP based on the level, if the Character is level 50 use champion points otherwise use unitXP
function XtoLevel.GetCurrentPlayerXP()
	if(GetUnitLevel('player') == 50) then
		return GetPlayerChampionXP()
	else
		return GetUnitXP('player')
	end
end

--Calculates the average time to level
function XtoLevel.AverageTime()
	--d("-------------")
	--d("Average Time")
	--d("XPAMin: ".. XPAMin)
	if (avgXPGained == nil or avgXPGained == '') then
		avgXPGained = 1
	end
	--d("Average XP Gained: "..avgXPGained)

	if(XPAMin == nil or XPAMin == 0) then
		avgXPGained = .9 * avgXPGained
	else
		avgXPGained = (.3 * XPAMin) + (.5 * avgXPGained)
	end

	local avgOverallXPAMin = zo_round(remainingXP/avgXPGained)
	if(avgOverallXPAMin > 120) then
		XtoLevelUITimeNum:SetText("> 2 hrs")
	else
		XtoLevelUITimeNum:SetText(avgOverallXPAMin .. " mins")
	end
	
	XPAMin = 0
end

function XtoLevel.SetText()
	local battle = zo_round(remainingXP/avgBattlegroundXP)
	local delv = math.ceil(remainingXP/avgDelveXP)
	local dol = math.ceil(remainingXP/avgDolmenXP)
	local dung = math.ceil(remainingXP/avgDungeonXP)
	local mon = math.ceil(remainingXP/avgMonsterXP)
	local ques = math.ceil(remainingXP/avgQuestXP)

	if(battle == math.huge) then
		XtoLevelUIBattlegroundsNum:SetText("?")
	else
		XtoLevelUIBattlegroundsNum:SetText(battle)
	end
	
	if(delv == math.huge) then
		XtoLevelUIDelvesNum:SetText("?")
	else
		XtoLevelUIDelvesNum:SetText(delv)
	end
	
	if(dol == math.huge) then
		XtoLevelUIDolmensNum:SetText("?")
	else
		XtoLevelUIDolmensNum:SetText(dol)
	end
	
	if(dung == math.huge) then
		XtoLevelUIDungeonsNum:SetText("?")
	else
		XtoLevelUIDungeonsNum:SetText(dung)
	end
	
	if(mon == math.huge) then
		XtoLevelUIMonstersNum:SetText("?")
	else
		XtoLevelUIMonstersNum:SetText(mon)
	end
	
	if (ques == math.huge) then
		XtoLevelUIQuestsNum:SetText("?")
	else
		XtoLevelUIQuestsNum:SetText(ques)
	end
end

function XtoLevel.SaveLoc()
	XtoLevel.savedVariables.OffSetX = XtoLevelUI:GetLeft()
	XtoLevel.savedVariables.OffSetY = XtoLevelUI:GetTop()
end

function XtoLevel.SaveSize()
	XtoLevel.savedVariables.width = XtoLevelUI:GetWidth()
	XtoLevel.savedVariables.height = XtoLevelUI:GetHeight()

end

function XtoLevel.Save()
	XtoLevel.savedVariables.avgXP = {avgBattlegroundXP,avgDelveXP,avgDolmenXP,avgDungeonXP,avgMonsterXP,avgQuestXP,avgXPGained}
	--XtoLevel.savedVariables.show = XtoLevelUI:IsHidden() -- should check if it's show and save
end

function XtoLevel.SetDisplayLegend(legend)
	XtoLevelUIBattlegroundsLabel:SetHidden(legend.text)
	XtoLevelUIBattlegroundsTexture:SetHidden(legend.icon)
	
	XtoLevelUIDelvesLabel:SetHidden(legend.text)
	XtoLevelUIDelvesTexture:SetHidden(legend.icon)
	
	XtoLevelUIDolmensLabel:SetHidden(legend.text)
	XtoLevelUIDolmensTexture:SetHidden(legend.icon)
	
	XtoLevelUIDungeonsLabel:SetHidden(legend.text)
	XtoLevelUIDungeonsTexture:SetHidden(legend.icon)
	
	XtoLevelUIMonstersLabel:SetHidden(legend.text)
	XtoLevelUIMonstersTexture:SetHidden(legend.icon)
	
	XtoLevelUIQuestsLabel:SetHidden(legend.text)
	XtoLevelUIQuestsTexture:SetHidden(legend.icon)
	
	XtoLevelUITimeLabel:SetHidden(legend.text)
	XtoLevelUITimeTexture:SetHidden(legend.icon)
end

--Reset all stored values
function XtoLevel.Reset()
	avgBattlegroundXP = 0
	avgDelveXP = 0
	avgDolmenXP = 0
	avgDungeonXP = 0
	avgMonsterXP = 0
	avgQuestXP = 0
	avgXPGained = 1
	XtoLevel.SetText()
end

------------------------------------------------------------------------------------------------
--  Slash --
------------------------------------------------------------------------------------------------
 
--[[SLASH_COMMANDS["/xtolevel"] = function (options)

	if options == "" or options == "help" then
       CHAT_SYSTEM:AddMessage("XtoLevel v" .. XtoLevel.version)
	   CHAT_SYSTEM:AddMessage("Author: Devisaur")
	   CHAT_SYSTEM:AddMessage("/xtolevel reset        -- resets XP values")
	   CHAT_SYSTEM:AddMessage("/xtolevel show       -- shows the addon")
	   CHAT_SYSTEM:AddMessage("/xtolevel hide         -- hides the addon")
	   CHAT_SYSTEM:AddMessage("/xtolevel text          -- displays categories as text")
	   CHAT_SYSTEM:AddMessage("/xtolevel icons       -- displays categories as icons")
    elseif options == "reset" then
		XtoLevel.Reset()
	elseif options == "show" then
		XtoLevelUI:SetHidden(false)
	elseif options == "hide" then
		XtoLevelUI:SetHidden(true)
	elseif options == "icons" then
		local legend = {text = true, icon = false}
		XtoLevel.SetDisplayLegend(legend)
		XtoLevel.savedVariables.display = "icon"
	elseif options == "text" then
		local legend = {text = false, icon = true}
		XtoLevel.SetDisplayLegend(legend)
		XtoLevel.savedVariables.display = "text"
	end
end]]--

------------------------------------------------------------------------------------------------
--  Events --
------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED, XtoLevel.Initialize)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_EXPERIENCE_GAIN, XtoLevel.XPUpdate)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_LEVEL_UPDATE, XtoLevel.LeveledUp)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_CHAMPION_POINT_GAINED, XtoLevel.ChampionLeveledUp)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_PLAYER_DEACTIVATED, XtoLevel.Save)
EVENT_MANAGER:RegisterForUpdate(XtoLevel.name, 60000, XtoLevel.AverageTime)