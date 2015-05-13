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
	o.tSettings = {
		nTimeout = 5,
		arrKeywords = { "laugh", "laughing", "lol", "heh", "hehe" }
	}
	o.nSayCounter = 0
	o.nLaughCounter = 0
	
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
		Apollo.RegisterSlashCommand("bubble", "OnBubbleSlashCommand", self)
		Apollo.RegisterEventHandler("ChatMessage", "OnChatMessage", self)
	end
end

-----------------------------------------------------------------------------------------------
-- Bubble Functions
-----------------------------------------------------------------------------------------------

-- This function is called when the /bubble command is executed.
-- When this happens, we show the config window for the Addon.
function Bubble:OnBubbleSlashCommand(strCommand, strArgs)
	-- Load all settings
	self.wndMain:FindChild("input_s_Timeout"):SetText(self.tSettings.nTimeout)
	self.wndMain:FindChild("input_s_Keywords"):SetText(table.concat(self.tSettings.arrKeywords, ","))
	self.wndMain:Show(true)
end

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

	-- Break out of emotes, to prevent the channel from being spammed.
	if channel == ChatSystemLib.ChatChannel_AnimatedEmote or channel == ChatSystemLib.ChatChannel_Emote then
		return
	end
	
	-- Construct the entire ChatMessage together.
	for idx, tSegment in ipairs(tMessage.arMessageSegments) do
    	strMessage = strMessage ..tSegment.strText
	end
	
	-- If we're dealing with a Yell, then we'll add some exclamation marks
	if channel == ChatSystemLib.ChatChannel_Yell then
    	strMessage = strMessage.."!!"
	end
		
	-- Check all required Emotes, and fire them before displaying the text bubble
	if(tMessage.unitSource == GameLib.GetPlayerUnit()) then
    	self:HelperLaughingEmote(strMessage)
	    self:HelperSayEmote(channelCurrent)
	end
	
	-- Display the text-bubble using correct formatting.
	self:DisplayBubble(tMessage.unitSource, strMessage)
end

-- Checks whether the provided text contains the required keys that would
-- trigger our laughing Emote, and actually invoke the Emote based on that.
-- We only trigger the emote on the first match
function Bubble:HelperLaughingEmote(strMessage)
	for i = 1, #karLaughKeyWords do
    	local strPattern = ".*"..karLaughKeyWords[i]..".*"
    
	    if(strMessage:match(strPattern)) then
			if (self.nLaughCounter >= self.tSettings.nTimeout) then
				self.nLaughCounter = 1
				ChatSystemLib.Command("/laugh")
				return
			else
				self.nLaughCounter = self.nLaughCounter + 1
			end
	    end
	end
end

-- Checks whether the received channel is currently say, and fires the
-- /talk command so the character performs the chat emote when saying something.
function Bubble:HelperSayEmote(channel)
	if channel:GetType() == ChatSystemLib.ChatChannel_Say then
		if(self.nSayCounter >= self.tSettings.nTimeout) then
			self.nSayCounter = 1
			ChatSystemLib.Command("/talk")
		else
			self.nSayCounter = self.nSayCounter + 1
		end
	end
end

-- Displays the chat bubble on the provided unitTarget, and injects the
-- provided strMessage inside the text bubble.
-- TODO: Perform proper formatting
function Bubble:DisplayBubble(unitTarget, strMessage)
	  unitTarget:AddTextBubble(strMessage)
end

-- Returns the chatChannel by the given Name.
-- Returns nil when no match is found.
function Bubble:GetChannelByName(strName)
	for i, this_chan in ipairs(ChatSystemLib.GetChannels()) do
		if this_chan:GetName() == strName then return this_chan end
	end
	
	return nil
end

function Bubble:OnOK( wndHandler, wndControl, eMouseButton )
	local nTimeout = self.wndMain:FindChild("input_s_Timeout"):GetText()
	local arrKeywords = self.wndMain:FindChild("input_s_Keywords"):GetText()
	
	self.tSettings.arrKeywords = {}
	
	-- Iterate over the string in the keyword box, split it by ,
	-- and store each keyword string inside the settings array.
	for i in string.gmatch(arrKeywords, ",") do
		table.insert(self.tSettings.arrKeywords, i)
	end
	
	-- Store the Data
	self.tSettings.nTimeout = tonumber(nTimeout) or 5
	
	Print("Bubble:New Settings Saved!")
end

function Bubble:OnCancel( wndHandler, wndControl, eMouseButton )
	self.wndMain:Show(false)
end

-----------------------------------------------------------------------------------------------
-- Bubble Instance
-----------------------------------------------------------------------------------------------
local BubbleInst = Bubble:new()
BubbleInst:Init()
