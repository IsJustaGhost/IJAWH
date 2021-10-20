-------------------------------------
-- Provisioning
-------------------------------------
local callbackSet = false
local oldScene = ''

local function isIngredient(itemData) 		-- comparator
	return itemData.itemType == ITEMTYPE_INGREDIENT
end

local function GetNodeByData(recipeData)
	for _, listNode in pairs(PROVISIONER.recipeTree.rootNode.children) do
		if listNode.data.recipeListIndex == recipeData.recipeListIndex then
			for _, node in pairs(listNode.children) do 
				if node.data.recipeIndex == recipeData.recipeIndex then 
					return node
				end
			end
		end
	end
end

local function GetIndexByData(recipeData)
	for index, entryData in pairs(GAMEPAD_PROVISIONER.recipeList.dataList) do
		if entryData.dataSource.recipeListIndex == recipeData.recipeListIndex then
			if entryData.dataSource.recipeIndex == recipeData.recipeIndex then 
				return index
			end
		end
	end
end

local function setRecipeListToItem(recipeData, tab, gamepadMode, isAutoCraft)
	local allowEvenIfDisabled	= false
	local withoutAnimation		= isAutoCraft and true or false
	if gamepadMode then
		-- select list
		ZO_GamepadGenericHeader_SetActiveTabIndex(GAMEPAD_PROVISIONER.header, tab)
		zo_callLater(function()
			-- select recipe
			local index = GetIndexByData(recipeData)
			GAMEPAD_PROVISIONER.recipeList:SetSelectedIndex(index, allowEvenIfDisabled, withoutAnimation)
		end, 200)
	else
		-- select list
		ZO_MenuBar_SelectDescriptor(PROVISIONER.tabs, tab)
		zo_callLater(function()
			-- select recipe
			local node = GetNodeByData(recipeData)
			node:GetTree():SelectNode(node)
		end, 100)
	end
end

-------------------------------------
local Provisioning_Writ_Object = IJA_WritHelper_Shared_Writ_Object:Subclass()

function Provisioning_Writ_Object:GetRecipeData(conditionInfo)
	local recipeLists = PROVISIONER_MANAGER:GetRecipeListData(CRAFTING_TYPE_PROVISIONING)
	--Locate any recipes that match the current quest recipes
	
	local itemId = conditionInfo.itemId
	for recipeListIndex = 1, GetNumRecipeLists() do
		local numRecipes = select(2, GetRecipeListInfo(recipeListIndex))
		
		for recipeIndex = 1, numRecipes do -- parse all recipes in list
			 local known, recipeName, numIngredients, _, _, _, _, resultItemId = GetRecipeInfo(recipeListIndex, recipeIndex)
 
             if itemId == resultItemId then
				local recipeData = {
					recipeListIndex	= recipeListIndex,
					recipeIndex		= recipeIndex,
					name			= recipeName,
					itemId			= itemId
				}
				
				return recipeData, itemId, GetRecipeResultItemLink(recipeListIndex, recipeIndex)
			end
		end
	end
end

function Provisioning_Writ_Object:AutoCraft()
	local maxIterations, craftingResult = self:GetMaxIterations()
	local numIterations = self:GetRequiredIterations()
	-- numIterations = no more than the maximum amount that can be crafted
	numIterations = maxIterations < numIterations and maxIterations or numIterations
	if maxIterations >= numIterations then
--		CraftProvisionerItem(self:GetAllCraftingParameters(numIterations))
		self:TryCraftItem(CraftProvisionerItem, self:GetAllCraftingParameters(numIterations))
	else
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, GetString("SI_TRADESKILLRESULT", craftingResult))
	end
end

function Provisioning_Writ_Object:GetPerIteration()
    local skillType, skillIndex = GetCraftingSkillLineIndices(CRAFTING_TYPE_PROVISIONING)
    local abilityIndex = GetItemLinkItemType(self.itemLink) == ITEMTYPE_DRINK and 6 or 5
	
    local _, _, _, _, _, purchased, _, rankIndex = GetSkillAbilityInfo(skillType, skillIndex, abilityIndex)
    if (not purchased) then
        return 1
    end

    return 1 + rankIndex
end

function Provisioning_Writ_Object:GetAllCraftingParameters()
	local maxIterations, craftingResult = self:GetMaxIterations()
	local numIterations = self:GetRequiredIterations()
	-- numIterations = no more than the maximum amount that can be crafted
	numIterations = maxIterations < numIterations and maxIterations or numIterations
	
    local recipeData = self.recipeData
    if recipeData then
        return recipeData.recipeListIndex, recipeData.recipeIndex, numIterations
    end
    return 0, 0, numIterations
end

function Provisioning_Writ_Object:GetCraftingParametersWithoutIterations()
    local recipeData = self.recipeData
    if recipeData then
        return recipeData.recipeListIndex, recipeData.recipeIndex
    end
    return 0, 0
end

function Provisioning_Writ_Object:MeetsCraftingRequierments()
	local maxIterations, limitReason = self:GetMaxIterations()
	local numIterations = self:GetRequiredIterations()
	local known = GetRecipeInfo(self:GetCraftingParametersWithoutIterations())
	
	self.craftingConditions = {
		[1] = not known and 100 or nil,
		[2] = maxIterations < numIterations and limitReason or nil
	}
