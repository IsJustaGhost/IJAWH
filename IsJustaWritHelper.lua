IJAWH = {
	displayName = "BETA: |cFF00FFIsJusta|r WritHelper with Easy Alchemy",
	name = "IsJustaWritHelper",
	version = "4.1.2",
	svVersion = 4.1,
	
    SI_IJAWH_PRIORITY_BY_STOCK = 1,
    SI_IJAWH_PRIORITY_BY_MANUAL = 2,
    SI_IJAWH_PRIORITY_BY_TTC = 3,
	
	writData = {},
	withdrawItems = {},
	PreviousKeybind = {},
	activeEvents = {},
	craftKeybindButtonDescriptor = {},
	savedCraftingAnchor = {},
	Callbacks = {},
	selectedStyle = {},
	
	dialogueQueue = {},
	
	LastChecked = 0,
	
	AlchemyFirstRun = true,
	isAlchemy = false,
	
	writsPanelFunc = {},
	
	DefaultSettings = {
		easyAlchemy = true,
		useMostStyle = true,
		showCraftForWrit = true,
		showWithdrawInChat = true,
		showInBankAlert = true,
		handleWithdraw = true,
		hideWhileMounted = false
	},
	
	WP = {
		isMinimized = false,
		isCollapsed = false,
		isGrouped = false
	},
}
IJAWH.iconList = {
	[1] = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing_up.dds", 	-- CRAFTING_TYPE_BLACKSMITHING
	[2] = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing_up.dds", 		-- CRAFTING_TYPE_CLOTHIER
	[3] = "/esoui/art/inventory/inventory_tabicon_craftbag_enchanting_up.dds", 		-- CRAFTING_TYPE_ENCHANTING
	[4] = "/esoui/art/inventory/inventory_tabicon_craftbag_alchemy_up.dds", 		-- CRAFTING_TYPE_ALCHEMY
	[5] = "/esoui/art/inventory/inventory_tabicon_craftbag_provisioning_up.dds", 	-- CRAFTING_TYPE_PROVISIONING
	[6] = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking_up.dds", 	-- CRAFTING_TYPE_WOODWORKING
	[7] = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting_up.dds" 	-- CRAFTING_TYPE_JEWELRYCRAFTING
}

IJAWH_CurrentWrit = {}
IJAWH_Igdnt_yPos = 0
IJAWH_PANEL_HEIGHT = 60
IJAWH_SET_GAMEPAD_ANCHOR_TYPE = 0

IJAWH_COMPLETED_WRITS = true

IJAWH_WITHDRAW_ITEMS = 0
IJAWH_CALLBACK_TIMER = 0

local onCraftItemUpdate
local OnCraftItem
-------------------------------------
-- Helper Functions
-------------------------------------
local function setCraftPanelAnchors()
	IJAWH.craftTLW:ClearAnchors()
	if IsInGamepadPreferredMode() then
		IJAWH.craftTLW:SetAnchor(TOPLEFT, GuiRoot, nil, 650, 100)
	else
		IJAWH.craftTLW:SetAnchor(TOPLEFT, GuiRoot, nil, 250, 150)
	end
end
IJAWH_CBM = ZO_CallbackObject:Subclass()
local function getTimeElapsed(lastTime)
	local timeStamp = lastTime
	local elapsedTime = GetTimeStamp() - timeStamp
	return elapsedTime
end

local function canCraft()
	if #IJAWH_CurrentWrit.recipeData > 0 then
		if not IJAWH_CurrentWrit.writType == CRAFTING_TYPE_ALCHEMY then
			if IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft then
				return true
			end
		else
			return true
		end
	end
end

local function EntryFactory(pool)
	local name = "CraftEntry" .. pool:GetNextControlId()
	local container = IJAWH.craftTLW:CreateControl(name, CT_CONTROL)
	local conditions = container:CreateControl("$(parent)Conditions", CT_LABEL)
	local ingredients = container:CreateControl("$(parent)Ingredients", CT_LABEL)

	conditions:SetFont("ZoFontWinH3")
	conditions:SetWidth(380)
	conditions:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	ingredients:SetFont("ZoFontWinH3")
	conditions:SetWidth(380)
	ingredients:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
	container.conditions = conditions
	container.ingredients = ingredients
	container:SetAnchor(BOTTOMLEFT, IsJustaWritHelper_CraftPanelDivider, nil, 0, 0)
	return container
end
local function ResetEntry(entry)
	entry:SetHidden(true)
	entry:ClearAnchors()
	entry.conditions:SetText("")
	entry.ingredients:SetText("")
end
IJAWH.writEntry = ZO_ObjectPool:New(EntryFactory, ResetEntry)

local function isWritForStation(station)
	local station = station and station or GetCraftingInteractionType()
	if IJAWH_CurrentWrit then
		if IJAWH_CurrentWrit.recipeData then
			if IJAWH_CurrentWrit.writType == station and #IJAWH_CurrentWrit.recipeData >= 1 then
				return true
			end
		end
	end
	return false
end

local function getAlchemyMode()
	if isWritForStation() and IJAWH_CurrentWrit.qName ~= GetString(SI_IJAWH_EASYALCHEMY) then
		return 1
	elseif IJAWH.savedVariables.easyAlchemy then
		return 2
	else
	return false
	end
end

function IJAWH:UpdateSolvent()
	local solvent
--	d( "IJAWH_CurrentWrit",IJAWH_CurrentWrit.solvent,"IJAWH_CurrentSolvent",IJAWH_CurrentSolvent)
	if IJAWH_CurrentWrit.solvent then
		solvent = IJAWH_CurrentWrit.solvent
	elseif IJAWH_CurrentSolvent then
		solvent = IJAWH_CurrentSolvent
	end
	if solvent then
		if solvent.meetsUsageRequirement then IJAWH:TryAddItemToCraft(solvent) end
		IJAWH:RefreshKeybinds()
	end
end
--	CALLBACK_MANAGER:RegisterCallback("IJAWH_SOLVENT_UPDATED", onSolventUpdated)

-------------------------------------
-- Writ Data Functions
-------------------------------------


local function getWritType(qName)
    for k,v in pairs(IJAWH_WRIT_TYPES) do
		if IJAWH:Contains(qName,v) then
			return k
		end
    end
--	return false
--	return -1
end
local function getWritTypeByInteraction(index, qName)
    for k,v in pairs(IJAWH_WRIT_TYPES_BY_INDEX) do
		if IJAWH:Contains(qName,v) and k == index then
			return k
		end
    end
end
local function isWritAdded(qName)
	for i=1, #IJAWH.writData do
		if IJAWH.writData[i].qName == qName then
			return true
		end
    end
    return false
end
local function addWrit(writType, qName)
--	if not isWritAdded(qName) then
		IJAWH.writData[#IJAWH.writData +1] = {writType = writType, qName = qName, recipeData = {nil}, ingredients = {nil}}
--	end
end
local function setWritIndexFromQuestName(qName)
	for i=1, #IJAWH.writData do
		if IJAWH.writData[i].qName == qName then
			IJAWH_WD_INDEX = i
			return
		end
    end
    return false
end
local function getWritForStation()
	local station = GetCraftingInteractionType()
	for i=1, #IJAWH.writData do
		if IJAWH.writData[i].writType == station and not IJAWH.writData[i].completed then
			return IJAWH.writData[i]
		end
    end
    return false
end
local function getIngredientData(step)
	if IJAWH.writData[IJAWH_WD_INDEX] and IJAWH.writData[IJAWH_WD_INDEX].ingredients[step] then
		local ingredentsTemp = IJAWH.writData[IJAWH_WD_INDEX].ingredients[step]
		return ingredentsTemp.func(ingredentsTemp)
	else
		return false
	end
end
local function getQuestIndex(writName)
	for qIndex=1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(qIndex) then
			if GetJournalQuestType(qIndex) == QUEST_TYPE_CRAFTING then
				local qName,_,qDesc,_,_,qCompleted  = GetJournalQuestInfo(qIndex)
				if string.match(writName, qName) then
					return qIndex
				end
			end
		end
	end
	return -1
end	
-------------------------------------
-- Crafting Functions
-------------------------------------
local function setResultTooltip()
	if IJAWH_CurrentWrit.recipeData then
		local recipeData = IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData]
		local craftingInteractionType = GetCraftingInteractionType()
		
		if craftingInteractionType == CRAFTING_TYPE_PROVISIONING then
			IJAWH:SetProvisioningResultTooltip(recipeData)
		elseif IJAWH:Contains(craftingInteractionType,IJAWH_CRAFTING_TYPE_SMITHING) then
			IJAWH:SetSmithingResultTooltip(recipeData)
		end
	end
