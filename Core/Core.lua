local IJA_WritHelper = IJA_WRITHELPER
IJA_ACTIVEWRITS = {}

local isGamepadMode = IJA_WritHelper.isGamepadMode
-------------------------------------
-- Comparators
-------------------------------------
function IJA_IsSmithingMaterial(itemData)
	return itemData.itemType == ITEMTYPE_BLACKSMITHING_MATERIAL or
		itemData.itemType == ITEMTYPE_CLOTHIER_MATERIAL or
		itemData.itemType == ITEMTYPE_JEWELRYCRAFTING_MATERIAL or
		itemData.itemType == ITEMTYPE_WOODWORKING_MATERIAL
end
function IJA_IsSmithingTrait(itemData)
	return itemData.itemType == ITEMTYPE_ARMOR_TRAIT or
		itemData.itemType == ITEMTYPE_JEWELRY_TRAIT or
		itemData.itemType == ITEMTYPE_WEAPON_TRAIT
end
function IJA_IsStyleMaterial(itemData)
	return itemData.itemType == ITEMTYPE_STYLE_MATERIAL
end
function IJA_IsSmithingResult(itemData)
	return itemData.itemType == ITEMTYPE_ARMOR or
		itemData.itemType == ITEMTYPE_WEAPON
end
function IJA_IsSmithingRawMatierial(itemData)
	return itemData.itemType == ITEMTYPE_BLACKSMITHING_RAW_MATERIAL or
	itemData.itemType == ITEMTYPE_CLOTHIER_RAW_MATERIAL or
	itemData.itemType == ITEMTYPE_JEWELRYCRAFTING_RAW_MATERIAL or
	itemData.itemType == ITEMTYPE_WOODWORKING_RAW_MATERIAL
end
function IJA_IsGlyph(itemData)
	return itemData.itemType == ITEMTYPE_GLYPH_ARMOR or
		itemData.itemType == ITEMTYPE_GLYPH_JEWELRY or
		itemData.itemType == ITEMTYPE_GLYPH_WEAPON
end
function IJA_IsRune(itemData)
	return itemData.itemType == ITEMTYPE_ENCHANTING_RUNE_ASPECT or
		itemData.itemType == ITEMTYPE_ENCHANTING_RUNE_ESSENCE or
		itemData.itemType == ITEMTYPE_ENCHANTING_RUNE_POTENCY
end
function IJA_IsIngredient(itemData)
	return itemData.itemType == ITEMTYPE_INGREDIENT
end
function IJA_IsFood(itemData)
	return itemData.itemType == ITEMTYPE_FOOD or
		itemData.itemType == ITEMTYPE_DRINK
end

IJA_Comparators = {}
do
	local comparators = {
		IJA_IsSmithingMaterial,
		IJA_IsSmithingTrait,
		IJA_IsStyleMaterial,
		IJA_IsSmithingResult,
		IJA_IsSmithingRawMatierial,
		IJA_IsGlyph,
		IJA_IsRune,
		IJA_IsIngredient,
		IJA_IsFood,
		IJA_IsAlchemyIngredient,
		IJA_IsAlchemySolvent,
		IJA_IsAlchemyReagent,
		IJA_IsAlchemyResultItem
	}

	for k, comparator in pairs(comparators) do
		table.insert(IJA_Comparators, comparator)
	end
end

-------------------------------------
-- Globals
-------------------------------------
CRAFTING_TYPE_CERTIFICATION = CRAFTING_TYPE_MAX_VALUE + 1

WRIT_TYPE_TALK = 0
WRIT_TYPE_REFINE = 1
WRIT_TYPE_CRAFT = 2
WRIT_TYPE_DECONSTRUCT = 3
WRIT_TYPE_ACQUIRE = 4

function IJA_insert(tble, ...)
    for i = 1, select("#", ...) do
        local source = select(i, ...)
        table.insert(tble, source)
    end
