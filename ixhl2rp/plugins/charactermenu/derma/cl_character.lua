local PANEL = {}

local WHITE = Color(255, 255, 255, 150)
local SELECTED = Color(255, 255, 255, 230)

PANEL.WHITE = WHITE
PANEL.SELECTED = SELECTED
PANEL.HOVERED = Color(255, 255, 255, 50)
PANEL.ANIM_SPEED = 0.1
PANEL.FADE_SPEED = 0.5

SOUND_CHAR_HOVER = {"buttons/button15.wav", 35, 250}
SOUND_CHAR_CLICK = {"buttons/button14.wav", 35, 255}
SOUND_CHAR_WARNING = {"friends/friend_join.wav", 40, 255}

-- Called when the tabs for the character menu should be created.
function PANEL:createTabs()
	local load, create

	-- Only show the load tab if playable characters exist.
	if (ix.characters and #ix.characters > 0) then
		load = self:addTab("continue", self.createCharacterSelection)
	end

	-- Only show the create tab if the local player can create characters.
	if (hook.Run("CanPlayerCreateCharacter", LocalPlayer()) ~= false) then
		create = self:addTab("create", self.createCharacterCreation)
	end

	-- By default, select the continue tab, or the create tab.
	if (IsValid(load)) then
		load:setSelected()
	elseif (IsValid(create)) then
		create:setSelected()
	end

	-- If the player has a character (i.e. opened this menu from F1 menu), then
	-- don't add a disconnect button. Just add a close button.
	if (IsValid(LocalPlayer()) and LocalPlayer():GetCharacter()) then
		self:addTab("return", function()
			if (IsValid(self) and LocalPlayer():GetCharacter()) then
				self:fadeOut()
			end
		end, true)
		return
	end

	-- Otherwise, add a disconnect button.
	self:addTab("leave", function()
		vgui.Create("ixCharacterConfirm")
			:setTitle(L("disconnect"):upper().."?")
			:setMessage(L("You will disconnect from the server."):upper())
			:onConfirm(function() LocalPlayer():ConCommand("disconnect") end)
	end, true)
end

function PANEL:createTitle()
	self.title = self:Add("DLabel")
	self.title:Dock(TOP)
	self.title:DockMargin(48, 48, 0, 0)
	self.title:SetContentAlignment(1)
	self.title:SetTall(96)
	self.title:SetFont("ixPluginCharTitleFont")
	self.title:SetText("Terranova")
	self.title:SetTextColor(WHITE)

	self.desc = self:Add("DLabel")
	self.desc:Dock(TOP)
	self.desc:DockMargin(64, 0, 0, 0)
	self.desc:SetTall(32)
	self.desc:SetContentAlignment(7)
	self.desc:SetText("Half-Life 2 Roleplay")
	self.desc:SetFont("ixPluginCharDescFont")
	self.desc:SetTextColor(WHITE)
end

function PANEL:loadBackground()
	-- Map scene integration.
	local mapScene = ix.plugin.list.mapscene
	if (not mapScene or table.Count(mapScene.scenes) == 0) then
		self.blank = true
	end

	local url = ix.config.Get("backgroundURL")
	if (url and url:find("%S")) then
		self.background = self:Add("DHTML")
		self.background:SetSize(ScrW(), ScrH())
		if (url:find("http")) then
			self.background:OpenURL(url)
		else
			self.background:SetHTML(url)
		end
		self.background.OnDocumentReady = function(background)
			self.bgLoader:AlphaTo(0, 2, 1, function()
				self.bgLoader:Remove()
			end)
		end
		self.background:MoveToBack()
		self.background:SetZPos(-999)

		if (ix.config.get("charMenuBGInputDisabled")) then
			self.background:SetMouseInputEnabled(false)
			self.background:SetKeyboardInputEnabled(false)
		end

		self.bgLoader = self:Add("DPanel")
		self.bgLoader:SetSize(ScrW(), ScrH())
		self.bgLoader:SetZPos(-998)
		self.bgLoader.Paint = function(loader, w, h)
			surface.SetDrawColor(20, 20, 20)
			surface.DrawRect(0, 0, w, h)
		end
	end
end

local gradient = ix.util.GetMaterial("vgui/gradient-u")

function PANEL:paintBackground(w, h)
	if (IsValid(self.background)) then return end

	if (self.blank) then
		surface.SetDrawColor(30, 30, 30)
		surface.DrawRect(0, 0, w, h)
	end

	surface.SetMaterial(gradient)
	surface.SetDrawColor(0, 0, 0, 250)
	surface.DrawTexturedRect(0, 0, w, h * 1.5)
end

function PANEL:IsClosing()
	return false
end

function PANEL:addTab(name, callback, justClick)
	local button = self.tabs:Add("ixCharacterTabButton")
	button:setText(L(name):upper())

	if (justClick) then
		if (isfunction(callback)) then
			button.DoClick = function(button) callback(self) end
		end
		return
	end

	button.DoClick = function(button)
		button:setSelected(true)
	end
	if (isfunction(callback)) then
		button:onSelected(function()
			callback(self)
		end)
	end

	return button
end

function PANEL:createCharacterSelection()
	self.content:Clear()
	self.content:InvalidateLayout(true)
	self.content:Add("ixCharacterSelection")
end

function PANEL:createCharacterCreation()
	self.content:Clear()
	self.content:InvalidateLayout(true)
	self.content:Add("ixCharacterCreation")
end

function PANEL:fadeOut()
	self:AlphaTo(0, self.ANIM_SPEED, 0, function()
		self:Remove()
	end)
end

function PANEL:Init()
	if (IsValid(ix.gui.characterMenu)) then
		ix.gui.characterMenu:Remove()
	end

	ix.gui.characterMenu = self
	self.currentAlpha = 255
	self:Dock(FILL)
	self:MakePopup()
	self:SetAlpha(0)
	self:AlphaTo(255, self.ANIM_SPEED * 2)

	self:createTitle()

	self.tabs = self:Add("DPanel")
	self.tabs:Dock(TOP)
	self.tabs:DockMargin(64, 32, 64, 0)
	self.tabs:SetTall(48)
	self.tabs:SetDrawBackground(false)
	
	self.content = self:Add("DPanel")
	self.content:Dock(FILL)
	self.content:DockMargin(64, 0, 64, 64)
	self.content:SetDrawBackground(false)

	self.music = self:Add("ixCharBGMusic")
	self:loadBackground()
	self:showContent()
end

function PANEL:showContent()
	self.tabs:Clear()
	self.content:Clear()
	self:createTabs()
end

function PANEL:setFadeToBlack(fade)
	local d = deferred.new()
	if (fade) then
		if (IsValid(self.fade)) then
			self.fade:Remove()
		end
		local fade = vgui.Create("DPanel")
		fade:SetSize(ScrW(), ScrH())
		fade:SetSkin("Default")
		fade:SetBackgroundColor(color_black)
		fade:SetAlpha(0)
		fade:AlphaTo(255, self.FADE_SPEED, 0, function() d:resolve() end)
		fade:SetZPos(999)
		fade:MakePopup()
		self.fade = fade
	elseif (IsValid(self.fade)) then
		local fadePanel = self.fade
		fadePanel:AlphaTo(0, self.FADE_SPEED, 0, function()
			fadePanel:Remove()
			d:resolve()
		end)
	end
	return d
end

function PANEL:Paint(w, h)
	ix.util.DrawBlur(self)
	self:paintBackground(w, h)
end

function PANEL:hoverSound()
	LocalPlayer():EmitSound(unpack(SOUND_CHAR_HOVER))
end

function PANEL:clickSound()
	LocalPlayer():EmitSound(unpack(SOUND_CHAR_CLICK))
end

function PANEL:warningSound()
	LocalPlayer():EmitSound(unpack(SOUND_CHAR_WARNING))
end

-- Called by the framework and here to avoid a possible nil error when called, unused.
function PANEL:Close(client) end;

-- This hook is called by the framework, we will redirect it to a different hook.
function PANEL:OnCharacterDeleted(character)
	hook.Run("CharacterListUpdated", ix.characters)
end;

vgui.Register("ixPluginCharMenu", PANEL, "EditablePanel")

if (IsValid(ix.gui.characterMenu)) then
	ix.gui.characterMenu:Remove()
	ix.gui.characterMenu = vgui.Create("ixPluginCharMenu")
end

function PLUGIN:OnCharacterMenuCreated(panel)
    panel = vgui.Create("ixPluginCharMenu")
end