end

function IJAWH:GetAllCraftingParametersWithoutIteration(recipeData)
	if recipeData then
		local craftingInteractionType = GetCraftingInteractionType()
		if craftingInteractionType == CRAFTING_TYPE_PROVISIONING then
			return recipeData.recipeListIndex, recipeData.recipeIndex, recipeData.numIterations
		elseif self:Contains(craftingInteractionType,IJAWH_CRAFTING_TYPE_SMITHING) then
			return recipeData.patternIndex,
				recipeData.materialIndex,
				recipeData.materialQuantity,
				IJAWH.savedVariables.useMostStyle and recipeData.styleIndex or self.selectedStyle.itemstyleIndex or GetFirstKnownStyleIndex(),
				recipeData.traitIndex
		end
	end
end
function IJAWH:GetAllCraftingParameters(recipeData)
	if recipeData then
		local craftingInteractionType = GetCraftingInteractionType()
		if craftingInteractionType == CRAFTING_TYPE_PROVISIONING then
			return recipeData.recipeListIndex, recipeData.recipeIndex, recipeData.numIterations
		elseif self:Contains(craftingInteractionType,IJAWH_CRAFTING_TYPE_SMITHING) then
			return recipeData.patternIndex,
				recipeData.materialIndex,
				recipeData.materialQuantity,
				IJAWH.savedVariables.useMostStyle and recipeData.styleIndex or self.selectedStyle.itemstyleIndex or GetFirstKnownStyleIndex(),
				recipeData.traitIndex,
				false,
				recipeData.numIterations
		end
	end
end	

local function checkInventoryForSpace(recipeData)
	if IJAWH:Contains(GetCraftingInteractionType(),IJAWH_CRAFTING_TYPE_SMITHING) then
		if not CheckInventorySpaceSilently(recipeData.numIterations) then
			return false
		end
	else
	local _,remainingInBank = GetItemLinkStacks(recipeData.itemLink)
	local stackCount
		if not recipeData.hasOther and FindFirstEmptySlotInBag(BAG_BACKPACK) == nil or FindFirstEmptySlotInBag(BAG_BACKPACK) == nil and (stackCount + recipeData.maximum) > 200 then
			return false
		end
	end
	return true
end
local function craftWrit()
	local recipeData = IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData]
	if recipeData and recipeData.canCraft then
		local craftingInteractionType = GetCraftingInteractionType()
		if not checkInventoryForSpace(recipeData) then
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_INVENTORY_ERROR_INVENTORY_FULL)
			return
		else
			EVENT_MANAGER:RegisterForEvent("IJAWH_CRAFT_COMPLETED", EVENT_CRAFT_COMPLETED, OnCraftItem)
			CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStopped", onCraftItemUpdate)
			
			if craftingInteractionType == CRAFTING_TYPE_PROVISIONING then
				CraftProvisionerItem(IJAWH:GetAllCraftingParameters(recipeData))
			elseif IJAWH:Contains(craftingInteractionType,IJAWH_CRAFTING_TYPE_SMITHING) then
				recipeData.styleIndex = IJAWH:UpdateSmithingStyleIndex(recipeData.patternIndex)
				CraftSmithingItem(IJAWH:GetAllCraftingParameters(recipeData))
			elseif craftingInteractionType == CRAFTING_TYPE_ALCHEMY then
				IJAWH_CurrentWrit.recipeData = {}
				if  IsInGamepadPreferredMode() then
					GAMEPAD_ALCHEMY:Create(ALCHEMY_Iterations)
				else
					ALCHEMY:Create(ALCHEMY_Iterations)
				end
			elseif craftingInteractionType == CRAFTING_TYPE_ENCHANTING then
				IJAWH:addRunesToCraft(IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].runeData)
				if  IsInGamepadPreferredMode() then
					GAMEPAD_ENCHANTING:Create(1)
				else
					ENCHANTING:Create(1)
				end
			end
		end
	else
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString(SI_TRADESKILLRESULT132))
	end
end

local function craftButtonEnabeled()
	if not IJAWH_CurrentWrit.recipeData[1] then
		return false
	elseif IJAWH_CurrentWrit.writType == CRAFTING_TYPE_ALCHEMY then
		return not ZO_CraftingUtils_IsPerformingCraftProcess() and IJAWH_CurrentWrit.recipeData[1].canCraft
	else
		return not ZO_CraftingUtils_IsPerformingCraftProcess() and IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft
	end
end
local function changeCraftKeybind()
	if not IJAWH.savedVariables.showCraftForWrit then return end
	if not IJAWH_CurrentWrit.recipeData then return end
	local button = nil
	if(button) then return end
	local button = KEYBIND_STRIP.keybinds["UI_SHORTCUT_SECONDARY"]
	IJAWH.craftKeybindButtonDescriptor = button.keybindButtonDescriptor
	if not IJAWH.PreviousKeybind.oldName then
		IJAWH.PreviousKeybind.oldName = IJAWH.craftKeybindButtonDescriptor.name
		IJAWH.PreviousKeybind.oldCallback = IJAWH.craftKeybindButtonDescriptor.callback
		IJAWH.PreviousKeybind.oldEnabled = IJAWH.craftKeybindButtonDescriptor.enabled
		IJAWH.craftKeybindButtonDescriptor.name = GetString(SI_IJAWH_CRAFT_WRIT)
		IJAWH.craftKeybindButtonDescriptor.callback = craftWrit
		IJAWH.craftKeybindButtonDescriptor.enabled = craftButtonEnabeled
	end
	KEYBIND_STRIP:UpdateKeybindButton(IJAWH.craftKeybindButtonDescriptor)
	if not IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_CRAFT_FOR_WRIT then
		IJAWH:DialogueQueue("IJAWH_TUTORIAL_CRAFT_FOR_WRIT")
	end
end
local function restoreCraftKeybind()
	if IJAWH.PreviousKeybind.oldName then
		IJAWH.craftKeybindButtonDescriptor.name = IJAWH.PreviousKeybind.oldName
		IJAWH.craftKeybindButtonDescriptor.callback = IJAWH.PreviousKeybind.oldCallback
		IJAWH.craftKeybindButtonDescriptor.enabled = IJAWH.PreviousKeybind.oldEnabled
		KEYBIND_STRIP:UpdateKeybindButton(IJAWH.craftKeybindButtonDescriptor)
		IJAWH.PreviousKeybind = {}
		IJAWH.craftKeybindButtonDescriptor = {}
	end
end

-------------------------------------
-- Callbacks and Hooks
-------------------------------------

