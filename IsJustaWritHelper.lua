local defaults = {
	displayName = "|cFF00FFIsJusta|r |cffffffWritHelper|r",
	name = "IsJustaWritHelper",
	version = "5.2.2",
}

local defaultSettings = {
	priorityBy			= IJA_REAGENT_PRIORITY_BY_STOCK,
	useMostStyle		= true,
	useRaceStyles		= true,
	showCraftForWrit	= true,
	showWithdrawInChat	= true,
	showInBankAlert		= true,
	handleWithdraw		= true,
	autoAccept			= false,
	hideWhileMounted 	= false,
	autoExit			= false,
	transparency		= 75,
	panelScale			= 3,
	autoOpenDelay		= 2,
	autoCraft 			= {}
}
local svVersion = 5.15

-------------------------------------
-- Initialize
-------------------------------------
local IJA_WritHelper = LibIJA:Subclass()

function IJA_WritHelper:New(...)
    local newObject = ZO_Object.New(self)
	zo_mixin(newObject, defaults)
    newObject:Initialize(...)
    return newObject
end

function IJA_WritHelper:Initialize(control)
	self.control = control
	self.control:RegisterForEvent( EVENT_ADD_ON_LOADED, function( ... ) self:OnLoaded( ... ) end )
end

function IJA_WritHelper:OnLoaded(event, addon)
	self.control:UnregisterForEvent(EVENT_ADD_ON_LOADED)
	
	self.savedVarsVersion	= svVersion
	self.defaultSettings	= defaultSettings
	
	self.bankedList = {}
	self.activeEvents = {}
	self.writData = {}
	self.craftedItems = {}
	self.writMasterList = {}
	self.craftingItems = {}
	self.craftedItems = {}
	
	self.itemIdToDataMap = {}
	self.questIndexToDataMap = {}
	
	self.lockedItems = {}
	
	local AccountWideSavedVars = ZO_SavedVars:NewAccountWide("IJAWH_SavedVars", svVersion, nil, defaultSettings, GetWorldName())

	if AccountWideSavedVars.character then
		local characterSavedVars = ZO_SavedVars:New("IJAWH_SavedVars", svVersion, nil, defaultSettings, GetWorldName())
		self.savedVars = characterSavedVars
	else
		self.savedVars = AccountWideSavedVars
	end
	
	self:InitializeDynamicEvents()
	self.writPanel = IJA_WritPanel_Initialize(self, IJA_WritHelperWritPanel)
	self:CreateMenu( self )
	
--	self:BuildDialogInfo()
	self:InitializeKeybindStripDescriptors()
	self:RegisterHooks()
	
	-- clear and rescan for writs
	local function onCommandEntered(args)
		if args == 'reset' or args == 'r' then
			-- purge and rebuild the lists
--			IJA_WRITHELPER.questWorkingList = {}
--			IJA_WRITHELPER:GetWritsFromJournal()
--			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_OPTIONS_RESET))
		end
		if args == 'loot' or args == 'l' then
			CALLBACK_MANAGER:FireCallbacks("IJAWH_OPEN")
		end
	end

	SLASH_COMMANDS["/ija_writhelper"] = onCommandEntered
	
	self.control:RegisterForEvent(EVENT_PLAYER_ACTIVATED, function() self:OnPlayerActivated() end)
end

function IJA_WritHelper:OnPlayerActivated()
	self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
	
	d( self.displayName .. " version: " .. self.version)
	self:RegisterEvents()
	
	local function OnGamepadPreferredModeChanged()
		-- fires on load
		local gamepadMode = IsInGamepadPreferredMode()
		self.gamepadMode = gamepadMode

		self.resetWritKeybindStripDescriptor.alignment = gamepadMode and KEYBIND_STRIP_ALIGN_LEFT or KEYBIND_STRIP_ALIGN_CENTER

		self.writPanel:SetPanelStyle()
		CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
	end
	ZO_PlatformStyle:New(OnGamepadPreferredModeChanged)
end

function IJA_WritHelper:SetRefreshGroup(func)	----------------------------------
	self.refreshGroup:AddDirtyState("Writ", function()
		func()
	end)
end

function IJA_WritHelper:MarkDirty(func)	----------------------------------
	self.refreshGroup:MarkDirty("Writ")
end

--------------Initialize--------------
function IJA_WritHelper_Initialize(control)
	IJA_WRITHELPER = IJA_WritHelper:New(control)
end

