end

do	--	IJAWH_IsPerformingCraftProcess
    local g_isCrafting = false
    CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStarted", function()
        g_isCrafting = true
    end)
    CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStopped", function()
        g_isCrafting = false
    end)
	
    function IJAWH_IsPerformingCraftProcess()
        return g_isCrafting
    end
end

-------------------------------------
-- 
-------------------------------------
local iconList = {
	[1] = "/esoui/art/inventory/inventory_tabicon_craftbag_blacksmithing", 		-- CRAFTING_TYPE_BLACKSMITHING
	[2] = "/esoui/art/inventory/inventory_tabicon_craftbag_clothing", 			-- CRAFTING_TYPE_CLOTHIER
	[3] = "/esoui/art/inventory/inventory_tabicon_craftbag_enchanting",			-- CRAFTING_TYPE_ENCHANTING
	[4] = "/esoui/art/inventory/inventory_tabicon_craftbag_alchemy", 			-- CRAFTING_TYPE_ALCHEMY
	[5] = "/esoui/art/inventory/inventory_tabicon_craftbag_provisioning", 		-- CRAFTING_TYPE_PROVISIONING
	[6] = "/esoui/art/inventory/inventory_tabicon_craftbag_woodworking", 		-- CRAFTING_TYPE_WOODWORKING
	[7] = "/esoui/art/inventory/inventory_tabicon_craftbag_jewelrycrafting",	-- CRAFTING_TYPE_JEWELRYCRAFTING
	[CRAFTING_TYPE_CERTIFICATION] = "/esoui/art/treeicons/achievements_indexicon_summary"
}

local smithingMaterialType = {
	[36] = true,
	[38] = true,
	[40] = true,
	[64] = true
}

local smithingMaterialToRaw = {
	[794]		= 793,
	[803]		= 802,
	[811]		= 812,
	[5413]		= 808,
	[135140]	= 135139,
}

local deconstructCraftingTypes = {
	[GetString(SI_ITEMTYPEDISPLAYCATEGORY10)] = CRAFTING_TYPE_BLACKSMITHING,
	[GetString(SI_ITEMTYPEDISPLAYCATEGORY11)] = CRAFTING_TYPE_CLOTHIER,
	[GetString(SI_ITEMTYPEDISPLAYCATEGORY12)] = CRAFTING_TYPE_WOODWORKING,
	[GetString(SI_ITEMTYPEDISPLAYCATEGORY13)] = CRAFTING_TYPE_JEWELRYCRAFTING,
	[GetString(SI_ITEMTYPEDISPLAYCATEGORY15)] = CRAFTING_TYPE_ENCHANTING
}

local function getDeconstructCraftingType(condition)
    for k,v in pairs(deconstructCraftingTypes) do
    	if string.match(condition, k) then
        	return v
    	end
    end
	return 0
end

local deconstructItems = {
	[1] = 43535,
	[2] = 43545,
	[6] = 43549,
	[7] = 43536
}

local function getDeconstructItem(craftingType)
	return deconstructItems[craftingType]
end

-------------------------------------
-- Core
-------------------------------------
-------------------------------------
-- Writ updaters
-------------------------------------
local usedInConsumableCrafting = {
    [CRAFTING_TYPE_ENCHANTING]		= true,
    [CRAFTING_TYPE_ALCHEMY]			= true,
    [CRAFTING_TYPE_PROVISIONING]	= true
}

