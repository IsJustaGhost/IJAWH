local function getCraftableState(completed, tot, numOver)
	return completed and 1 or	-- completed
		numOver == 0 and 2 or	-- not completed but all craftable
		numOver < tot and 3 or		-- not completed, not all items are craftable
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
-- 
-------------------------------------
local RecipeData_Object = ZO_Object:Subclass()

function RecipeData_Object:New(parent, ...)
	local newObject = ZO_Object:MultiSubclass(self, parent)
	newObject:Initialize(parent, ...)
	return newObject
end

function RecipeData_Object:Initialize(parent, questIndex, conditionIndex, condition ,current, maximum)
	self.parent 	= parent
	self.current	= current
	self.maximum	= maximum
	self.condition	= condition
	self.questIndex = questIndex
	self.conditionIndex = conditionIndex
end

function RecipeData_Object:Build(conditionIndex, conditionInfo)
	self.conditionInfo = conditionInfo
	
	if string.match(self.condition, GetString(IJAWH_ACQUIRE_STRING)) then
		self.itemId = conditionInfo.itemId
		self.itemLink = self:GetItemLink(self.itemId)
		self.comparator = self:GetComparator(self.itemLink)
--		self.inBank = self:SearchBank(self.questIndex, self.conditionInfo, self.comparator, true)
		self.inBank = self:SearchBank(IsAcquire)
		
		IJA_WRITHELPER:MapWritData(self)
	elseif conditionInfo.craft then
		local recipeData, itemId, itemLink = self:GetRecipeData(conditionInfo)
		if itemId ~= nil then
			self.itemId = itemId
			self.isPoison = self:GetBaseIsPoison(itemId)
			self.recipeData = recipeData 
			self.perIteration = self:GetPerIteration()
			
			itemLink = self:MakeLinkCrafted(itemLink)
			
			self.itemLink = itemLink
			conditionInfo.itemLink = itemLink
--			self.inBank = self:SearchBank(self.questIndex, self.conditionInfo, self.comparator)
			self.inBank = self:SearchBank()
			
			IJA_WRITHELPER:MapWritData(self)
		end
	end
end

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

function RecipeData_Object:GetComparator(itemLink)
	local itemType, specializedItemType = GetItemLinkItemType(itemLink)

	for k, comparator in pairs(IJA_Comparators) do
		if comparator({itemType = itemType}) then 
			return comparator
		end
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

	if current == maximum then
		return 0
	else
		local numRequiered = math.ceil(maximum - current)
		local numIterations = math.ceil(numRequiered / self:GetPerIteration())
		return numIterations
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

function RecipeData_Object:CanCraftItemHere()
	if self.condition ~= '' then
		if self.isMaterWrit then
			local itemSetId = self.itemSetId
			local  setName = select(2, GetItemLinkSetInfo(self.itemLink))
			
			if not CanSpecificSmithingItemSetPatternBeCraftedHere(itemSetId) then
				local strng = zo_strformat(GetString(SI_IJAWH_USE_SET_STATION), setName)
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, strng)

				if LibSets then
					local zoneId = LibSets.setInfo[itemSetId].zoneIds[1]
					local zoneName = GetZoneNameById(zoneId)
					
					strng = strng .. '\n' .. zo_strformat(GetString(SI_IJAWH_FOUND_IN), zoneName)
				end
				-- notify in chat that a set station must be used
				d( strng)
				return false
			end
		end
		
		return not self:GetCompleted()
	end
end

function RecipeData_Object:GetMissingMessage()
	return {}
end

--	Search bank		-----------------------------------------------------------
--[[
function RecipeData_Object:SearchBank(...)
	return self:BeginBankSearch(...)
end
--]]
function RecipeData_Object:RefreshBankItems()
	if string.match(self.condition, GetString(IJAWH_ACQUIRE_STRING)) then
		self.inBank = self:SearchBank(IsAcquire)
	elseif self.conditionInfo and self.conditionInfo.craft then
		self.inBank = self:SearchBank()
	end
end

local function getAmmoutRequired(current, maximum, bagCount, bankCount)
	-- get num needed based on what is in inventory
	local amountRequired = (bankCount > 0 and (bagCount < (maximum - current)) and maximum - bagCount or 0)

	return amountRequired > 0 and (bankCount >= amountRequired) and amountRequired or bankCount, bankCount
