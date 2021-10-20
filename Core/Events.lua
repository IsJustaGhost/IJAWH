-------------------------------------
-- Events
-------------------------------------
local function updateQuestList()
	local runOnce = false
	local function OnUpdateHandler()
		-- update list when returned to hud
		if SCENE_MANAGER:GetCurrentScene():GetName() == 'hud' and not runOnce then
			EVENT_MANAGER:UnregisterForUpdate("IJAWH_UpdateQuestList")
	--		CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
			IJA_WRITHELPER:UpdateWrits()
			runOnce = true
		end
	end
	
	EVENT_MANAGER:RegisterForUpdate("IJAWH_UpdateQuestList", 100, OnUpdateHandler)
end

local function delayedUpdate(name, func, ...)
	local updateName = "IJAWH_" .. name
    EVENT_MANAGER:UnregisterForUpdate(updateName)
	local runOnce = false
	local function OnUpdateHandler(...)
		-- update list when returned to hud
		if SCENE_MANAGER:GetCurrentScene():GetName() == 'hud' then
			EVENT_MANAGER:UnregisterForUpdate(updateName)
			runOnce = true
			
			return func(...)
		end
	end
	
	EVENT_MANAGER:RegisterForUpdate(updateName, 100, OnUpdateHandler)
end

-------------------------------------
local IJA_WritHelper = IJA_WRITHELPER

local function shouldAlchemyBeEnabled()
--	return IJA_WRITHELPER.currentWrit ~= nil and not IsJustaEasyAlchemy
	return IJA_WRITHELPER.currentWrit ~= nil
end

local function isInCreationMode(writType)
	if SMITHING_SCENE:IsShowing() then
		return SMITHING.mode == writType
	elseif GAMEPAD_SMITHING_CREATION_SCENE:IsShowing() or GAMEPAD_SMITHING_REFINE_SCENE:IsShowing() or GAMEPAD_SMITHING_DECONSTRUCT_SCENE:IsShowing() then
		return SMITHING_GAMEPAD.mode == writType
	elseif GAMEPAD_PROVISIONER_ROOT_SCENE:IsShowing() then
		return GAMEPAD_PROVISIONER.filterType < 3
	elseif PROVISIONER_SCENE:IsShowing() then
		return PROVISIONER.filterType < 3
	elseif GAMEPAD_ENCHANTING_CREATION_SCENE:IsShowing() then
		return true
	elseif ENCHANTING_SCENE:IsShowing() then
		return ENCHANTING.enchantingMode == ENCHANTING_MODE_CREATION
	elseif GAMEPAD_ALCHEMY_CREATION_SCENE:IsShowing() then
		return true
	elseif ALCHEMY_SCENE:IsShowing() then
		return ALCHEMY.mode == ZO_ALCHEMY_MODE_CREATION
	elseif IJA_WRITHELPER:IsShowingAlchemyCraftingScene() then
		return true
	end
	return false
end

local function QuestInformationUpdated()
	local selectedMasterListIndex = CRAFT_ADVISOR_MANAGER.selectedMasterListIndex
	if selectedMasterListIndex then
		local questInfo = CRAFT_ADVISOR_MANAGER.questMasterList[selectedMasterListIndex]
		if questInfo then
			if IJA_WRITHELPER.writData[questInfo.craftingType] and IJA_WRITHELPER.writData[questInfo.craftingType][questInfo.questIndex]then
				IJA_WRITHELPER.selectedQuestIndex = questInfo.questIndex
			end
		end
	end
end

CRAFT_ADVISOR_MANAGER:RegisterCallback("QuestInformationUpdated", function()
	if isInCreationMode() then
		QuestInformationUpdated()
	end
end)

