-------------------------------------
-- Enchanting
-------------------------------------
local glyphTable = { -- essenceRune and key to use for selecting the potencyRune table
	[5364]	= { -- Glyph of Frost Resist
		["key"] = 1,
		["essenceRune"] = 45839
	},
	[26586] = { -- Glyph of Poison Resist
		["key"] = 1,
		["essenceRune"] = 45837
	},
	[26591] = { -- Glyph of Weakening
		["key"] = 1,
			["essenceRune"] = 45843
	},
	[26845] = { -- Glyph of Crushing
		["key"] = 1,
		["essenceRune"] = 45842
	},
	[26847] = { -- Glyph of Disease Resist
		["key"] = 1,
		["essenceRune"] = 45841
	},
	[26849] = { -- Glyph of Flame Resist
		["key"] = 1,
		["essenceRune"] = 45838
	},
	[43570] = { -- Glyph of Shock Resist
		["key"] = 1,
		["essenceRune"] = 45840
	},
	[43573] = { -- Glyph of Absorb Health
		["key"] = 1,
		["essenceRune"] = 45831
	},
	[45867] = { -- Glyph of Absorb Stamina
		["key"] = 1,
		["essenceRune"] = 45833
	},
	[45868] = { -- Glyph of Absorb Magicka
		["key"] = 1,
		["essenceRune"] = 45832
	},
	[45869] = { -- Glyph of Decrease Health
		["key"] = 1,
		["essenceRune"] = 45834
	},
	[45870] = { -- Glyph of Reduce Spell Cost
		["key"] = 1,
		["essenceRune"] = 45835
	},
	[45871] = { -- Glyph of Reduce Feat Cost
		["key"] = 1,
		["essenceRune"] = 45836
	},
	[45873] = { -- Glyph of Bracing
		["key"] = 1,
		["essenceRune"] = 45849
	},
	[45875] = { -- Glyph of Potion Speed
		["key"] = 1,
		["essenceRune"] = 45846
	},
	[45885] = { -- Glyph of Decrease Physical Harm
		["key"] = 1,
			["essenceRune"] = 45847
	},
	[45886] = { -- Glyph of Decrease Spell Harm
		["key"] = 1,
		["essenceRune"] = 45848
	},
	[68344]	= { -- Glyph of Prismatic Onslaught
		["key"] = 1,
		["essenceRune"] = 68342
	},
	[166046] = { -- Glyph of Reduce Skill Cost
		["key"] = 1,
		["essenceRune"] = 166045
	},

	[5365] 	= { -- Glyph of Frost
		["key"] = 2,
		["essenceRune"] = 45839
	},
	[5366]	= { -- Glyph of Hardening
		["key"] = 2,
		["essenceRune"] = 45842
	},
	[26580] = { -- Glyph of Health
		["key"] = 2,
		["essenceRune"] = 45831
	},
	[26581] = { -- Glyph of Health Recovery
		["key"] = 2,
		["essenceRune"] = 45834
	},
	[26582] = { -- Glyph of Magicka
		["key"] = 2,
		["essenceRune"] = 45832
	},
	[26583] = { -- Glyph of Magicka Recovery
		["key"] = 2,
		["essenceRune"] = 45835
	},
	[26587] = { -- Glyph of Poison
		["key"] = 2,
		["essenceRune"] = 45837
	},
	[26588] = { -- Glyph of Stamina
		["key"] = 2,
		["essenceRune"] = 45833
	},
	[26589] = { -- Glyph of Stamina Recovery
		["key"] = 2,
		["essenceRune"] = 45836
	},
	[26841] = { -- Glyph of Foulness
		["key"] = 2,
		["essenceRune"] = 45841
	},
	[26844] = { -- Glyph of Shock
		["key"] = 2,
		["essenceRune"] = 45840
	},
	[26848] = { -- Glyph of Flame
		["key"] = 2,
		["essenceRune"] = 45838
	},
	[45872] = { -- Glyph of Bashing
		["key"] = 2,
		["essenceRune"] = 45849
	},
	[45874] = { -- Glyph of Potion Boost
		["key"] = 2,
			["essenceRune"] = 45846
	},
	[45883] = { -- Glyph of Increase Physical Harm
		["key"] = 2,
			["essenceRune"] = 45847
	},
	[45884] = {  -- Glyph of Increase Magical Harm
		["key"] = 2,
		["essenceRune"] = 45848
	},
	[54484] = { -- Glyph of Weapon Damage
		["key"] = 2,
		["essenceRune"] = 45843
	},
	[68343] = { -- Glyph of Prismatic Defense
		["key"] = 2,
		["essenceRune"] = 68342
	},
	[166047] = { -- Glyph of Prismatic Recovery
		["key"] = 2,
		["essenceRune"] = 166045
	}
}

