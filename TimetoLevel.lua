TimetoLevel = {}
------------------------------------------------------------------------------------------------
--  Initialize Variables --
------------------------------------------------------------------------------------------------
TimetoLevel.name = "TimetoLevel"
TimetoLevel.version = 1
TimetoLevel.XP = GetUnitXP('player')
TimetoLevel.levelXP = GetNumExperiencePointsInLevel(GetUnitLevel('player')) 
TimetoLevel.remainingXP = TimetoLevel.levelXP - TimetoLevel.XP
TimetoLevel.initialXP = GetUnitXP('player')



TimetoLevel.avgMonsterXP = 0
TimetoLevel.avgDiscoverXP = 0
TimetoLevel.avgQuestXP = 0
TimetoLevel.avgDolmenXP = 0
TimetoLevel.avgXP = 1

------------------------------------------------------------------------------------------------
--  Functions --
------------------------------------------------------------------------------------------------


function TimetoLevel.Initalize(eventCode, addOnName)
	--TimetoLevelCounter:SetText(string.format(TimetoLevel.name)
	if ( addOnName ~= TimetoLevel.name) then
		return
	end

	EVENT_MANAGER:UnregisterForEvent(TimetoLevel.name, EVENT_ADD_ON_LOADED)
end
function TimetoLevel.Update(eventCode, unitTag, currentExp, maxExp, reason)
	   if ( unitTag ~= 'player' ) then return end
       local XPgain = currentExp - TimetoLevel.XP
       d("You gained " .. XPgain .. " experience.")
       TimetoLevel.XP = currentExp
	   TimetoLevel.remainingXP = TimetoLevel.levelXP - TimetoLevel.XP
	   
	   if(reason == 0) then
			--d("Monster kill and counter".. monsterCounter)		
			TimetoLevel.avgMonsterXP = (.1 * XPgain) + (.9 * TimetoLevel.avgMonsterXP)
			
	   elseif(reason == 1) then
			d("Quest complete")
			TimetoLevel.avgQuestXP = (.5 * XPgain) + (.5 * TimetoLevel.avgQuestXP)		
	   elseif(reason == 7) then
			d("Dolmen Completed")
			TimetoLevel.avgDolmenXP = (.5 * XPgain) + (.5 * TimetoLevel.avgDolmenXP)
	   elseif(reason == 3) then
			d("Discovered complete")
			-- Discover XP is identical, so it doesn't need a formula
			TimetoLevel.avgDiscoverXP = XPgain
	   else
			d("Other XP event:" .. reason)
	   end
	   TimetoLevel.SetText()
end

function TimetoLevel.AverageTime()
	local XPAMin = GetUnitXP('player') - TimetoLevel.initialXP
	TimetoLevel.avgXP = (.5 * XPAMin) + (.5 * TimetoLevel.avgXP)
	local avgXPAMin = zo_round(TimetoLevel.remainingXP/TimetoLevel.avgXP)
	if(avgXPAMin > 120) then
		TimetoLevelUITimeNum:SetText("> 2 hrs")
	else
		TimetoLevelUITimeNum:SetText(avgXPAMin)
	end
	
	TimetoLevel.initialXP = GetUnitXP('player')
	
end

function TimetoLevel.LeveledUp(eventCode, unitTag, level)
	d("Player leveled up.")
	if ( unitTag ~= 'player' ) then return end
	TimetoLevel.initialXP = GetUnitXP('player')
	TimetoLevel.levelXP = GetNumExperiencePointsInLevel(level) 
	TimetoLevel.remainingXP = TimetoLevel.levelXP - TimetoLevel.XP
	TimetoLevel.SetText()
	TimetoLevel.AverageTime()
end

function TimetoLevel.SetText()
	   local m = zo_round(TimetoLevel.remainingXP/TimetoLevel.avgMonsterXP)
	   local q = zo_round(TimetoLevel.remainingXP/TimetoLevel.avgQuestXP)
	   local d = zo_round(TimetoLevel.remainingXP/TimetoLevel.avgDiscoverXP)
	   local dol = zo_round(TimetoLevel.remainingXP/TimetoLevel.avgDolmenXP)
	   if(m == math.huge) then
			TimetoLevelUIMonstersNum:SetText("?")
	   else
			TimetoLevelUIMonstersNum:SetText(m)
	   end
	   if (q == math.huge) then
			TimetoLevelUIQuestNum:SetText("?")
	   else
			TimetoLevelUIQuestNum:SetText(q)
	   end
	   if(d == math.huge) then
			TimetoLevelUIDiscoverNum:SetText("?")
	   else
			TimetoLevelUIDiscoverNum:SetText(d)
	   end
	   if(dol == math.huge) then
			TimetoLevelUIDolmenNum:SetText("?")
	   else
			TimetoLevelUIDolmenNum:SetText(dol)
	   end
end

EVENT_MANAGER:RegisterForEvent(TimetoLevel.name, EVENT_ADD_ON_LOADED, TimetoLevel.Initalize)
EVENT_MANAGER:RegisterForEvent(TimetoLevel.name, EVENT_EXPERIENCE_UPDATE, TimetoLevel.Update)
EVENT_MANAGER:RegisterForEvent(TimetoLevel.name, EVENT_LEVEL_UPDATE, TimetoLevel.LeveledUp)
EVENT_MANAGER:RegisterForUpdate(TimetoLevel.name, 60000, TimetoLevel.AverageTime)
