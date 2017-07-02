-- Name: XtoLevel
-- Verson: 1.1.0
-- Author: Devisaur
-- Description: Displays information on character leveling.
-- ToDo:
--  See Github README (https://github.com/Davis24/XtoLevel)


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
XtoLevel.version = 1.10

XtoLevel.playerXP = 0
XtoLevel.initialXP = 0
XtoLevel.levelXP = 0
XtoLevel.remainingXP = 0

XtoLevel.avgBattlegroundXP = 0
XtoLevel.avgDelveXP = 0
XtoLevel.avgDolmenXP = 0
XtoLevel.avgDungeonXP = 0
XtoLevel.avgMonsterXP = 0
XtoLevel.avgQuestXP = 0
XtoLevel.avgOverallXP = 1

------------------------------------------------------------------------------------------------
--  Functions --
------------------------------------------------------------------------------------------------
function XtoLevel.Initalize(eventCode, addOnName)
	if ( addOnName ~= XtoLevel.name) then
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
	XtoLevel.avgOverallXP = XtoLevel.savedVariables.avgOverallXP
	
	
	if(GetPlayerChampionPointsEarned() > 0) then
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

function XtoLevel.Update(eventCode, unitTag, currentExp, maxExp, reason)
	if ( unitTag ~= 'player' ) then return end
    
	local XPgain = currentExp - XtoLevel.playerXP
    XtoLevel.playerXP = currentExp
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.playerXP
	   
	if(reason == 0) then -- Kill (i.e monster)		
		XtoLevel.avgMonsterXP = (.1 * XPgain) + (.9 * XtoLevel.avgMonsterXP)
	elseif(reason == 1) then -- Quest Completed
		XtoLevel.avgQuestXP = (.5 * XPgain) + (.5 * XtoLevel.avgQuestXP)
	elseif(reason == 2) then -- Complete POI (which should be delves but I believe it also triggers on other things)
		XtoLevel.avgDelveXP = (.5 * XPgain) + (.5 * XtoLevel.avgDelveXP)
	elseif(reason == 37) then -- Dungeon XP
		XtoLevel.avgDungeonXP = (.5 * XPgain) + (.5 * XtoLevel.avgDungeonXP)
	elseif(reason == 4) then -- Battleground
		XtoLevel.avgBattlegroundXP = (.5 * XPgain) + (.5 * XtoLevel.avgBattlegroundXP)
	elseif(reason == 7) then -- Dolmens (big and little ones)
		XtoLevel.avgDolmenXP = (.5 * XPgain) + (.5 * XtoLevel.avgDolmenXP)
	--else
		--d("Other XP event:" .. reason) -- Comment out before deployment
	end
	XtoLevel.SetText()
end

function XtoLevel.SetChampionValues()
	XtoLevel.playerXP = GetPlayerChampionXP() -- the players XP, updates as XP is gained
	XtoLevel.initialXP = GetPlayerChampionXP() -- the players XP at the start of the minute, used to calculate AverageTime
	XtoLevel.levelXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) -- total level XP
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.playerXP --How much XP remaining in the level
end

function XtoLevel.SetLevelValues()
	XtoLevel.playerXP = GetUnitXP('player') -- the players XP, updates as XP is gained
	XtoLevel.initialXP = GetUnitXP('player') -- the players XP at the start of the minute, used to calculate AverageTime
	XtoLevel.levelXP = GetNumExperiencePointsInLevel(GetUnitLevel('player')) -- total level XP
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.playerXP --How much XP remaining in the level
end

function XtoLevel.GetCurrentPlayerXP()
	if(GetPlayerChampionPointsEarned() > 0) then
		return GetPlayerChampionXP()
	else
		return GetUnitXP('player')
	end
end

function XtoLevel.AverageTime()
	local XPAMin = XtoLevel.GetCurrentPlayerXP()
	
	XtoLevel.avgOverallXP = (.5 * XPAMin) + (.5 * XtoLevel.avgOverallXP)
	local avgOverallXPAMin = zo_round(XtoLevel.remainingXP/XtoLevel.avgOverallXP)
	if(avgOverallXPAMin > 120) then
		XtoLevelUITimeNum:SetText("> 2 hrs")
	else
		XtoLevelUITimeNum:SetText(avgOverallXPAMin .. " mins")
	end
	
	XtoLevel.initialXP = XtoLevel.GetCurrentPlayerXP()
end

function XtoLevel.LeveledUp(eventCode, unitTag, level)
	if ( unitTag ~= 'player' ) then return end
	
	if(GetPlayerChampionPointsEarned() > 0) then
		XtoLevel.initialXP = GetPlayerChampionXP() 
		XtoLevel.levelXP = GetNumChampionXPInChampionPoint(GetPlayerChampionPointsEarned()) 
		XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.playerXP 
	else
		XtoLevel.initialXP = GetUnitXP('player')
		XtoLevel.levelXP = GetNumExperiencePointsInLevel(level) 
		XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.playerXP
	end
	XtoLevel.SetText()
	XtoLevel.AverageTime()
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
		d("Quest"..XtoLevel.avgQuestXP)
	d("RemainingXp"..XtoLevel.remainingXP)
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
	XtoLevel.savedVariables.avgOverallXP = XtoLevel.avgOverallXP
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


function XtoLevel.Reset()
	XtoLevel.avgBattlegroundXP = 0
	XtoLevel.avgDelveXP = 0
	XtoLevel.avgDolmenXP = 0
	XtoLevel.avgDungeonXP = 0
	XtoLevel.avgMonsterXP = 0
	XtoLevel.avgQuestXP = 0
	XtoLevel.avgOverallXP = 1
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
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED, XtoLevel.Initalize)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_EXPERIENCE_UPDATE, XtoLevel.Update)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_LEVEL_UPDATE, XtoLevel.LeveledUp)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_PLAYER_DEACTIVATED, XtoLevel.Save)
EVENT_MANAGER:RegisterForUpdate(XtoLevel.name, 60000, XtoLevel.AverageTime)


	