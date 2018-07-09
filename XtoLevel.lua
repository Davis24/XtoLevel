-- Name: XtoLevel
-- Verson: 1.1.5
-- Author: Devisaur
-- Description: Displays information on character leveling.
-- For More Info See Github README (https://github.com/Davis24/XtoLevel)


------------------------------------------------------------------------------------------------
--  Initialize Variables --
------------------------------------------------------------------------------------------------
XtoLevel = {}
XtoLevel.Default = {
	OffSetX = 0,
	OffSetY = 0,
	width = 200,
	height = 175,
	avgBattlegroundXP = 0,
	avgDelveXP = 0,
	avgDolmenXP = 0,
	avgDungeonXP = 0,
	avgMonsterXP = 0,
	avgQuestXP = 0,
	avgOverallXP = 1,
	display = "text",
	hidden = false
}

XtoLevel.name = "XtoLevel"
XtoLevel.version = 1.15

XtoLevel.currentPlayerXP = 0
XtoLevel.XPAMin = 0
XtoLevel.levelXP = 0
XtoLevel.remainingXP = 0
XtoLevel.XPAMin = 0

XtoLevel.avgBattlegroundXP = 0
XtoLevel.avgDelveXP = 0
XtoLevel.avgDolmenXP = 0
XtoLevel.avgDungeonXP = 0
XtoLevel.avgMonsterXP = 0
XtoLevel.avgQuestXP = 0
XtoLevel.avgXPGained = 1

------------------------------------------------------------------------------------------------
--  Functions --
------------------------------------------------------------------------------------------------

--Loads all the saved variables
function XtoLevel.Initialize(eventCode, addonName)
	if (addonName ~= XtoLevel.name) then
		return
	end
	
	XtoLevel.savedVariables = ZO_SavedVars:New("XtoLevelVars", XtoLevel.version, nil, XtoLevel.Default)
	XtoLevelUI:ClearAnchors()
	XtoLevelUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, XtoLevel.savedVariables.OffSetX, XtoLevel.savedVariables.OffSetY)
	XtoLevelUI:SetDimensions(XtoLevel.savedVariables.width, XtoLevel.savedVariables.height)
	
	XtoLevel.avgBattlegroundXP = XtoLevel.savedVariables.avgBattlegroundXP
	XtoLevel.avgDelveXP = XtoLevel.savedVariables.avgDelveXP 
	XtoLevel.avgDolmenXP = XtoLevel.savedVariables.avgDolmenXP
	XtoLevel.avgDungeonXP = XtoLevel.savedVariables.avgDungeonXP
	XtoLevel.avgMonsterXP = XtoLevel.savedVariables.avgMonsterXP
	XtoLevel.avgQuestXP = XtoLevel.savedVariables.avgQuestXP
	XtoLevel.avgXPGained = XtoLevel.savedVariables.avgXPGained

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
	
	if(XtoLevel.savedVariables.hidden == true) then
		XtoLevelUI:SetHidden(true)
	end

	EVENT_MANAGER:UnregisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED)
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
	XtoLevel.currentPlayerXP = currentExperience 
	XtoLevel.remainingXP = XtoLevel.levelXP - currentExperience

	if(reason == 0) then -- Kill (i.e monster)		
		XtoLevel.avgMonsterXP = (.1 * xpGained) + (.9 * XtoLevel.avgMonsterXP)
	elseif(reason == 1) then -- Quest Completed
		XtoLevel.avgQuestXP = (.5 * xpGained) + (.5 * XtoLevel.avgQuestXP)
	elseif(reason == 2) then -- Complete POI (which should be delves but I believe it also triggers on other things)
		XtoLevel.avgDelveXP = (.5 * xpGained) + (.5 * XtoLevel.avgDelveXP)
	elseif(reason == 37) then -- Dungeon XP
		XtoLevel.avgDungeonXP = (.5 * xpGained) + (.5 * XtoLevel.avgDungeonXP)
	elseif(reason == 4) then -- Battleground
		XtoLevel.avgBattlegroundXP = (.5 * xpGained) + (.5 * XtoLevel.avgBattlegroundXP)
	elseif(reason == 7) then -- Dolmens (big and little ones)
		XtoLevel.avgDolmenXP = (.5 * xpGained) + (.5 * XtoLevel.avgDolmenXP)
	--else
		--d("Other XP event:" .. reason) -- Comment out before deployment
	end

	XtoLevel.XPAMin = XtoLevel.XPAMin + xpGained
	XtoLevel.SetText()
	
end

function XtoLevel.ChampionLeveledUp(eventCode, championPointsDelta)
	XtoLevel.levelXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) 
	XtoLevel.currentPlayerXP = GetPlayerChampionXP()
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.currentPlayerXP 

	XtoLevel.SetText()
	XtoLevel.AverageTime()