-------------------------------------
local origTooltip = ALCHEMY.tooltip
function IJA_WritHelper:alchemy_KG_Setup()
	local mode = ALCHEMY.mode
	local isActive = shouldAlchemyBeEnabled() and mode == ZO_ALCHEMY_MODE_CREATION
	LIB_IJA_Alchemy:SetHidden(not isActive)
	self.keyboardTooltip:SetHidden(not isActive)
	ALCHEMY.tooltip:SetHidden(mode == ZO_ALCHEMY_MODE_RECIPES)
	CRAFTING_RESULTS:SetCraftingTooltip(nil)
	if isActive then
		self:SetTooltipOverRide(true)
	--	origTooltip = ALCHEMY.tooltip
--		ALCHEMY.tooltip = self.keyboardTooltip
		self.tooltip = self.keyboardTooltip
		CRAFTING_RESULTS:SetCraftingTooltip(ALCHEMY.tooltip)
	else
--		ALCHEMY.tooltip = origTooltip
	end
end

local alchemy_KG_Showinng = false
function IJA_WritHelper:RegisterHooks()
    local oldMode = 0
	local function SelectMode_KB(mode, object)
		if shouldAlchemyBeEnabled() and not alchemy_KG_Showinng then
			if oldMode ~= mode then
				self:alchemy_KG_Setup()
                if mode == ZO_ALCHEMY_MODE_RECIPES then
                    self:SetTooltipOverRide(false)
                else -- mode is ZO_ALCHEMY_MODE_CREATION
                    if oldMode == ZO_ALCHEMY_MODE_RECIPES then
                    end
                    self:SetTooltipOverRide(true)
                    CRAFTING_RESULTS:SetCraftingTooltip(self.tooltip)
                    QuestInformationUpdated()
                    self.currentWrit = self.writData[CRAFTING_TYPE_ALCHEMY][self.selectedQuestIndex]
                    if self.currentWrit ~= nil then
                        self.currentWrit:OnCraftingStation()
                    end
                end
            end
		else
			self.keyboardTooltip:SetHidden(true)
			LIB_IJA_Alchemy:SetHidden(true)
        end
		oldMode = mode
	end
	ZO_PostHook(ALCHEMY, "SetMode", function(self, mode)
		return SelectMode_KB(mode, self)
	end)
    
	local monitoredTutorials = {
		[TUTORIAL_TRIGGER_ALCHEMY_OPENED] = true,
		[TUTORIAL_TRIGGER_BLACKSMITHING_CREATION_OPENED] = true,
		[TUTORIAL_TRIGGER_BLACKSMITHING_DECONSTRUCTION_OPENED] = true,
		[TUTORIAL_TRIGGER_BLACKSMITHING_REFINEMENT_OPENED] = true,
		[TUTORIAL_TRIGGER_CLOTHIER_CREATION_OPENED] = true,
		[TUTORIAL_TRIGGER_CLOTHIER_DECONSTRUCTION_OPENED ]= true,
		[TUTORIAL_TRIGGER_CLOTHIER_REFINEMENT_OPENED] = true,
		[TUTORIAL_TRIGGER_CLOTHIER_RESEARCH_OPENED] = true,
		[TUTORIAL_TRIGGER_ENCHANTING_CREATION_OPENED] = true,
		[TUTORIAL_TRIGGER_ENCHANTING_EXTRACTION_OPENED] = true,
		[TUTORIAL_TRIGGER_JEWELRYCRAFTING_CREATION_OPENED] = true,
		[TUTORIAL_TRIGGER_JEWELRYCRAFTING_DECONSTRUCTION_OPENED] = true,
		[TUTORIAL_TRIGGER_JEWELRYCRAFTING_REFINEMENT_OPENED] = true,
		[TUTORIAL_TRIGGER_WOODWORKING_CREATION_OPENED] = true,
		[TUTORIAL_TRIGGER_WOODWORKING_DECONSTRUCTION_OPENED] = true,
		[TUTORIAL_TRIGGER_WOODWORKING_REFINEMENT_OPENED] = true,
		[TUTORIAL_TRIGGER_UNIVERSAL_STYLE_ITEM] = true
	}

	local triggerTutorial = TriggerTutorial
	function TriggerTutorial(tutorialId)
		zo_callLater(function()
			local isMonitored = monitoredTutorials[tutorialId] or false
			if isMonitored and self.isCrafting then
				-- tutorial stopped to prevent errors
			else
				triggerTutorial(tutorialId)
			end
		end, 300)
	end