local IJAWH_SMITHING_oldMode, IJAWH_ENCHANTING_oldMode
do -- hooks
	ZO_PostHook(ZO_Provisioner, "RefreshRecipeDetails", function(self)
		if isWritForStation() and not ZO_CraftingUtils_IsPerformingCraftProcess() and IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft then setResultTooltip() end
	end)
	ZO_PostHook(ZO_GamepadProvisioner, "GetRecipeData", function(self)
		if isWritForStation() and not ZO_CraftingUtils_IsPerformingCraftProcess() and IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft then setResultTooltip() end
	end)
	ZO_PostHook(ZO_Provisioner, "OnTabFilterChanged", function(self, filterData)
		if isWritForStation() and not ZO_CraftingUtils_IsPerformingCraftProcess() and IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft then 
			if self.filterType ~= PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING then
				changeCraftKeybind()
			else
				restoreCraftKeybind()
			end
		end
	end)
	ZO_PostHook(ZO_GamepadProvisioner, "OnTabFilterChanged", function(self, filterType)
		if isWritForStation() and not ZO_CraftingUtils_IsPerformingCraftProcess() and IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft then 
			if filterType ~= PROVISIONER_SPECIAL_INGREDIENT_TYPE_FURNISHING then
				changeCraftKeybind()
			else
				restoreCraftKeybind()
			end
		end
	end)
	
	ZO_PostHook(ZO_GamepadSmithingCreation, "OnStyleChanged", function(self, selectedData)
		if isWritForStation() and not ZO_CraftingUtils_IsPerformingCraftProcess() then
			IJAWH.selectedStyle = {localizedName = selectedData.localizedName, itemstyleIndex = selectedData.itemStyleId}
		end
	end)
	ZO_PostHook(ZO_SmithingCreation, "OnStyleChanged", function(self, selectedData)
		if isWritForStation() and not ZO_CraftingUtils_IsPerformingCraftProcess() then
			IJAWH.selectedStyle = {localizedName = selectedData.localizedName, itemstyleIndex = selectedData.itemStyleId}
		end
	end)
	
	ZO_PostHook(ZO_Smithing, "SetMode", function(self)
		if isWritForStation() then
			if self.mode ~= IJAWH_SMITHING_oldMode and self.mode ~= SMITHING_MODE_RECIPES then
				if self.mode == SMITHING_MODE_CREATION then
					changeCraftKeybind()
					
				else
					restoreCraftKeybind()
				end
				IJAWH_SMITHING_oldMode = self.mode
			end
			
		end
	end)
	
	ZO_PostHook(ZO_EnchantingInventory, "ChangeMode", function(self, enchantingMode)
		if isWritForStation() then
			if enchantingMode ~= IJAWH_ENCHANTING_oldMode then
				if enchantingMode == ENCHANTING_MODE_CREATION then
					changeCraftKeybind()
				else
					restoreCraftKeybind()
				end
				IJAWH_ENCHANTING_oldMode = enchantingMode
			end
		end
	end)
end


local function setUpCallbacks()
	local IJAWH_SMITHING_SCENE = SCENE_MANAGER:GetScene("smithing")
	IJAWH_SMITHING_SCENE:RegisterCallback("StateChange", function(oldState, newState)
	
		local craftingType = GetCraftingInteractionType()
		local isCraftingTypeDifferent = not SMITHING.interactingWithSameStation
		SMITHING.creationPanel:SetCraftingType(craftingType, SMITHING.oldCraftingType, isCraftingTypeDifferent)
		
		if isWritForStation() then
--			if newState == SCENE_SHOWN and IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].enableCraftButton then
			if newState == SCENE_SHOWN then
				ZO_MenuBar_SelectDescriptor(SMITHING.modeBar, SMITHING_MODE_CREATION)
			elseif newState == SCENE_HIDDEN then
			end
		end
	end)
	
	local IJAWH_GAMEPAD_SMITHING_CREATION_SCENE = SCENE_MANAGER:GetScene("gamepad_smithing_creation")
	IJAWH_GAMEPAD_SMITHING_CREATION_SCENE:RegisterCallback("StateChange", function(oldState, newState)
	
		local craftingType = GetCraftingInteractionType()
		local isCraftingTypeDifferent = craftingType ~= SMITHING_GAMEPAD.oldCraftingType and true
		SMITHING_GAMEPAD.creationPanel:SetCraftingType(craftingType, SMITHING_GAMEPAD.oldCraftingType, isCraftingTypeDifferent)
		
		if isWritForStation() then
--			if newState == SCENE_SHOWN  and IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].enableCraftButton then
			if newState == SCENE_HOWING then
			elseif newState == SCENE_SHOWN and SMITHING_GAMEPAD.mode ~= SMITHING_MODE_RECIPES then
				changeCraftKeybind()
			elseif newState == SCENE_HIDDEN then
				restoreCraftKeybind()
			end
		end
	end)
	
	local IJAWH_GAMEPAD_ALCHEMY_CREATION_SCENE = SCENE_MANAGER:GetScene("gamepad_alchemy_creation")
	IJAWH_GAMEPAD_ALCHEMY_CREATION_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		local alchemyMode = getAlchemyMode()
		if alchemyMode then
			if newState == SCENE_SHOWING then
				if alchemyMode == 1 then
					changeCraftKeybind()
					IJAWH:EnableReagentPanel(true)
					IJAWH:showCraftPannel()
				elseif alchemyMode == 2 then
					IsJustaEasyAlchemy:OnAlchemyStation()
					IJAWH:EnableReagentPanel(true)
					IsJustaEasyAlchemy.AlchemyTLW:SetHidden(false)
				else
					return
				end
				IJAWH_PANEL_HEIGHT = 170
				IJAWH.craftPanel:SetHeight(IJAWH_PANEL_HEIGHT)
				IJAWH:UpdateSolvent()
				IJAWH:RefreshKeybinds()
				IJAWH.craftTLW:SetHidden(false)
			elseif newState == SCENE_HIDDEN then
				restoreCraftKeybind()
				IJAWH:EnableReagentPanel(false)
				IJAWH.craftTLW:SetHeight(IJAWH_LAST_PANEL_HEIGHT)
				if IJAWH.savedVariables.easyAlchemy then IsJustaEasyAlchemy.AlchemyTLW:SetHidden(true) end
			end
		end
	end)
	local IJAWH_ALCHEMY_CREATION_SCENE = SCENE_MANAGER:GetScene("alchemy")
	IJAWH_ALCHEMY_CREATION_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		local alchemyMode = getAlchemyMode()
		if alchemyMode then
			if newState == SCENE_SHOWN then
				if alchemyMode == 1 then
					changeCraftKeybind()
					IJAWH:EnableReagentPanel(true)
					IJAWH:showCraftPannel()
				elseif alchemyMode == 2 then
					IsJustaEasyAlchemy:OnAlchemyStation()
					IJAWH:EnableReagentPanel(true)
					IsJustaEasyAlchemy.AlchemyTLW:SetHidden(false)
				else
					return
				end
				IJAWH_PANEL_HEIGHT = 175
				IJAWH.craftPanel:SetHeight(IJAWH_PANEL_HEIGHT)
				IJAWH:UpdateSolvent()
				IJAWH:RefreshKeybinds()
				IJAWH.craftTLW:SetHidden(false)
			elseif newState == SCENE_HIDDEN then
				restoreCraftKeybind()
				IJAWH:EnableReagentPanel(false)
				if IJAWH.savedVariables.easyAlchemy then IsJustaEasyAlchemy.AlchemyTLW:SetHidden(true) end
			end
		end
	end)

	local IJAWH_GAMEPAD_ENCHANTING_CREATION_SCENE = SCENE_MANAGER:GetScene("gamepad_enchanting_creation")
    IJAWH_GAMEPAD_ENCHANTING_CREATION_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if not isWritForStation() then return end
        if newState == SCENE_SHOWING then
			IJAWH:addRunesToCraft(IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].runeData)
        elseif newState == SCENE_SHOWN then
			changeCraftKeybind()
        elseif newState == SCENE_HIDDEN then
			restoreCraftKeybind()
			KEYBIND_STRIP:UpdateKeybindButtonGroup(GAMEPAD_ENCHANTING.keybindEnchantingStripDescriptor)
        end
    end)
	local IJAWH_ENCHANTING_SCENE = SCENE_MANAGER:GetScene("enchanting")
    IJAWH_ENCHANTING_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if not isWritForStation() then return end
        if newState == SCENE_SHOWING then
			IJAWH:addRunesToCraft(IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].runeData)
--			KEYBIND_STRIP:UpdateKeybindButtonGroup(ENCHANTING.keybindStripDescriptor)
		elseif newState == SCENE_SHOWN then
			changeCraftKeybind()
        elseif newState == SCENE_HIDDEN then
        end
    end)
	