local potencyRuneTable = { -- potencyRune tables
	[1] = {
		[102] = 45817, -- Jode 
		[103] = 45818, -- Notade
		[108] = 45823, -- Pojode
		[109] = 45824, -- Rekude
		[207] = 64508, -- Jehade
		[225] = 68340, -- Itade
	},
	[2] = {
		[102] = 45855, -- Jora
		[103] = 45856, -- Porade
		[108] = 45809, -- Edora 
		[109] = 45810, -- Jaera
		[207] = 64509, -- Rejera
		[225] = 68341, -- Repora
	},
}

local function GetEssenceRuneAndKey(itemId)
	return glyphTable[itemId].essenceRune, glyphTable[itemId].key
end

local function GetPotencyRune(key, materialItemId)
	return potencyRuneTable[key][materialItemId]
end

local function setRuneSounds(rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex)
	-- set the spoken audio of rune names that will be used during crafting
	local zo_Object = IsInGamepadPreferredMode() and GAMEPAD_ENCHANTING or ENCHANTING
	
	zo_Object.potencySound, zo_Object.potencyLength = GetRunestoneSoundInfo(rune1BagId, rune1SlotIndex)
	zo_Object.essenceSound, zo_Object.essenceLength = GetRunestoneSoundInfo(rune2BagId, rune2SlotIndex)
	zo_Object.aspectSound, zo_Object.aspectLength	= GetRunestoneSoundInfo(rune3BagId, rune3SlotIndex)
end

local function SetEnchantingSlots(runes)	
	-- sets selected runes to crafting slots
	local zo_Object = IsInGamepadPreferredMode() and GAMEPAD_ENCHANTING or ENCHANTING
	for i=1, #runes do
		if runes[i].meetsUsageRequirement then
			local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(runes[i])
			
			zo_Object:AddItemToCraft(bagId, slotIndex)
		end
	end
	
	if IsInGamepadPreferredMode() then
		GAMEPAD_ENCHANTING:UpdateSelection()
	else
		ENCHANTING.inventory:HandleDirtyEvent()
	end
end

local function notEnough(itemLink)
	return zo_strformat(GetString(SI_IJAWH_NOT_ENOUGH), itemLink)
end

-------------------------------------
local Enchanting_Writ_Object = IJA_WritHelper_Shared_Writ_Object:Subclass()

function Enchanting_Writ_Object:GetRecipeData(conditionInfo)
	local itemId = conditionInfo.itemId
	local potencyRune, essenceRune, aspectRune = self:GetRunesForItemId(itemId, conditionInfo.materialItemId, conditionInfo.itemFunctionalQuality)

	local itemLink = self:GetItemLink(itemId)
	self.comparator	= self:GetComparator(itemLink)
	
	conditionInfo.potencyRune = potencyRune
	conditionInfo.essenceRune = essenceRune
	conditionInfo.aspectRune = aspectRune
	
	if potencyRune and essenceRune and aspectRune then
		local recipeData = {
			['runes'] = {
				[1] = self:GetItemData(potencyRune, IJA_IsRune),
				[2] = self:GetItemData(essenceRune, IJA_IsRune),
				[3] = self:GetItemData(aspectRune, IJA_IsRune)
			},
			itemId = itemId
		}
		
		return recipeData, itemId, self:GetItemLink(itemId)
	end
end

function Enchanting_Writ_Object:AutoCraft()
	local function onCraftStarted()
		-- speeds up crafting a little by skipping final animation
		if SCENE_MANAGER:IsShowing("gamepad_enchanting_creation") then
			GAMEPAD_CRAFTING_RESULTS:OnAllEnchantSoundsFinished()
		elseif SCENE_MANAGER:IsShowing("enchanting") then
			CRAFTING_RESULTS:OnAllEnchantSoundsFinished()
		end
		CALLBACK_MANAGER:UnregisterCallback("CraftingAnimationsStarted", onCraftStarted)
	end
	CALLBACK_MANAGER:RegisterCallback("CraftingAnimationsStarted", onCraftStarted)
	
	local rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex = self:GetAllCraftingBagAndSlots()
	
	local maxIterations, craftingResult = self:GetMaxIterations()
	local numIterations = self:GetRequiredIterations()
	-- numIterations = no more than the maximum amount that can be crafted
	numIterations = maxIterations < numIterations and maxIterations or numIterations
	if maxIterations >= numIterations then
		setRuneSounds(rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex)
		self:TryCraftItem(CraftEnchantingItem, rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex, numIterations)
	else
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString("SI_TRADESKILLRESULT", craftingResult))
	end
