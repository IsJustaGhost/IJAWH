-------------------------------------
-- Events
-------------------------------------
local function updateQuestList()
	local runOnce = false
	local function OnUpdateHandler()
		-- update list when returned to hud
		if SCENE_MANAGER:GetCurrentScene():GetName() == 'hud' and not runOnce then
			EVENT_MANAGER:UnregisterForUpdate("IJAWH_UpdateQuestList")
			CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
			runOnce = true
		end
	end
	
	EVENT_MANAGER:RegisterForUpdate("IJAWH_UpdateQuestList", 100, OnUpdateHandler)
end

local function delayedUpdate(name, func, ...)
	local updateName = "IJAWH_" .. name
	local function OnUpdateHandler(...)
		-- update list when returned to hud
		if SCENE_MANAGER:GetCurrentScene():GetName() == 'hud' then
			EVENT_MANAGER:UnregisterForUpdate(updateName)
			return func(...)
		end
	end
	
	EVENT_MANAGER:RegisterForUpdate(updateName, 100, OnUpdateHandler)
end

-------------------------------------
local IJA_WritHelper = IJA_WRITHELPER

local function shouldAlchemyBeEnabled()
	return IJA_WRITHELPER.currentWrit ~= nil and not IsJustaEasyAlchemy
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

-------------------------------------
function IJA_WritHelper:RegisterHooks()
	local function SelectMode_KB(mode, object)
		if shouldAlchemyBeEnabled() then
			local oldMode = self.mode
			if oldMode ~= mode then
				self.keyboardTooltip:SetHidden(mode == ZO_ALCHEMY_MODE_RECIPES)
				LIB_IJA_Alchemy:SetHidden(mode == ZO_ALCHEMY_MODE_RECIPES)
				
				CRAFTING_RESULTS:SetCraftingTooltip(nil)
				ALCHEMY.tooltip:SetHidden(true)
				if mode == ZO_ALCHEMY_MODE_RECIPES then
					KEYBIND_STRIP:RemoveKeybindButtonGroup(ALCHEMY.keybindStripDescriptor)
					PROVISIONER:EmbedInCraftingScene()
					
					self:SetTooltipOverRide(false)
				else -- mode is ZO_ALCHEMY_MODE_CREATION
					if oldMode == ZO_ALCHEMY_MODE_RECIPES then
						PROVISIONER:RemoveFromCraftingScene()
						KEYBIND_STRIP:AddKeybindButtonGroup(ALCHEMY.keybindStripDescriptor)
					end
					
					self.tooltip = self.keyboardTooltip
					CRAFTING_RESULTS:SetCraftingTooltip(self.tooltip)
					CRAFTING_RESULTS:SetTooltipAnimationSounds(SOUNDS.ALCHEMY_CREATE_TOOLTIP_GLOW_SUCCESS, SOUNDS.ALCHEMY_CREATE_TOOLTIP_GLOW_FAIL)
					ALCHEMY:ResetMultiCraftNumIterations()
					
					self:SetTooltipOverRide(true)
					QuestInformationUpdated()
					self.currentWrit = self.writData[CRAFTING_TYPE_ALCHEMY][self.selectedQuestIndex]
					if self.currentWrit ~= nil then
						self.currentWrit:OnCraftingStation()
					end
				end
				ALCHEMY.control:GetNamedChild("Inventory"):SetHidden(mode ~= ZO_ALCHEMY_MODE_CREATION)
				ALCHEMY.control:GetNamedChild("SlotContainer"):SetHidden(mode ~= ZO_ALCHEMY_MODE_CREATION)
			end
			self.mode = mode
			return true
		end
		return false
	end
	ZO_PreHook(ALCHEMY, "SetMode", function(self, mode)
		return SelectMode_KB(mode, self)
	end)


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

--	ZO_PreHook("TriggerTutorial", triggerTutorial)
end