-- not currently used
	local IJAWH_GAMEPAD_PROVISIONER_ROOT_SCENE = SCENE_MANAGER:GetScene("gamepad_provisioner_root")
    IJAWH_GAMEPAD_PROVISIONER_ROOT_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if not isWritForStation(CRAFTING_TYPE_PROVISIONING) then return end
        if newState == SCENE_SHOWN then
			changeCraftKeybind()
        elseif newState == SCENE_HIDDEN then
        end
    end)
	local IJAWH_PROVISIONER_SCENE = SCENE_MANAGER:GetScene("provisioner")
	IJAWH_PROVISIONER_SCENE:RegisterCallback("StateChange", function(oldState, newState)
		if not isWritForStation() then return end
        if newState == SCENE_SHOWN and SMITHING_GAMEPAD.mode ~= SMITHING_MODE_RECIPES then
			changeCraftKeybind()
        elseif newState == SCENE_HIDDEN then
        end
    end)
end


-------------------------------------
-- Writ panel
-------------------------------------
local WRIT_SORT_KEYS ={
	completed = { tiebreaker = "inBank", reverseTiebreakerSortOrder = ZO_SORT_ORDER_UP },
	inBank = { tiebreaker = "qName", tieBreakerSortOrder = ZO_SORT_ORDER_UP },
	qName = { },
	canCraft = {},
}
local function writSortFunc(data1, data2)
	return ZO_TableOrderingFunction(data1, data2, "completed", WRIT_SORT_KEYS, ZO_SORT_ORDER_UP) 
end
function IJAWH:SetHeaderColor(control, action)
	local r, g, b, a = control:GetColor()
	local enter = {r = r and r / 0.8 or 0, g = g and g / 0.8 or 0, b = b and b / 0.8 or 0}
	local down = {r = r and r * 0.8 or 0, g = g and g * 0.8 or 0, b = b and b * 0.8 or 0}
	
	control:SetColor(enter.r, enter.g, enter.b, 1)
	
	control:SetHandler("OnMouseExit", function()
		control:SetColor(r, g, b, 1)
	end)
	control:SetHandler("OnMouseDown", function()
		control:SetColor(down.r, down.g, down.b, 1)
	end)
end

local function updateWritsPanel(...)
	IJAWH.writsPanel.writList:ReleaseAllObjects()

	local function getWritDetails()
		local function isBanked(qName)
		if not IJAWH.withdrawItems then return end
			for k,v in pairs(IJAWH.withdrawItems) do
				if string.match(v.qName, qName) then
					return true
				end
			end
		end
		
		local function getWritStatus(qIndex, index)
			local tot, comp, conText = 0, 0, ''
			for lineId = 1, GetJournalQuestNumConditions(qIndex,1) do
				local condition,current,maximum,_,complete = GetJournalQuestConditionInfo(qIndex,1,lineId)
				if condition ~= '' then
					if string.find(condition, GetString(SI_IJAWH_DELIVER)) then
						conText = condition
						IJAWH_WRITLIST[index].completed = true
					else
						tot = tot +1
						--- get number of conditions
						if current == maximum then
							comp = comp + 1
						end
						conText = conText .. condition .. "\n"
					end
				end
			end
			conText = string.gsub(conText, "\n$", "")
			IJAWH_WRITLIST[index].toolTip = conText
			IJAWH_WRITLIST[index].status = comp .. "/" .. tot
							if isBanked(IJAWH_WRITLIST[index].qName) then IJAWH_WRITLIST[index].inBank = true end
		end
		
		for i=1, #IJAWH_WRITLIST do
			getWritStatus(IJAWH_WRITLIST[i].qIndex, i)
		end	
	end
		
	getWritDetails()	
--	table.sort(IJAWH_WRITLIST,function(a,b) return a.qName < b.qName end)
--	table.sort(IJAWH_WRITLIST,function(a,b) return a.qName:len() < b.qName:len() end)
	table.sort(IJAWH_WRITLIST, writSortFunc)
	
	local completed, yPos = 0, 0
	for i=1, #IJAWH_WRITLIST do
		local writEntry = IJAWH.writsPanel.writList:AcquireObject(i)
--		writEntry:SetHidden(false)

		local writColor
		local qName = IJAWH_WRITLIST[i].qName
		
		if IJAWH_WRITLIST[i].completed then
			completed = completed + 1
			writColor = "00cc00"
		else
			writColor = "CCCCCC"
			writEntry.status:SetText(zo_strformat("|c<<1>><<2>>|r",writColor,IJAWH_WRITLIST[i].status))
		end
		yPos = 28 * i

		writEntry.writ:SetText(zo_strformat(GetString(SI_IJAWH_WRIT_NAME), writColor, qName))
		writEntry.writ:SetAnchor(CENTER, IsJustaWritHelper_WritsPanelContainerDivider, nil, 0, yPos)
		writEntry.toolTip:SetAnchor(CENTER, IsJustaWritHelper_WritsPanelContainerDivider, nil, 0, yPos)
		
		writEntry.status:SetAnchor(RIGHT, IsJustaWritHelper_WritsPanelContainerDivider, RIGHT, 0, yPos)

		writEntry.setToolTip(IJAWH_WRITLIST[i].toolTip)
		
		if IJAWH_WRITLIST[i].inBank then
			writEntry.icon:SetHidden(false)
			writEntry.icon:SetAnchor(LEFT, IsJustaWritHelper_WritsPanelContainerDivider, nil, 0, yPos)
			writEntry.iconToolTip:SetHidden(false)
			writEntry.iconToolTip:SetAnchor(LEFT, IsJustaWritHelper_WritsPanelContainerDivider, nil, 0, yPos)
		else
			writEntry.icon:SetHidden(true)
		end
	end
	
	IJAWH_WRITPANEL_ADJUSTED_HEIGHT = yPos + 25
	
	local headerColor
	if completed == #IJAWH_WRITLIST then
		headerColor = "00FF00"
		IJAWH.writsPanel.header:SetColor(0, 0.8, 0, 1)
	else
		headerColor = "CCCCCC"
		IJAWH.writsPanel.header:SetColor(0.8, 0.8, 0.8, 1)
	end
	local totalWrits = #IJAWH_WRITLIST
--	local header = zo_strformat(GetString(SI_IJAWH_TOTAL_WRITS), headerColor, completed, totalWrits)
	local header = zo_strformat(GetString(SI_IJAWH_TOTAL_WRITS), completed, totalWrits)
	
	IJAWH_WRITPANEL_ADJUSTED_HEIGHT = IJAWH_WRITPANEL_ADJUSTED_HEIGHT + IJAWH_WRITPANEL_ORIGINAL_HEIGHT
	
	local panelHeight
	if IJAWH_WRITPANEL_LIST_IsHidden then
		panelHeight = IJAWH_WRITPANEL_ORIGINAL_HEIGHT
	else
		IJAWH:wpMinMax(false)
		panelHeight = IJAWH_WRITPANEL_ADJUSTED_HEIGHT
	end
	IJAWH.writsPanel.header:SetText(header)
	IJAWH.writsPanel.container:SetHeight(panelHeight)
	
	if completed == #IJAWH_WRITLIST and #IJAWH_WRITLIST > 0 then
		-- minimize or hide list when all lists are completed
		local oldState = IJAWH.writsPanel.listContainer:IsHidden()
		IJAWH:wpMinMax(true)
		IJAWH_WRITPANEL_LIST_IsHidden = oldState
	elseif not IJAWH_WRITPANEL_LIST_IsHidden then
		IJAWH:wpMinMax(false)
	end
end

CALLBACK_MANAGER:RegisterCallback("IJAWH_Update_Writs_Panel", function() zo_callLater(updateWritsPanel, 500) end)

local function shouldShowPanel()
	local shouldShow = true
	if #IJAWH_WRITLIST < 1 				then shouldShow = false end		--	works
	if IsUnitInCombat("player") 		then shouldShow = false end		--	works
	if IsUnitInDungeon("player") 		then shouldShow = false end		--	works
	if IsUnitActivelyEngaged("player") 	then shouldShow = false end
	if IsUnitPvPFlagged("player") 		then shouldShow = false end		--	works