end

function RecipeData_Object:SearchBank(isAcquire)
	local condition ,current, maximum = self:GetConditionAndCounts()
	if current ~= maximum then
		local bagId, slotIndex = self:GetBankBagAndSlot(self.itemId, self.itemLink, self.comparator, self.encodedAlchemyTraits, isAcquire)
		
		if slotIndex ~= nil then
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

-------------------------------------
-- Writ_Object shared
-------------------------------------
local Shared_Writ_Object = ZO_Object:Subclass()

function Shared_Writ_Object:New(parent, ...)
	local newObject = ZO_Object:MultiSubclass(self, parent)
    newObject:Initialize(parent, ...)
    return newObject
end

function Shared_Writ_Object:Initialize(parent, writData)
	self.parent 		= parent
	
	self.name			= writData.name
	self.writId			= writData.writId
	self.questIndex		= writData.questIndex
	self.isMaterWrit	= writData.isMaterWrit
	self.craftingType	= writData.craftingType
	self.conditionData	= writData.conditionData
	
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
	
	local inBank, required = 0, 0
	local numComplete, numRecipes, completed = 0, 0, false
	
	local conditionCount = GetJournalQuestNumConditions(questIndex, QUEST_MAIN_STEP_INDEX)
	
	for conditionIndex = 1, conditionCount do
		local condition ,current, maximum = GetJournalQuestConditionInfo(questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
		
--		if string.find(condition, GetString(SI_IJAWH_DELIVER)) then
		if self:GetCompleted() then
			self.completed = true
		end
		
		local recipeData_Object = RecipeData_Object:New(self, questIndex, conditionIndex, condition ,current, maximum)
		
		if condition ~= '' and current ~= maximum then
			local conditionInfo = self:GetConditionObject(conditionIndex)
			if conditionInfo ~= nil then
				recipeData_Object:Build(conditionIndex, conditionInfo)
				
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

function Shared_Writ_Object:GetNextCraftableItem()
	local alertId = 0
	for k, recipeData_Object in pairs(self.sortedConditions) do
		if recipeData_Object:CanCraftItemHere() then
			local maxIterations, craftingResult = recipeData_Object:GetMaxIterations()
			if maxIterations > 0 then
				if recipeData_Object.isMaterWrit and recipeData_Object:HasItemToImproveForWrit() then
					-- for master smithing writs, if item has already been crafted
					-- skip item if not autoImprove, allows selecting other writ for station
					if self.savedVars.autoImprove then
						return recipeData_Object, true
					end
				else
					return recipeData_Object, false
				end
			else
				alertId = craftingResult
			end
		end
	end
	
	ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString('SI_TRADESKILLRESULT', alertId))
end

function Shared_Writ_Object:SortRecipeData()
	self.sortedConditions = self.conditions
end

