function format_list(tableList)
    local out = {}
    for k,v in pairs(tableList) do
        table.insert(out, v)
    end
    return table.concat(out, " ")
end

function IJAWH:GetNextDialogue()
	for i=1,#self.dialogueQueue  do 
		if self.dialogueQueue[i] then
			if string.match(self.dialogueQueue[i],IJAWH.currentQueue) then
				self.dialogueQueue[i] = nil
			end
		end
	end
	if #self.dialogueQueue > 0 then
		local dialogue = self.dialogueQueue[#self.dialogueQueue]
		zo_callLater(function() ZO_Dialogs_ShowDialog(dialogue) end, 500)
	end
end
function IJAWH:DialogueQueue(dialogue)
	if self.Contains(dialogue,self.dialogueQueue) then return end
	self.dialogueQueue[#self.dialogueQueue + 1] = dialogue
	if #self.dialogueQueue == 1 then
		zo_callLater(function() ZO_Dialogs_ShowDialog(dialogue) end, 1000)
	end
end

local function atBankInteraction()
	for k,v in pairs(IJAWH.withdrawItems) do
		local qName, itemLink, amountRequired, maximum, isAcquire = v.qName, v.itemLink, v.amountRequired, v.maximum, v.isAcquire
		local bagId, slotIndex
		if isAcquire then
			local itemData = IJAWH:getItemDataFromLink(itemLink)
			bagId, slotIndex = itemData.bagId, itemData.slotIndex
		else
			bagId, slotIndex = IJAWH:GetBagAndSlotForCreated(itemLink)
		end
		local keyName = k
		local function onMoveItem()
			EVENT_MANAGER:UnregisterForEvent("IJAWH_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
			IJAWH.withdrawItems[keyName] = nil
			IJAWH_WITHDRAW_ITEMS = IJAWH_WITHDRAW_ITEMS - 1
					
			if IJAWH_WITHDRAW_ITEMS > 0 then
				zo_callLater(atBankInteraction, 200)
			else
				local writDataTemp = {}
				for i=1, #IJAWH.writData do
					if not IJAWH.writData[i].WithdrawText then 
						writDataTemp[#writDataTemp+1] = IJAWH.writData[i]
					end
				end	
				if #writDataTemp > 0 then
					IJAWH.writData = writDataTemp
				end
				IJAWH.activeEvents.OpenBank = false
				EVENT_MANAGER:UnregisterForEvent("IJWH_Open_Bank", EVENT_OPEN_BANK)
				CALLBACK_MANAGER:FireCallbacks("IJAWH_Update_Writs_Panel")

				local function onBankClose()
					EVENT_MANAGER:UnregisterForEvent("IJAWH_ON_CLOSE_BANK", EVENT_CLOSE_BANK, onBankClose)
					IJAWH:refreshWritData()
				end
				EVENT_MANAGER:RegisterForEvent("IJAWH_ON_CLOSE_BANK", EVENT_CLOSE_BANK, onBankClose)
			end
		end
		
		if DoesBagHaveSpaceFor(BAG_BACKPACK, bagId, slotIndex) then
			local emptySlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
			EVENT_MANAGER:RegisterForEvent("IJAWH_INVENTORY_SINGLE_SLOT_UPDATE", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, onMoveItem)
			CallSecureProtected("RequestMoveItem", bagId, slotIndex, BAG_BACKPACK, emptySlot, amountRequired)
			break
		else
			
			ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, SI_INVENTORY_ERROR_INVENTORY_FULL)
			CALLBACK_MANAGER:FireCallbacks("IJAWH_Update_Writs_Panel")
			return
		end
	end
	
end

function IJAWH:GetBagAndSlotForCreated(itemLink)
	local itemName = GetItemLinkName(itemLink)
	local itemLinkType = GetItemLinkItemType(itemLink)
	local bankBags = {BAG_BANK, BAG_SUBSCRIBER_BANK}
	for i, bagId in ipairs(bankBags) do
		local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
		while slotIndex do
			local itemType = GetItemType(bagId, slotIndex)
			if itemType == itemLinkType and not IsItemPlayerLocked(bagId, slotIndex) then
				if string.match(GetItemName(bagId, slotIndex), itemName) then
					local creatorName = GetItemCreatorName(bagId, slotIndex)
					if creatorName and string.match(creatorName, GetUnitName("player")) then
						return bagId, slotIndex
					end
				end
			end
			slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
		end
	end
    return false
end
local function inWithdrawList(itemLink)
	for i=1, #IJAWH.withdrawItems do
		if IJAWH.withdrawItems[i].itemLink == itemLink then return true end
	end
end
function IJAWH:IsRequieredInBank(qIndex, qName, lineId, itemLink, maximum, isAcquire)
	local bagId, slotIndex
	if isAcquire then
		local itemData = IJAWH:getItemDataFromLink(itemLink)
		bagId, slotIndex = itemData.bagId, itemData.slotIndex
	else
		bagId, slotIndex = IJAWH:GetBagAndSlotForCreated(itemLink)
	end
	
	local smithingItemTypes = {ITEMTYPE_ARMOR,ITEMTYPE_WEAPON}
	local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
	local keyName
	local itemLinkName = GetItemLinkName(itemLink)
	if bankCount > 0 and slotIndex then
		local bagNbank = bagCount > bankCount and (bagCount - bankCount) or (bankCount - bagCount)
		local amountRequired = (bagNbank >= maximum) and maximum or bagNbank
		if self.savedVariables.handleWithdraw then
			if not IJAWH.withdrawItems[itemLinkName] then
				IJAWH_WITHDRAW_ITEMS = IJAWH_WITHDRAW_ITEMS + 1
				IJAWH.withdrawItems[itemLinkName] = {
					["qName"] = qName,
					["amountRequired"]= amountRequired, 
					["maximum"] = maximum,
					itemLink = itemLink,
					isAcquire = isAcquire
				}
			end
			if self.savedVariables.showWithdrawInChat then d(zo_strformat(SI_IJAWH_ADDED_TO_WTHDRAW_LIST, itemLink, amountRequired)) end

			if not IJAWH.activeEvents.OpenBank then
				EVENT_MANAGER:RegisterForEvent("IJWH_Open_Bank", EVENT_OPEN_BANK, atBankInteraction)
				IJAWH.activeEvents.OpenBank = true
			end
		end
		
		if not IJAWH.savedVariables.tutorials.IJAWH_TUTORIAL_AUTO_WITHDRAW then
			IJAWH:DialogueQueue("IJAWH_TUTORIAL_AUTO_WITHDRAW")
		end
		if self.savedVariables.showInBankAlert then
			if not inWithdrawList(itemLink) then
				ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, zo_strformat(SI_IJAWH_WRIT_ITEM_IN_BANK,itemLink, bankCount))
			end
		end
		if amountRequired > 0 then return true, amountRequired end -- returns true to prevent iteration equaling 0
	end
	return false, 0
end

function IJAWH:GetAmountToMake(...) -- (required - amount in bag)-- not in use
	local sum = 0
	for k, v in ipairs{...} do
		if sum == 0 then 
			sum = (v > 0 and v or 0)
		else 
			sum = sum - (v > 0 and v or 0)
		end
	end
	return (sum > 0 and sum or 0)
end
		
function IJAWH:BufferReached(key, buffer)
	if key == nil then return end
	if BufferTable[key] == nil then BufferTable[key] = {} end
	BufferTable[key].buffer = buffer or 3
	BufferTable[key].now = GetFrameTimeSeconds()
	if BufferTable[key].last == nil then BufferTable[key].last = BufferTable[key].now end
	BufferTable[key].diff = BufferTable[key].now - BufferTable[key].last
	BufferTable[key].eval = BufferTable[key].diff >= BufferTable[key].buffer
	if BufferTable[key].eval then BufferTable[key].last = BufferTable[key].now end
	return BufferTable[key].eval
end

function IJAWH:TryAddItemToCraft(inventorySlot)
--	if not inventorySlot.meetsUsageRequirement then return end
    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    if SYSTEMS:IsShowing("alchemy") then
        SYSTEMS:GetObject("alchemy"):AddItemToCraft(bagId, slotIndex)
    elseif ZO_Enchanting_IsSceneShowing() then
		if IsInGamepadPreferredMode() then
			GAMEPAD_ENCHANTING:AddItemToCraft(bagId, slotIndex)
		else
			ENCHANTING:AddItemToCraft(bagId, slotIndex)
		end
	end
end

function IJAWH:GetIngredientLabel(itemData,numNeeded)
	local itemListName = ''
	if itemData.stackCount ~= nil then
		if itemData.stackCount >= numNeeded then
			local stackRemainig = (itemData.stackCount - numNeeded)
			local stackLable = 0
			if stackRemainig >= 100 then 
				stackLable = zo_strformat("|c<<1>><<2>>|r","3CA2E9",itemData.stackCount)	-- blue
			elseif stackRemainig >= 50 and stackRemainig <= 99 then 
				stackLable = zo_strformat("|c<<1>><<2>>|r","3ce989",itemData.stackCount)	-- green
			elseif stackRemainig >= 20 and stackRemainig <= 49 then 
				stackLable = zo_strformat("|c<<1>><<2>>|r","E6E93C",itemData.stackCount)	-- yellow
			elseif stackRemainig >= 5 and stackRemainig <= 19 then 
				stackLable = zo_strformat("|c<<1>><<2>>|r","E9913C",itemData.stackCount)	-- orange
			else
				stackLable = zo_strformat("|c<<1>><<2>>|r","FF4040",itemData.stackCount)	-- red
			end
			itemListName = GetItemLink(itemData.bagId, itemData.slotIndex)
			return itemListName, stackLable, true	--	hasEnough == true
		else
			stackLable = zo_strformat("|c<<1>><<2>>|r","FF4040",itemData.stackCount)	-- red
			itemListName = zo_strformat("|c<<1>><<2>>|r","FF4040",itemData.name)
			return itemListName, stackLable, false	--	hasEnough == false
		end
	end
end

function IJAWH:getItemDataFromLink(itemLink)
	local bagCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
	local totalStacks = bagCount + bankCount + craftBagCount
	local itemId = GetItemLinkItemId(itemLink)
	local itemName = GetItemLinkName(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
	local bagId, slotIndex = IJAWH:GetFirstStack(itemId, itemType)
	local itemData = {name = itemName, bagId = bagId, slotIndex = slotIndex, stackCount = totalStacks}
	return itemData
end

function IJAWH:GetItemData(itemName,itemTypeList)
	local allBags = {BAG_VIRTUAL,BAG_BACKPACK,BAG_BANK, BAG_SUBSCRIBER_BANK}
	local sum = 0
	if itemName ~= nil then
		for _, bagId in pairs(allBags) do -- check backpack, bank, craft bag
			for index, data in pairs(SHARED_INVENTORY.bagCache[bagId])do
				if data ~= nil then
					local itemType = GetItemType(bagId, data.slotIndex)
					if self:ContainsNumber(itemType, itemTypeList) and not IsItemPlayerLocked(bagId, data.slotIndex) then
						if self:Contains(string.lower(data.name), string.lower(itemName)) then
					--	if data.rawName == itemName or string.find(string.lower(data.name),itemName) then
							return data
						end
					end
				end
			end
		end
		local itemData = {}
		itemData.name = itemName
		itemData.stackCount = 0
		return itemData
	end
end

function IJAWH:Equal(text, keyList)
    if text == nil or text == "" or keyList == nil or #keyList == 0 then
        return nil
    end
    local lowerText = string.lower(text)
    local result
    for _, key in ipairs(keyList) do
        if key and key ~= "" then
            if text == key then
                return true
            end
            local lowerKey = string.lower(key)
            if lowerText == lowerKey then
                return true
            end
        end
    end
    return nil
end

function IJAWH:EqualAll(textList, keyList)
    if textList == nil or #textList == 0 or keyList == nil or #keyList == 0 then
        return nil
    end
    for _, text in ipairs(textList) do
        if (not self:Equal(text, keyList)) then
            return nil
        end
    end
    return true
end

function IJAWH:GetHouseBankIdList()

    local houseBankBagId = GetBankingBag()
    if GetInteractionType() == INTERACTION_BANK
        and IsOwnerOfCurrentHouse()
        and IsHouseBankBag(houseBankBagId) then
        return {houseBankBagId}

    elseif IsOwnerOfCurrentHouse() then
        return {BAG_HOUSE_BANK_ONE,
                BAG_HOUSE_BANK_TWO,
                BAG_HOUSE_BANK_THREE,
                BAG_HOUSE_BANK_FOUR,
                BAG_HOUSE_BANK_FIVE,
                BAG_HOUSE_BANK_SIX,
                BAG_HOUSE_BANK_SEVEN,
                BAG_HOUSE_BANK_EIGHT,
                BAG_HOUSE_BANK_NINE,
                BAG_HOUSE_BANK_TEN}
    end
    return {}
end

function IJAWH:GetCraftingBagList()

    if GetInteractionType() == INTERACTION_BANK and IsOwnerOfCurrentHouse() then
        local _, name, _, _, additionalInfo, houseBankBagId = GetGameCameraInteractableActionInfo()
        if additionalInfo == ADDITIONAL_INTERACT_INFO_HOUSE_BANK then
            return {
                BAG_BANK,
                houseBankBagId,
                BAG_BACKPACK,
                BAG_VIRTUAL,
            }
        end
    end

    return {
        BAG_BANK,
        BAG_SUBSCRIBER_BANK,
        BAG_BACKPACK,
        BAG_VIRTUAL,
    }
end

function IJAWH:GetFirstStack(itemId, itemTypeList, bagId)
    if itemId == nil then
        return nil, nil
    end
	local bagList = {}
	if bagId then
		bagList = bagId
	else
		bagList = self:GetCraftingBagList()
	end
	for i, bagId in ipairs(bagList) do
		local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
		while slotIndex do
			local itemType = GetItemType(bagId, slotIndex)
			if self:ContainsNumber(itemType, itemTypeList) and not IsItemPlayerLocked(bagId, slotIndex) then
				if GetItemId(bagId, slotIndex) == itemId then
					return bagId, slotIndex
				end
			end
			slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
		end
	end
    return nil, nil
end

function IJAWH:GetStackList(itemTypeList)
    local list = {}
    for i, bagId in ipairs({BAG_BACKPACK, BAG_VIRTUAL, BAG_BANK, BAG_SUBSCRIBER_BANK}) do
        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            local itemType = GetItemType(bagId, slotIndex)
            if self:ContainsNumber(itemType, itemTypeList) and not IsItemPlayerLocked(bagId, slotIndex) then

                local itemId = GetItemId(bagId, slotIndex)
                local _, stack = GetItemInfo(bagId, slotIndex)
                local totalStack = list[itemId] or 0
                list[itemId] = totalStack + stack
            end
            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end
    return list
end

function IJAWH:GetHouseStackList()

    if GetInteractionType() == INTERACTION_BANK then
        if (not IsOwnerOfCurrentHouse()) then
            return {}
        end
    end


    local list = {}
    for _, bagId in pairs(self:GetHouseBankIdList()) do
        local slotIndex = ZO_GetNextBagSlotIndex(bagId, nil)
        while slotIndex do
            local itemType = GetItemType(bagId, slotIndex)
            if self:ContainsNumber(itemType, ITEMTYPE_POTION_BASE,
                                             ITEMTYPE_POISON_BASE,
                                             ITEMTYPE_REAGENT) and self:IsUnLocked(bagId, slotIndex) then

                local itemId = GetItemId(bagId, slotIndex)
                local _, stack = GetItemInfo(bagId, slotIndex)
                local totalStack = list[itemId] or 0
                list[itemId] = totalStack + stack
            end

            slotIndex = ZO_GetNextBagSlotIndex(bagId, slotIndex)
        end
    end
    return list
end

function IJAWH:Contains(text, ...)
    if text == nil or text == "" then
        return nil
    end
    if type(text) == "table" then
        return false
    end

    local keyList = {...}
    if type(keyList[1]) == "table" then
        keyList = keyList[1]
    end
    local lowerText = string.lower(text)
    local result
    for _, key in ipairs(keyList) do
        if key and key ~= "" then
		key = "^" .. key .. "$"
            result, result2 = string.match(text, key)
            if result then
 --               return result, result2
                return true
            end
            local lowerKey = string.lower(key)
            if lowerText and lowerKey then
                result, result2 = string.match(lowerText, lowerKey)
                if result then
 --                   return result, result2
                    return true
                end
            end
        end
    end
--    return nil
    return false
end

function IJAWH:ContainsNumber(num, ...)
    if num == nil then
        return false
    end
    if type(num) == "table" then
        return false
    end

    local keyList = {...}

    if type(keyList[1]) == "table" then
        keyList = keyList[1]
    end
    for i, key in ipairs(keyList) do
        if num == key then
            return true
        end
    end
    return false
end

function IJAWH:Choice(conditions, trueValue, falseValue)
    if conditions then
       return trueValue
    else
        return falseValue
    end
end

function IJAWH:GetSkillRank(craftingType, abilityIndex)
	local rankIndex
    local skillType, skillIndex = GetCraftingSkillLineIndices(craftingType)
    local abilityName, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        rankIndex = 0
    end
    return rankIndex
end

function IJAWH:GetItemLink(itemId, subType, level, styleId)
    local subType 	= subType 	and subType or "0"
    local level 	= level 	and level 	or "0"
    local styleId 	= styleId 	and styleId or "0"
	local itemFormat = "|H0:item:<<1>>:<<2>>:<<3>>:0:0:0:0:0:0:0:0:0:0:0:0:<<4>>:0:0:0:1000:0|h|h"
	local itemLink = zo_strformat(itemFormat, itemId, subType, level, styleId)
	return itemLink
end

function IJAWH:GetAcquireItem(qIndex, qName, lineId, condition, maximum)
	local itemTypeList = {
						ITEMTYPE_ENCHANTING_RUNE_ASPECT,ITEMTYPE_ENCHANTING_RUNE_ESSENCE,ITEMTYPE_ENCHANTING_RUNE_POTENCY,
						ITEMTYPE_POISON_BASE,ITEMTYPE_POTION_BASE,ITEMTYPE_REAGENT
					}
	local acquireItemName = IJAWH:AcquireItemName(condition)
	local itemData = IJAWH:GetItemData(acquireItemName,itemTypeList)
	local itemLink = GetItemLink(itemData.bagId,itemData.slotIndex)
	local inBank, amountRequired = self:IsRequieredInBank(qIndex, qName, lineId, itemLink, maximum, true)
	return inBank, itemLink, amountRequired 
end