local PANEL = {}
local HIGHLIGHT = Color(255, 255, 255, 50)
local exampleSounds = {
	[1] = {
		"npc/metropolice/vo/affirmative.wav",
		"npc/combine_soldier/vo/overwatch.wav"
	},
	[2] = {
		"HLAComVoice/Grunt/orderresponse_positive_06.wav",
		"HLAComVoice/Grunt/calloutentity_overwatch_01.wav"
	}
}

function PANEL:Init()
	local parent = self

	self.label = self:AddLabel("Unit Setup")
	self.sublabel = self:SubLabel("Customise your unit")

	self.voiceType = self:Add("DComboBox")
	self.voiceType:SetFont("ixPluginCharTraitFont")
	self.voiceType:Dock(TOP)
	self.voiceType:DockMargin(0, 10, 0, 0)
	self.voiceType.OnSelect = function( self, index, value )
		local index = 1

		if(value == "HLA") then
			index = 2
		end

		surface.PlaySound(exampleSounds[index][math.random(1, 2)])
		
		parent:SetPayload("voicetype", value)
	end

	self.taglineDropBox = self:Add("DComboBox")
	self.taglineDropBox:SetFont("ixPluginCharTraitFont")
	self.taglineDropBox:Dock(TOP)
	self.taglineDropBox:DockMargin(0, 10, 0, 0)
	self.taglineDropBox.OnSelect = function( self, index, value )
		parent.selectedTagline = value;
		parent:SetPayload("tagline", value)
		parent:RebuildIDs()
	end

	self.idDropBox = self:Add("DComboBox")
	self.idDropBox:SetFont("ixPluginCharTraitFont")
	self.idDropBox:Dock(TOP)
	self.idDropBox:DockMargin(0, 10, 0, 0)
	self.idDropBox.OnSelect = function( self, index, value )
		parent:SetPayload("cpid", value)
	end

	self.sublabel = self:SubLabel("Describe your unit")
	self.sublabel:DockMargin(0,20,0,0)
	
	self.desc = self:AddTextEntry("cpdesc")
	self.desc:SetTall(128)
	self.desc:SetMultiline(true)

	netstream.Start("RequestTaglineCache")
	self:Register("Unit Setup")
end

function PANEL:AddTextEntry(payloadName)
	local entry = self:Add("DTextEntry")
	entry:Dock(TOP)
	entry:SetFont("ixPluginCharButtonFont")
	entry.Paint = self.PaintTextEntry
	entry:DockMargin(0, 4, 0, 16)
	entry.OnValueChange = function(_, value)
		self:SetPayload(payloadName, string.Trim(value))
	end
	entry.payloadName = payloadName
	entry.OnKeyCodeTyped = function(name, keyCode)
		if (keyCode == KEY_TAB) then
			entry:onTabPressed()
			return true
		end
	end
	entry:SetUpdateOnType(true)
	return entry
end

function PANEL:PaintTextEntry(w, h)
	ix.util.DrawBlur(self)
	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(0, 0, w, h)
	self:DrawTextEntryText(color_white, HIGHLIGHT, HIGHLIGHT)
end

function PANEL:Display()
	self.taglines = self.taglines or self:GetTaglines()

	self.voiceType:Clear()
	self.voiceType:SetValue( "Taglines" )

	self.taglineDropBox:Clear()
	self.taglineDropBox:SetValue( "Taglines" )

	self.idDropBox:Clear()
	self.idDropBox:SetValue( "IDs" )

	for k, v in pairs(cpSystem.config.voiceTypes) do
		self.voiceType:AddChoice(v)
	end

	for k, v in pairs(self.taglines) do 
		self.taglineDropBox:AddChoice(k)
	end

	self.desc:SetText(self:GetPayload("cpdesc", ""))
end

function PANEL:ShouldSkip()
	local faction = ix.faction.indices[self:GetPayload("faction")]

	if(faction.name != "Civil Protection") then
		return true
	end
end

function PANEL:RebuildIDs()
	self.idDropBox:Clear()
	
	for k, v in pairs(self.taglines[self.selectedTagline].id) do
		if(v == false) then
			self.idDropBox:AddChoice(k)
		end
	end
end

function PANEL:Validate()
	if(self:GetPayload("tagline") == nil) then
		return false, "You must select a tagline."
	end

	if(self:GetPayload("cpid") == nil) then
		return false, "You must select an ID."
	end

	local minLength = ix.config.Get("minDescriptionLength", 16)
	self:SetPayload("cpdesc", string.Trim((tostring(self:GetPayload("cpdesc")):gsub("\r\n", ""):gsub("\n", ""))))

	if (self:GetPayload("cpdesc"):len() < minLength) then
		return false, "descMinLen", minLength
	elseif (!self:GetPayload("cpdesc"):find("%s+") or !self:GetPayload("cpdesc"):find("%S")) then
		return false, "invalid", "description"
	end
end

-- This is pretty expensive, keep the use of this to a minimal amount.
function PANEL:GetTaglines()
	local data = {}

	for k, v in pairs(cpSystem.config.taglines) do
		data[v] = {}
		data[v].id = {}

		for i = 1, 9 do
			table.insert(data[v].id, false)
		end
	end

	for k, v in pairs(cpSystem.cache.taglines or {}) do
		if(v.tagline and v.id) then
			data[v.tagline].id[v.id] = true
		end	
	end

	return data
end

vgui.Register("ixCharacterCPSetup", PANEL, "ixCharacterCreateStep")
