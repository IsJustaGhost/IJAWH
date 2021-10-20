local COLOR_CRAFTABLE	= ZO_ColorDef:New(0.8, 0.8, 0.8, 0.99)
local COLOR_COMPLETE 	= ZO_ColorDef:New(0, 0.8, 0, 0.99)
local COLOR_ERROR	 	= ZO_ColorDef:New(1, 0, 0, 0.8, 0.99)
local COLOR_NOTICE	 	= ZO_ColorDef:New(0.8, 0.9, 0.1, 0.99)

local function getColor(state)
	return state == 1 and COLOR_COMPLETE or
		state == 2 and COLOR_CRAFTABLE or 
		state == 3  and COLOR_NOTICE or
		COLOR_CRAFTABLE
--		COLOR_ERROR
end

local scaleTemplates = {
	[1] = {
		['header'] = {
			['height'] = 36,
			['font'] = "ZoFontWinH4", -- 18
		},
		['width'] = 370,
		['adjustment'] = 20, -- +3?
		['font'] = 'ZoFontWinH5'
	},
	[2] = {
		['header'] = {
			['height'] = 38,
			['font'] = "ZoFontWinH3",
		},
		['width'] = 380,
		['adjustment'] = 22, -- +3?
		['font'] = 'ZoFontWinH4'
	},
	[3] = {
		['header'] = {
			['height'] = 40,
			['font'] = "ZoFontWinH2",
		},
		['width'] = 410,
		['adjustment'] = 24, -- +3?
		['font'] = 'ZoFontWinH3'
	},
	[4] = {
		['header'] = {
			['height'] = 48, -- +0
			['font'] = "ZoFontWinH1",
		},
		['width'] = 450,
		['adjustment'] = 28, -- +3?
		['font'] = 'ZoFontWinH2'	
	},
}

local performingFullRefresh = false
-------------------------------------
-- Writ panel
-------------------------------------
local IJA_WritPanel = ZO_CallbackObject:Subclass()