function IJA_WritHelper:RegisterEvents()
--------------------------------------------------------------------
	self:InitQuestEvents()
	self:RegisterCraftingEvents()
	self:InitializeDynamicEvents()

	function ZO_WRIT_ADVISOR_GAMEPAD:InitializeKeybinds()
		self.keybindStripDescriptor =
		{
			{
				--Ethereal binds show no text, the name field is used to help identify the keybind when debugging. This text does not have to be localized.
				name = "Cycle Active Writs",
				ethereal = true,
				keybind = "UI_SHORTCUT_LEFT_STICK",
				callback = function() 
					if #self.writMasterList > 1 then
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
	self.selectedQuestIndex = 0
	
	local function cycleActiveQuests()	---------------<
		self:CycleActiveQuests()
	end

	local function shouldBeEnabled()	---------------<
		return self.currentWrit ~= nil and not IsJustaEasyAlchemy
	end

	local function GetNodeByData(writData)	---------------<
		for _, node in pairs(ZO_WRIT_ADVISOR_WINDOW.navigationTree.rootNode.children) do
			if node.data.questIndex == writData.questIndex then
				return node
			end
		end
	end

	local function setKeyboardQuestList(writData)	---------------<
		local node = GetNodeByData(writData)
		node:GetTree():SelectNode(node)
	end
	
--	shared			------------------------------------------------------------------
	local function OnCraftStation(eventCode, craftingType, sameStation)
		if eventCode ~= 0 then -- 0 is an invalid code
			self.currentWrit = nil

--			QuestInformationUpdated()
			local writObject = self:GetWritForStation(craftingType)
			
			if writObject then
				self.isCrafting = self:IsAutoCraft(craftingType, writObject.writType)
				self.currentWrit = writObject
			end
		end
	end

	local function OnCloseCraftStation(eventCode)
		if eventCode ~= 0 then
			self.isCrafting = false
			if self.currentWrit ~= nil then
				self.currentWrit:OnCloseCraftingStation()
				self.currentWrit = nil
		--		CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
			end
			updateQuestList()
		end
	end

	local function onStateChange(oldState, newState)
		QuestInformationUpdated()
		if self.currentWrit ~= nil and not self.currentWrit.completed then
			if newState == SCENE_SHOWING then
			elseif newState == SCENE_SHOWN then
				self.currentWrit = self:GetWritByQuestIndex(self.selectedQuestIndex)
				if self.currentWrit ~= nil then
					self.currentWrit:OnCraftingStation()
				end
			elseif newState == SCENE_HIDING then
			elseif newState == SCENE_HIDDEN then
			end
		end
	end
	
	local function onRootScene(oldState, newState)
		if self.currentWrit ~= nil and not self.currentWrit.completed then
			if not IsInGamepadPreferredMode() then
				onStateChange(oldState, newState)
			end
			self.currentWrit:SelectMode()
		end
	end
	
--	alchemy			------------------------------------------------------------------
	local function alchemyStateChanged_KB(oldState, newState)
		if self.currentWrit ~= nil and not self.currentWrit.completed then
			onStateChange(oldState, newState)
			if newState == SCENE_SHOWING then
			elseif newState == SCENE_SHOWN then
				self:SetTooltipOverRide(true)
				CALLBACK_MANAGER:RegisterCallback("AlchemyInfoReady", QuestInformationUpdated )
				KEYBIND_STRIP:RemoveKeybindButtonGroup(ALCHEMY.keybindStripDescriptor)
				
				self.tooltip = self.keyboardTooltip
				CRAFTING_RESULTS:SetCraftingTooltip(self.tooltip)
				CRAFTING_RESULTS:SetTooltipAnimationSounds(SOUNDS.ALCHEMY_CREATE_TOOLTIP_GLOW_SUCCESS, SOUNDS.ALCHEMY_CREATE_TOOLTIP_GLOW_FAIL)
				
				ALCHEMY.tooltip:SetHidden(true)
				self.currentWrit:SelectMode()
			elseif newState == SCENE_HIDING then
			elseif newState == SCENE_HIDDEN then
				ZO_InventorySlot_RemoveMouseOverKeybinds()
				KEYBIND_STRIP:RemoveKeybindButtonGroup(self.currentKeybindStripDescriptor)
				self.tooltip:SetHidden(true)
				
				self:SetTooltipOverRide(false)
				CALLBACK_MANAGER:UnregisterCallback("AlchemyInfoReady", QuestInformationUpdated )
			end
		end
	end

    local function gamePadAlchemyCraft(oldState, newState)
--		if shouldAlchemyBeEnabled() then
		if self.currentWrit ~= nil and not self.currentWrit.completed then
			onStateChange(oldState, newState)
			if newState == SCENE_SHOWING then
				ApplyTemplateToControl(ZO_GamepadAlchemyTopLevelSlotContainer, "IJA_GamepadAlchemyTopLevelSlotContainer")
			elseif newState == SCENE_SHOWN then
				self:SetTooltipOverRide(true)
				self.tooltip = GAMEPAD_ALCHEMY.tooltip
				GAMEPAD_CRAFTING_RESULTS:SetCraftingTooltip(self.tooltip)
				GAMEPAD_CRAFTING_RESULTS:SetTooltipAnimationSounds(SOUNDS.ALCHEMY_CREATE_TOOLTIP_GLOW_SUCCESS, SOUNDS.ALCHEMY_CREATE_TOOLTIP_GLOW_FAIL)
				
			elseif newState == SCENE_HIDDEN then
				self:SetTooltipOverRide(false)
				ApplyTemplateToControl(ZO_GamepadAlchemyTopLevelSlotContainer, "ZO_GamepadCraftingIngredientBarTemplate")
			end
		end
	end

	local function alchemyStateChanged_GP(oldState, newState)
		if self.currentWrit ~= nil and not self.currentWrit.completed then
			if newState == SCENE_SHOWN then
				CALLBACK_MANAGER:RegisterCallback("AlchemyInfoReady", QuestInformationUpdated )
				self.currentWrit:SelectMode()
			elseif newState == SCENE_HIDDEN then
				self.tooltip:SetHidden(true)
				GAMEPAD_CRAFTING_RESULTS:SetCraftingTooltip(nil)
				CALLBACK_MANAGER:UnregisterCallback("AlchemyInfoReady", QuestInformationUpdated )
			end
		end
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
		},
		[1] = {
			[1] = {
				['func'] = onRootScene,
				['object'] = SMITHING_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[2] = {
				['func'] = onRootScene,
				['object'] = GAMEPAD_SMITHING_ROOT_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[3] = {
				['func'] = onStateChange,
				['object'] = GAMEPAD_SMITHING_CREATION_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[4] = {
				['func'] = onStateChange,
				['object'] = GAMEPAD_SMITHING_REFINE_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[5] = {
				['func'] = onStateChange,
				['object'] = GAMEPAD_SMITHING_DECONSTRUCT_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
		},
		[CRAFTING_TYPE_ALCHEMY] = {
			[1] = {
				['func'] = alchemyStateChanged_KB,
				['object'] = ALCHEMY_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[2] = {
				['func'] = alchemyStateChanged_GP,
				['object'] = GAMEPAD_ALCHEMY_ROOT_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[3] = {
				['func'] = gamePadAlchemyCraft,
				['object'] = GAMEPAD_ALCHEMY_CREATION_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
		},
		[CRAFTING_TYPE_ENCHANTING] = {
			[1] = {
				['func'] = onRootScene,
				['object'] = GAMEPAD_ENCHANTING_MODE_SCENE_ROOT,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[2] = {
				['func'] = onStateChange,
				['object'] = GAMEPAD_ENCHANTING_CREATION_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[3] = {
				['func'] = onRootScene,
				['object'] = ENCHANTING_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
		},
		[CRAFTING_TYPE_PROVISIONING] = {
			[1] = {
				['func'] = onStateChange,
				['object'] = GAMEPAD_PROVISIONER_ROOT_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
			},
			[2] = {
				['func'] = onStateChange,
				['object'] = PROVISIONER_SCENE,
				['name'] = "StateChange",
				['type'] = "callback",
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
					
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
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
		
			local force = true
			if stationWrits then
				for questIndex, writ_Object in pairs(stationWrits) do
					writ_Object:Update(force)
				end
				CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
			elseif self.itemIdToDataMap[itemId] then
				self.itemIdToDataMap[itemId]:Update(force)
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
	local itemCompleted = false
	local function continueToNext(o)
		return itemCompleted and self.savedVars.autoContinue
	end
	
	local function onCraftItemUpdate(bagId, slotId, craftingType)
		-- lets not let this run if crafting furniture
		if self.currentWrit and isInCreationMode(self.currentWrit.writType) then
			zo_callLater(function()
				local currentWrit = self:GetCurrentWrit()
				local o = currentWrit:GetCurrentCondition()
				
				itemCompleted = o:GetCompleted()
				
				if o:HasItemToImproveForWrit() then 
					-- prevent crafting duplicate item
					itemCompleted = true
					if self.savedVars.autoImprove then
						if o.improvementItemData ~= nil then
							o:TryImproveItem(o:GetImprovementItemData())
						end
					end
				end
				
				local itemId = GetItemId(bagId, slotId)
				self.craftedItems[itemId] = true -----------------
				
				if self.bankedList[itemId] then
					-- need to remove crafted item from the list to be withdrawn from bank
					table.remove(self.bankedList, itemId)
					
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
--					if continueToNext(o) then
					if itemCompleted then
						currentWrit:OnCraftingStation()
					elseif o:GetRequiredIterations() > 0 and o.retried ~= true then
		--				d( 'retrying to craft the current item or craft next item')
						o.retried = true
						o:TryToCraft()
					elseif o.retried then
						-- should this ever run, since crafting must have started in order to get here?
	--					d( 'was unable to craft')
						self.isCrafting = false
						o.retried = false
					end
--[[
					--]]
				end
			end, 300)
		end
	end
	CALLBACK_MANAGER:RegisterCallback("IsJustaWritHelper_OnCraftComplete", onCraftItemUpdate)
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
	for craftingType, v in pairs(self.writData) do
		local key = IsSmithingCraftingType(craftingType) and 1 or craftingType
		if key <= 7 then
			registerStationEvents(self.stationEvents[key])
		end
	end
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
	for craftingType, v in pairs(self.writData) do
		local key = IsSmithingCraftingType(craftingType) and 1 or craftingType
		if key <= 7 then
			unregisterStationEvents(self.stationEvents[key])
		end
	end
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
		local itemId = GetItemId(itemData.bagId, itemData.slotIndex)
		local itemLink = self:GetItemLink(itemId)
		local isForCraft = GetItemLinkFlavorText(itemLink):lower():match(GetString(SI_IJAWH_WRITREWARD1):lower()) or
			GetItemLinkFlavorText(itemLink):lower():match(GetString(SI_IJAWH_WRITREWARD2):lower()) or false
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
--			d( itemData.name)
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
	--	WRIT_OpenContainers = true
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
				self:DoUpdateOnce("IJAWH_WRIT_TurnInUpdate", self.savedVars.autoOpenDelay * 1000, startOpeningContainers)
			end

			CompleteQuest()
		end
	end

	local function onChatterEnd()
		self.control:UnregisterForEvent(EVENT_CHATTER_END, onChatterEnd)
		if self.hasNewWrit then
--			self:RefreshQuestList()
			updateQuestList()
			self.hasNewWrit = false
		else
		end
	end

	local function acceptQuest(eventCode)
		self.control:UnregisterForEvent(EVENT_QUEST_OFFERED)
		AcceptOfferedQuest()
	end

	local function autoAccept()
		self.control:RegisterForEvent(EVENT_QUEST_OFFERED, acceptQuest)
		SelectChatterOption(1)
	end

	local chatterOptionString = ''
	local function chatterOptionText(optionText)
		for i=1, 8 do
			chatterOptionString = GetString("SI_IJAWH_CHATTEROPTION", i)
			if optionText:lower():match(GetString("SI_IJAWH_CHATTEROPTION", i):lower()) then
				return true
			end
		end
		return false
	end

	local function chatterOptionTextTurnIn(optionText)
		for i=9, 11 do
			chatterOptionString = GetString("SI_IJAWH_CHATTEROPTION", i)
			if optionText:lower():match(GetString("SI_IJAWH_CHATTEROPTION", i):lower()) then
				return true
			end
		end
		return false
	end

	local function isChatterOptionQuestWrit(optionText, optiontype)
		local isWrit = chatterOptionText(optionText)
		return (optiontype == CHATTER_START_NEW_QUEST_BESTOWAL or
			optiontype == CHATTER_START_TALK or
			optiontype == CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS) and isWrit
	end

	local function isChatterOptionQuestTurnIn(optionText, optiontype)
		local isWrit = chatterOptionTextTurnIn(optionText)
		return (optiontype == CHATTER_START_COMPLETE_QUEST or
			optiontype == CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS)  and isWrit
	end

	local isFromBoard = false
	local function onChatterBegin()
		if GetInteractionType() == INTERACTION_CONVERSATION then
			local greeting = GetChatterGreeting()
			for i=1, GetChatterOptionCount() do
				local optionText, optiontype, optionalArg = GetChatterOption(i)
				-- pick up
				if isChatterOptionQuestWrit(optionText:lower(), optiontype) then
					isFromBoard = true
					self.control:RegisterForEvent(EVENT_CHATTER_END, onChatterEnd)
					if self.savedVars.autoAccept then
						if GetNumJournalQuests() < MAX_JOURNAL_QUESTS then
							autoAccept()
						else
							ZO_Alert(SOUNDS.NEGATIVE_CLICK, GetString(SI_MARKETPURCHASABLERESULT31))
						end
					end
					return
				-- trun in
				elseif isChatterOptionQuestTurnIn(optionText, optiontype) then
					self.control:RegisterForEvent(EVENT_QUEST_COMPLETE_DIALOG, writTurnIn)
					
					SelectChatterOption(i)
					return
				end
			end
		end
	end

	local function onWritAccepted(eventId, questIndex, writName)
		if isFromBoard then
			self.hasNewWrit = true
			isFromBoard = false
			
		-- added to show master writs in the writ panel when the writ is used from inventory
		-- only non-smithing master writs can be made with this addon but all will show in the Writ Panel -- todo
		elseif string.find(writName, GetString(SI_IJAWH_MASTERFUL)) or string.find(writName, GetString(SI_IJAWH_WRIT)) then
	--		self:RefreshQuestList()
			updateQuestList()
		end
	end

	self.control:RegisterForEvent(EVENT_QUEST_ADDED, onWritAccepted)
	self.control:RegisterForEvent(EVENT_CHATTER_BEGIN, onChatterBegin)

    self.control:RegisterForEvent(EVENT_QUEST_ADVANCED, function(eventCode, questIndex, questName, isPushed, isComplete, mainStepChanged)
		-- needed for when a wirt quest is updated from talking. certification quests need this.
		if isFromBoard and mainStepChanged then
			isFromBoard = false
			self:RemoveWritByQuestIndex(questIndex)
			updateQuestList()
		end
	end)
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