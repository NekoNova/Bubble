-----------------------------------------------------------------------------------------------
-- Client Lua Script for Bubble
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
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

    return o
end

function Bubble:Init()
	local bHasConfigureFunction = false
	local strConfigureButtonText = ""
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- Bubble OnLoad
-----------------------------------------------------------------------------------------------
function Bubble:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("Bubble.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
end

-----------------------------------------------------------------------------------------------
-- Bubble OnDocLoaded
-----------------------------------------------------------------------------------------------
function Bubble:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "BubbleForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		Apollo.RegisterEventHandler("ChatMessage", "OnChatMessage", self)
	end
end

-----------------------------------------------------------------------------------------------
-- Bubble Functions
-----------------------------------------------------------------------------------------------
function Bubble:OnChatMessage(channelCurrent, tMessage)
	local unitSender = tMessage.unitSource
	
	if unitSender == nil then return end
	
	local strMessage = ""
	local channel = channelCurrent:GetType()
	
	-- Iterate of the segment array.
	-- Contains the following values:
	-- 	strText : the message
	-- 	bRolePlay: boolean if this is a RP message
	--	bAlien: Boolean if this is from the other faction
	-- 	bProfanity: Boolean for swearing
	for idx, tSegment in ipairs(tMessage.arMessageSegments) do
		strMessage = strMessage ..tSegment.strText
	end
	
	-- Check for emotes, we're going to surrounded them by *
	if channel == ChatSystemLib.ChatChannel_AnimatedEmote or channel == ChatSystemLib.ChatChannel_Emote then
		strMessage = "*"..strMessage.."*"
	end
	
	-- If we're dealing with a Yell, then we'll add some exclamation marks
	if channel == ChatSystemLib.ChatChannel_Yell then
		strMessage = strMessage.."!!"
	end
		
	
	unitSender:AddTextBubble(strMessage)
end

-----------------------------------------------------------------------------------------------
-- Bubble Instance
-----------------------------------------------------------------------------------------------
local BubbleInst = Bubble:new()
BubbleInst:Init()
