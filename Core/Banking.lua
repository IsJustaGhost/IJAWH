
-------------------------------------
-- Bank handling
-------------------------------------
local HandleBankedItems = IJA_WRITHELPER
local withdrawList = {}

<<<<<<< HEAD
local function isItemLocked(bagId, slotIndex)
	local locked = IsItemPlayerLocked(bagId, slotIndex)
	
	if FCOIS and not locked then
		locked = FCOIS.IsPlayerBankWithdrawLocked(bagId, slotIndex)
	end
	if locked then
		d( zo_strformat(GetString(SI_LIBIJA_ITEMLOCKED), GetItemName(bagId, slotIndex)))
		IJA_WRITHELPER.lockedItems[GetItemId(bagId, slotIndex)] = GetItemName(bagId, slotIndex)
	end
	return locked
end

local function isMatch(itemId, bagId, slotIndex)
	return itemId == GetItemId(bagId, slotIndex) and 
		not isItemLocked(bagId, slotIndex)
end

=======
>>>>>>> 24e0d3fce82455052f34b6c61351b5ef86aa7008
local function CreatedBySelf(itemData) -- comparator
	local creatorName = GetItemCreatorName(itemData.bagId, itemData.slotIndex)
	return creatorName ~= '' and string.match(creatorName, GetUnitName("player"))
end

function HandleBankedItems:Withdraw(bagId, slotIndex, amountRequired)
	local bankCount = select(2, GetItemLinkStacks(GetItemLink(bagId, slotIndex)))
	local withdrawAmmount = bankCount >= amountRequired and amountRequired or bankCount
	local hasEnough = withdrawAmmount == amountRequired
	
	local function onSlotUpdated(bagId, slotId)
		SHARED_INVENTORY:UnregisterCallback("SingleSlotInventoryUpdate", onSlotUpdated)
		table.remove(withdrawList, 1)
		if hasEnough then
			self.bankedList[GetItemId(bagId, slotId)] = nil
		else
			self.bankedList[GetItemId(bagId, slotId)].required = amountRequired - withdrawAmmount
			-- do alert ?
		end

		if #withdrawList > 0 then
			zo_callLater(function() self:StartWithdraw() end, 200)
		elseif NonContiguousCount(self.bankedList) == 0 then
			self.control:UnregisterForEvent(EVENT_OPEN_BANK)
		end
	end
SHARED_INVENTORY:RegisterCallback("SingleSlotInventoryUpdate", onSlotUpdated)
	
	local emptySlot = FindFirstEmptySlotInBag(BAG_BACKPACK)
	CallSecureProtected("RequestMoveItem", bagId, slotIndex, BAG_BACKPACK, emptySlot, amountRequired)
end
--	/script d(IJA_WRITHELPER.bankedList)

function HandleBankedItems:StartWithdraw()
	local required, bagId, slotIndex = withdrawList[1].required, withdrawList[1].bagId, withdrawList[1].slotIndex
	if DoesBagHaveSpaceFor(BAG_BACKPACK, bagId, slotIndex) then
		self:Withdraw(bagId, slotIndex, required)
--		break
	else
		self:AlertQue(SOUNDS.NEGATIVE_CLICK, SI_INVENTORY_ERROR_INVENTORY_FULL)
		return
	end
end
function HandleBankedItems:AtBankInteraction()
	withdrawList = {}

	for k,v in pairs(self.bankedList) do
		table.insert(withdrawList, v)
	end

	local function onBankClose()
		self.control:UnregisterForEvent(EVENT_CLOSE_BANK, onBankClose)
		CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
	end
	self.control:RegisterForEvent(EVENT_CLOSE_BANK, onBankClose)
	
	self:StartWithdraw()
end

function HandleBankedItems:CheckBankList(questIndex, itemId)
	local isInBank = self.bankedList[itemId] and self.bankedList[itemId][questIndex]
	return isInBank
end

local function addItem(bagId, slotIndex, withdrawAmount, questIndex)
	local data = {
		['required'] = withdrawAmount,
		['bagId'] = bagId,
		['slotIndex'] = slotIndex,
		[questIndex] = true
	}
	
	return data
end

<<<<<<< HEAD
function HandleBankedItems:GetBankBagAndSlotForCreated(itemId, itemLink, comparator, encodedAlchemyTraits)
	local function IsCreatedItem(itemData) -- comparator
		return CreatedBySelf(itemData) and comparator(itemData)
	end
	local encodedLinkData = self:GetItemLinkEncodedData(itemLink)
	
	local inventoryCache = SHARED_INVENTORY:GenerateFullSlotData(IsCreatedItem, BAG_BANK, BAG_SUBSCRIBER_BANK)
	if #inventoryCache > 0 then
		for index, itemData in pairs(inventoryCache)do
			if itemData ~= nil then
				local newItemLink =  GetItemLink(itemData.bagId, itemData.slotIndex)
				