end

function Enchanting_Writ_Object:GetAllCraftingBagAndSlots()
    local runes = self.recipeData.runes
	
	local rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex
	if runes[1] then
		rune1BagId, rune1SlotIndex = ZO_Inventory_GetBagAndIndex(runes[1])
	end
	if runes[2] then
		rune2BagId, rune2SlotIndex = ZO_Inventory_GetBagAndIndex(runes[2])
	end
	if runes[3] then
		rune3BagId, rune3SlotIndex = ZO_Inventory_GetBagAndIndex(runes[3])
	end
	
	return rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex
end

function Enchanting_Writ_Object:MeetsCraftingRequierments()
	local maxIterations, limitReason = self:GetMaxIterations()
	local numIterations = self:GetRequiredIterations()
	
	self.craftingConditions = {
		[1] = maxIterations < numIterations and limitReason or nil
	}
end

function Enchanting_Writ_Object:GetMissingMessage()
	local missingMessage = {}
	local conditionInfo = self.conditionInfo
	
	if not DoesPlayerHaveRunesForEnchanting(conditionInfo.aspectRune, conditionInfo.essenceRune, conditionInfo.potencyRune) then
		local rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex = self:GetAllCraftingBagAndSlots()
		if not rune1SlotIndex then
			table.insert(missingMessage, notEnough(self:GetItemLink(conditionInfo.potencyRune)))
			
		end
		if not rune2SlotIndex then
			table.insert(missingMessage, notEnough(self:GetItemLink(conditionInfo.essenceRune)))
            
		end		
		if not rune3SlotIndex then
			table.insert(missingMessage, notEnough(self:GetItemLink(conditionInfo.aspectRune)))
            
		end
	else
		
		local maxIterations, limitReason = self:GetMaxIterations()
		local numIterations = self:GetRequiredIterations()
		if numIterations > maxIterations then
			table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", limitReason))
		end
	end
	
	return missingMessage
end

function Enchanting_Writ_Object:Alert()
	d( GetString(SI_TRADESKILLRESULT14), self:GetMissingMessage())
end

--					-----------------------------------------------------------
function Enchanting_Writ_Object:SetStation()
	SetEnchantingSlots(self.recipeData.runes)
end

function Enchanting_Writ_Object:SelectMode()
	if SCENE_MANAGER:GetPreviousSceneName() == 'hud' then
		if IsInGamepadPreferredMode() then
			SCENE_MANAGER:Push("gamepad_enchanting_creation")
		else
			ZO_MenuBar_SelectDescriptor(ENCHANTING.modeBar, ENCHANTING_MODE_CREATION)
		end
	end
end

function Enchanting_Writ_Object:GetRunesForItemId(itemId, materialItemId, itemFunctionalQuality)
	local aspectRunes = {[1] = 45850, [2] = 45851, [3] = 45852, [4] = 45853, [5] = 45854}
	
	local essenceRune, key =  GetEssenceRuneAndKey(itemId)
	local potencyRune = GetPotencyRune(key, materialItemId)
	local aspectRune = aspectRunes[itemFunctionalQuality]
	
	return potencyRune, essenceRune, aspectRune
end	

function Enchanting_Writ_Object:GetMaxIterations()
    local maxIterations, craftingResult = GetMaxIterationsPossibleForEnchantingItem(self:GetAllCraftingBagAndSlots())
    return maxIterations, craftingResult
end

function Enchanting_Writ_Object:GetResultItemLink()
	return GetEnchantingResultingItemLink(self:GetAllCraftingBagAndSlots())
end

IJA_WritHelper_Enchanter_Object = Enchanting_Writ_Object



--[[



	conditionInfo.potencyRune
	conditionInfo.essenceRune
	conditionInfo.aspectRune
	
    local rune1BagId, rune1SlotIndex = self.runeSlots[ENCHANTING_RUNE_POTENCY]:GetBagAndSlot()
    local rune2BagId, rune2SlotIndex = self.runeSlots[ENCHANTING_RUNE_ESSENCE]:GetBagAndSlot()
    local rune3BagId, rune3SlotIndex = self.runeSlots[ENCHANTING_RUNE_ASPECT]:GetBagAndSlot()
    return rune1BagId, rune1SlotIndex, rune2BagId, rune2SlotIndex, rune3BagId, rune3SlotIndex, numIterations
	
	
--]]