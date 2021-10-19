
function IJAWH:CreateMenu()
	local LAM2 = LibAddonMenu2
	if not LAM2 then return end
	
    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "|cFF00FFIsJustaGhost|r",
        version = self.version,
        registerForDefaults = true,
		registerForRefresh = true,
    }
    local panel = LAM2:RegisterAddonPanel(self.name, panelData)


    local submenuFunction = LAMCreateControl["submenu"]
    LAMCreateControl["submenu"] = function(parent, submenuData, controlName)
        local control = submenuFunction(parent, submenuData, controlName)
        if (not control) then
            return control
        end
        if parent ~= panel then
            return control
        end
        if submenuData.reference == "PriorityByManual"  then
            control:SetHidden(self.savedVariables.priorityBy ~= self.SI_IJAWH_PRIORITY_BY_MANUAL)
        end
        return control
    end

    local dropdownFunction = LAMCreateControl["dropdown"]
    LAMCreateControl["dropdown"] = function(parent, dropdownData, controlName)
        local control = dropdownFunction(parent, dropdownData, controlName)
        if (not control) then
            return control
        end
        if parent ~= PriorityByManual then
            return control
        end
        if self:Contains(dropdownData.reference, {"Reagent"}) then
            control.label:SetAnchor(TOPLEFT, control, TOPLEFT, 340, 0)
        end
        return control
    end


    local optionsTable = {
		{	-- SI_IJAWH_SETTING_SAVEPERCHARACTER
			type = "checkbox",
            name = GetString(SI_IJAWH_SETTING_SAVEPERCHARACTER),
			tooltip = GetString(SI_IJAWH_SETTING_SAVEPERCHARACTER_TOOLTIP),
            getFunc = function()
                return self.savedVariables.character
            end,
            setFunc = function(value)
                self.savedVariables.character = value
            end,
            width = "full",
			requiresReload = true,
        },
        {
            type = "header",
            name = GetString(SI_IJAWH_PRIORITY_HEADER),
            width = "full",
        },
        self:CreateMenuForPriority(),
        self:CreateMenuForManual(),
		
        { 	-- SI_IJAWH_HEADER_OTHER
			type = "header",
            name = GetString(SI_IJAWH_HEADER_WRIT),
            width = "full",
        },
		{ 	-- hide while mounted
			type = "checkbox",
            name = GetString(SI_IJAWH_SETTING_HIDEMOUNTED),
			tooltip = GetString(SI_IJAWH_SETTING_HIDEMOUNTED_TOOLTIP),
            getFunc = function()
                return self.savedVariables.hideWhileMounted
            end,
            setFunc = function(value)
                self.savedVariables.hideWhileMounted = value
            end,
            width = "full",
            default = IJAWH.DefaultSettings.hideWhileMounted
		},

        { 	-- SI_IJAWH_HEADER_OTHER
			type = "header",
            name = GetString(SI_IJAWH_HEADER_CRAFT),
            width = "full",
        },
		{ 	-- SI_IJAWH_SETTING_SHOWCRAFTFORWRIT
			type = "checkbox",
            name = GetString(SI_IJAWH_SETTING_SHOWCRAFTFORWRIT),
			tooltip = GetString(SI_IJAWH_SETTING_SHOWCRAFTFORWRIT_TOOLTIP),
            getFunc = function()
                return self.savedVariables.showCraftForWrit
            end,
            setFunc = function(value)
                self.savedVariables.showCraftForWrit = value
				if value ~= true then self.savedVariables.useMostStyle = value end
            end,
            width = "full",
            default = IJAWH.DefaultSettings.showCraftForWrit,
		},
		{ 	-- SI_IJAWH_SETTING_USEMOSTSTYLE
			type = "checkbox",
            name = GetString(SI_IJAWH_SETTING_USEMOSTSTYLE),
			tooltip = GetString(SI_IJAWH_SETTING_USEMOSTSTYLE_TOOLTIP),
            getFunc = function()
                return self.savedVariables.useMostStyle
            end,
            setFunc = function(value)
                self.savedVariables.useMostStyle = value
            end,
            width = "full",
            default = IJAWH.DefaultSettings.useMostStyle,
			disabled = function() return not IJAWH.savedVariables.showCraftForWrit end,
		},
		
		
        { 	-- SI_IJAWH_HEADER_OTHER
			type = "header",
            name = GetString(SI_IJAWH_HEADER_OTHER),
            width = "full",
        },
		{ 	-- SI_IJAWH_EASYALCHEMY_LABEL
			type = "checkbox",
            name = GetString(SI_IJAWH_SETTING_EASYALCHEMY),
			tooltip = GetString(SI_IJAWH_SETTING_EASYALCHEMY_TOOLTIP),
            getFunc = function()
                return self.savedVariables.easyAlchemy
            end,
            setFunc = function(value)
                self.savedVariables.easyAlchemy = value
            end,
            width = "full",
            default = IJAWH.DefaultSettings.easyAlchemy,
			requiresReload = true,
        },
		{ 	-- SI_IJAWH_SETTING_HANDLEWITHDRAW
			type = "checkbox",
            name = GetString(SI_IJAWH_SETTING_HANDLEWITHDRAW),
			tooltip = GetString(SI_IJAWH_SETTING_HANDLEWITHDRAW_TOOLTIP),
            getFunc = function()
                return self.savedVariables.handleWithdraw
            end,
            setFunc = function(value)
                self.savedVariables.handleWithdraw = value
            end,
            width = "full",
            default = IJAWH.DefaultSettings.handleWithdraw,
        },
        { 	-- SI_IJAWH_HEADER_ALERTS
			type = "header",
            name = GetString(SI_IJAWH_HEADER_ALERTS),
            width = "full",
        },
		{ 	-- SI_IJAWH_SETTING_SHOWWRITITEMALERT
			type = "checkbox",
            name = GetString(SI_IJAWH_SETTING_SHOWWRITITEMALERT),
			tooltip = GetString(SI_IJAWH_SETTING_SHOWWRITITEMALERT_TOOLTIP),
            getFunc = function()
                return self.savedVariables.showInBankAlert
            end,
            setFunc = function(value)
                self.savedVariables.showInBankAlert = value
            end,
            width = "full",
            default = IJAWH.DefaultSettings.showWithdrawInChat,
        },
		{	-- SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT
			type = "checkbox",
            name = GetString(SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT),
			tooltip = GetString(SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT_TOOLTIP),
            getFunc = function()
                return self.savedVariables.showWithdrawInChat
            end,
            setFunc = function(value)
                self.savedVariables.showWithdrawInChat = value
            end,
            width = "full",
            default = IJAWH.DefaultSettings.showWithdrawInChat,
        },
        { 	-- SI_IJAWH_SETTING_RESETTUTORIALS
			type = "header",
            width = "full",
        },
		{	type ="button",
            name = GetString(SI_IJAWH_SETTING_RESETTUTORIALS),
			tooltip = GetString(SI_IJAWH_SETTING_RESETTUTORIALS_TOOLTIP),
			func = function() IJAWH.savedVariables.tutorials = {} end,
		}
    }

    LAM2:RegisterOptionControls(self.name, optionsTable)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", function(newPanel)
        if (newPanel == panel) then
            local saveVer = self.savedVariables
            if saveVer.showPriceTTC then
                self:RefreshMenuForManual()
                LAM2.util.RequestRefreshIfNeeded(PriorityByManual)
            end
        end
    end)