function Shared_Writ_Object:OnCloseCraftingStation()
	EVENT_MANAGER:UnregisterForEvent("IJAWH_ON_CRAFTED_ITEM_UPDATED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onCraftedItemUpdated)
	self:RemoveCraftKeybind()
end

function Shared_Writ_Object:OnCraftingStation()
	local recipeObject, improveSmithingitem = self:GetNextCraftableItem()
	
	if recipeObject ~= nil then
		recipeObject:SetStation()
		self.currentCondition = recipeObject
		
		if improveSmithingitem then
			recipeObject:TryImproveItem(recipeObject:GetImprovementItemData())
		else
			if recipeObject:CanCraft() then --< not in use since self:GetNextCraftableItem() only returns data if can craft
				EVENT_MANAGER:RegisterForEvent("IJAWH_ON_CRAFTED_ITEM_UPDATED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onCraftedItemUpdated)
				if self:IsCrafting() then
					recipeObject:AutoCraft()
				end
				if not IsInGamepadPreferredMode() then
					self:AddCraftKeybind()
				end
			end
		end
	end
end
--[[
function Shared_Writ_Object:GetCompleted()
	local conditionCount = GetJournalQuestNumConditions(self.questIndex, QUEST_MAIN_STEP_INDEX)
	for conditionIndex = 1, conditionCount do
		local condition, current, maximum, _, _, _, _, conditionType = GetJournalQuestConditionInfo(self.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
		local conditionType = select(8, GetJournalQuestConditionInfo(self.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex))
		
--		local condition ,current, maximum = GetJournalQuestConditionInfo(self.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
		if condition ~= '' then
			if string.find(condition, GetString(SI_IJAWH_DELIVER)) then
				return true
			end
		end
	end
end
--]]
function Shared_Writ_Object:AddMaterialCounts(matName,  stackCount)
	local curCount = self.materialCount[matName] or 0
	self.materialCount[matName] = curCount + stackCount
end

function Shared_Writ_Object:GetMaterialCount(matName)
	return self.materialCount[matName]
end

function Shared_Writ_Object:GetConditionObject(selectedIndex)
	for k, conditionInfo in pairs(self.conditionData) do
		if conditionInfo.conditionIndex == selectedIndex then
			return conditionInfo
		end
	end
end

function Shared_Writ_Object:Update()
	self.questIndex = self:GetQuestIndex()
	self.completed = self:GetCompleted()
	if self.completed then return end
--	self:RefreshWritMasterList()
	local conditions = {}
	
	local conditionCount = GetJournalQuestNumConditions(self.questIndex, QUEST_MAIN_STEP_INDEX)
	if #self.conditions ~= conditionCount then
		d( '--	 rebuild')
		self:Build()
	else
		d( '--	 update')
		for conditionIndex, recipeData_Object in pairs(self.conditions) do
			local conditionType = select(8, GetJournalQuestConditionInfo(self.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex))
		
			local condition ,current, maximum = recipeData_Object:GetUpdateConditionAndCounts()
			
			if condition ~= '' then
				local conditionInfo = recipeData_Object.conditionInfo
--				d( '--	conditionInfo', conditionInfo)
				if conditionInfo ~= nil then
					recipeData_Object:Build(conditionIndex, conditionInfo)
				end
				
				table.insert(conditions, recipeData_Object)
			end
		end
		self.conditions = conditions
		self:SortRecipeData()
	end
	
	IJA_WRITHELPER:MapQuestIndexToDataMap(self)
end

function Shared_Writ_Object:GetItemList(comparator)
	return SHARED_INVENTORY:GenerateFullSlotData(comparator, BAG_VIRTUAL,BAG_BACKPACK,BAG_BANK, BAG_SUBSCRIBER_BANK)
end

function Shared_Writ_Object:GetCurrentCondition()
	return self.currentCondition
end

function Shared_Writ_Object:GetQuestIndex()
	if IJA_WRITHELPER.questIndexToDataMap[self.questIndex] then
		 IJA_WRITHELPER.questIndexToDataMap[self.questIndex] = nil
	end
	
	for i, questInfo in ipairs(IJA_WRITHELPER.writMasterList) do
		if self.writId == questInfo.writId then
			return questInfo.questIndex
		end
	end
end

function Shared_Writ_Object:TryCraftItem(craftFunction, ...)
	craftFunction(...)
	
	zo_callLater(function()
		if IJAWH_IsPerformingCraftProcess() then
--			d( 'crafting started')
		else
--			d( 'crafting failed')
			-- failed to craft
			EVENT_MANAGER:UnregisterForEvent("IJAWH_ON_CRAFTED_ITEM_UPDATED", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onCraftedItemUpdated)
		end
	end, 100)
end

function Shared_Writ_Object:GetCompleted()
	local conditionCount = GetJournalQuestNumConditions(self.questIndex, QUEST_MAIN_STEP_INDEX)
	for conditionIndex = 1, conditionCount do
		local condition, _, _, _, _, _, _, conditionType = GetJournalQuestConditionInfo(self.questIndex, QUEST_MAIN_STEP_INDEX, conditionIndex)
		if condition ~= '' then
			return conditionType == QUEST_CONDITION_TYPE_ADVANCE_COMPLETABLE_SIBLINGS or 
				conditionType == QUEST_CONDITION_TYPE_TALK_TO
		end
	end
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
	local bankTextIcon = zo_iconFormat("/esoui/art/tooltips/icon_bank.dds", "20", "20")
	local noticeTextIcon = '  ' .. zo_iconFormat("/esoui/art/tutorial/tutorial_illo_canceledit.dds", "25", "25")
	
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
	
	self.questIndex = self:GetQuestIndex()
	
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
function Shared_Writ_Object:GetComparator()
    -- intended to be overwritten
end

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