local WRIT_SORT_KEYS ={
	canCraft		= { tiebreaker = "completed", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
	completed		= { tiebreaker = "inBank", reverseTiebreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
	inBank			= { tiebreaker = "isSmithing", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
	isSmithing 		= { tiebreaker = "craftingType", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
	craftingType	= { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
	name			= { },
}
local function writSortFunc(data1, data2)
	return ZO_TableOrderingFunction(data1, data2, "canCraft", WRIT_SORT_KEYS, ZO_SORT_ORDER_DOWN) 
end

local function setHighlightColors(control)
	local r, g, b, a = control:GetColor()
	local normal = ZO_ColorDef:New(r, g, b, 0.9)
	local enter = {r = r and r / 0.8 or 0, g = g and g / 0.8 or 0, b = b and b / 0.8 or 0}
	local down = {r = r and r * 0.8 or 0, g = g and g * 0.8 or 0, b = b and b * 0.8 or 0}
	
	control.color = {}
	control.color.normal = normal
	control.color.enter = ZO_ColorDef:New(enter.r, enter.g, enter.b, 1)
	control.color.down = ZO_ColorDef:New(down.r, down.g, down.b, 0.8)
end

local function setRowColor(row, state)
	local r,g,b,a = getColor(state):UnpackRGBA()
	row.name:SetColor(r,g,b,a)
	row.icon:SetColor(r,g,b,a)
end

local function setIconSize(row, data, iconSize)
end

local function setMouseOver(ctrl, text)
	setHighlightColors(ctrl)
	
	ctrl:SetHandler("OnMouseEnter", function(self)
		self:SetColor(self.color.enter:UnpackRGBA())
		ZO_Tooltips_ShowTextTooltip(self:GetParent():GetNamedChild("Status"), RIGHT, text)
	end)
	ctrl:SetHandler("OnMouseExit", function(self)
		ZO_Tooltips_HideTextTooltip()
		self:SetColor(self.color.normal:UnpackRGBA())
	end)
end

-------------------------------------
function IJA_WritPanel:Initialize(owner, control)
	self.owner = owner
	self.savedVars = owner.savedVars
	local container = control:GetNamedChild("Container")
	control.header = container:GetNamedChild("Header")
	control.container = container
	self.control = control
	self.control:SetHidden(true)
	
	self.WP = {
		isMinimized = false,
		isCollapsed = false,
		isGrouped = false
	}
	self.template = {
		row = {},
		header = {}
	}
	
	self.writs = container:GetNamedChild("Writs")
	ZO_ScrollList_Initialize(self.writs)
	
	self:AddListDataTypes()
	self:InitializePanel()
	
	return self
end

function IJA_WritPanel:InitializePanel()
	-- adding it as a fragment to the hud scene to give hud control over hiding and showing it. 
	-- this will cause the panel to auto-hid/show with the hud for instances such as opening a menu
	self.sceneFragment = ZO_HUDFadeSceneFragment:New(self.control, nil, 0)

	IJAWH_WRITPANEL_ORIGINAL_HEIGHT = 45
	IJAWH_WRITPANEL_ADJUSTED_HEIGHT = 0

	local function minimizeButton()
		self:Minimize()
	end

	local function maximizeButton()
		self:Maximize()
	end
	function IJA_WritPanel:buttonMaxMin(state)
		if state then
			minimizeButton()
		else
			maximizeButton()
		end
	end

	IJA_WritHelperWritPanelMaximize_Button:SetHidden(true)

	IJA_WritHelperWritPanelMinimize_Button:SetHandler("OnMouseUp", minimizeButton)
	IJA_WritHelperWritPanelMaximize_Button:SetHandler("OnMouseUp", maximizeButton)
	
	self.control.header:SetColor(COLOR_CRAFTABLE:UnpackRGBA())
	setHighlightColors(self.control.header)
	
	function IJA_WritPanel:wpMinMax(state)
		PlaySound(SOUNDS.DEFAULT_CLICK)
		IJAWH_WRITPANEL_LIST_IsHidden = state
		local HEIGHT = state and IJAWH_WRITPANEL_ORIGINAL_HEIGHT or IJAWH_WRITPANEL_ADJUSTED_HEIGHT
		self.control.container:SetHeight(HEIGHT)
		self.control.container:GetNamedChild("Divider"):SetHidden(state)
		
		self.writs:SetHidden(state)
		
		local newState = not state
		-- highlight header
		local r, g, b, a = self.control.header:GetColor()
		local num = tostring(g):gsub("^(0.8).*", "%1")
		if num ~= "0.8" then
		self.control.header:SetColor(self.control.header.color.enter:UnpackRGB())
		end
		self.control.header:SetHandler("OnMouseUp", function() self:wpMinMax(newState) end)
	end
	self:wpMinMax(false)
end

function IJA_WritPanel:AddListDataTypes()
 	local function setupRow(rowControl, data)
		rowControl.owner = self
		local row = rowControl:GetNamedChild("Row")
		row.owner = self
		local iconContainer					= rowControl:GetNamedChild("IconContainer")
		row.name 		= row.name 			or rowControl:GetNamedChild("Name")
		row.status 		= row.status 		or rowControl:GetNamedChild("Status")
		
		row.strike 		= row.strike 		or row.name:GetNamedChild("Strike")
		row.icon 		= row.icon 			or iconContainer:GetNamedChild("Icon")
		row.notice 		= row.notice 		or row.name:GetNamedChild("Notice")
		
		row.strike:SetHidden(true)

		local color = data.state == 1 and COLOR_COMPLETE or COLOR_CRAFTABLE
		local r,g,b,a = color:UnpackRGBA()
------ icon
		row.icon:SetTexture(data.icon)
		local scale = self.savedVars.panelScale
		local iconSize = scaleTemplates[scale].adjustment * 1.4

		if data.inBank then
			row.icon:SetDimensions(iconSize * 0.8, iconSize * 0.8)
			setMouseOver(row.icon, GetString(SI_IJAWH_IN_WTHDRAW_LIST))
		else
			row.icon:SetDimensions(iconSize, iconSize)
		end
		iconContainer:SetWidth(iconSize * 1.1)
		row.icon:SetColor(r,g,b,a)
		
------ name
		row.name:SetText(data.name)
		row.name:SetColor(r,g,b,a)
		setMouseOver(row.name, data.toolTip)
		
------ notice
		local noticeShown = data.state == 3 or data.state == 0
		local noticeColor = data.state == 3 and COLOR_NOTICE or COLOR_ERROR
		row.notice:SetHidden(not noticeShown)
		row.notice:SetDimensions(iconSize * 0.8, iconSize * 0.8)
		row.notice:SetColor(noticeColor:UnpackRGBA())
		
------ x/y
		row.status:SetWidth(iconSize * 1.1)
		row.status:SetText(data.status)
		row.status:SetColor(r,g,b,a)
		
		rowControl:SetHandler("OnDragStart", nil)
		rowControl:SetHandler("OnReceiveDrag", nil)
	end

	local LIST_TYPE = 1
	ZO_ScrollList_AddDataType(self.writs, LIST_TYPE, "IJA_WritHelper_WritPanelTemplate", nil, function(rowControl, data) setupRow(rowControl, data) end)
end

local COMPLETEDWRITS = 0
function IJA_WritPanel:UpdateWritsPanel(panelData, completedWrits)
	if completedWrits == #panelData then
		self.control.header:SetColor(COLOR_COMPLETE:UnpackRGBA())
	else
		self.control.header:SetColor(COLOR_CRAFTABLE:UnpackRGBA())
	end
	local totalWrits = #panelData
	self.control.header:SetText(zo_strformat(GetString(SI_IJAWH_TOTAL_WRITS), completedWrits, totalWrits))
	
	IJAWH_WRITLIST_HEIGHT = self.template.adjustment * totalWrits
	IJAWH_WRITPANEL_ADJUSTED_HEIGHT = IJAWH_WRITLIST_HEIGHT + 20
	IJAWH_WRITPANEL_ADJUSTED_HEIGHT = IJAWH_WRITPANEL_ADJUSTED_HEIGHT + IJAWH_WRITPANEL_ORIGINAL_HEIGHT

	local panelHeight
	if IJAWH_WRITPANEL_LIST_IsHidden then
		panelHeight = IJAWH_WRITPANEL_ORIGINAL_HEIGHT
	else
		self:wpMinMax(false)
		panelHeight = IJAWH_WRITPANEL_ADJUSTED_HEIGHT
	end
	
	setHighlightColors(self.control.header)
	self.control.header:SetHandler("OnMouseEnter", function(self)
		self:SetColor(self.color.enter:UnpackRGBA())
	end)
	self.control.header:SetHandler("OnMouseExit", function(self)
		self:SetColor(self.color.normal:UnpackRGBA())
	end)
	self.control.header:SetHandler("OnMouseDown", function(self)
		self:SetColor(self.color.down:UnpackRGBA())
	end)
	
	COMPLETEDWRITS = completedWrits
end

function IJA_WritPanel:UpdateWritsPanelData()
	local panelData = {}
	local completedWrits = 0
	
	for craftingType, stationWrits in pairs(IJA_WRITHELPER.writData) do
		for questIndex, writObject in pairs(stationWrits) do
			writObject:UpdatePanelData()
			completedWrits = writObject.completed and completedWrits + 1 or completedWrits
			
			table.insert(panelData, writObject.panelData)
		end
	end
	
	table.sort(panelData, writSortFunc)
	
	return panelData, completedWrits
end

function IJA_WritPanel:PerformFullRefresh()
	if not performingFullRefresh then
		ZO_ScrollList_Clear(self.writs)
		performingFullRefresh = true
		self:Refresh(ZO_ScrollList_GetDataList(self.writs))
		ZO_ScrollList_Commit(self.writs)
		
		if self.savedVars.autoCollaps then
			local panelData = ZO_ScrollList_GetDataList(self.writs)
			if COMPLETEDWRITS == #panelData and #panelData > 0 then
				-- minimize or hide list when all lists are completed
				local oldState = IJAWH_WRITPANEL_LIST_IsHidden and true or false
				self:wpMinMax(true)
				IJAWH_WRITPANEL_LIST_IsHidden = oldState
			elseif not IJAWH_WRITPANEL_LIST_IsHidden then
				self:wpMinMax(false)
			end
		end
		performingFullRefresh = false
	end
end

function IJA_WritPanel:Refresh(data)
--	IJA_WRITHELPER:RefreshQuestList()
	-- upadate all writs
--	IJA_WRITHELPER:UpdateWrits()
	
	local panelData, completedWrits = self:UpdateWritsPanelData()
	for index, newData in pairs(panelData) do
		if type(newData) == "table" then
			table.insert(data, ZO_ScrollList_CreateDataEntry(1, newData))
		end
	end
	
	self:UpdateWritsPanel(panelData, completedWrits)
end

local function hideWritPanel(questCount)
	return questCount < 1 or
		IsUnitInCombat("player") or
		IsUnitActivelyEngaged("player") or
		IsUnitPvPFlagged("player") or
		IsUnitInDungeon("player") or
		IJA_WRITHELPER.savedVars.hideWhileMounted and IsMounted()
end

function IJA_WritPanel:WritsPanelControl()
	if IsUnitGrouped("player") then
		if not self.groupCheck then
			self.groupCheck = true
			self:MoveRight()
		end
		local currentGroupSize = GetGroupSize()
		if currentGroupSize > 4 then
			self:wpMinMax(true)
		end
	else
		if self.groupCheck then
			self.groupCheck = false
			self:MoveLeft()
		end
	end

	self:PerformFullRefresh()
	
	local questCount = NonContiguousCount(IJA_WRITHELPER.writData)
	
	if questCount < 1 then
		HUD_SCENE:RemoveFragment(self.sceneFragment)
		HUD_UI_SCENE:RemoveFragment(self.sceneFragment)
	else
		HUD_SCENE:AddFragment(self.sceneFragment)
		HUD_UI_SCENE:AddFragment(self.sceneFragment)
	end
	
	if HUD_FRAGMENT:IsShowing() then
		self.control:SetHidden(hideWritPanel(questCount))
	end
end

local function updateWritsPanel()
	IJA_WritPanel:WritsPanelControl()
end
CALLBACK_MANAGER:RegisterCallback("IJA_WritHelper_Update_Writs_Panel", updateWritsPanel)

function IJA_WritPanel:SetPanelStyle()
	local scale = self.savedVars.panelScale
	local template = scaleTemplates[scale]
	self.template = template
	
	self.control.header:SetFont(template.header.font)
	self.control.header:SetHeight(template.header.height)
	
	IJAWH_WRITPANEL_ORIGINAL_HEIGHT = template.header.height
	
	self.control.container:SetWidth(template.width)
	self.control.container:GetNamedChild("BG"):SetAlpha( self.savedVars.transparency / 100)
	
	ZO_ScrollList_UpdateDataTypeHeight(self.writs, 1, template.adjustment)
	CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
end

function IJA_WritPanel_GetPanelFont()
	local scale = IJA_WRITHELPER.savedVars.panelScale
	return scaleTemplates[scale].font
end

--------------Initialize--------------
function IJA_WritPanel_Initialize(...)
	return IJA_WritPanel:Initialize(...)
end

-------------------------------------
-- Writ Panel Animation Functions
-------------------------------------
local function CreateSlideAnimations(control)
	if not control.slideAnim then control.slideAnim = ANIMATION_MANAGER:CreateTimelineFromVirtual("IJAMinMaxAnim", control.container) end
end

local function selectButton(minimize)
	IJA_WritHelperWritPanelMinimize_Button:SetHidden(minimize)
	IJA_WritHelperWritPanelMaximize_Button:SetHidden(not minimize)
end

local function setToGroup()
	local groupDistance = IJA_WRITHELPER.isGamepadMode and 60 or -10
	return (ZO_SmallGroupAnchorFrame:GetRight() + groupDistance)
end
local function setToScreen(control)
	return control.container:GetLeft()
end

function IJA_WritPanel:Move(distance, maximizeAnimation)
	local control = self.control
	CreateSlideAnimations(control, maximizeAnimation)

	local moveDistance
	if not control.slideAnim:IsPlaying() then
		moveDistance = distance
		control.originalPosition = moveDistance
	else
		moveDistance = control.originalPosition
	end

	control.slideAnim:GetAnimation(1):SetTranslateDeltas(moveDistance, 0)
	control.slideAnim:PlayFromStart()
end

function IJA_WritPanel:Minimize()
	local control = self.control
	if not self.control.isMinimized then
		CreateSlideAnimations(control)
		control.container:SetClampedToScreen(false)

		control.slideAnim:SetHandler('OnStop', function() self.control.container:SetHidden(true) end)

		self:Move(-(control.container:GetRight() + 50))
		PlaySound(SOUNDS.CHAT_MINIMIZED)
		
		self.control.isMinimized = true
		selectButton(self.control.isMinimized)
    end
end
function IJA_WritPanel:Maximize()
	local control = self.control
	if self.control.isMinimized then
		CreateSlideAnimations(control)
		self.control.container:SetHidden(false)
		
		local screenDistance	= -(setToScreen(control))
		local groupDistance		= setToGroup() + screenDistance
		local maximizeDistance	= self.groupCheck and groupDistance or screenDistance + 50
		
		control.slideAnim:SetHandler("OnStop", function() control.container:SetClampedToScreen(true) end)
		
		self:Move(maximizeDistance)
        PlaySound(SOUNDS.CHAT_MAXIMIZED)
		
		self.control.isMinimized = false
		selectButton(self.control.isMinimized)
    end
end

-- for reposition for group
function IJA_WritPanel:MoveRight()		-- >>>>>>>>>>>>>>>>>
	if self.control.isMinimized then return end
	local control = self.control
	if not self.control.isRight then
		CreateSlideAnimations(control)
		self:Move(setToGroup())
        PlaySound(SOUNDS.CHAT_MAXIMIZED)
		self.control.isRight = true
    end
end
function IJA_WritPanel:MoveLeft()		-- <<<<<<<<<<<<<<<<<
	if self.control.isMinimized then return end
	local control = self.control
	if self.control.isRight then
		CreateSlideAnimations(control)
		self:Move( -(setToScreen(control)) + 8 )
        PlaySound(SOUNDS.CHAT_MINIMIZED)
		self.control.isRight = false
    end
end