local function GetBaseConditionInfo(questIndex, conditionIndex)
    local itemId, materialItemId, craftingType, itemFunctionalQuality = GetQuestConditionItemInfo(questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
--    local conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible, conditionType = GetJournalQuestConditionInfo(questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
	return {
        conditionIndex = conditionIndex,
        itemId = itemId,
        materialItemId = materialItemId,
        craftingType = craftingType,
        itemFunctionalQuality = itemFunctionalQuality,
        craft = false
    }
end

local function GetCraftConditionInfo(conditionIndex, isMasterWrit, itemId, materialItemId, craftingType, itemFunctionalQuality, itemTemplateId, itemSetId, itemTraitType, itemStyleId, encodedAlchemyTraits)
	return {
        conditionIndex = conditionIndex,
        itemId = itemId,
        materialItemId = materialItemId,
        craftingType = craftingType,
        itemFunctionalQuality = itemFunctionalQuality,
        itemTemplateId = itemTemplateId,
        itemSetId = itemSetId,
        itemTraitType = itemTraitType,
        itemStyleId = itemStyleId,
        encodedAlchemyTraits = encodedAlchemyTraits,
        isMasterWrit = isMasterWrit,
        craft = true,
    }
end

function IJA_WritHelper:RefreshWritMasterList()
	--Grab the current quest information from the journal
	local quests = QUEST_JOURNAL_MANAGER:GetQuestList()
	--Clear out the current writMasterList
	ZO_ClearTable(self.writMasterList)
	--Filter out any non-crafting quests from the list
	for i, questInfo in ipairs(quests) do
		if questInfo.questType == QUEST_TYPE_CRAFTING then
			local conditionData, isMasterWrit, craftType, writType = {}, false, 0, 0
--		d( '---- questInfo.name', questInfo.name)

			local conditionCount = self:GetJournalQuestNumConditions(questInfo.questIndex, QUEST_MAIN_STEP_INDEX)
			for conditionIndex = 1, conditionCount do
				local conditionType = select(8, GetJournalQuestConditionInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex))
--		d( 'conditionType', conditionType)
				if conditionType == QUEST_CONDITION_TYPE_GATHER_ITEM then -- 44
					local itemId, materialItemId, craftingType, itemFunctionalQuality = GetQuestConditionItemInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
					local conditionInfo =  GetCraftConditionInfo(conditionIndex, isMasterWrit, itemId, materialItemId, craftingType, itemFunctionalQuality)

					local itemType = GetItemLinkItemType(self:GetItemLink(itemId))
					if smithingMaterialType[itemType] then
						-- refine material cerification
						conditionInfo.itemId = smithingMaterialToRaw[itemId]
						writType = WRIT_TYPE_REFINE
						craftType = GetItemLinkCraftingSkillType(self:GetItemLink(itemId))
					else
						writType = WRIT_TYPE_CRAFT
						if craftingType > 0 then craftType = craftingType end
					end

					table.insert(conditionData, conditionInfo)
				elseif conditionType == QUEST_CONDITION_TYPE_CRAFT_RANDOM_WRIT_ITEM then -- 48
					isMasterWrit = true
					local itemId, materialItemId, craftingType, itemFunctionalQuality, itemTemplateId, itemSetId, itemTraitType, itemStyleId, encodedAlchemyTraits = GetQuestConditionMasterWritInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
					local conditionInfo = GetCraftConditionInfo(conditionIndex, isMasterWrit, itemId, materialItemId, craftingType, itemFunctionalQuality, itemTemplateId, itemSetId, itemTraitType, itemStyleId, encodedAlchemyTraits)
					
					table.insert(conditionData, conditionInfo)
					if craftingType ~= 0 then craftType = craftingType end
----------------------------------------------------------------------------------------------------------------------------------
				elseif conditionType == QUEST_CONDITION_TYPE_DECONSTRUCT_ITEM then -- 25
					local conditionText = GetJournalQuestConditionInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)

					local craftingType = getDeconstructCraftingType(conditionText)
					local itemId = getDeconstructItem(craftingType)
					local data = {
						conditionIndex = conditionIndex,
						itemId = itemId,
						craftingType = craftingType,
						isMasterWrit = isMasterWrit,
						craft = false
					}
					writType = WRIT_TYPE_DECONSTRUCT
					table.insert(conditionData, data)
					if craftingType > 0 then craftType = craftingType end
				elseif conditionType == QUEST_CONDITION_TYPE_SCRIPT_ACTION then -- 17
					local conditionText, current, max, isFailCondition, isComplete, isCreditShared, isVisible, conditionType = GetJournalQuestConditionInfo(questInfo.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
					GetBaseConditionInfo(questInfo.questIndex, conditionIndex)
					local data = 
					{
						conditionIndex = conditionIndex,
						isMasterWrit = isMasterWrit,
						craft = false,
					}
					
					table.insert(conditionData, data)
					craftType = CRAFTING_TYPE_CERTIFICATION
				elseif conditionType == QUEST_CONDITION_TYPE_COLLECT_ITEM then -- 6
GetBaseConditionInfo(questInfo.questIndex, conditionIndex)
				elseif conditionType == QUEST_CONDITION_TYPE_TALK_TO then -- 9
GetBaseConditionInfo(questInfo.questIndex, conditionIndex)
					craftType = CRAFTING_TYPE_CERTIFICATION
				elseif conditionType == 0 then
					local conditionInfo = GetBaseConditionInfo(questInfo.questIndex, 0)
					table.insert(conditionData, conditionInfo)
					craftType = CRAFTING_TYPE_CERTIFICATION
				end
			end
		
			if conditionData ~= nil then
				questInfo.writType = writType
				questInfo.conditionData = conditionData
				questInfo.craftingType = craftType
				questInfo.writId = tonumber(craftType .. (isMasterWrit and 1 or 0))
				table.insert(self.writMasterList, questInfo)
			end
		end
	end
end

function IJA_WritHelper:RefreshQuestList()
	self:RefreshWritMasterList()
	self.itemTypeToCraftingType = {}

	local InitializeWrit = {
		[CRAFTING_TYPE_BLACKSMITHING]	= IJA_WritHelper_Smithing_Object,
		[CRAFTING_TYPE_CLOTHIER]		= IJA_WritHelper_Smithing_Object,
		[CRAFTING_TYPE_ENCHANTING]		= IJA_WritHelper_Enchanter_Object,
		[CRAFTING_TYPE_ALCHEMY]			= IJA_WritHelper_Alchemy_Object,
		[CRAFTING_TYPE_PROVISIONING]	= IJA_WritHelper_Provisioning_Object,
		[CRAFTING_TYPE_WOODWORKING]		= IJA_WritHelper_Smithing_Object,
		[CRAFTING_TYPE_JEWELRYCRAFTING]	= IJA_WritHelper_Smithing_Object,
		[CRAFTING_TYPE_CERTIFICATION]	= IJA_WritHelper_Certification_Object
	}

	local numWrits = 0
	local writs = self.writMasterList
--	if writs == nil then return end
	for writIndex, writInfo in pairs(writs) do
		-- create writs as objects
		local craftingType = writInfo.craftingType
		if InitializeWrit[craftingType] ~= nil then
			if not self.writData[craftingType] then self.writData[craftingType] = {} end
			
			local questIndex = writInfo.questIndex
			if not self.writData[craftingType][questIndex] then 
				local writObject = InitializeWrit[craftingType]:New(self, writInfo)
				writObject.icon = iconList[craftingType]
				self.writData[craftingType][questIndex] = writObject
				
				IJA_ACTIVEWRITS[craftingType] = true
			end
			numWrits = numWrits + 1
		end
	end
	
	if numWrits == 0 then
		self:CleanUp()
	end
	self:UpdateDynamicEvents()
end

function IJA_WritHelper:UpdateWrits()
	IJA_ACTIVEWRITS = {}
	for craftingType, stationWrits in pairs(self.writData) do
		for questIndex, writObject in pairs(stationWrits) do
			writObject:Update(true)
		end
		IJA_ACTIVEWRITS[craftingType] = true
	end
	self:RefreshQuestList()
end

function IJA_WritHelper:RefreshSingleWrit(questIndex)
	local writ_Object = self.questIndexToDataMap[questIndex]
	
	if writ_Object then
		writ_Object:Update()
	end
end

function IJA_WritHelper:UpdateWritsForItem(usedInCraftingType)
    local questCache = {}
    if usedInConsumableCrafting[usedInCraftingType] then
		local stationWrits = self.writData[usedInCraftingType]
    
        if stationWrits then
            for questIndex, writ_Object in pairs(stationWrits) do
                questCache[#questCache + 1] = writ_Object
            end
        end
    else 
        for k, craftingType in pairs({CRAFTING_TYPE_BLACKSMITHING,CRAFTING_TYPE_CLOTHIER,CRAFTING_TYPE_WOODWORKING,CRAFTING_TYPE_JEWELRYCRAFTING}) do
            local stationWrits = self.writData[craftingType]
        
            if stationWrits then
                for questIndex, writ_Object in pairs(stationWrits) do
                    questCache[#questCache + 1] = writ_Object
                end
            end
        end
    end
    local FORCE = true
    for i=1, #questCache do
        questCache[i]:Update(FORCE)
    end
end

function IJA_WritHelper:Destroy(object)
	if object.questIndex  then
		local craftingType, questIndex = object.craftingType, object.questIndex
		self.writData[craftingType][questIndex] = nil
		
		if NonContiguousCount(self.writData[craftingType]) == 0 then
			self.writData[craftingType] = nil
		end
	else
 	   object = nil
	end
end

-------------------------------------
-- 
-------------------------------------
local function getZOSMasterListIndex(questIndex)
	for index, questInfo in pairs(CRAFT_ADVISOR_MANAGER.questMasterList) do
		if questInfo.questIndex == questIndex then
			return index
		end
	end
end

local function setWritAdviserToSelectedWrit()
	local questIndex = 0
	if CRAFT_ADVISOR_MANAGER.questMasterList then
		if CRAFT_ADVISOR_MANAGER.questMasterList[CRAFT_ADVISOR_MANAGER.selectedMasterListIndex] then
			questIndex = CRAFT_ADVISOR_MANAGER.questMasterList[CRAFT_ADVISOR_MANAGER.selectedMasterListIndex].questIndex
		end
	end
	
	if questIndex ~= 0 and questIndex ~= IJA_WRITHELPER.selectedQuestIndex then
		if isGamepadMode then
			ZO_WRIT_ADVISOR_GAMEPAD:CycleActiveQuest()
		else
		end
	end
end

function IJA_WritHelper:CycleActiveQuests()--------------------------
	-- cycle writs for station
	local craftingType = GetCraftingInteractionType()
	self.currentWritIndex = self.currentWritIndex + 1
	
	if self.currentWritIndex > #self.writData[craftingType] then
		self.currentWritIndex = DEFAULT_DISPLAYED_QUEST_INDEX
	end
	
	self.currentWrit = self.writData[craftingType][self.currentWritIndex]
	if self.currentWrit == nil then return end
	self.currentWrit:OnCraftingStation()
end

function IJA_WritHelper:GetWritForStation(craftingType)
	local stationWrits = self.writData[craftingType]
	
	if stationWrits then
		for questIndex, writObject in pairs(stationWrits) do
			if not writObject:GetCompleted() then
				CRAFT_ADVISOR_MANAGER.selectedMasterListIndex = getZOSMasterListIndex(questIndex)
				CRAFT_ADVISOR_MANAGER:OnSelectionChanged(questIndex)
				self.selectedQuestIndex = questIndex
				setWritAdviserToSelectedWrit()
				return writObject
			end
		end
	end
	return
end

function IJA_WritHelper:GetWritByQuestIndex(questIndex)
	for craftingType, stationWrits in pairs(self.writData) do
		for qIndex, writObject in pairs(stationWrits) do
			if qIndex == questIndex then
				return writObject
			end
		end
	end
	return
end

function IJA_WritHelper:RemoveWritByQuestIndex(questIndex)
	for craftingType, stationWrits in pairs(self.writData) do
		for qIndex, writObject in pairs(stationWrits) do
			if qIndex == questIndex then
				self.writData[craftingType][qIndex] = nil
			end
		end
	end
end

function IJA_WritHelper:GetCurrentWrit()
	return self.currentWrit
end

function IJA_WritHelper:IsCrafting()
	-- used for auto crafting. this includes crafting consecutive items using manual crafting or if auto-craft is enabled
	return self.isCrafting
end

function IJA_WritHelper:IsAutoCraft(craftingType, writType)
	-- is auto-crafting set for craftingType
	local isAutoCraft = false
	if writType == WRIT_TYPE_REFINE or writType == WRIT_TYPE_DECONSTRUCT then
		isAutoCraft = writType == WRIT_TYPE_REFINE and self.savedVars.autoCraft[6] or
			writType == WRIT_TYPE_DECONSTRUCT and self.savedVars.autoCraft[7] or false
	else
		isAutoCraft = (IsSmithingCraftingType(craftingType) and self.savedVars.autoCraft[1]) or self.savedVars.autoCraft[craftingType] or false
	end

	return isAutoCraft
end

function IJA_WritHelper:CleanUp()
	if self.activeEvents ~= {} then
--		self:UnregisterEvents()
	end
	
	self.writData = {}
	self.bankedList = {}
	self.activeEvents = {}
	self.craftedItems = {}
	self.writMasterList = {}
end

-------------------------------------
-- 
-------------------------------------
function IJA_WritHelper:GetJournalQuestNumConditions(journalQuestIndex, stepIndex)
	-- needed for when numConditions == 0 so the writ can pass thru "for" loops
	local numConditions = GetJournalQuestNumConditions(journalQuestIndex, stepIndex)
	return (numConditions > 0 and numConditions or 1)
end

-------------------------------------
-- 
-------------------------------------
function IJA_WritHelper:MapItemIdToDataMap(object)
    self.itemIdToDataMap[object.itemId] = object
end

function IJA_WritHelper:MapQuestIndexToDataMap(object)
    self.questIndexToDataMap[object.questIndex] = object
end

function IJA_WritHelper:SafelyDestroy(reference)
    reference = false
    reference = nil
end
    
-------------------------------------
-- Bag Cache
-------------------------------------
function IJA_WritHelper:GetOrCreateBagCache(bag)
    if self.craftingInventory[bag].bagCache then
        return self.craftingInventory[bag].bagCache
    else
        self:UpdateBagCache(bag)
        return self.craftingInventory[bag].bagCache
    end
end

function IJA_WritHelper:UpdateBagCache(bag)
    ZO_GamepadInventoryList.inventoryTypes = self.craftingInventory[bag].backingBags
    local items = ZO_GamepadInventoryList:GenerateSlotTable()

    if items then
        self.craftingInventory[bag].bagCache = {}
        for _, itemData in pairs(items) do
			if self:DefaultFilterFunction(itemData) then
				itemData.itemlink = GetItemLink(itemData.bagId, itemData.slotIndex)
				self.craftingInventory[bag].bagCache[itemData.slotIndex] = itemData
			end
        end
    end
end

function IJA_WritHelper:UpdateAllBags()
    for i=1, 3 do
        self:UpdateBagCache(i)
    end
	-- self:UpdateAllCraftItems()
end

function IJA_WritHelper:UpdateSingleSlot(bagId, slotIndex)
    for bag = 1, 3 do
        local bagCache = self:GetOrCreateBagCache(bag)
		local slotData = bagCache[slotIndex]
		if slotData then
			local itemData = SHARED_INVENTORY:GenerateSingleSlotData(slotData.bagId, slotIndex)
			if itemData and self:DefaultFilterFunction(itemData) then
				itemData.itemlink = GetItemLink(itemData.bagId, itemData.slotIndex)
				itemData.bestGamepadItemCategoryName = ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription(itemData)
				self.craftingInventory[bag].bagCache[itemData.slotIndex] = itemData
			else
				-- if item removed then remove from bagCache
				self.craftingInventory[bag].bagCache[slotIndex] = nil
			end
		end
    end
	-- self:UpdateAllCraftItems()
end

function IJA_WritHelper:GetItemData(itemId, filterFunction, bag)
    local function comparator(itemId, itemData)
		return itemId == GetItemId(itemData.bagId, itemData.slotIndex)
	end
	if not filterFunction then
		filterFunction = comparator
	end

    local bagCache = self:GetOrCreateBagCache(bag)
    for slotIndex, itemData in pairs(bagCache) do
		if itemData then
			if filterFunction(itemId, itemData) then
				return itemData
			end
		end
    end
end

IJA_BAG_ALL = 1
IJA_BAG_BACKPACK = 2
IJA_BAG_BANK = 3
function IJA_WritHelper:InitializeCraftingInventory()
    self.craftingInventory = {
        [IJA_BAG_BACKPACK]  = {backingBags = {BAG_BACKPACK}},
        [IJA_BAG_BANK]      = {backingBags = {BAG_BANK, BAG_SUBSCRIBER_BANK}},
        [IJA_BAG_ALL]		= {backingBags = {BAG_BACKPACK, BAG_VIRTUAL, BAG_BANK, BAG_SUBSCRIBER_BANK}},
    }

    local function OnInventoryUpdated()
        self:UpdateAllBags()
    end
    local function OnSingleSlotInventoryUpdated(...)
        self:UpdateSingleSlot(...)
    end
    
    SHARED_INVENTORY:RegisterCallback("FullInventoryUpdate", OnInventoryUpdated)
    SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", OnSingleSlotInventoryUpdated)
    OnInventoryUpdated()
end

function IJA_WritHelper:DefaultFilterFunction(itemData)
	-- for optionalDependsOn filtering addons.
	local locked = itemData.locked
	if not locked then
		if self.isFCOIS and not isGamepadMode then
			locked = FCOIS.IsLocked(itemData.bagId, itemData.slotIndex)
		end
	end
	return not locked
end
--	self.isGamepadMode = IsInGamepadPreferredMode()
--	local isGamepadMode = IJA_WritHelper.isGamepadMode
-------------------------------------
-- Item Link Functions
-------------------------------------
function IJA_WritHelper:GetItemLink(itemId, subType, level, styleId, potData)
    local subType 	= subType 	and subType or "30"
    local level 	= level 	and level 	or "1"
    local styleId 	= styleId 	and styleId or "0"
    local potData 	= potData 	and potData or "0"
	local linkFormat = "|H0:item:<<1>>:<<2>>:<<3>>:0:0:0:0:0:0:0:0:0:0:0:0:<<4>>:0:0:0:0:<<5>>|h|h"
	local itemLink = zo_strformat(linkFormat, itemId, subType, level, styleId, potData)
	return itemLink
end

function IJA_WritHelper:MakeLinkCrafted(itemLink)
	local linkString = "(|H%d:item:[%d:]+)%d+(:%d+:%d+:%d+:%d+|h|h)"
	return itemLink:gsub(linkString, '%11%2')
end

function IJA_WritHelper:GetItemLinkEncodedData(itemLink)
    local itemComboId, setId, crafted, encodedAlchemyTraits = itemLink:match('|H%d:item:(%d+:%d+:%d+:%d+:)[%d:]+(%d+):(%d+):%d+:%d+:(%d+)|h|h')
    itemComboId = itemComboId:gsub('%:', '') .. setId
--	return itemComboId, setId, crafted, encodedAlchemyTraits
	return tonumber(itemComboId), tonumber(encodedAlchemyTraits)
end

math.randomseed( os.time() )  -- Seed the pseudo-random number generator
local function shuffleTable( t )
    if ( type(t) ~= "table" ) then
        print( "WARNING: shuffleTable() function expects a table" )
        return false
    end
 
    local j
 
    for i = #t, 2, -1 do
        j = math.random( i )
        t[i], t[j] = t[j], t[i]
    end
    return t
end

function IJA_WritHelper:CompareEncoadedAlchemyTraits(encodedAlchemyTraits, writ_encodedAlchemyTraits)
	local traits = self:GetTraitsFromEncodedAlchemyTraits(encodedAlchemyTraits)
	if writ_encodedAlchemyTraits == encodedAlchemyTraits then return true end

    local step, matches = 0, false
    repeat
		-- shuffle the trait table to get 
        traits = shuffleTable(traits)

        if writ_encodedAlchemyTraits == self:GetEncodedAlchemyTraits(traits) then
            matches = true
            break
        end
        step = step + 1
    until step == 100
    return matches
end

-------------------------------------
-- Keybinds
-------------------------------------
function IJA_WritHelper:InitializeKeybindStripDescriptors()
    self.resetWritKeybindStripDescriptor =
    {
        alignment = KEYBIND_STRIP_ALIGN_CENTER,
        -- reset selected recipe
        {
            name = GetString(SI_IJAWH_BUTTON_RESETWRIT),
            keybind = "UI_SHORTCUT_QUATERNARY",
            callback = function()
                if self.currentWrit then
					self.currentWrit:OnCraftingStation()
				end
            end,
            visible = function()
                if self.currentWrit then
					return true
                end
				return false
            end,
        }
    }
	
    ZO_CraftingUtils_ConnectKeybindButtonGroupToCraftingProcess(self.resetWritKeybindStripDescriptor)
end

function IJA_WritHelper:AddCraftKeybind()
	KEYBIND_STRIP:AddKeybindButtonGroup(self.resetWritKeybindStripDescriptor)
	KEYBIND_STRIP:UpdateKeybindButton(self.resetWritKeybindStripDescriptor)
end

function IJA_WritHelper:RemoveCraftKeybind()
	KEYBIND_STRIP:RemoveKeybindButtonGroup(self.resetWritKeybindStripDescriptor)
end

-------------------------------------
-- Items used for crafting
-------------------------------------
IJA_WritHelper_CraftItems = ZO_Object:Subclass()

function IJA_WritHelper_CraftItems:New(condition, required)
    self.usedIn = {
        [condition.conditionId] = required
    }
    self.required = required
end

function IJA_WritHelper_CraftItems:Add(condition, required)
    if not self.usedIn[condition.conditionId] then
        self.usedIn[condition.conditionId] = required
        self.required = self.required + required
    end
end

function IJA_WritHelper_CraftItems:Subtract(condition)
    self.required = self.required - self.usedIn[condition.conditionId]
    self.usedIn[condition.conditionId] = nil
    if NonContiguousCount(self.usedIn) == 0 then
        IJA_WRITHELPER:Destroy(self) -- destroy self
    end
end

function IJA_WritHelper_CraftItems:ResetCraftItemsForWrit(object)
	if not object.sortedConditions then return end
    for k, condition in pairs(object.sortedConditions) do
        for itemId, itemInfo in pairs(IJA_WRITHELPER.craftingItems) do
            if itemInfo.conditionId == condition.conditionId  then
                itemInfo:Subtract(condition)
            end
        end
    end
end

function IJA_WritHelper_CraftItems:Reset()
    self.usedIn = nil
    self.required = nil
end

--	/script SHARED_INVENTORY:FireCallbacks("SingleSlotInventoryUpdate")
--	/script d(IJA_WRITHELPER.writInventory[1].bagId)



-------------------------------------
-- 
-------------------------------------