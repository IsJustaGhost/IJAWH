local defaults = {
	displayName = "BETA: |cFF00FFIsJusta|r |cffffffWritHelper|r",
	name = "IsJustaWritHelper_Beta",
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
local svVersion = 5.16

IJA_ACTIVEWRITS = {}

-------------------------------------
-- Initialize
-------------------------------------
--local IJA_WritHelper = ZO_InitializingObject:Subclass()
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

	self.writData = {}
	self.writMasterList = {}

	self.bankedList = {}
	self.activeEvents = {}
	self.craftItems = {}
	self.craftingItems = {}
	self.craftedItems = {}
	self.writInventory = {}

	self.itemIdToDataMap = {}
	self.questIndexToDataMap = {}
	
	self.accountWideSavedVars = ZO_SavedVars:NewAccountWide("IJAWH_SavedVars_Beta", svVersion, nil, defaultSettings, GetWorldName())

	if self.accountWideSavedVars.character then
		local characterSavedVars = ZO_SavedVars:New("IJAWH_SavedVars_Beta", svVersion, nil, defaultSettings, GetWorldName())
		self.savedVars = characterSavedVars
	else
		self.savedVars = self.accountWideSavedVars
	end

	self:InitializeCraftingInventory()
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

	
	self.isFCOIS = FCOIS ~= nil
end

function IJA_WritHelper:OnPlayerActivated()
	self.control:UnregisterForEvent(EVENT_PLAYER_ACTIVATED)
	
	d( self.displayName .. " version: " .. self.version)
	self:RegisterEvents()
	
	local function OnGamepadPreferredModeChanged()
		-- fires on load
		local gamepadMode = IsInGamepadPreferredMode()
		self.isGamepadMode = gamepadMode

		self.resetWritKeybindStripDescriptor.alignment = gamepadMode and KEYBIND_STRIP_ALIGN_LEFT or KEYBIND_STRIP_ALIGN_CENTER

		self.writPanel:SetPanelStyle()
		CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
	end
	ZO_PlatformStyle:New(OnGamepadPreferredModeChanged)
	self:UpdateWrits()
end

--------------Initialize--------------
function IJA_WritHelper_Initialize(control)
	IJA_WRITHELPER = IJA_WritHelper:New(control)
end

-- test function
-- /script IJA_GetAllWritData()
function IJA_GetAllWritData()
    local questData = {}
    local quests = QUEST_JOURNAL_MANAGER:GetQuestList()
    for i, questInfo in ipairs(quests) do
        if questInfo.questType == QUEST_TYPE_CRAFTING then
            local stepData = {}
            local numSteps = GetJournalQuestNumSteps(questInfo.questIndex)
            for stepIndex=1, numSteps do
               	local conditinoData = {}
                local conditionCount = GetJournalQuestNumConditions(questInfo.questIndex, stepIndex)
                local stepText, visibility, stepType, trackerOverrideText, numConditions = GetJournalQuestStepInfo(questInfo.questIndex, stepIndex)
                for conditionIndex = 1, conditionCount do
                    local itemId, materialItemId, craftingType, itemFunctionalQuality, itemTemplateId, itemSetId, itemTraitType, itemStyleId, encodedAlchemyTraits = 0, 0, 0, 0, 0, 0, 0, 0, 0
                    local conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible, conditionType = GetJournalQuestConditionInfo(questInfo.questIndex, stepIndex, conditionIndex)
                    
                    if conditionType == QUEST_CONDITION_TYPE_CRAFT_RANDOM_WRIT_ITEM then
                        itemId, materialItemId, craftingType, itemFunctionalQuality, itemTemplateId, itemSetId, itemTraitType, itemStyleId, encodedAlchemyTraits = GetQuestConditionMasterWritInfo(questInfo.questIndex, stepIndex, conditionIndex)
                    else
                        itemId, materialItemId, craftingType, itemFunctionalQuality = GetQuestConditionItemInfo(questInfo.questIndex, stepIndex, conditionIndex)
                    end
                    table.insert(conditinoData,
                        {
                            conditionIndex = conditionIndex,
                            conditionText = conditionText,
                            current = current,
                            max = max,
                            isFailCondition = isFailCondition,
                            isComplete = isComplete,
                            isCreditShared = isCreditShared,
                            isVisible = isVisible,
                            conditionType = conditionType,
                            itemId = itemId,
                            materialItemId = materialItemId,
                            craftingType = craftingType,
                            itemFunctionalQuality = itemFunctionalQuality,
                            itemTemplateId = itemTemplateId,
                            itemSetId = itemSetId,
                            itemTraitType = itemTraitType,
                            itemStyleId = itemStyleId,
                            encodedAlchemyTraits = encodedAlchemyTraits
                        }
                    )
                end

                table.insert(stepData, 
                {
                    stepText = stepText, 
                    visibility = visibility, 
                    stepType = stepType, 
                    trackerOverrideText = trackerOverrideText, 
                    numConditions = numConditions,
                    conditinoData = conditinoData
                }
            )
            end
            questInfo.stepData = stepData
            table.insert(questData , questInfo)
        end
    end
    d( questData)
end
