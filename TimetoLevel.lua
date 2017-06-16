TimetoLevel = {}
------------------------------------------------------------------------------------------------
--  Initialize Variables --
------------------------------------------------------------------------------------------------
TimetoLevel.name = "TimetoLevel"
TimetoLevel.version = 1
TimetoLevel.XP = 0
TimetoLevel.levelXP = 0
TimetoLevel.remainingXP = 0
TimetoLevel.initialXP = 0
--TimetoLevel.monsters = 0
--TimetoLevel.avgMonsterXP = 0

--Initalize Function
function TimetoLevel.Initalize(eventCode, addOnName)
	--TimetoLevelCounter:SetText(string.format(TimetoLevel.name)
	if ( addOnName ~= "TimetoLevel") then
		return
	end

	TimetoLevel.XP = GetUnitXP('player')
	TimetoLevel.levelXP = GetNumExperiencePointsInLevel(GetUnitLevel('player')) 
	TimetoLevel.remainingXP = TimetoLevel.levelXP - TimetoLevel.XP
	TimetoLevel.initialXP = GetUnitXP('player')

	EVENT_MANAGER:UnregisterForEvent(TimetoLevel.name, EVENT_ADD_ON_LOADED)
end
function TimetoLevel.Update(eventCode, unitTag, currentExp, maxExp, reason)
	   if ( unitTag ~= 'player' ) then return end
       local XPgain = currentExp - TimetoLevel.XP
       d("You gained " .. XPgain .. " experience.")
       TimetoLevel.XP = currentExp
	   TimetoLevel.remainingXP = TimetoLevel.levelXP - TimetoLevel.XP
	   if(reason == 0) then
			d("Monster kill")
			TimetoLevelMonstersNum:SetText(zo_round(TimetoLevel.remainingXP/XPgain))
	   elseif(reason == 1) then
			d("Quest complete")
			TimetoLevelQuestNum:SetText(zo_round(TimetoLevel.remainingXP/XPgain))
	   elseif(reason == 3) then
			d("Discovered complete")
			TimetoLevelDiscoverNum:SetText(zo_round(TimetoLevel.remainingXP/XPgain))
	   else
			d("Other XP event")
	   end

end

function TimetoLevel.AverageTime()
	if (TimetoLevel.initialXP == GetUnitXP('player')) then
		TimetoLevelTimeNum:SetText("Unknown")
	else
		local XPAMin = GetUnitXP('player') - TimetoLevel.initialXP
		TimetoLevelTimeNum:SetText(zo_round(TimetoLevel.remainingXP / XPAMin))
		TimetoLevel.initialXP = GetUnitXP('player')
	end
	
	
end


EVENT_MANAGER:RegisterForEvent(TimetoLevel.name, EVENT_ADD_ON_LOADED, TimetoLevel.Initalize)
EVENT_MANAGER:RegisterForEvent(TimetoLevel.name, EVENT_EXPERIENCE_UPDATE, TimetoLevel.Update)
EVENT_MANAGER:RegisterForUpdate(TimetoLevel.name, 60000, TimetoLevel.AverageTime)