--	if GetGroupSize() > 4 				then shouldShow = false end		--	works
	
	if IJAWH.savedVariables.hideWhileMounted and IsMounted() then shouldShow = false end
	return shouldShow
end
local function writsPanelControl()
	if IsUnitGrouped("player") then
		if not IJAWH.groupCheck then
			IJAWH.groupCheck = true
			IJAWH.writsPanelFunc:MoveRight()
		end
		local currentGroupSize = GetGroupSize()
		if currentGroupSize > 4 then
			IJAWH:wpMinMax(true)
		end
	else
		if IJAWH.groupCheck then
			IJAWH.groupCheck = false
			IJAWH.writsPanelFunc:MoveLeft()
		end
	end
	
	if shouldShowPanel() then
		IsJustaWritHelper_WritsPanel:SetHidden(false)
		updateWritsPanel("writsPanelControl")
	else
		IsJustaWritHelper_WritsPanel:SetHidden(true)
	end
end

-------------------------------------
-- 
-------------------------------------
function IJAWH:setStationForWrit()
-------------------	PROVISIONING
	if IJAWH_CurrentWrit.writType == CRAFTING_TYPE_PROVISIONING then
			EVENT_MANAGER:RegisterForUpdate("IJAWH_setResultTooltip", 100, setResultTooltip)
		return
	end
------------------- ALCHEMY
	if IJAWH_CurrentWrit.writType == CRAFTING_TYPE_ALCHEMY then
		IJAWH:AddKeybinds()
		if IJAWH_CurrentWrit.recipeData then
			IJAWH.recipeList:Clear()
			for i=1, #IJAWH_CurrentWrit.recipeData do
				IJAWH.recipeList:AddEntry(IJAWH_CurrentWrit.recipeData[i])
			end
			IJAWH.recipeList:Commit()
		end
		
		if not IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_ALCHEMYWRIT and GetCraftingInteractionType() == CRAFTING_TYPE_ALCHEMY then
			IJAWH:DialogueQueue("IJAWH_TUTORIAL_ALCHEMYWRIT")
		end
		return
	end
-------------------	ENCHANTING
	if IJAWH_CurrentWrit.writType == CRAFTING_TYPE_ENCHANTING then
		IJAWH:addRunesToCraft(IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].runeData)
		return
	end
-------------------	SMITHING
	if IJAWH:Contains(GetCraftingInteractionType(),IJAWH_CRAFTING_TYPE_SMITHING) then
		EVENT_MANAGER:RegisterForUpdate("IJAWH_setResultTooltip", 100, setResultTooltip)
		if not IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_STYLEMATERIALS then
			IJAWH:DialogueQueue("IJAWH_TUTORIAL_STYLEMATERIALS")
		end
		return
	end
end

local function buildWritData(qIndex, qName, currentWritType)
	local withdrawText = {}
	if currentWritType == CRAFTING_TYPE_PROVISIONING then
		withdrawText = IJAWH:ParseProvisioningQuest(qName, qIndex, lineId)
	elseif currentWritType == CRAFTING_TYPE_ALCHEMY then
		withdrawText = IJAWH:ParseAlchemyQuest(qName, qIndex, lineId)
	elseif currentWritType == CRAFTING_TYPE_ENCHANTING then
		withdrawText = IJAWH:ParseEnchantingQuest(qName, qIndex, lineId)
	elseif IJAWH:Contains(currentWritType,IJAWH_CRAFTING_TYPE_SMITHING) then
		IJAWH:ParseSmithingQuest(qName, qIndex, lineId)
	end
	if #withdrawText > 0 then
		IJAWH.writData[IJAWH_WD_INDEX].WithdrawText = withdrawText
	end
--	if #IJAWH.writData[IJAWH_WD_INDEX].recipeData < 1 then table.remove(IJAWH.writData, IJAWH_WD_INDEX) end
end

local function updateWritForStation()
	local qName = IJAWH_CurrentWrit.qName
	local qIndex = getQuestIndex(qName)

	setWritIndexFromQuestName(qName)
	buildWritData(qIndex, qName, GetCraftingInteractionType())
end