end

function IJAWH:CreateMenuForPriority()

    local priorityList = {
		{self.SI_IJAWH_PRIORITY_BY_TTC, GetString(SI_IJAWH_PRIORITY_BY_TTC)},
        {self.SI_IJAWH_PRIORITY_BY_STOCK, GetString(SI_IJAWH_PRIORITY_BY_STOCK)},
        {self.SI_IJAWH_PRIORITY_BY_MANUAL, GetString(SI_IJAWH_PRIORITY_BY_MANUAL)}
	}
	
   -- Default
    if (not self.savedVariables.priorityBy) then
        self.savedVariables.priorityBy = self.SI_IJAWH_PRIORITY_BY_STOCK
    end
	
    local values = {}
    local displays = {}
    for key, priority in pairs(priorityList) do
        if priority then
			if priority[1] == 3 and TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
				values[#values + 1] = priority[1]
				displays[#displays + 1] = priority[2]
			elseif priority[1] ~= 3 then
				values[#values + 1] = priority[1]
				displays[#displays + 1] = priority[2]
			end
        end
    end
	
    local menu = {
        type = "dropdown",
        name = GetString(SI_IJAWH_PRIORITY_BY),
        choices = displays,
        choicesValues = values,
        getFunc = function()
            return self.savedVariables.priorityBy
        end,
        setFunc = function(value)
            self.savedVariables.priorityBy = value

            local isManual = (value == self.SI_IJAWH_PRIORITY_BY_MANUAL)
            PriorityByManual:SetHidden(not isManual)
            if (isManual) and (PriorityByManual.open) then
                return
            elseif (not isManual) and (not PriorityByManual.open) then
                return
            end
            local laben = PriorityByManual.label
            laben:GetHandler("OnMouseUp")(laben, true)
        end,
        width = "full",
    }
    return menu
end

function IJAWH:GetMenuItemIdList()

    return {30148,  -- blue entoloma
            30149,  -- stinkhorn
            30151,  -- emetic russula
            30152,  -- violet coprinus
            30153,  -- namira's rot
            30154,  -- white cap
            30155,  -- luminous russula
            30156,  -- imp stool
            30157,  -- blessed thistle
            30158,  -- lady's smock
            30159,  -- wormwood
            30160,  -- bugloss
            30161,  -- corn flower
            30162,  -- dragonthorn
            30163,  -- mountain flower
            30164,  -- columbine
            30165,  -- nirnroot
            30166,  -- water hyacinth
            77581,  -- Torchbug Thorax
            77583,  -- Beetle Scuttle
            77584,  -- Spider Egg
            77585,  -- Butterfly Wing
            77587,  -- Fleshfly Larva||Fleshfly Larvae
            77589,  -- Scrib Jelly
            77590,  -- Nightshade
            77591,  -- Mudcrab Chitin
            139019, -- Powdered Mother of Pearl
            139020, -- Clam Gall
            150731, -- Dragon's Blood
            150789, -- Dragon's Bile
            150671, -- Dragon Rheum
            }
end

function IJAWH:CreateMenuForManual()
	local LAM2 = LibAddonMenu2 or LibStub("LibAddonMenu-2.0")
	
    local formatText = "|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    local itemIdList = self:GetMenuItemIdList()
    local displays = {}
    local values = {}
    for i, itemId in ipairs(itemIdList) do
        local itemLink = zo_strformat(formatText, itemId)
        local icon = GetItemLinkIcon(itemLink)
        displays[#displays + 1] = zo_iconFormat(icon, 18, 18) .. itemLink
        values[#values + 1] = itemId
    end


    if (not self.savedVariables.priorityByManual) then
        self.savedVariables.priorityByManual = {}
        for i, itemId in ipairs(itemIdList) do
            self.savedVariables.priorityByManual[i] = itemId
        end
    end


    local controlList = {}

     if TamrielTradeCentre and TamrielTradeCentre.ItemLookUpTable then
        controlList[#controlList + 1] = {
            type = "checkbox",
            name = zo_strformat(GetString(SI_IJAWH_SHOW_PRICE_MANUAL), "TamrielTradeCentre"),
            getFunc = function()
                return self.savedVariables.showPriceTTC
            end,
            setFunc = function(value)
                self.savedVariables.showPriceTTC = value
                self:RefreshMenuForManual()
                LAM2.util.RequestRefreshIfNeeded(PriorityByManual)
            end,
            width = "full",
            default = false,
        }
    else
        self.savedVariables.showPriceTTC = false
    end

    for i, itemId in ipairs(itemIdList) do
        local control = {
            type = "dropdown",
            reference = "Reagent".. i,
            choices = displays,
            choicesValues = values,
            name = tostring(i) .. ":",
            getFunc = function()
                return self.savedVariables.priorityByManual[i]
            end,
            setFunc = function(value)
                local oldValue = self.savedVariables.priorityByManual[i]
                for key, reagent in ipairs(self.savedVariables.priorityByManual) do
                    if reagent == value then
                        self.savedVariables.priorityByManual[key] = oldValue
                        break
                    end
                end
                self.savedVariables.priorityByManual[i] = value
            end,
            width = "full",
        }
        controlList[#controlList + 1] = control
    end


    local menu = {
        type = "submenu",
        name = GetString(SI_IJAWH_PRIORITY_BY_MANUAL),
        reference = "PriorityByManual",
        controls = controlList,
    }
    return menu
end

function IJAWH:RefreshMenuForManual()
    local saveVer = self.savedVariables
    local goldIcon = zo_iconFormat("EsoUI/Art/currency/currency_gold.dds", 16, 16)
    local formatText = "|H0:item:<<1>>:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h"
    local itemIdList = self:GetMenuItemIdList()
    local list = {}
    for i, itemId in ipairs(itemIdList) do
        local itemLink = zo_strformat(formatText, itemId)
        local icon = GetItemLinkIcon(itemLink)
        local txt
        if saveVer.showPriceTTC then
            local price = self:GetAvgPrice(itemLink)
            txt = zo_iconFormat(icon, 18, 18) .. itemLink .. " " .. string.format('%.0f', price) .. goldIcon
        else
            txt = zo_iconFormat(icon, 18, 18) .. itemLink
        end
        list[#list + 1] = {itemId, txt}
    end
    table.sort(list, function(a, b)
        return a[1] < b[1]
    end)
    local displays = {}
    local values = {}
    for i, entry in ipairs(list) do
        values[#values + 1] = entry[1]
        displays[#displays + 1] = entry[2]
    end

    Reagent1:UpdateChoices(displays, values)
    Reagent2:UpdateChoices(displays, values)
    Reagent3:UpdateChoices(displays, values)
    Reagent4:UpdateChoices(displays, values)
    Reagent5:UpdateChoices(displays, values)
    Reagent6:UpdateChoices(displays, values)
    Reagent7:UpdateChoices(displays, values)
    Reagent8:UpdateChoices(displays, values)
    Reagent9:UpdateChoices(displays, values)
    Reagent10:UpdateChoices(displays, values)
    Reagent11:UpdateChoices(displays, values)
    Reagent12:UpdateChoices(displays, values)
    Reagent13:UpdateChoices(displays, values)
    Reagent14:UpdateChoices(displays, values)
    Reagent15:UpdateChoices(displays, values)
    Reagent16:UpdateChoices(displays, values)
    Reagent17:UpdateChoices(displays, values)
    Reagent18:UpdateChoices(displays, values)
    Reagent19:UpdateChoices(displays, values)
    Reagent20:UpdateChoices(displays, values)
    Reagent21:UpdateChoices(displays, values)
    Reagent22:UpdateChoices(displays, values)
    Reagent23:UpdateChoices(displays, values)
    Reagent24:UpdateChoices(displays, values)
    Reagent25:UpdateChoices(displays, values)
    Reagent26:UpdateChoices(displays, values)
    Reagent27:UpdateChoices(displays, values)
    Reagent28:UpdateChoices(displays, values)
    Reagent29:UpdateChoices(displays, values)
    Reagent30:UpdateChoices(displays, values)
    Reagent31:UpdateChoices(displays, values)
end

