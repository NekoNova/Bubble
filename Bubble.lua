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
local karLaughKeyWords = { "laugh", "laughing", "lol", "heh", "hehe" }
 
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
-- Gets called when the XML document finishes loading.
-- Although we do not have any form to load, we're keeping the code, as we might want
-- to be able to configure something in the future.
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
  -- Information:
  --
  -- tMessage contains the following properties:
  --
  --  bAutoResponse     : Boolean indicating whether this message is an automated response.
  --  bGM               : Boolean indicating whether this message comes from a GM
  --  bSelf             : Boolean indicating if this is a message the player wrote
  --  strSender         : The name of the sender
  --  strRealmName      : The name of the Realm
  --  nPresenceState    : 0 on successful message
  --  arMessageSegments : The segments of the message.
  --  unitSource        : the unit sending the message.
  --  bShowChatBubble   : Boolean indicating whether to show the bubble.
  --  bCrossFaction     : Boolean indicating whether this is cross faction.
  --  nReportId         : The ID for reporting the message.
  --
  -- arMessageSegments contains the following structure:
  --
  --  strText     : The message
  --  bRolePlay   : Boolean if this is a RP message
  --  bAlien      : Boolean if this is from the other faction
  --  bProfanity  : Boolean for swearing
  --
	if tMessage.unitSource == nil then return end
	
	local strMessage = ""
	local channel = channelCurrent:GetType()
	
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
		
	-- Check all required Emotes, and fire them before displaying the text bubble
	if(tMessage.unitSource == GameLib.GetPlayerUnit()) then
    self:HelperLaughingEmote(strMessage)
	end
	
	-- Display the text-bubble using correct formatting.
	self:DisplayBubble(tMessage.unitSource, strMessage)
end

-- Checks whether the provided text contains the required keys that would
-- trigger our laughing Emote, and actually invoke the Emote based on that.
-- We only trigger the emote on the first match
function Bubble:HelperLaughingEmote(strMessage)
  for i = 1, #karLaughKeyWords do
    local strPattern = "*"..karLaughKeyWords[i].."*"
    
    if(strMessage.match(pattern)) then
      ChatSystemLib.Command("/laugh")
      break
    end
  end
end

-- Displays the chat bubble on the provided unitTarget, and injects the
-- provided strMessage inside the text bubble.
-- TODO: Perform proper formatting
--
function Bubble:DisplayBubble(unitTarget, strMessage)
  unitTarget:AddTextBubble(strMessage)
end

-----------------------------------------------------------------------------------------------
-- Bubble Instance
-----------------------------------------------------------------------------------------------
local BubbleInst = Bubble:new()
BubbleInst:Init()