local function getWritsFromJournal()
--	GAMEPAD_ALCHEMY_CREATION_SCENE:UnregisterCallback("StateChange", onAlchemyStateChangedCallback)
	local isCraftingQuest = false
	local GetCraftingInteractionType = GetCraftingInteractionType()
	IJAWH_WRITLIST = {}
	for qIndex=1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(qIndex) then
			isCraftingQuest = true
			if GetJournalQuestType(qIndex) == QUEST_TYPE_CRAFTING then
				local qName,_,qDesc,_,_,qCompleted  = GetJournalQuestInfo(qIndex)
			-- set writ entries for the Writ Panel
				if qName ~= "" then
					IJAWH_WRITLIST[#IJAWH_WRITLIST + 1] = {qName = qName, qIndex = qIndex, completed = false, inBank = false, toolTip = '', status = ''}
				end
			-- build initial writ list
				if not isWritAdded(qName) then
					local currentWritType = IJAWH_CONSUMABEL_WRIT[qName] or getWritTypeByInteraction(GetCraftingInteractionType, qName) or -1
					if currentWritType > 0 then
						addWrit(currentWritType, qName)
						setWritIndexFromQuestName(qName)
						buildWritData(qIndex, qName, currentWritType)
					end
				end
			end
		end
	end
	
	if isCraftingQuest then
		local elapsedTime = getTimeElapsed(IJAWH.LastChecked)
		if #IJAWH.withdrawItems > 0 and elapsedTime > 600 then
			if IJAWH.savedVariables.showWithdrawInChat then d(zo_strformat(SI_IJAWH_IN_WTHDRAW_LIST)) end
			IJAWH.LastChecked = elapsedTime
		end
	end
end

-------------------------------------
-- Craft panel
-------------------------------------
local function updateWritText(qName)
	local qIndex = getQuestIndex(qName)
	local writText = {}
	local step = 0
	for lineId = 1, GetJournalQuestNumConditions(qIndex,1) do
		local ingredLists = nil
		local condition,current,maximum,_,complete = GetJournalQuestConditionInfo(qIndex,1,lineId)
		convertedCondition = IJAWH:ConvertedCondition(condition)

		if condition ~= '' then
			local itemLink, conditionString
			local colour
			if IJAWH:Contains(condition, IJAWH:AcquireConditions()) then
				if current == maximum then
					colour = "00FF00"
				else
					colour = "CCCCCC"
				end
			elseif IJAWH:Contains(condition, IJAWH:CraftingConditions()) then
				if current == maximum then
					colour = "00FF00"
				else
					colour = "CCCCCC"
					step = step + 1
					if not IJAWH_CurrentWrit.recipeData[step] then break end
					itemLink = IJAWH_CurrentWrit.recipeData[step].itemLink:gsub("%|H1", "|H0")
					ingredLists, yPos = getIngredientData(step)
				end
			else
				colour = "00FF00"
			end
			
			if itemLink then
				conditionString = zo_strformat(convertedCondition,colour,itemLink)
			else
				conditionString = zo_strformat("|c<<1>><<2>>|r",colour,condition)
			end
			
			if ingredLists ~= nil then
				writText[#writText+1] = {condition = conditionString, ingredients = ingredLists, yPos = yPos}
			else
				writText[#writText+1] = {condition = conditionString}
			end
		end
	end
	return writText
end
local function setConditionText(entry, text)
	entry.conditions:SetText(zo_strformat("<<1>>",text))
	entry.conditions:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	entry.conditions:SetAnchor(TOPLEFT, IsJustaWritHelper_CraftPanelDivider, TOPLEFT, 0, IJAWH_yPos)
	
	IsJustaWritHelper_CraftPanelConditions:SetText(zo_strformat("<<1>>",text))
	local origHeight = IsJustaWritHelper_CraftPanelConditions:GetTextHeight(IsJustaWritHelper_CraftPanelConditions:GetText())
	local newHeight = entry.conditions:GetTextHeight(entry.conditions:GetText())
	
	if newHeight > origHeight then
		IJAWH_yPos = IJAWH_yPos + 30
	end
end
local function setIngredientText(entry, text, yPos)
	IJAWH_yPos = IJAWH_yPos + 25
	entry.ingredients:SetText(zo_strformat("<<1>>",text))
	entry.ingredients:SetAnchor(TOP, IsJustaWritHelper_CraftPanelDivider, TOP, 0, IJAWH_yPos)
	IJAWH_yPos = IJAWH_yPos + yPos - 25
end
function IJAWH:showCraftPannel(condition)
	IJAWH_yPos = 20
	IJAWH_Igdnt_yPos = 0
	IJAWH_PANEL_HEIGHT = 70
	
	local writText, header = {}, ""
	if condition then	-- for Easy Alchemy
		local ingredients, yPos = getIngredientData(1)
		writText = {[1] = {condition = condition, ingredients = ingredients, yPos = yPos}}
		header = GetString(SI_IJAWH_EASYALCHEMY)
		IJAWH_PANEL_HEIGHT = IJAWH_PANEL_HEIGHT + 20
	else
		writText = updateWritText(IJAWH_CurrentWrit.qName)
		header = IJAWH_CurrentWrit.qName
	end
	
	if #writText > 0 then
		-- move Acquire line to top so the condition with ingredients will be at the bottom
		if string.find(writText[#writText].condition, GetString(IJAWH_ACQUIRE_STRING)) then table.sort(writText,  function(a,b) return a.condition < b.condition end) end
		for i=1, #writText do
			local conditionText = writText[i].condition or ""
			local ingredientText = writText[i].ingredients or nil
			
			local entry, key = IJAWH.writEntry:AcquireObject(i)
			entry:ClearAnchors()
			
			setConditionText(entry, conditionText)
			
			if ingredientText then setIngredientText(entry, ingredientText, writText[i].yPos) end
			IJAWH_yPos = IJAWH_yPos + 30
			entry:SetHidden(false)
		end
		IJAWH.craftPanel.icon:SetTexture(IJAWH.iconList[GetCraftingInteractionType()])
		IJAWH.craftPanel.header:SetText(zo_strformat("<<1>>",header))
		
		if not IJAWH.craftPanel.listControl:IsHidden() then
			IJAWH_LAST_PANEL_HEIGHT = IJAWH_PANEL_HEIGHT + IJAWH_yPos
			IJAWH.craftPanel.listControl:ClearAnchors()
			IJAWH.craftPanel.listControl:SetAnchor(TOP, IsJustaWritHelper_CraftPanelDivider, TOP, -5, IJAWH_yPos - 20)
			
			if IsInGamepadPreferredMode() then
				IJAWH_yPos = IJAWH_yPos + 80
			else
				IJAWH_yPos = IJAWH_yPos + 85
			end
		end
		
		if IJAWH_CurrentWrit.WithdrawText then
			IsJustaWritHelper_CraftPanelWithdrawDivider:ClearAnchors()
			IJAWH_yPos = IJAWH_yPos + 10
			IsJustaWritHelper_CraftPanelWithdrawDivider:SetAnchor(TOP, IsJustaWritHelper_CraftPanelDivider, TOP, 0, IJAWH_yPos)
			IsJustaWritHelper_CraftPanelWithdrawDivider:SetHidden(false)
			IJAWH_yPos = IJAWH_yPos + 15
			IJAWH.craftPanel.bankNotice:ClearAnchors()
			IJAWH.craftPanel.bankNotice:SetAnchor(TOP, IsJustaWritHelper_CraftPanelDivider, TOP, 0, IJAWH_yPos)
			
			IJAWH_yPos = IJAWH_yPos + 25
			local BankNoticeHeight = 25
			local WithdrawText = zo_strformat(SI_IJAWH_WITHDRAW_FROM_BANK, "E6E93C")
			for i=1, #IJAWH_CurrentWrit.WithdrawText do
				IJAWH_yPos = IJAWH_yPos + 30
				BankNoticeHeight = BankNoticeHeight + 30
				WithdrawText = WithdrawText .. "\n" .. IJAWH_CurrentWrit.WithdrawText[i]
			end
			IJAWH.craftPanel.bankNotice:SetHeight(BankNoticeHeight)
			IJAWH.craftPanel.bankNotice:SetText(WithdrawText)
			IJAWH.craftPanel.bankNotice:SetHidden(false)
		else
			IJAWH.craftPanel.bankNotice:SetHidden(true)
		end
		
		IJAWH_yPos = IJAWH_yPos + 10
		IJAWH_PANEL_HEIGHT = IJAWH_PANEL_HEIGHT + IJAWH_yPos
		IJAWH.craftTLW:SetHeight(IJAWH_PANEL_HEIGHT)
		
	elseif #writText > 0 and not canCraft() then
		table.remove(IJAWH.writData, IJAWH_WD_INDEX)
		IJAWH:refreshWritData()
	else
		IJAWH.craftTLW:SetHidden(true)
	end
end

local function cleanUp()
	EVENT_MANAGER:UnregisterForUpdate("IJAWH_setResultTooltip")
	IJAWH.craftPanel.bankNotice:SetText("")
	IJAWH:EnableReagentPanel(false)
	IsJustaWritHelper_CraftPanelWithdrawDivider:SetHidden(true)
	IJAWH_SMITHING_oldMode = 0
	EVENT_MANAGER:UnregisterForUpdate("IJAWH_setResultTooltip", 100, setResultTooltip)

	IJAWH.writEntry:ReleaseAllObjects()
end
local function hideWritPannel()
	if IJAWH.savedVariables.easyAlchemy then IsJustaEasyAlchemy.AlchemyTLW:SetHidden(true) end
	IJAWH.craftTLW:SetHidden(true)
end

-------------------------------------
--
-------------------------------------
local function sortWritByCraftable()
	table.sort(IJAWH_CurrentWrit.recipeData, function(data1,data2)
		return ZO_TableOrderingFunction(data1, data2, "canCraft", WRIT_SORT_KEYS, ZO_SORT_ORDER_UP)
	end)
end
local function OnCraftStation(eventCode, craftingType, sameStation)
	if eventCode ~= 0 then -- 0 is an invalid code
		if IJAWH:Contains(craftingType,IJAWH_CRAFTING_TYPE_SMITHING) then
			getWritsFromJournal()
		end
		
		if #IJAWH.writData > 0 then
			setCraftPanelAnchors()
			IJAWH_CurrentWrit = getWritForStation()
			if IJAWH_CurrentWrit then 
				updateWritForStation()
				if IJAWH_CurrentWrit.recipeData and #IJAWH_CurrentWrit.recipeData > 0 then
					if IJAWH_CurrentWrit.writType ~= CRAFTING_TYPE_ALCHEMY then
						sortWritByCraftable()
					end
					IJAWH:EnableReagentPanel(false)
					IJAWH:SetGamepadAnchors()
					setWritIndexFromQuestName(IJAWH_CurrentWrit.qName)
					if IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft or IJAWH_CurrentWrit.writType == CRAFTING_TYPE_ALCHEMY then IJAWH:setStationForWrit() end
					IJAWH.craftTLW:SetHidden(false)
					IJAWH:showCraftPannel()
					return
				end
			end
		end
	end
	
	if GetCraftingInteractionType() == CRAFTING_TYPE_ALCHEMY and IJAWH.savedVariables.easyAlchemy then
	-- if is alchemy but no alchemy writ then do easy alchemy
		if not isWritAdded(GetString(SI_IJAWH_EASYALCHEMY)) then addWrit(CRAFTING_TYPE_ALCHEMY, GetString(SI_IJAWH_EASYALCHEMY)) end
		IJAWH_CurrentWrit = {writType = CRAFTING_TYPE_ALCHEMY, qName = GetString(SI_IJAWH_EASYALCHEMY), recipeData = {}}
		setWritIndexFromQuestName(GetString(SI_IJAWH_EASYALCHEMY))
		IsJustaEasyAlchemy.isEasyAlchemy = true
			setCraftPanelAnchors()
		if IsInGamepadPreferredMode() then IJAWH:SetGamepadAnchors(CRAFTING_TYPE_ALCHEMY) end
	end
end
local function OnCloseCraftStation(eventCode)
	if eventCode ~= 0 then
		IJAWH.craftTLW:ClearAnchors()
		
		cleanUp()
--		IJAWH.activeEvents = {}
		IJAWH.CraftingData = {}
		IJAWH_CurrentWrit = {}
		hideWritPannel()
		IJAWH:RemoveKeybinds()
		IJAWH.craftPanel.header:SetText(GetString(SI_IJAWH_EASYALCHEMY))
		IsJustaEasyAlchemy:OnCloseAlchemyStation()
		
		if IsInGamepadPreferredMode() then -- restore gamepad recipe result and ingredient boxes positions
			ZO_GamepadAlchemyTopLevelSlotContainer:ClearAnchors()
			ZO_GamepadAlchemyTopLevelSlotContainer:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PANEL_FLOATING_CENTER_QUADRANT_1_SHOWN, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET)
			ZO_GamepadProvisionerTopLevelIngredientsBar:ClearAnchors()
			ZO_GamepadProvisionerTopLevelIngredientsBar:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PANEL_FLOATING_CENTER_QUADRANT_1_SHOWN, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET)
			ZO_GamepadEnchantingTopLevelRuneSlotContainer:ClearAnchors()
			ZO_GamepadEnchantingTopLevelRuneSlotContainer:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PANEL_FLOATING_CENTER_QUADRANT_1_SHOWN, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET)
		end	
		if IJAWH.craftKeybindButtonDescriptor then restoreCraftKeybind() end
	end
end

-------------------------------------
-- on item crafted
-------------------------------------
local function isInCraftingMode()
	local scene = SCENE_MANAGER:GetCurrentScene():GetName()
	local craftingInteractionType = GetCraftingInteractionType()
	if IJAWH:Contains(craftingInteractionType,IJAWH_CRAFTING_TYPE_SMITHING) then
		if IsInGamepadPreferredMode() then
			if scene == "gamepad_smithing_creation" then return true end
		else
			if SMITHING.mode == 2 then return true end
		end
	elseif craftingInteractionType == CRAFTING_TYPE_ENCHANTING then
		if IsInGamepadPreferredMode() then
			if scene == "gamepad_enchanting_creation" then return true end
		else
			if ENCHANTING.mode == 2 then return true end
		end
	else
		return true
	end
end

local function ifOtherWritForStation()
	local station = GetCraftingInteractionType()
	if IJAWH.writData then
		for i=1, #IJAWH.writData do
			if IJAWH.writData[i].writType == station and not IJAWH.writData[i].completed then
				return true
			end
		end
	end
	return false
end
onCraftItemUpdate = function(eventCode)
	zo_callLater(function()
		CALLBACK_MANAGER:UnregisterCallback("CraftingAnimationsStopped", onCraftItemUpdate)
		IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData] = nil	-- remove last recipeData from list
		KEYBIND_STRIP:UpdateKeybindButton(IJAWH.craftKeybindButtonDescriptor)
		
		IJAWH.writEntry:ReleaseAllObjects()
		CALLBACK_MANAGER:FireCallbacks("IJAWH_Update_Writs_Panel")

		if #IJAWH_CurrentWrit.recipeData > 0 and IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft then
			if IJAWH.craftKeybindButtonDescriptor then KEYBIND_STRIP:UpdateKeybindButton(IJAWH.craftKeybindButtonDescriptor) end
			IJAWH:showCraftPannel()
			craftWrit()
		elseif #IJAWH_CurrentWrit.recipeData > 0 and not IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].canCraft then
			IJAWH:showCraftPannel()
--			cleanUp()
			restoreCraftKeybind()
		else
			cleanUp()
			IJAWH.writData[IJAWH_WD_INDEX].completed = true
			restoreCraftKeybind()
			if ifOtherWritForStation() then
				OnCraftStation(1)
			else
				IJAWH:showCraftPannel()
			end
		end
	end, 200)
end

OnCraftItem = function(eventCode)
	if eventCode ~= 0 then
		EVENT_MANAGER:UnregisterForEvent("IJAWH_CRAFT_COMPLETED", EVENT_CRAFT_COMPLETED, OnCraftItem)
		
		local function getCraftedItemLink()
			if IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].itemLink then
				return IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].itemLink
			end
		end
		
		local craftingType = GetCraftingInteractionType()
		if not IsJustaEasyAlchemy.isEasyAlchemy then
