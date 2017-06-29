-- Name: XtoLevel
-- Verson: 1.0.0
-- Author: Devisaur
-- Description: Displays information on character leveling.
-- ToDo:
--  See Github README (https://github.com/Davis24/XtoLevel)


------------------------------------------------------------------------------------------------
--  Initialize Variables --
------------------------------------------------------------------------------------------------
XtoLevel = {}
XtoLevel.Default = {
	Position = {
		OffSetX = -25,
		OffSetY = 25
	},
	XP = {
		avgBattlegroundXP = 0,
		avgDelveXP = 0,
		avgDolmenXP = 0,
		avgDungeonXP = 0,
		avgMonsterXP = 0,
		avgQuestXP = 0,
		avgOverallXP = 1
	}
}

XtoLevel.name = "XtoLevel"
XtoLevel.version = 1.00
XtoLevel.XP = GetUnitXP('player')
XtoLevel.levelXP = GetNumExperiencePointsInLevel(GetUnitLevel('player')) 
XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.XP
XtoLevel.initialXP = GetUnitXP('player')

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
	
	XtoLevel.avgBattlegroundXP = XtoLevel.savedVariables.avgBattlegroundXP
	XtoLevel.avgDelveXP = XtoLevel.savedVariables.avgDelveXP 
	XtoLevel.avgDolmenXP = XtoLevel.savedVariables.avgDolmenXP
	XtoLevel.avgDungeonXP = XtoLevel.savedVariables.avgDungeonXP
	XtoLevel.avgMonsterXP = XtoLevel.savedVariables.avgMonsterXP
	XtoLevel.avgQuestXP = XtoLevel.savedVariables.avgQuestXP
	XtoLevel.avgOverallXP = XtoLevel.savedVariables.avgOverallXP
	XtoLevel.SetText()
	
	EVENT_MANAGER:UnregisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED)
end

function XtoLevel.Update(eventCode, unitTag, currentExp, maxExp, reason)
	if ( unitTag ~= 'player' ) then return end
    local XPgain = currentExp - XtoLevel.XP

    XtoLevel.XP = currentExp
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.XP
	   
	if(reason == 0) then -- Kill (i.e monster)		
		XtoLevel.avgMonsterXP = (.1 * XPgain) + (.9 * XtoLevel.avgMonsterXP)
	elseif(reason == 1) then -- Quest Completed
		XtoLevel.avgQuestXP = (.5 * XPgain) + (.5 * XtoLevel.avgQuestXP)
	elseif(reason == 2) then -- Complete POI (which should be delves but I believe it also triggers on other things)
		XtoLevel.avgDelveXP = (.5 * XPgain) + (.5 * XtoLevel.avgDelveXP)
	elseif(reason == 37) then -- Dungeon XP  !!!!!!!! What is the ID for this
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

function XtoLevel.AverageTime()
	local XPAMin = GetUnitXP('player') - XtoLevel.initialXP
	XtoLevel.avgOverallXP = (.5 * XPAMin) + (.5 * XtoLevel.avgOverallXP)
	local avgOverallXPAMin = zo_round(XtoLevel.remainingXP/XtoLevel.avgOverallXP)
	if(avgOverallXPAMin > 120) then
		XtoLevelUITimeNum:SetText("> 2 hrs")
	else
		XtoLevelUITimeNum:SetText(avgOverallXPAMin)
	end
	
	XtoLevel.initialXP = GetUnitXP('player')	
end

function XtoLevel.LeveledUp(eventCode, unitTag, level)
	if ( unitTag ~= 'player' ) then return end
	
	XtoLevel.initialXP = GetUnitXP('player')
	XtoLevel.levelXP = GetNumExperiencePointsInLevel(level) 
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.XP
	XtoLevel.SetText()
	XtoLevel.AverageTime()
end

function XtoLevel.SetText()
	local battle = zo_round(XtoLevel.remainingXP/XtoLevel.avgBattlegroundXP)
	local delv = zo_round(XtoLevel.remainingXP/XtoLevel.avgDelveXP)
	local dol = zo_round(XtoLevel.remainingXP/XtoLevel.avgDolmenXP)
	local dung = zo_round(XtoLevel.remainingXP/XtoLevel.avgDungeonXP)
	local mon = zo_round(XtoLevel.remainingXP/XtoLevel.avgMonsterXP)
	local ques = zo_round(XtoLevel.remainingXP/XtoLevel.avgQuestXP)
	
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

function XtoLevel.Save()
	XtoLevel.savedVariables.avgBattlegroundXP = XtoLevel.avgBattlegroundXP
	XtoLevel.savedVariables.avgDelveXP = XtoLevel.avgDelveXP
	XtoLevel.savedVariables.avgDolmenXP = XtoLevel.avgDolmenXP
	XtoLevel.savedVariables.avgDungeonXP = XtoLevel.avgDungeonXP
	XtoLevel.savedVariables.avgMonsterXP = XtoLevel.avgMonsterXP
	XtoLevel.savedVariables.avgQuestXP = XtoLevel.avgQuestXP
	XtoLevel.savedVariables.avgOverallXP = XtoLevel.avgOverallXP
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

end
------------------------------------------------------------------------------------------------
--  Slash --
------------------------------------------------------------------------------------------------
 
SLASH_COMMANDS["/xtolevel"] = function (extra)
    -- !Code from ESOUI Wiki!
	local options = {}
    local searchResult = { string.match(option,"^(%S*)%s*(.-)$") }
    for i,v in pairs(searchResult) do
        if (v ~= nil and v ~= "") then
            options[i] = string.lower(v)
        end
    end
	
	if #options == 0 or options[1] == "help" then
       d("XtoLevel " .. XtoLevel.version)
	   d("Author: Devisaur")
	   d("/xtolevel resetxp -- resets XP values")
	   d("/xtolevel resetloc -- resets addon location")
	   d("/xtolevel show -- shows the addon")
	   d("/xtolevel hide -- hides the addon")
	   d("/xtolevel text -- displays categories as text")
	   d("/xtolevel icons -- displays categories as icons")
    elseif options[1] == "resetxp" then
		--Reset
	elseif options[1] == "resetloc" then
		-- reset location
	elseif options[1] == "show" then
		XtoLevelUI:SetHidden(false)
	elseif options[1] == "hide" then
		XtoLevelUI:SetHidden(true)
	elseif options[1] == "icons" then
		local legend = { text = false, icon = true}
		XtoLevel.SetDisplayLegend(legend)
	elseif options[1] == "text" then
		local legend = { text = true, icon = false}
		XtoLevel.SetDisplayLegend(legend)
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


	