-----------------------------------------------------------------------------------------------
-- Client Lua Script for Bubble
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "Unit"
 
-----------------------------------------------------------------------------------------------
-- Bubble Module Definition
-----------------------------------------------------------------------------------------------
local Bubble = {} 
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
-- e.g. local kiExampleVariableMax = 999
 
-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------
function Bubble:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- initialize variables here
	self.tUnits = {}

    return o
end

function Bubble:Init()	
    Apollo.RegisterAddon(self)
	Apollo.RegisterEventHandler("ChatMessage", "OnChatMessage", self)
	Apollo.RegisterEventHandler("UnitCreated", "OnUnitCreated", self)
	Apollo.RegisterEventHandler("UnitDestroyed", "OnUnitDestroyed", self)
end

-----------------------------------------------------------------------------------------------
-- Bubble Functions
-----------------------------------------------------------------------------------------------

-- Get's triggered whenever a Unit is created. When the unit is created, we store that
-- unit, along with it's ID in our units table to track it for proper name displays.
function Bubble:OnUnitCreated(unitSpawned)
	table.insert(self.tUnits, { id = unitSpawned:GetId(), unit = unitSpawned })
end

-- Get's triggered whenever a Unit is despawned.
-- We remove the unit from our table.
function Bubble:OnUnitDestroyed(unitDestroyed)
	for idx,tUnit in ipairs(self.tUnits) do
		if(tUnit.id == unitDestroyed:GetId()) then
			self.tUnits[unitSpawned:GetId()] = nil
		end
	end
end

-- Displays messages that are being said using /say in the bubbles above people's head.
-- If the unit cannot be found, then we do not anything.
function Bubble:OnChatMessage(channelCurrent, tMessage)
	local unitSender = tMessage.unitSource	
	local strMessage = ""
	
	for idx, tSegment in ipairs(tMessage.arMessageSegments) do
		strMessage = strMessage .. tSegment.strText
	end
	
	-- No unit provided, could be a channel message, let's see if the Unit is nearby
	if unitSender == nil then
		for idx,tUnit in ipairs(self.tUnits) do
			if(tUnit.unit:GetName() == tMessage.strSender) then
				tUnit.unit:AddTextBubble(strMessage)
			end
		end
	else
		unitSender:AddTextBubble(strMessage)
	end
end
-----------------------------------------------------------------------------------------------
-- Bubble Instance
-----------------------------------------------------------------------------------------------
local BubbleInst = Bubble:new()
BubbleInst:Init()