end

-- Called when character level is below 50
function XtoLevel.LeveledUp(eventCode, unitTag, level) 
	if ( unitTag ~= 'player' ) then return end

	XtoLevel.initialXP = GetUnitXP('player')
	XtoLevel.levelXP = GetNumExperiencePointsInLevel(level) 
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.currentPlayerXP
	
	XtoLevel.SetText()
	XtoLevel.AverageTime()
end

function XtoLevel.SetChampionValues()
	XtoLevel.currentPlayerXP = GetPlayerChampionXP() -- the players XP, updates as XP is gained
	XtoLevel.levelXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) -- total level XP
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.currentPlayerXP --How much XP remaining in the level
end

function XtoLevel.SetLevelValues()
	XtoLevel.currentPlayerXP = GetUnitXP('player') -- the players XP, updates as XP is gained
	XtoLevel.levelXP = GetNumExperiencePointsInLevel(GetUnitLevel('player')) -- total level XP
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.currentPlayerXP --How much XP remaining in the level
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
	--d("XPAMin: ".. XtoLevel.XPAMin)
	if (XtoLevel.avgXPGained == nil or XtoLevel.avgXPGained == '') then
		XtoLevel.avgXPGained = 1
	end
	--d("Average XP Gained: "..XtoLevel.avgXPGained)
	
	if(XtoLevel.XPAMin == 0) then
		XtoLevel.avgXPGained = .9 * XtoLevel.avgXPGained
	else
		XtoLevel.avgXPGained = (.3 * XtoLevel.XPAMin) + (.5 * XtoLevel.avgXPGained)
	end

	local avgOverallXPAMin = zo_round(XtoLevel.remainingXP/XtoLevel.avgXPGained)
	if(avgOverallXPAMin > 120) then
		XtoLevelUITimeNum:SetText("> 2 hrs")
	else
		XtoLevelUITimeNum:SetText(avgOverallXPAMin .. " mins")
	end
	
	XtoLevel.XPAMin = 0
end

function XtoLevel.SetText()
	local battle = zo_round(XtoLevel.remainingXP/XtoLevel.avgBattlegroundXP)
	local delv = math.ceil(XtoLevel.remainingXP/XtoLevel.avgDelveXP)
	local dol = math.ceil(XtoLevel.remainingXP/XtoLevel.avgDolmenXP)
	local dung = math.ceil(XtoLevel.remainingXP/XtoLevel.avgDungeonXP)
	local mon = math.ceil(XtoLevel.remainingXP/XtoLevel.avgMonsterXP)
	local ques = math.ceil(XtoLevel.remainingXP/XtoLevel.avgQuestXP)
	
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
	XtoLevel.savedVariables.avgBattlegroundXP = XtoLevel.avgBattlegroundXP
	XtoLevel.savedVariables.avgDelveXP = XtoLevel.avgDelveXP
	XtoLevel.savedVariables.avgDolmenXP = XtoLevel.avgDolmenXP
	XtoLevel.savedVariables.avgDungeonXP = XtoLevel.avgDungeonXP
	XtoLevel.savedVariables.avgMonsterXP = XtoLevel.avgMonsterXP
	XtoLevel.savedVariables.avgQuestXP = XtoLevel.avgQuestXP
	XtoLevel.savedVariables.avgXPGained = XtoLevel.avgXPGained
	XtoLevel.savedVariables.hidden = XtoLevelUI:IsHidden() -- should check if it's hidden and save
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
	XtoLevel.avgBattlegroundXP = 0
	XtoLevel.avgDelveXP = 0
	XtoLevel.avgDolmenXP = 0
	XtoLevel.avgDungeonXP = 0
	XtoLevel.avgMonsterXP = 0
	XtoLevel.avgQuestXP = 0
	XtoLevel.avgXPGained = 1
	XtoLevel.SetText()
end

------------------------------------------------------------------------------------------------
--  Slash --
------------------------------------------------------------------------------------------------
 
SLASH_COMMANDS["/xtolevel"] = function (options)

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
end

------------------------------------------------------------------------------------------------
--  Events --
------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED, XtoLevel.Initialize)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_EXPERIENCE_GAIN, XtoLevel.XPUpdate)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_LEVEL_UPDATE, XtoLevel.LeveledUp)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_CHAMPION_POINT_GAINED, XtoLevel.ChampionLeveledUp)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_PLAYER_DEACTIVATED, XtoLevel.Save)
EVENT_MANAGER:RegisterForUpdate(XtoLevel.name, 60000, XtoLevel.AverageTime)