--				if isMatch(itemId, itemData.bagId, itemData.slotIndex) then
				if encodedLinkData == self:GetItemLinkEncodedData(newItemLink) then
					if IJA_IsAlchemyResultItem(itemData) then 
						if self:CompareAlchemyResultLinks(newItemLink, encodedAlchemyTraits) then
							return itemData.bagId, itemData.slotIndex
						end
		--			elseif newItemLink == itemLink then
					else
						return itemData.bagId, itemData.slotIndex
					end
				end
			end
		end
	end
    return false
end
--[[
function HandleBankedItems:GetBankBagAndSlot(itemId, itemLink, comparator, encodedAlchemyTraits, isAcquire)
	if isAcquire then
		local ingredientCache = SHARED_INVENTORY:GenerateFullSlotData(comparator, BAG_BANK, BAG_SUBSCRIBER_BANK)
		for index, itemData in pairs(ingredientCache)do
			if itemData ~= nil then
				if isMatch(itemId, itemData.bagId, itemData.slotIndex) then
					return itemData.bagId, itemData.slotIndex
				end
			end
		end
		return false
	else
		return self:GetBankBagAndSlotForCreated(itemId, itemLink, comparator, encodedAlchemyTraits)
	end
end
--]]

function HandleBankedItems:GetBankBagAndSlot()
	local function didIMakeThis(itemData) -- comparator
		return CreatedBySelf(itemData) and self.comparator(itemData)
	end

    local comparator = self.isMasterWrit and didIMakeThis or self.comparator
    local itemData = self:GetItemData(self.itemId, comparator, BAG_BANK, BAG_SUBSCRIBER_BANK)
    if itemData ~= nil then
		local search_encodedLinkData = self:GetItemLinkEncodedData(self.itemLink)
		local encodedLinkData, encodedAlchemyTraits = self:GetItemLinkEncodedData(itemData.itemLink)
        if search_encodedLinkData == encodedLinkData then
            if IJA_IsAlchemyResultItem(itemData) then 
                if self:CompareEncoadedAlchemyTraits(encodedAlchemyTraits, self.encodedAlchemyTraits) then
=======
function HandleBankedItems:GetBankBagAndSlot()
	local function itemIdsMatch(itemId, itemData)
		return itemId == GetItemId(itemData.bagId, itemData.slotIndex) and IsItemLinkCrafted(GetItemLink(itemData.bagId, itemData.slotIndex))
	end
	local function didIMakeThis(itemId, itemData) -- comparator
		return CreatedBySelf(itemData) and itemIdsMatch(itemId, itemData)
	end

    local comparator = self.isMasterWrit and didIMakeThis or itemIdsMatch
	local itemData = IJA_WRITHELPER:GetItemData(self.itemId, comparator, IJA_BAG_BANK)
    if itemData ~= nil then
		local search_encodedLinkData, search_encodedAlchemyTraits = self:GetItemLinkEncodedData(self.itemLink)
		local encodedLinkData, encodedAlchemyTraits = self:GetItemLinkEncodedData(itemData.itemlink)
        if search_encodedLinkData == encodedLinkData then
            if IJA_IsAlchemyResultItem(itemData) and encodedAlchemyTraits and search_encodedAlchemyTraits then 
                if self:CompareEncoadedAlchemyTraits(encodedAlchemyTraits, search_encodedAlchemyTraits) then
>>>>>>> 24e0d3fce82455052f34b6c61351b5ef86aa7008
                    return itemData.bagId, itemData.slotIndex
                end
            else
                return itemData.bagId, itemData.slotIndex
            end
        end
    end
    return false
end

function HandleBankedItems:BankListAdd(itemId, itemLink, bagId, slotIndex, withdrawAmount, questIndex)
	if not self.bankedList[itemId] then
		self.bankedList[itemId] = addItem(bagId, slotIndex, withdrawAmount, questIndex)
		d(zo_strformat(SI_IJAWH_ADDED_TO_WTHDRAW_LIST, itemLink, self.bankedList[itemId].required)) 
	elseif not self.bankedList[itemId][questIndex] then
		self.bankedList[itemId][questIndex] = true
		self.bankedList[itemId].required = self.bankedList[itemId].required + withdrawAmount
		d(zo_strformat(SI_IJAWH_ADDED_TO_WTHDRAW_LIST, itemLink, self.bankedList[itemId].required)) 
	end
end
<<<<<<< HEAD
=======
--
>>>>>>> 24e0d3fce82455052f34b6c61351b5ef86aa7008