end

function IJA_WritHelper:RegisterEvents()
--------------------------------------------------------------------
	self:InitQuestEvents()
	self:RegisterCraftingEvents()
	self:InitializeDynamicEvents()
-- 	/script d(#ZO_WRIT_ADVISOR_GAMEPAD.questMasterList)
	function ZO_WRIT_ADVISOR_GAMEPAD:InitializeKeybinds()
		self.keybindStripDescriptor =
		{
			{
				--Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
				name = "Cycle Active Writs",
				ethereal = true,
				keybind = "UI_SHORTCUT_LEFT_STICK",
				callback = function() 
					if #self.questMasterList > 1 then
						self:CycleActiveQuest()
					elseif IJA_WRITHELPER.currentWrit then
						IJA_WRITHELPER.currentWrit:OnCraftingStation()
					end
				end,
				enabled = function() return not ZO_CraftingUtils_IsPerformingCraftProcess() and self.writMasterList and #self.writMasterList > 0 end,
			},
		}
		local cycleQuestsDescriptor =
		{
			keybind = "UI_SHORTCUT_LEFT_STICK",
			visible = function()
				return self.writMasterList and #self.writMasterList > 1
			end,
		}
		self.questHeader.keybind:SetKeybindButtonDescriptor(cycleQuestsDescriptor)
		ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(self.keybindStripDescriptor)
	end
	ZO_WRIT_ADVISOR_GAMEPAD:InitializeKeybinds()
	
--------------------------------------------------------------------
	LIBIJA_RESULTPANEL.control:SetMovable(not self.savedVars.lock)
end

function IJA_WritHelper:InitializeDynamicEvents()
	self.isCrafting = false

--	shared			------------------------------------------------------------------
	local function OnCraftStation(eventCode, craftingType, sameStation)
        -- 0 is an invalid code
		if eventCode ~= 0 then

            -- get uncompleted writ for craftingType
			local writObject = self:GetWritForStation(craftingType)
			
			if writObject then
                -- set writ for auto-crafting
				self.isCrafting = self:IsAutoCraft(craftingType, writObject.writType)
				self.currentWrit = writObject

                local callbackName = "IJA_OnCraftStation_" .. craftingType
                CALLBACK_MANAGER:FireCallbacks(callbackName)
			end
		end
	end
    
	local function OnCloseCraftStation(eventCode)
		if eventCode ~= 0 then
			self.isCrafting = false
			if self.currentWrit ~= nil then
				self.currentWrit:OnCloseCraftingStation()
				self.currentWrit = nil
			end
			updateQuestList()
		end
	end

    local function delayed_OnCraftStation_Update(func, ...)
        local function OnUpdateHandler(...)
            if SCENE_MANAGER:GetCurrentScene():GetName() ~= 'hud' then
                EVENT_MANAGER:UnregisterForUpdate("IJAWH_OnCraftStation_Update")
                
                return func(...)
            end

        end
        
        EVENT_MANAGER:RegisterForUpdate("IJAWH_OnCraftStation_Update", 100, OnUpdateHandler)
    end

    local function onCraftStationCallback_Smithing()
		local function OnUpdateHandler()
			self.currentWrit:SelectMode()
			self.currentWrit:OnCraftingStation()
		end
		delayed_OnCraftStation_Update(OnUpdateHandler)
    end
    local function onCraftStationCallback_Enchanting()
		local function OnUpdateHandler()
			self.currentWrit:OnCraftingStation()
		end
		delayed_OnCraftStation_Update(OnUpdateHandler)
    end

    local function onCraftStationCallback_Alchemy()
		local function OnUpdateHandler()
			self.currentWrit:SelectMode()
			self.currentWrit:OnCraftingStation()
		end
		delayed_OnCraftStation_Update(OnUpdateHandler)
    end

    local function onCraftStationCallback_Provisioning()
		local function OnUpdateHandler()
			self.currentWrit:OnCraftingStation()
		end
		delayed_OnCraftStation_Update(OnUpdateHandler)
    end

    local onCraftStationCallbacks = {
        ["IJA_OnCraftStation_1"]    = onCraftStationCallback_Smithing,
        ["IJA_OnCraftStation_2"]    = onCraftStationCallback_Smithing,
        ["IJA_OnCraftStation_3"]    = onCraftStationCallback_Enchanting,
        ["IJA_OnCraftStation_4"]    = onCraftStationCallback_Alchemy,
        ["IJA_OnCraftStation_5"]    = onCraftStationCallback_Provisioning,
        ["IJA_OnCraftStation_6"]    = onCraftStationCallback_Smithing,
        ["IJA_OnCraftStation_7"]	= onCraftStationCallback_Smithing
    }
    for callbackName, callbackFunction in pairs(onCraftStationCallbacks) do
        CALLBACK_MANAGER:RegisterCallback(callbackName, callbackFunction)
    end

--	station event table	--------------------------------------------------------------
	self.stationEvents = {
		[0] = {
			[1] = {
				['func'] = OnCraftStation,
				['object'] = self.control,
				['name'] = EVENT_CRAFTING_STATION_INTERACT,
				['type'] = "event",
			},
			[2] = {
				['func'] = OnCloseCraftStation,
				['object'] = self.control,
				['name'] = EVENT_END_CRAFTING_STATION_INTERACT,
				['type'] = "event",
			},
		}
	}

	local function questCounterChanged(eventId, questIndex, questName, conditionText, conditionType, curCondtionVal, newConditionVal, conditionMax)
		if newConditionVal ~= conditionMax then
			local function OnUpdateHandler()
				-- update list when returned to hud
				local writ_Object = self.questIndexToDataMap[questIndex]
				if writ_Object then
					local force = true
					writ_Object:Update(force)
					
	--				CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end
			end
			
			delayedUpdate("questCounterChanged", OnUpdateHandler, questIndex)
		end
		
	end

	local function onSingleSLotUpdated(eventId, bagId, slotIndex, oldSlotData, suppressItemAlert)
		-- need to be able to update writs if a item used for a writ is updated
		local function OnUpdateHandler()
			local itemId = GetItemId(bagId, slotIndex)
			local usedInCraftingType = GetItemCraftingInfo(bagId, slotIndex)
			local stationWrits = self.writData[usedInCraftingType]
		
			local FORCE = true
			if stationWrits then
				for questIndex, writ_Object in pairs(stationWrits) do
					writ_Object:Update(FORCE)
				end
	--			CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
			elseif self.itemIdToDataMap[itemId] then
				self.itemIdToDataMap[itemId]:Update(FORCE)
			end
		end
		
		delayedUpdate("onSingleSLotUpdated", OnUpdateHandler, bagId, slotIndex)
	end
	
	local function updateWritPanel()
		local function OnUpdateHandler()
			CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
		end
		
		delayedUpdate("updateWritPanel", OnUpdateHandler)
	end
	
	self.updateEvents = {
		[1] = {
			['func'] = questCounterChanged,
			['object'] = self.control,
			['name'] = EVENT_QUEST_CONDITION_COUNTER_CHANGED,
			['type'] = "event",
		},
		[2] = {
			['func'] = onSingleSLotUpdated,
			['object'] = self.control,
			['name'] = EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
			['type'] = "event",
		},
		[3] = {
			['func'] = updateWritPanel,
			['object'] = self.control,
			['name'] = EVENT_MOUNTED_STATE_CHANGED,
			['type'] = "event",
		},
		[4] = {
			['func'] = updateWritPanel,
			['object'] = self.control,
			['name'] = EVENT_PLAYER_ACTIVATED,
			['type'] = "event",
		},
		[5] = {
			['func'] = updateWritPanel,
			['object'] = self.control,
			['name'] = EVENT_PLAYER_COMBAT_STATE,
			['type'] = "event",
		},
		[6] = {
			['func'] = updateWritPanel,
			['object'] = self.control,
			['name'] = EVENT_GROUP_MEMBER_JOINED,
			['type'] = "event",
		},
		[7] = {
			['func'] = updateWritPanel,
			['object'] = self.control,
			['name'] = EVENT_GROUP_MEMBER_LEFT,
			['type'] = "event",
		}
	}
end

function IJA_WritHelper:RegisterCraftingEvents()
	local function onCraftItemUpdate(bagId, slotId, craftingType)
		-- lets not let this run if crafting furniture
		local currentWrit = self:GetCurrentWrit()
		if currentWrit and isInCreationMode(currentWrit.writType) then
			zo_callLater(function()
				local condition = currentWrit:GetCurrentCondition()
				local itemCompleted = condition:GetCompleted()
				
				if condition:HasItemToImproveForWrit() then
					-- prevent crafting duplicate item
					itemCompleted = true
					if self.savedVars.autoImprove then
						if condition.improvementItemData ~= nil then
							condition:TryImproveItem(condition:GetImprovementItemData())
						end
					end
				end
				
				local itemId = GetItemId(bagId, slotId)
--				self.craftedItems[itemId] = true -----------------
				
				if self.bankedList[itemId] then
					-- need to remove crafted item from the list to be withdrawn from bank
					self.bankedList[itemId] = nil

					-- if there are no items left on the withdraw list, then stop the addon from trying to access the bank on bank interaction
					if NonContiguousCount(self.bankedList) < 1 then
						self.control:UnregisterForEvent(EVENT_OPEN_BANK)
					end
				end
				
				if currentWrit:GetCompleted() then
					self:RemoveCraftKeybind()
					
					local writObject = self:GetWritForStation(craftingType)
					
					if self.savedVars.autoContinue and writObject ~= nil then
						-- if there is another writ for the current station, select it and begin crafting
		--				d( 'another writ of same type')
						self.currentWrit = writObject
						writObject:OnCraftingStation()
					else
						-- else, clean up and exit the station
	--					d( 'no other writ of same type')
						self.isCrafting = false
						if self.savedVars.autoExit then
				--			CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
							SCENE_MANAGER:ShowBaseScene()
						end
					end
					return
				else
					if itemCompleted then
						currentWrit:OnCraftingStation()
					elseif not condition.retried then
		--				d( 'retrying to craft the current item or craft next item')
						condition.retried = true
						condition:TryToCraft()
					elseif condition.retried then
						-- should this ever run, since crafting must have started in order to get here?
	--					d( 'was unable to craft')
						self.isCrafting = false
						condition.retried = false
					end
				end
			end, 300)
			CALLBACK_MANAGER:RegisterCallback("IsJustaWritHelper_OnCraftComplete", onCraftItemUpdate)
		end
	end
end

function IJA_WritHelper:RegisterDynamicEvents()
	local function registerEvent(event)
		if event.type == 'callback' then
			event.object:RegisterCallback(event.name, event.func)
		end
		if event.type == 'event' then
			event.object:RegisterForEvent(event.name, event.func)
		end
	end

	local function registerStationEvents(eventGroup)
		for k, event in pairs(eventGroup) do
			registerEvent(event)
		end
	end
	registerStationEvents(self.stationEvents[0])
	--[[
	for craftingType, v in pairs(self.writData) do
		local key = IsSmithingCraftingType(craftingType) and 1 or craftingType
		if key <= 7 then
			registerStationEvents(self.stationEvents[key])
		end
	end
	]]
	for k,event in pairs(self.updateEvents) do
		registerEvent(event)
	end
end

function IJA_WritHelper:UnregisterDynamicEvents()
	local function unregisterEvent(event)
		if event.type == 'callback' then
			event.object:UnregisterCallback(event.name, event.func)
		end
		if event.type == 'event' then
			event.object:UnregisterForEvent(event.name, event.func)
		end
	end

	local function unregisterStationEvents(eventGroup)
		for k, event in pairs(eventGroup) do
			unregisterEvent(event)
		end
	end
	unregisterStationEvents(self.stationEvents[0])
	--[[
	for craftingType, v in pairs(self.writData) do
		local key = IsSmithingCraftingType(craftingType) and 1 or craftingType
		if key <= 7 then
			unregisterStationEvents(self.stationEvents[key])
		end
	end
	]]
	for k,event in pairs(self.updateEvents) do
		unregisterEvent(event)
	end
end

function IJA_WritHelper:UpdateDynamicEvents()
	if NonContiguousCount(IJA_WRITHELPER.writData) > 0 then
		self:RegisterDynamicEvents()
	else
		self:UnregisterDynamicEvents()
	end
end

-------------------------------------
function IJA_WritHelper:DoUpdateOnce(name, delay, func)
	EVENT_MANAGER:UnregisterForUpdate(name)
	EVENT_MANAGER:RegisterForUpdate(name, delay, func)
end

-------------------------------------
function IJA_WritHelper:InitQuestEvents()
--	open writ containers	----------------------------------------------------------
	local WRIT_OpenContainers = false
	local WRIT_TurnInUpdate = false

--	open containers		--------------------------------------------------------------

	local function isWritCoffer(itemData)	-- comparator
		local itemLink = GetItemLink(itemData.bagId, itemData.slotIndex)

		local flavorText = GetItemLinkFlavorText(itemLink):lower()
		local isForCraft = flavorText:match(GetString(SI_IJAWH_WRITREWARD1):lower()) or
			flavorText:match(GetString(SI_IJAWH_WRITREWARD2):lower()) or false

		return itemData.specializedItemType == SPECIALIZED_ITEMTYPE_CONTAINER and isForCraft
	end
	
	local function onLootUpdated(...)
		LOOT_SHARED.LootAllItems()
		SCENE_MANAGER:ShowBaseScene()
	end

	local containers = {}
	local function getContainersAndCount()
		if not CheckInventorySpaceSilently(1) then
			return -1
		end
		containers = {}
		local filteredDataTable = SHARED_INVENTORY:GenerateFullSlotData(isWritCoffer, BAG_BACKPACK)
		for _, itemData in pairs(filteredDataTable) do
			table.insert(containers, itemData.slotIndex)
		end
		
		return #containers
	end

	local function unregisterOpenEvents()
		WRIT_OpenContainers = false
		WRIT_TurnInUpdate = false
		
		EVENT_MANAGER:UnregisterForUpdate('IJAWH_getNextContainer')
		EVENT_MANAGER:UnregisterForEvent("IJAWH_WRIT_TurnIn_UPDATE", EVENT_LOOT_CLOSED)
		self.control:UnregisterForEvent(EVENT_LOOT_UPDATED)
	end
	
	ZO_PostHook('ZO_Alert', function(category, soundId, message, ...)
		-- if alert "Item not ready yet" then retry opening last container
		if WRIT_TurnInUpdate and string.match(message, GetString(SI_ITEM_FORMAT_STR_ON_COOLDOWN)) then
			WRIT_OpenContainers = true
		end
	end)
	
	local function startOpening()
		local num = getContainersAndCount()
		if num > 0 then
			WRIT_OpenContainers = true
		elseif num == 0 then
			unregisterOpenEvents()
		elseif num == -1 then
			-- stop opening containers if inventory is full. will resume when inventory changes
		end
	end
	
	local function getNextContainer(eventCode)
		if WRIT_OpenContainers then
			WRIT_OpenContainers = false
			
			if #containers > 0 then
				if CheckInventorySpaceSilently(1) then
					local slotIndex = containers[#containers]
					containers[#containers] = nil
				
					zo_callLater(function() CallSecureProtected("UseItem", BAG_BACKPACK, slotIndex) end, 500)
				end
			else
				-- get remaining containers and shipments
				startOpening()
			end
		end
	end
	
	local function CloseLootWindow()
		WRIT_OpenContainers = true
	end

	local function registerOpenEvents()
		if not WRIT_TurnInUpdate then
			self.control:RegisterForEvent(EVENT_LOOT_UPDATED, onLootUpdated)
			EVENT_MANAGER:RegisterForEvent("IJAWH_WRIT_TurnIn_UPDATE", EVENT_LOOT_CLOSED, CloseLootWindow)
			EVENT_MANAGER:RegisterForEvent("IJAWH_WRIT_TurnIn_FAILED", EVENT_LOOT_ITEM_FAILED, CloseLootWindow)
			
			EVENT_MANAGER:RegisterForUpdate("IJAWH_getNextContainer", 500, getNextContainer)
			startOpening()
		end
	end

	local firedOnce = false
	local function startOpeningContainers()
		WRIT_OpenContainers = false
		
		if firedOnce then
			EVENT_MANAGER:UnregisterForUpdate("IJAWH_WRIT_TurnInUpdate")
			registerOpenEvents()
		end
		firedOnce = true
	end
	
	-- for testing opening via a chat command
	CALLBACK_MANAGER:RegisterCallback("IJAWH_OPEN", function()
		self.control:RegisterForEvent(EVENT_LOOT_UPDATED, onLootUpdated)
		WRIT_TurnInUpdate = false
		firedOnce = true
		startOpeningContainers()
	end)

--	writ remove		------------------------------------------------------------------
	local function removeWrit(removedQuest)
		local o = {}
		for craftingType, stationWrits in pairs(self.writData) do
			for questIndex, writData in pairs(stationWrits) do
				if questIndex ~= removedQuest then
					if not o[craftingType] then o[craftingType] = {} end
					o[craftingType][questIndex] = writData
				end
			end
		end
		self.writData = o
		updateQuestList()
	end

	local function onQuestRemoved(...)
		local questIndex = select(3, ...)
		removeWrit(questIndex)
	end
	self.control:RegisterForEvent(EVENT_QUEST_REMOVED, onQuestRemoved)
	
--	writ add/turn-in		----------------------------------------------------------
	local function writTurnIn()
		self.control:UnregisterForEvent(EVENT_QUEST_COMPLETE_DIALOG, writTurnIn)
		if GetInteractionType() == INTERACTION_QUEST then
			if self.savedVars.autoOpen then
				firedOnce = false
				
				-- delayed action to start opening all containers. The delay resets each time a writ is turned in.
				-- This is to allow for a chance to run the action once for all writs.
				self:DoUpdateOnce("IJAWH_WRIT_TurnInUpdate", (self.savedVars.autoOpenDelay * 1000), startOpeningContainers)
			end

			CompleteQuest()
		end
	end

	local hasNewWrit = false
	local function onChatterEnd()
		self.control:UnregisterForEvent(EVENT_CHATTER_END, onChatterEnd)
		if hasNewWrit then
			updateQuestList()
			hasNewWrit = false
		else
		end
	end

	local function acceptQuest(eventCode)
		self.control:UnregisterForEvent(EVENT_QUEST_OFFERED, acceptQuest)
		AcceptOfferedQuest()
	end

	local function autoAccept()
		self.control:RegisterForEvent(EVENT_QUEST_OFFERED, acceptQuest)
		SelectChatterOption(1)
	end

--	writ interactions		----------------------------------------------------------
	local chatterOptions_Offered = {
		[SI_IJAWH_CHATTEROPTION1] = true,
		[SI_IJAWH_CHATTEROPTION2] = true,
		[SI_IJAWH_CHATTEROPTION3] = true,
		[SI_IJAWH_CHATTEROPTION4] = true,
		[SI_IJAWH_CHATTEROPTION5] = true,
		[SI_IJAWH_CHATTEROPTION6] = true,
		[SI_IJAWH_CHATTEROPTION7] = true,
		[SI_IJAWH_CHATTEROPTION8] = true,
		[CHATTER_START_TALK] = true,
		[CHATTER_START_NEW_QUEST_BESTOWAL] = true,
		[CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS] = true
	}

	local chatterOptions_Complete = {
		[SI_IJAWH_CHATTEROPTION9] = true,
		[SI_IJAWH_CHATTEROPTION10] = true,
		[SI_IJAWH_CHATTEROPTION11] = true,
		[CHATTER_START_COMPLETE_QUEST] = true,
		[CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS] = true
	}

	local function isChatterOptionQuestWrit(optionText, optiontype)
		return chatterOptions_Offered[optionText] and chatterOptions_Offered[optiontype]
	end

	local function isChatterOptionQuestTurnIn(optionText, optiontype)
		return chatterOptions_Complete[optionText] and chatterOptions_Complete[optiontype]
	end

	local isWritInteraction = false
	local function onChatterBegin()
		if GetInteractionType() == INTERACTION_CONVERSATION then
			local greeting = GetChatterGreeting()
			for i=1, GetChatterOptionCount() do
				local optionText, optiontype, optionalArg = GetChatterOption(i)
				d( 'optionText', optionText)
				-- pick up
				if isChatterOptionQuestWrit(optionText, optiontype) then
					isWritInteraction = true
					self.control:RegisterForEvent(EVENT_CHATTER_END, onChatterEnd)
					if self.savedVars.autoAccept then
						if GetNumJournalQuests() < MAX_JOURNAL_QUESTS then
							autoAccept()
						else
							ZO_Alert(SOUNDS.NEGATIVE_CLICK, GetString(SI_MARKETPURCHASABLERESULT31))
						end
					end
				-- trun in
				elseif isChatterOptionQuestTurnIn(optionText, optiontype) then
					self.control:RegisterForEvent(EVENT_QUEST_COMPLETE_DIALOG, writTurnIn)
					
					SelectChatterOption(i)
				end
			end
		end
	end

	local function onWritAccepted(eventId, questIndex, writName)
		if isWritInteraction then
			hasNewWrit = true
			isWritInteraction = false

		-- added to show master writs in the writ panel when the writ is used from inventory
		elseif string.find(writName, GetString(SI_IJAWH_MASTERFUL)) or string.find(writName, GetString(SI_IJAWH_WRIT)) then
			updateQuestList()
		end
	end

	local function questAdvanced(eventCode, questIndex, questName, isPushed, isComplete, mainStepChanged)
		-- needed for when a wirt quest is updated from talking. certification quests need this.
		if isWritInteraction and mainStepChanged then
			isWritInteraction = false
			self:RemoveWritByQuestIndex(questIndex)
			updateQuestList()
		end
	end

	self.control:RegisterForEvent(EVENT_QUEST_ADDED, onWritAccepted)
	self.control:RegisterForEvent(EVENT_CHATTER_BEGIN, onChatterBegin)
	self.control:RegisterForEvent(EVENT_QUEST_ADVANCED, questAdvanced)
end


--[[

	
update all writs

update writ by type
	local craftingType =
	self.dataMap[craftingType]:Update()

update single writ
	local itemId = GetItemId(bagId, slotId)
	self.itemIdToDataMap[itemId]:Update()

[craftingType]
[itemId]

self.itemIdToDataMap


self.questIndexToDataMap
self.craftingTypeToDataMap


function IJA_WritHelper:MapWritData(data)
    self.itemIdToDataMap[data.itemId] = data
end

IJA_WRITHELPER:MapWritData(self)





			
			
			

	
	
--]]