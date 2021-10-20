
-------------------------------------
-- Locals
-------------------------------------
local function getCraftableState(completed, tot, numOver)
	return completed and 1 or	-- completed
		numOver == 0 and 2 or	-- not completed but all craftable
		numOver < tot and 3 or	-- not completed, not all items are craftable
		0
		-- else uncraftable
end

local function onCraftedItemUpdated(eventId, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
	EVENT_MANAGER:UnregisterForEvent("IJAWH_ON_CRAFTED_ITEM_UPDATED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onCraftedItemUpdated)
	CALLBACK_MANAGER:FireCallbacks("IsJustaWritHelper_OnCraftComplete", bagId, slotId, GetCraftingInteractionType())
end

local iconSuffix = {
	[false] = "_up.dds",
	[true] = "_down.dds"
}

local icon_Completed = '/esoui/art/miscellaneous/check.dds'

local DEFAULT_PERITERATION = 1
local IsAcquire = true

-------------------------------------
-- Recipe Data
-------------------------------------
local RecipeData_Object = ZO_Object:Subclass()

function RecipeData_Object:New(parent, ...)
	local newObject = self:MultiSubclass(parent)
	newObject:Initialize(parent, ...)
	return newObject
end

function RecipeData_Object:Initialize(parent, writId, conditionIndex, condition ,current, maximum)
	self.parent 	= parent
	self.current	= current
	self.maximum	= maximum
	self.condition	= condition
	self.writId 	= writId
	self.conditionId = tonumber(writId .. conditionIndex)
	self.conditionIndex = conditionIndex
end

function RecipeData_Object:Build(conditionInfo)
	local function setDefaultData(itemId, itemLink)
		local itemLink = itemLink or self:GetItemLink(self.itemId)
		self.itemId = itemId
		self.itemLink = self:MakeLinkCrafted(itemLink)
		IJA_WRITHELPER:MapItemIdToDataMap(self)
	end
	
	self.conditionInfo = conditionInfo
	if self:GetWrtitType() == WRIT_TYPE_REFINE then
		setDefaultData(conditionInfo.itemId)
		self.inBank = self:SearchBank()
	elseif self:GetWrtitType() == WRIT_TYPE_DECONSTRUCT then
		setDefaultData(conditionInfo.itemId)
	elseif string.match(self.condition, GetString(IJAWH_ACQUIRE_STRING)) then
		self.craft = false
		setDefaultData(conditionInfo.itemId)
		self.inBank = self:SearchBank()
	elseif conditionInfo.craft then
		local recipeData, itemId, itemLink = self:GetRecipeData(conditionInfo)
		if itemId ~= nil then
			self.recipeData = recipeData
			self.isPoison = self:GetBaseIsPoison(self.itemId)
			self.perIteration = self:GetPerIteration()
			self.craft = true
			setDefaultData(itemId, itemLink)
			self.inBank = self:SearchBank()
		end
	end
end


--[[


WRIT_TYPE_TALK = 0
WRIT_TYPE_REFINE = 1
WRIT_TYPE_CRAFT = 2
WRIT_TYPE_DECONSTRUCT = 3
WRIT_TYPE_ACQUIRE = 4

]]
function RecipeData_Object:CanCraft()
	local maxIterations, craftingResult = self:GetMaxIterations()
	if maxIterations == 0 then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString("SI_TRADESKILLRESULT", craftingResult))
		
		d( GetString("SI_TRADESKILLRESULT", craftingResult))
		return false
	else
		return true
	end
end

function RecipeData_Object:GetCompleted()
	return self:GetRequiredIterations() == 0
end

function RecipeData_Object:GetConditionAndCounts()
	return self.condition, self.current, self.maximum
end

function RecipeData_Object:GetItemIdAndLink(conditionInfo)
	local itemId = conditionInfo.itemId
	return itemId, self:GetItemLink(itemId)
end

function RecipeData_Object:GetPerIteration()
	return DEFAULT_PERITERATION
end

function RecipeData_Object:GetRequiredIterations()
	local condition, current, maximum = self:GetUpdateConditionAndCounts()
	
	if condition ~= '' then
		if current == maximum then
			return 0
		else
			local numRequiered = math.ceil(maximum - current)
			local numIterations = math.ceil(numRequiered / self:GetPerIteration())
			return numIterations
		end
	else
		return 0
	end
end

function RecipeData_Object:GetUpdateConditionAndCounts()
	self:UpdateConditionAndCounts()
	return self.condition, self.current, self.maximum
end

function RecipeData_Object:UpdateConditionAndCounts()
	local condition ,current, maximum = GetJournalQuestConditionInfo(self.questIndex, QUEST_MAIN_STEP_INDEX, self.conditionIndex)

	self.condition	= condition
	self.current	= current
	self.maximum	= maximum
end


function RecipeData_Object:UpdateRecipeData()
	self:UpdateConditionAndCounts()
	if not self.recipeData then return end
	local recipeData, itemId, itemLink = self:GetRecipeData(self.conditionInfo)
	self.recipeData = recipeData
end

function RecipeData_Object:Update()
	self.parent:Update()
end

function RecipeData_Object:TryToCraft()
	EVENT_MANAGER:RegisterForEvent("IJAWH_ON_CRAFTED_ITEM_UPDATED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onCraftedItemUpdated)
	self:AutoCraft()
end

-------------------------------------------------------------
function RecipeData_Object:CanCraftItemHere()
	if self.condition ~= '' then
		if self.isMaterWrit and IsSmithingCraftingType(self.craftingType) then
			local itemSetId = self.itemSetId
			local  setName = select(2, GetItemLinkSetInfo(self.itemLink))
			
			if not CanSpecificSmithingItemSetPatternBeCraftedHere(itemSetId) then
				local strng = zo_strformat(GetString(SI_IJAWH_USE_SET_STATION), setName)
	--			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, strng)

				if LibSets then
					local zoneId = LibSets.setInfo[itemSetId].zoneIds[1]
					local zoneName = GetZoneNameById(zoneId)
					
					-- notify in chat that a set station must be used
					d( strng .. '\n' .. zo_strformat(GetString(SI_IJAWH_FOUND_IN), zoneName))
				end
				return strng
			end
		end
	end
end

function RecipeData_Object:GetCraftItemResult()
	if self.craft then
		local maxIterations, craftingResult = self:GetMaxIterations()
		if maxIterations == 0 then
			return GetString('SI_TRADESKILLRESULT', craftingResult)
		else
			return self:CanCraftItemHere()
		end
	end
end

function RecipeData_Object:GetRefineItemResult()
	-- has enough raw material
	local function comparator(itemId, itemData)
		if itemId == GetItemId(itemData.bagId, itemData.slotIndex) then return false end
		return ZO_SharedSmithingExtraction_IsRefinableItem(itemData.bagId, itemData.slotIndex)
	end
	local itemData = IJA_WRITHELPER:GetItemData(self.itemId, comparator, IJA_BAG_ALL)
	local stackCount = itemData ~= nil and itemData.stackCount or 0
	if stackCount < GetRequiredSmithingRefinementStackSize() then
		return GetString(SI_TRADESKILLRESULT72) --"You do not have enough to refine", -- SI_TRADESKILLRESULT72
	end
end

function RecipeData_Object:GetDeconItemResult()
	-- has item needed to decon
	local function comparator(itemId, itemData)
		if itemId == GetItemId(itemData.bagId, itemData.slotIndex) then return false end

		local functionalQuality = select(8, GetItemInfo(itemData.bagId, itemData.slotIndex))
		return functionalQuality == ITEM_FUNCTIONAL_QUALITY_NORMAL
	end
	
	local itemData = IJA_WRITHELPER:GetItemData(self.itemId, comparator, IJA_BAG_BACKPACK)
	
	local stackCount = itemData ~= nil and itemData.stackCount or 0
	local itemEncodedLinkData = self:GetItemLinkEncodedData(itemData.itemLink)
	local writEncodedLinkData = self:GetItemLinkEncodedData(self.itemLink)

	-- ensure the item is of correct level
	if stackCount == 0 or itemEncodedLinkData ~= writEncodedLinkData then
		return zo_strformat(GetString(SI_ADDON_MANAGER_DEPENDENCY_MISSING), itemLink)
	end
end

function RecipeData_Object:AutoImproveSmithingItem()
	if self.isMaterWrit then
		if self.savedVars.autoImprove then
			return self:HasItemToImproveForWrit()
		end
	end
	return false
end

-------------------------------------
-- Items used for crafting
-------------------------------------
function RecipeData_Object:UpdateCraftItems(itemId, required)
	if itemId == nil or type(itemId) ~= 'number' then return end
	if not IJA_WRITHELPER.craftingItems[itemId] then
		IJA_WRITHELPER.craftingItems[itemId] = IJA_WritHelper_CraftItems:New(self, required)
	else
		IJA_WRITHELPER.craftingItems[itemId]:Add(self, required)
	end
	-- IJA_WRITHELPER:AddCraftItemUsed(itemId, condition, required)
end

function RecipeData_Object:GetAllCraftItemsForCondition()
    local craftItems = {}
    for itemId, itemInfo in pairs(IJA_WRITHELPER.craftingItems) do
        if itemInfo.usedIn[self.conditionId] then
            table.insert(craftItems, {
                ['itemId'] = itemId,
                ['required'] = itemInfo.usedIn[self.conditionId]
            })
        end
    end
    return craftItems
end

function RecipeData_Object:GetAllCraftItemsUsed()
    local craftItems = {}
    for itemId, itemInfo in pairs(IJA_WRITHELPER.craftingItems) do
        if itemInfo.usedIn[self.conditionId] then
            table.insert(craftItems, {
                ['itemId'] = itemId,
                ['required'] = itemInfo.required
            })
        end
    end
    return craftItems
end

function RecipeData_Object:SubtractItemsUsed()
    for itemId, itemInfo in pairs(IJA_WRITHELPER.craftingItems) do
        IJA_WRITHELPER:SubtractCraftItemUsed(itemId, self.conditionId)
    end
end

function RecipeData_Object:GetMissingCraftItemStrings()
    local craftItems = self:GetAllCraftItemsUsed()
    local missingStrings = {}
	for _, itemInfo in pairs(craftItems) do
		local function comparator(itemId, itemData)
			return itemId == GetItemId(itemData.bagId, itemData.slotIndex)
		end

		local itemData = IJA_WRITHELPER:GetItemData(itemId, comparator, IJA_BAG_ALL)
        local stackCount = itemData.stackCount or 0
    
        if itemInfo.required < stackCount then
			local itemLink = self:GetItemLink(itemInfo.itemId)
            table.insert(missingStrings, zo_strformat(GetString(SI_STATS_EQUIPMENT_BONUS_TOOLTIP_EMPTY_SLOT), itemLink))
        end
        return missingStrings
    end
end

function RecipeData_Object:UpdateFailedConditions()
	local failedConditions = {}
	
	local missingMessage = self:GetMissingMessage()
	if #missingMessage > 0 then
		for k, row in pairs(missingMessage) do
			table.insert(failedConditions, row)
		end
	end
	
	if self.improveItem then
		local improvementData, sufficientPrecursorReagents = self:BuildImprovementData()
		for k, data in pairs(improvementData) do
			if data.extraInfo then
				table.insert(failedConditions, data.extraInfo)
			end
		end
	end

	self.failedConditions = failedConditions
end

-------------------------------------
-- Search bank for items needed for writ
-------------------------------------
local function getAmmoutRequired(current, maximum, bagCount, bankCount)
	-- get num needed based on what is in inventory
	local amountRequired = (bankCount > 0 and (bagCount < (maximum - current)) and maximum - bagCount or 0)

	return amountRequired > 0 and (bankCount >= amountRequired) and amountRequired or bankCount, bankCount
end

function RecipeData_Object:RefreshBankItems()
	if string.match(self.condition, GetString(IJAWH_ACQUIRE_STRING)) then
		self.inBank = self:SearchBank()
	elseif self.conditionInfo and self.conditionInfo.craft then
		self.inBank = self:SearchBank()
	end
end

function RecipeData_Object:SearchBank()
	local condition ,current, maximum = self:GetConditionAndCounts()
	if current ~= maximum then
		local bagId, slotIndex = self:GetBankBagAndSlot(self.itemId, self.itemLink, self.isMaterWrit)
		
		if bagId then
			local amountRequired, bankCount = getAmmoutRequired(current, maximum, GetItemLinkStacks(self.itemLink))
			if amountRequired > 0 then
				IJA_WRITHELPER:BankListAdd(self.itemId, self.itemLink, bagId, slotIndex, amountRequired, self.questIndex)
				ZO_Alert(SOUNDS.NEGATIVE_CLICK, zo_strformat(SI_IJAWH_WRIT_ITEM_IN_BANK,self.itemLink, bankCount))
					
				if self.savedVars.handleWithdraw then
					local function atBankInteraction() self:AtBankInteraction() end
					self.control:RegisterForEvent(EVENT_OPEN_BANK, atBankInteraction)
				end
				return true
			end
		end
	end
	return false
end

--function RecipeData_Object:Shouldupdate()
function RecipeData_Object:HasConditionInfoChanged()
	local condition ,current, maximum = GetJournalQuestConditionInfo(self.questIndex, QUEST_MAIN_STEP_INDEX, self.conditionIndex)
	return condition ~= '' and self.current ~= current
end

function RecipeData_Object:TryCraftItem(craftFunction, ...)
	craftFunction(...)
	
	zo_callLater(function()
		if IJAWH_IsPerformingCraftProcess() then
			self:SubtractItemsUsed()
	--		IJA_WRITHELPER:SubtractCraftItemUsed(self.itemId, self.conditionId)
--			d( 'crafting started')
		else
--			d( 'crafting failed')
			-- failed to craft
			EVENT_MANAGER:UnregisterForEvent("IJAWH_ON_CRAFTED_ITEM_UPDATED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onCraftedItemUpdated)
		end
	end, 100)
end

--------------------------------------------------------------------------
-- Writ_Object shared
-------------------------------------
local Shared_Writ_Object = ZO_Object:Subclass()

function Shared_Writ_Object:New(parent, ...)
	local newObject = self:MultiSubclass(parent)
	zo_mixin(newObject, ...)
    newObject:Initialize(parent, ...)
    return newObject
end

function Shared_Writ_Object:Initialize(parent, writData)
	self.parent 		= parent
	
	self.inBank			= false
	self.completed		= false
	
	self.selectedData	= {}
	self.materialCount	= {}
	
	self.craftingConditions = {}
	self:Build()
end

function Shared_Writ_Object:Build()
	local questIndex = self.questIndex
	self.conditions = {}
	
	local conditionCount = self:GetJournalQuestNumConditions(self.questIndex, QUEST_MAIN_STEP_INDEX)
	
	for conditionIndex = 1, conditionCount do
		local condition ,current, maximum = GetJournalQuestConditionInfo(questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
--		d( 'condition', condition)
--		d( 'current', current)
--		d( 'maximum', maximum)
--		if string.find(condition, GetString(SI_IJAWH_DELIVER)) then
		if self:GetCompleted() then
			self.completed = true
		end
		
		local recipeData_Object = RecipeData_Object:New(self, self.writId, conditionIndex, condition ,current, maximum)
		
		if condition ~= '' and current ~= maximum then
			local conditionInfo = self:GetConditionObject(conditionIndex)
			if conditionInfo ~= nil then
				recipeData_Object:Build(conditionInfo)
				
				if conditionInfo.itemSetId then
					self.itemSetId = conditionInfo.itemSetId
					self.improveItem = recipeData_Object.improvementItemData ~= nil
				end
			end
		end
		
		table.insert(self.conditions, recipeData_Object)
	end
	
	self:SortRecipeData()
end

function Shared_Writ_Object:SortRecipeData()
	self.sortedConditions = self.conditions
end

-------------------------------------
-- 
-------------------------------------
function Shared_Writ_Object:OnCloseCraftingStation()
	EVENT_MANAGER:UnregisterForEvent("IJAWH_ON_CRAFTED_ITEM_UPDATED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onCraftedItemUpdated)
	self:RemoveCraftKeybind()
end

function Shared_Writ_Object:OnCraftingStation()
	local recipeObject = self:GetNextRecipeObject()
	self.currentCondition = recipeObject
	
	if recipeObject ~= nil then
		if recipeObject:AutoImproveSmithingItem() then
			recipeObject:TryImproveItem(recipeObject:GetImprovementItemData())
		else
			recipeObject:SetStation()
			EVENT_MANAGER:RegisterForEvent("IJAWH_ON_CRAFTED_ITEM_UPDATED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onCraftedItemUpdated)
			if self:IsCrafting() then
				recipeObject:AutoCraft()
			end
			if not IsInGamepadPreferredMode() and (self.craftingType == CRAFTING_TYPE_ALCHEMY and not IsJustaEasyAlchemy) then
				self:AddCraftKeybind()
			end
--			if recipeObject:CanCraft() then --< not in use since self:GetNextCraftableItem() only returns data if can craft
--			end
		end
	end
end

function Shared_Writ_Object:GetNextRecipeObject()
	local alertText
	
	for _, recipeData_Object in pairs(self.sortedConditions) do
		if not recipeData_Object:GetCompleted() then
			if self.writType == WRIT_TYPE_CRAFT then
				alertText = recipeData_Object:GetCraftItemResult()
			elseif self.writType == WRIT_TYPE_REFINE then
				alertText = recipeData_Object:GetRefineItemResult()
			elseif self.writType == WRIT_TYPE_DECONSTRUCT then
				alertText = recipeData_Object:GetDeconItemResult()
			end
			if alertText == nil then
				return recipeData_Object
			end
		end
	end
	
	if alertText then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, alertText)
	end
end	

function Shared_Writ_Object:GetConditionObject(selectedIndex)
	for k, conditionInfo in pairs(self.conditionData) do
		if conditionInfo.conditionIndex == selectedIndex then
			return conditionInfo
		end
	end
end

function Shared_Writ_Object:GetCurrentCondition()
	return self.currentCondition
end

function Shared_Writ_Object:GetWrtitType()
	return self.writType
end

function Shared_Writ_Object:GetQuestIndex()
	if IJA_WRITHELPER.questIndexToDataMap[self.questIndex] then
		self:SafelyDestroy(IJA_WRITHELPER.questIndexToDataMap[self.questIndex])
	end
	
	for i, questInfo in ipairs(IJA_WRITHELPER.writMasterList) do
		if self.writId == questInfo.writId then
			return questInfo.questIndex
		end
	end
end

-------------------------------------
--
-------------------------------------
function Shared_Writ_Object:GetCompleted()
	local conditionCount = self:GetJournalQuestNumConditions(self.questIndex, QUEST_MAIN_STEP_INDEX)
	local total, comp = 0, 0
	for conditionIndex = 1, conditionCount do
		local condition ,current, maximum, _, _, _, _, conditionType = GetJournalQuestConditionInfo(self.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)

		if condition ~= '' then
			total = total + 1
			if current == maximum or conditionType == QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS or conditionType == QUEST_CONDITION_TYPE_TALK_TO then
				comp = comp + 1
			end
		end
	end
	return total == comp
end
--[[
			return conditionType == QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS or 
				conditionType == QUEST_CONDITION_TYPE_TALK_TO or current == maximum
]]

function Shared_Writ_Object:Update(force)
	local origQestIndex = self.questIndex
	self.questIndex = self:GetQuestIndex()

	if self.questIndex ~= nil then
		self.completed = self:GetCompleted()

		if self.completed then return end
	--	self:RefreshWritMasterList()
		local conditions = {}
		
		local conditionCount = self:GetJournalQuestNumConditions(self.questIndex, QUEST_MAIN_STEP_INDEX)
		if #self.conditions ~= conditionCount then
			self:Build()
		else
			for conditionIndex, recipeData_Object in pairs(self.conditions) do
				if force or recipeData_Object:HasConditionInfoChanged() then
					recipeData_Object:UpdateConditionAndCounts()
					local conditionInfo = recipeData_Object.conditionInfo
	--				d( '--	conditionInfo', conditionInfo)
					if conditionInfo ~= nil then
						recipeData_Object:Build(conditionInfo)
					end
				end
				table.insert(conditions, recipeData_Object)
			end
			self.conditions = conditions
			self:SortRecipeData()
		end
		
		IJA_WRITHELPER:MapQuestIndexToDataMap(self)
	else
		self.questIndex = origQestIndex
		IJA_WRITHELPER:Destroy(self)
	end
end

-------------------------------------
-- 
-------------------------------------
function Shared_Writ_Object:AddMaterialCounts(matName,  stackCount)
	local curCount = self.materialCount[matName] or 0
	self.materialCount[matName] = curCount + stackCount
end

function Shared_Writ_Object:GetMaterialCount(matName)
	return self.materialCount[matName]
end

--	Panel data		-----------------------------------------------------------
function Shared_Writ_Object:GetWritIcon(panelData, completed, inBank)
	local function getIconSuffix(panelData)
		local index = panelData.isSmithing and 1 or panelData.craftingType
		local highlight = (self.savedVars.autoCraft[index] and not completed) or false
		
		return iconSuffix[highlight]
	end
	
	local icon = completed and icon_Completed or (inBank and not completed) and "/esoui/art/tooltips/icon_bank.dds" or self.icon .. getIconSuffix(panelData)
	
	return icon
end

function Shared_Writ_Object:GetPanelDetails()
	local tot, comp, numFails, cond, inBank = 0, 0, 0, '', false
--	local bankTextIcon = zo_iconFormat("/esoui/art/tooltips/icon_bank.dds", "20", "20")
--	local noticeTextIcon = '  ' .. zo_iconFormat("/esoui/art/tutorial/tutorial_illo_canceledit.dds", "25", "25")
	local bankTextIcon = '  ' .. "|cFFD700|t100%:100%:/esoui/art/tooltips/icon_bank.dds:inheritcolor|t|r"
	local noticeTextIcon = '  ' .. "|cff6666|t100%:100%:/esoui/art/tutorial/tutorial_illo_canceledit.dds:inheritcolor|t|r"

	self.inBank = false
--	IJA_WritHelper_CraftItems:ResetCraftItemsForWrit(self)
	for k, recipeData_Object in pairs(self.sortedConditions) do
		local condition ,current, maximum = recipeData_Object:GetUpdateConditionAndCounts()
		
		if  condition ~= '' then
--			if string.find(condition, GetString(SI_IJAWH_DELIVER)) then

			self.completed = self:GetCompleted()
			if self.completed then
				cond = condition
			else
				
				tot = tot + 1 -- build number of conditions
				
				-- check if the item is in the bank
				recipeData_Object:RefreshBankItems()
				if recipeData_Object.inBank then
					cond = cond .. bankTextIcon .. " "
					self.inBank = true
				end
				cond = cond .. condition .. "\n"
			
				if maximum == current then
					comp = comp + 1 -- number of completed conditions
				else

					recipeData_Object:UpdateFailedConditions()
					
					if #recipeData_Object.failedConditions > 0 then
						local failsCondition = ''
						for k, failedCondition in pairs(recipeData_Object.failedConditions) do
							failsCondition = failsCondition .. noticeTextIcon .. failedCondition .. "\n"
						end
						if failsCondition ~= '' then
							cond = cond .. failsCondition
							numFails = numFails + 1
						end
					end

				end
			end
		end
	end
	self.numComplete = comp
	return cond, comp, tot, numFails
end

function Shared_Writ_Object:UpdatePanelData()
	-- generates the data needed for the writ panel
--	self:UpdateConditionData()
	self.materialCount = {}
	self.inBank = false
	
--	self.questIndex = self:GetQuestIndex()
	
	local panelData = {
		["isSmithing"] 		= IsSmithingCraftingType(self.craftingType),
		["craftingType"]	= self.craftingType,
	}
	
--	self:Update()
	local cond, comp, tot, numFails = self:GetPanelDetails()
	
	panelData.state 	= getCraftableState(self.completed, tot, numFails)
	panelData.icon		= self:GetWritIcon(panelData, self.completed, self.inBank)
	panelData.name		= self.name
	panelData.status	= self.completed and '' or comp .. "/" .. tot
	panelData.inBank	= self.inBank
	panelData.toolTip	= string.gsub(cond, "\n$", "")
	panelData.canCraft	= (tot - comp) > numFails
	panelData.completed = self.completed
	
	self.panelData = panelData
	
	IJA_WRITHELPER:MapQuestIndexToDataMap(self)
end

--	Placeholders	-----------------------------------------------------------
function Shared_Writ_Object:BuildImprovementData()
    -- intended to be overwritten
	-- generates the data needed for each item needed to be crafted
end

function Shared_Writ_Object:UpdateRecipeData()
    -- intended to be overwritten
	-- generates the data needed for each item needed to be crafted
end

function Shared_Writ_Object:AutoCraft()
    -- intended to be overwritten
	-- used for auto-crafting
end

function Shared_Writ_Object:SetStation()
	-- overwritten for each crafting type
	-- used to set the station to craft manually and set the tooltip for the current item
	-- auto crafting will start prior to the first item being set in station. this will cause the initial tooltip to be wrong
end

function Shared_Writ_Object:GetMaxIterations()
    -- intended to be overwritten
	--	returns itemLink, 
end

function Shared_Writ_Object:SelectMode()
    -- intended to be overwritten
	-- used to set the station to the crafting tab
end

function Shared_Writ_Object:HasItemToImproveForWrit()
	return false
end

function Shared_Writ_Object:Alert()
end
function Shared_Writ_Object:GetMissingMessage()
end

IJA_WritHelper_Shared_Writ_Object = Shared_Writ_Object