--			if not isInCraftingMode() then return end	-- cancel if not in crafting mode (decon, refine, improvement, furniture)
			if IJAWH_WITHDRAW_ITEMS > 0 then
				local itemLinkName = GetItemLinkName(getCraftedItemLink())
				if IJAWH:Contains(craftingType,IJAWH_CRAFTING_TYPE_SMITHING) then
					local numIterations = IJAWH_CurrentWrit.recipeData[#IJAWH_CurrentWrit.recipeData].numIterations
					for i=1, numIterations do
						local keyName = itemLinkName .. 1
						if IJAWH.withdrawItems[keyName] then 
							IJAWH.withdrawItems[keyName] = nil
							IJAWH_WITHDRAW_ITEMS = IJAWH_WITHDRAW_ITEMS - 1
						end
					end
				else
					if IJAWH.withdrawItems[itemLinkName] then 
						IJAWH.withdrawItems[itemLinkName] = nil
						IJAWH_WITHDRAW_ITEMS = IJAWH_WITHDRAW_ITEMS - 1
					end
				end
				if IJAWH_WITHDRAW_ITEMS == 0 then
					EVENT_MANAGER:UnregisterForEvent("IJAWH_Open_Bank", EVENT_OPEN_BANK)
					IJAWH.activeEvents.OpenBank = false
				end
			end
			
		else
			if IsJustaEasyAlchemy.Unknown then
				IsJustaEasyAlchemy.Unknown = false
				IsJustaEasyAlchemy:UpdatePanel()
			end
		end
	end
end

-------------------------------------
--
-------------------------------------
function IJAWH:SetGamepadAnchors()
	ZO_GamepadAlchemyTopLevelSlotContainer:ClearAnchors()
	ZO_GamepadAlchemyTopLevelSlotContainer:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PANEL_FLOATING_CENTER_QUADRANT_1_2_SHOWN, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET)
	ZO_GamepadProvisionerTopLevelIngredientsBar:ClearAnchors()
	ZO_GamepadProvisionerTopLevelIngredientsBar:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PANEL_FLOATING_CENTER_QUADRANT_1_2_SHOWN, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET)
	ZO_GamepadEnchantingTopLevelRuneSlotContainer:ClearAnchors()
	ZO_GamepadEnchantingTopLevelRuneSlotContainer:SetAnchor(BOTTOM, GuiRoot, BOTTOMLEFT, ZO_GAMEPAD_PANEL_FLOATING_CENTER_QUADRANT_1_2_SHOWN, ZO_GAMEPAD_CRAFTING_UTILS_FLOATING_BOTTOM_OFFSET)
end
local function changeMode()
	if IJAWH_WRITLIST and #IJAWH_WRITLIST > 0 then
		CALLBACK_MANAGER:FireCallbacks("IJAWH_Update_Writs_Panel")
	end
end

-------------------------------------
--
-------------------------------------
local function getNewQuests()
	getWritsFromJournal()
	IJAWH.writsPanel.writList:ReleaseAllObjects()
	writsPanelControl()
	IJAWH:wpMinMax(false)
	CALLBACK_MANAGER:FireCallbacks("IJAWH_Update_Writs_Panel")
