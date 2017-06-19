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



XtoLevel.avgMonsterXP = 0

--XtoLevel.avgDiscoverXP = 0 remove
XtoLevel.avgQuestXP = 0
XtoLevel.avgDolmenXP = 0
XtoLevel.avgXP = 1

------------------------------------------------------------------------------------------------
--  Functions --
------------------------------------------------------------------------------------------------
function XtoLevel.Initalize(eventCode, addOnName)
	--XtoLevelCounter:SetText(string.format(XtoLevel.name)
	if ( addOnName ~= XtoLevel.name) then
		return
	end

	EVENT_MANAGER:UnregisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED)
end
function XtoLevel.Update(eventCode, unitTag, currentExp, maxExp, reason)
	   if ( unitTag ~= 'player' ) then return end
       local XPgain = currentExp - XtoLevel.XP
       d("You gained " .. XPgain .. " experience.")
       XtoLevel.XP = currentExp
	   XtoLevel.remainingXP = XtoLevel.levelXP - XtoLevel.XP
	   
	   if(reason == 0) then
			--d("Monster kill and counter".. monsterCounter)		
			XtoLevel.avgMonsterXP = (.1 * XPgain) + (.9 * XtoLevel.avgMonsterXP)
			
	   elseif(reason == 1) then
			d("Quest complete")
			XtoLevel.avgQuestXP = (.5 * XPgain) + (.5 * XtoLevel.avgQuestXP)		
	   elseif(reason == 7) then
			d("Dolmen Completed")
			XtoLevel.avgDolmenXP = (.5 * XPgain) + (.5 * XtoLevel.avgDolmenXP)
	   elseif(reason == 3) then
			d("Discovered complete")
			-- Discover XP is identical, so it doesn't need a formula
			XtoLevel.avgDiscoverXP = XPgain
	   else
			d("Other XP event:" .. reason)
	   end
	   XtoLevel.SetText()
end

function XtoLevel.AverageTime()
	local XPAMin = GetUnitXP('player') - XtoLevel.initialXP
	XtoLevel.avgXP = (.5 * XPAMin) + (.5 * XtoLevel.avgXP)
	local avgXPAMin = zo_round(XtoLevel.remainingXP/XtoLevel.avgXP)
	if(avgXPAMin > 120) then
		XtoLevelUITimeNum:SetText("> 2 hrs")
	else
		XtoLevelUITimeNum:SetText(avgXPAMin)
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
	   local m = zo_round(XtoLevel.remainingXP/XtoLevel.avgMonsterXP)
	   local q = zo_round(XtoLevel.remainingXP/XtoLevel.avgQuestXP)
	   local d = zo_round(XtoLevel.remainingXP/XtoLevel.avgDiscoverXP)
	   local dol = zo_round(XtoLevel.remainingXP/XtoLevel.avgDolmenXP)
	   if(m == math.huge) then
			XtoLevelUIMonstersNum:SetText("?")
	   else
			XtoLevelUIMonstersNum:SetText(m)
	   end
	   if (q == math.huge) then
			XtoLevelUIQuestNum:SetText("?")
	   else
			XtoLevelUIQuestNum:SetText(q)
	   end
	   if(d == math.huge) then
			XtoLevelUIDiscoverNum:SetText("?")
	   else
			XtoLevelUIDiscoverNum:SetText(d)
	   end
	   if(dol == math.huge) then
			XtoLevelUIDolmenNum:SetText("?")
	   else
			XtoLevelUIDolmenNum:SetText(dol)
	   end
end

------------------------------------------------------------------------------------------------
--  Events --
------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_ADD_ON_LOADED, XtoLevel.Initalize)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_EXPERIENCE_UPDATE, XtoLevel.Update)
EVENT_MANAGER:RegisterForEvent(XtoLevel.name, EVENT_LEVEL_UPDATE, XtoLevel.LeveledUp)
EVENT_MANAGER:RegisterForUpdate(XtoLevel.name, 60000, XtoLevel.AverageTime)