end

function Provisioning_Writ_Object:GetMissingMessage()
	local missingMessage = {}

	local recipeListIndex, recipeIndex = self:GetCraftingParametersWithoutIterations()
	local known, name, numIngredients, provisionerLevelReq = GetRecipeInfo(recipeListIndex, recipeIndex)
	if known then
		for ingredientIndex=1, numIngredients do
			local itemLink = GetRecipeIngredientItemLink(recipeListIndex,  recipeIndex, ingredientIndex)
            local requiredQuantity = select(3, GetRecipeIngredientItemInfo(recipeListIndex, recipeIndex, ingredientIndex))
            IJA_WRITHELPER:AddCraftItemUsed(GetItemLinkItemId(itemLink), self.conditionId, requiredQuantity)
		end
		
	else
		table.insert(missingMessage, GetString(SI_TRADESKILLRESULT100)) --  "Recipe Unknown"
	end
	
	if #missingMessage == 0 then
		-- used if no other definded reson was true
		local maxIterations, limitReason = self:GetMaxIterations()
		local numIterations = self:GetRequiredIterations()
		if maxIterations == numIterations then
			table.insert(missingMessage, GetString("SI_TRADESKILLRESULT", limitReason))
		end
	end

	return missingMessage
end

function Provisioning_Writ_Object:HasEnoughForRecipe(itemLink, recipeListIndex,  recipeIndex, ingredientIndex)
	local requiredQuantity = select(3, GetRecipeIngredientItemInfo(recipeListIndex, recipeIndex, ingredientIndex))
	
	local backpackCount, bankCount, craftBagCount = GetItemLinkStacks(itemLink)
	local totalStacks = backpackCount + bankCount + craftBagCount
	
	return totalStacks >= requiredQuantity
end

--					-----------------------------------------------------------
function Provisioning_Writ_Object:SetStation(isAutoCraft)
--	local gamepadMode = IsInGamepadPreferredMode()
	local recipeData = self.recipeData
	local recipeListIndex = recipeData.recipeListIndex
	-- tab is the the list needed (food/drink)
	local tab = (recipeListIndex <= 7 or recipeListIndex == 16) and 1 or 2
	
	local sceneName = IJA_WRITHELPER.isGamepadMode and "gamepad_provisioner_root" or "provisioner"
	local provisioningScene = SCENE_MANAGER:GetScene(sceneName)

	-- the callback is used to set the recipe list and recipe after station UI has finished loading
	local function setStation(oldState, newState)
		if newState == SCENE_SHOWING then
		elseif newState == SCENE_SHOWN then
			setRecipeListToItem(recipeData, tab, IJA_WRITHELPER.isGamepadMode, isAutoCraft)
		elseif newState == SCENE_HIDDEN then
			provisioningScene:UnregisterCallback("StateChange", setStation)
			callbackSet = false
		end
	end
	
	if oldScene ~= '' and oldScene ~= sceneName then 
		-- if last scene was a different mode, then unregistered the callback
		SCENE_MANAGER:GetScene(oldScene):UnregisterCallback("StateChange", setStation)
		callbackSet = false
	end
	
	if callbackSet then
		setRecipeListToItem(recipeData, tab, IJA_WRITHELPER.isGamepadMode, isAutoCraft)
	else
		oldScene = sceneName
		provisioningScene:RegisterCallback("StateChange", setStation)
		callbackSet = true
	end
end

function Provisioning_Writ_Object:GetMaxIterations()
    local maxIterations, craftingResult = GetMaxIterationsPossibleForRecipe(self:GetCraftingParametersWithoutIterations())
    return maxIterations, craftingResult
end

function Provisioning_Writ_Object:GetResultItemLink()
	return GetRecipeResultItemLink(self:GetCraftingParametersWithoutIterations())
end

IJA_WritHelper_Provisioning_Object = Provisioning_Writ_Object

function Provisioning_Writ_Object:GetIngredientData()	--------------------------
	local recipeData = self:GetRecipeData()
	local ingredients = {}
	
	for ingredientIndex = 1, recipeData.numIngredients do
		local itemLink = GetRecipeIngredientItemLink(recipeData.recipeListIndex, recipeData.recipeIndex, ingredientIndex)
		local itemId = GetItemLinkItemId(itemLink)
--		local itemData = self:GetItemData(itemId, isIngredient)
		
	local function comparator(itemId, itemData)
		if itemId ~= GetItemId(itemData.bagId, itemData.slotIndex) then return false end
		return itemData.itemType == ITEMTYPE_INGREDIENT
	end

		local itemData = IJA_WRITHELPER:GetItemData(itemId, comparator, IJA_BAG_ALL)

		local name, icon, requiredQuantity, _, displayQuality = GetRecipeIngredientItemInfo(recipeData.recipeListIndex, recipeData.recipeIndex, ingredientIndex)
		local ingredientCount = GetCurrentRecipeIngredientCount(recipeData.recipeListIndex, recipeData.recipeIndex, ingredientIndex)
		
		if ingredientCount >= requiredQuantity then
		
		end
		
		ingredients[itemId] = itemData
	end
	recipeData.ingredients = ingredients
end