XtoLevel = {}
------------------------------------------------------------------------------------------------
--  Initialize Variables --
------------------------------------------------------------------------------------------------
XtoLevel.name = "XtoLevel"
XtoLevel.version = 1
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
	
	--set initial variables from saved 
	
	EVENT_MANAGER:UnregisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED)
end

function XtoLevel.Update(eventCode, unitTag, currentExp, maxExp, reason)
	if ( unitTag ~= 'player' ) then return end
    local XPgain = currentExp - XtoLevel.XP
    d("You gained " .. XPgain .. " experience.")
    XtoLevel.XP = currentExp
	XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.XP
	   
	if(reason == 0) then -- Kill (i.e monster)		
		XtoLevel.avgMonsterXP = (.1 * XPgain) + (.9 * XtoLevel.avgMonsterXP)
	elseif(reason == 1) then -- Quest Completed
		XtoLevel.avgQuestXP = (.5 * XPgain) + (.5 * XtoLevel.avgQuestXP)
	elseif(reason == 2) then -- Complete POI (which should be delves but I believe it also triggers on other things)
		XtoLevel.avgDelveXP = (.5 * XPgain) + (.5 XtoLevel.avgDelveXP)
	elseif(reason == 3) then -- Dungeon XP  !!!!!!!! What is the ID for this
		XtoLevel.avgDungeonXP = (.5 * XPgain) + (.5 * XtoLevel.avgDungeonXP)
	elseif(reason == 4) then -- Battleground
		XtoLevel.avgBattlegroundXP = (.5 XPgain) + (.5 * XtoLevel.avgBattlegroundXP)
	elseif(reason == 7) then -- Dolmens (big and little ones)
		d("Dolmen Completed")
		XtoLevel.avgDolmenXP = (.5 * XPgain) + (.5 * XtoLevel.avgDolmenXP)
	else
		d("Other XP event:" .. reason) -- Comment out before deployment
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
	d("Player leveled up.")
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

function XtoLevel.Help()
	--reset the XP
	--Hide
	--Show
end

------------------------------------------------------------------------------------------------
--  Events --
------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED, XtoLevel.Initalize)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_EXPERIENCE_UPDATE, XtoLevel.Update)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_LEVEL_UPDATE, XtoLevel.LeveledUp)
EVENT_MANAGER:RegisterForUpdate(XtoLevel.name, 60000, XtoLevel.AverageTime)

------------------------------------------------------------------------------------------------
--  Slash --
------------------------------------------------------------------------------------------------
SLASH_COMMANDS["/XtoLevel"] = XtoLevel.Help()