end
function IJAWH:refreshWritData()

	local qNameList, remainingWrits, remainingWithdraws = {}, {}, {}
	
	for qIndex=1, MAX_JOURNAL_QUESTS do
		if IsValidQuestIndex(qIndex) then
			local qName,_,qDesc,_,_,qCompleted  = GetJournalQuestInfo(qIndex)
			if GetJournalQuestType(qIndex) == QUEST_TYPE_CRAFTING and isWritAdded(qName) then
				qNameList[#qNameList +1] = qName
			end
		end
	end
	
	if #self.writData > 0 then
		for i=1, #self.writData do
			if self:Contains(self.writData[i].qName,qNameList) then
				remainingWrits[#remainingWrits +1] = self.writData[i]
			end
		end
		self.writData = remainingWrits
	end
	
	if self.withdrawItems then
		for k,v in pairs(self.withdrawItems) do
			if self:Contains(v.qName,qNameList) then
				remainingWithdraws[#remainingWithdraws + 1] = v
			end
		end
		if #remainingWithdraws > 0 then
			self.withdrawItems = remainingWithdraws
		else
			self.withdrawItems =  {}
			EVENT_MANAGER:UnregisterForEvent("IJWH_Open_Bank", EVENT_OPEN_BANK)
		end
	end
	getNewQuests()
end

-------------------------------------
-- Daily-Writ new and auto-complete
-------------------------------------
local function writTurnIn()
	if GetInteractionType() == INTERACTION_QUEST then
		EVENT_MANAGER:UnregisterForEvent("IJAWH_QUEST_COMPLETE_DIALOG", EVENT_QUEST_COMPLETE_DIALOG, writTurnIn)
		CompleteQuest()
	end
end
local function onChatterEnd()
	EVENT_MANAGER:UnregisterForEvent("IJAWH_WRIT_CHATTER_END", EVENT_CHATTER_END, onChatterEnd)
	if IJAWH.hasNewWrit then
		getNewQuests()
		IJAWH.hasNewWrit = false
	end
end
local function onChatterBegin()
	IsJustaWritHelper_WritsPanel:SetHidden(true)
	if GetInteractionType() == INTERACTION_CONVERSATION then
		for i=1, GetChatterOptionCount() do
			local optionText, optiontype = GetChatterOption(i)
			if optiontype == CHATTER_START_NEW_QUEST_BESTOWAL then
				EVENT_MANAGER:RegisterForEvent("IJAWH_WRIT_CHATTER_END", EVENT_CHATTER_END, onChatterEnd)
				return
			elseif optiontype == CHATTER_START_ADVANCE_COMPLETABLE_QUEST_CONDITIONS or optiontype == CHATTER_START_COMPLETE_QUEST then
				if string.find(optionText, "goods") or string.find(optionText, "Sign") then
					EVENT_MANAGER:RegisterForEvent("IJAWH_QUEST_COMPLETE_DIALOG", EVENT_QUEST_COMPLETE_DIALOG, writTurnIn)
					SelectChatterOption(i)
				end
			end
		end
	end
end--
local function onWritAccepted(...)
	local  _, _, writName = ...
	if string.find(writName, GetString(SI_IJAWH_WRIT)) then
		IJAWH.hasNewWrit = true
	end
	-- added to show master writs in the writ panel when the writ is used from inventory
	-- only non-smithing master writs can be made with this addon
	if string.find(writName, GetString(SI_IJAWH_MASTERFUL)) then
		getNewQuests()
	end
end

-------------------------------------
-- Startup functions
-----------------------------------

local function onCommandEntered(args)
    if args == 'reset' or args == 'r' then
		IJAWH_WRITLIST = {}
		IJAWH.writData = {}
        getNewQuests()
    end
end

local function OnPlayerActivated()
	EVENT_MANAGER:UnregisterForEvent("IJAWH_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED)
	
	if not TamrielTradeCentre then
		d(zo_strformat(IJAWH.displayName),GetString(SI_IJAWH_TTC_INSTALL))
	elseif IJAWH.savedVariables.priorityBy == GetString(SI_IJAWH_PRIORITY_BY_TTC) then
		local totalSecPerDay = 24 * 60 * 60
		local elapsedTime = getTimeElapsed(TamrielTradeCentrePrice.PriceTable.TimeStamp)
		local elapsedDays = elapsedTime/totalSecPerDay
		if (elapsedDays > 3) then
			d(zo_strformat(IJAWH.displayName),GetString(SI_IJAWH_TTC_UPDATE))
		end
	end
	zo_callLater(getNewQuests, 500)
	
	--	event that control the writs panel
	EVENT_MANAGER:RegisterForEvent("IJAWH_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, function() zo_callLater(writsPanelControl) end, 500)
	EVENT_MANAGER:RegisterForEvent("IJAWH_CHATTER_END", EVENT_CHATTER_END, writsPanelControl)
	EVENT_MANAGER:RegisterForEvent("IJAWH_PLAYER_COMBAT_STATE", EVENT_PLAYER_COMBAT_STATE, writsPanelControl)
	EVENT_MANAGER:RegisterForEvent("IJAWH_PLAYER_DEAD", EVENT_PLAYER_DEAD, writsPanelControl)
	EVENT_MANAGER:RegisterForEvent("IJAWH_PLAYER_ALIVE", EVENT_PLAYER_ALIVE, writsPanelControl)
	EVENT_MANAGER:RegisterForEvent("IJAWH_GROUP_MEMBER_JOINED", EVENT_GROUP_MEMBER_JOINED, writsPanelControl)
	EVENT_MANAGER:RegisterForEvent("IJAWH__GROUP_MEMBER_LEFT", EVENT_GROUP_MEMBER_LEFT, writsPanelControl)
	EVENT_MANAGER:RegisterForEvent("IJAWH_MOUNTED_STATE_CHANGED", EVENT_MOUNTED_STATE_CHANGED, writsPanelControl)
end
function IJAWH:Setup()
	local AccountWideSavedVars = ZO_SavedVars:NewAccountWide("IJAWH_SavedVars", IJAWH.svVersion, nil, self.DefaultSettings)
	local characterSavedVars = ZO_SavedVars:New("IJAWH_SavedVars", IJAWH.svVersion, nil, self.DefaultSettings)

	if AccountWideSavedVars.character then
		IJAWH.savedVariables = characterSavedVars
	else
		IJAWH.savedVariables = AccountWideSavedVars
	end
	if not self.savedVariables.tutorials then IJAWH.savedVariables.tutorials = {} end
	
	EVENT_MANAGER:RegisterForEvent("IJAWH_CRAFTING_STATION_INTERACT", EVENT_CRAFTING_STATION_INTERACT, OnCraftStation)
	EVENT_MANAGER:RegisterForEvent("IJAWH_END_CRAFTING_STATION_INTERACT", EVENT_END_CRAFTING_STATION_INTERACT, OnCloseCraftStation)
	EVENT_MANAGER:RegisterForEvent("IJAWH_QUEST_ADDED", EVENT_QUEST_ADDED, onWritAccepted)
	EVENT_MANAGER:RegisterForEvent("IJAWH_CHATTER_BEGIN", EVENT_CHATTER_BEGIN, onChatterBegin)
	EVENT_MANAGER:RegisterForEvent("IJAWH_QUEST_REMOVED", EVENT_QUEST_REMOVED, function() IJAWH:refreshWritData() end)

	self:CreateMenu()

	self:CreateWritPanel()
	self:BuildDialogInfo()
	if self.savedVariables.easyAlchemy then IsJustaEasyAlchemy:Initialize() end
	self:InitializeKeybindStripDescriptors()
	
	setUpCallbacks()
	
	SLASH_COMMANDS["/ijawh"] = onCommandEntered
end
function IJAWH.OnLoad(eventCode, addOnName)
	if addOnName ~= IJAWH.name then
        return
    end
	
	EVENT_MANAGER:UnregisterForEvent("IJAWH_ADD_ON_LOADED", EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("IJAWH_PLAYER_ACTIVATED", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
	IJAWH:Setup()
end

EVENT_MANAGER:RegisterForEvent("IJAWH_ADD_ON_LOADED", EVENT_ADD_ON_LOADED, IJAWH.OnLoad)
EVENT_MANAGER:RegisterForEvent("IJAWH_ON_MODE_CHANGED", EVENT_GAMEPAD_PREFERRED_MODE_CHANGED, changeMode)
