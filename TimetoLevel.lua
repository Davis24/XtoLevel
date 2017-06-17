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
TimetoLevel.avgXP = 1

--Initalize Function
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
			--TimetoLevelUIMonstersNum:SetText(zo_round(TimetoLevel.remainingXP/TimetoLevel.avgMonsterXP))
	   elseif(reason == 1) then
			d("Quest complete")
			TimetoLevel.avgQuestXP = (.5 * XPgain) + (.5 * TimetoLevel.avgQuestXP)
			--TimetoLevelUIQuestNum:SetText(zo_round(TimetoLevel.remainingXP/TimetoLevel.avgQuestXP))
	   elseif(reason == 3) then
			d("Discovered complete")
			-- Discover XP is identical, so it doesn't need a formula
			TimetoLevel.avgDiscoverXP = XPgain
			--TimetoLevelUIDiscoverNum:SetText(zo_round(TimetoLevel.remainingXP/XPgain))
	   else
			d("Other XP event")
	   end
		TimetoLevel.UpdateOthers()
end

function TimetoLevel.AverageTime()
	local XPAMin = GetUnitXP('player') - TimetoLevel.initialXP
	TimetoLevel.avgXP = (.5 * XPAMin) + (.5 * TimetoLevel.avgXP)
	TimetoLevelUITimeNum:SetText(zo_round(TimetoLevel.remainingXP/TimetoLevel.avgXP))
	TimetoLevel.initialXP = GetUnitXP('player')
	
end

function TimetoLevel.UpdateOthers()
	TimetoLevelUIMonstersNum:SetText(zo_round(TimetoLevel.remainingXP/TimetoLevel.avgMonsterXP))
	TimetoLevelUIQuestNum:SetText(zo_round(TimetoLevel.remainingXP/TimetoLevel.avgQuestXP))
	TimetoLevelUIDiscoverNum:SetText(zo_round(TimetoLevel.remainingXP/TimetoLevel.avgDiscoverXP))
end
--[[
function Average(theArray)
	local totalXP = 0
	local arraysize = #theArray
	for i=1, arraysize do
		totalXP = zo_round(totalXP + (theArray[i] * (.85)^(arraysize-i)))
	end
	d("Total XP :".. totalXP .. ".")
	if(totalXP == 0) then
		return 1
	else
		return (totalXP/arraysize)
	end
end--]]



EVENT_MANAGER:RegisterForEvent(TimetoLevel.name, EVENT_ADD_ON_LOADED, TimetoLevel.Initalize)
EVENT_MANAGER:RegisterForEvent(TimetoLevel.name, EVENT_EXPERIENCE_UPDATE, TimetoLevel.Update)
EVENT_MANAGER:RegisterForUpdate(TimetoLevel.name, 60000, TimetoLevel.AverageTime)