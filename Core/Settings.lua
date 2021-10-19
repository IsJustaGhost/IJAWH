local IJA_WritHelper = IJA_WRITHELPER
--	/script IJA_WRITHELPER:CreateMenu()
function IJA_WritHelper:CreateMenu( owner )
--	self.savedVars = owner.savedVars
	if not self.savedVars.autoCraft then self.savedVars.autoCraft = {} end
	
    local optionsTable = {
		[1] = {
			{	-- SI_IJAWH_SETTING_SAVEPERCHARACTER
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_SAVEPERCHARACTER),
				tooltip = GetString(SI_IJAWH_SETTING_SAVEPERCHARACTER_TOOLTIP),
				getFunc = function()
					return self.accountWideSavedVars.character
				end,
				setFunc = function(value)
					self.accountWideSavedVars.character = value
				end,
				width = "full",
				requiresReload = true,
			},
			{ 	-- SI_IJAWH_HEADER_OTHER
				type = "header",
				name = GetString(SI_IJAWH_HEADER_WRIT),
				width = "full",
				--{
			},
			{
				type = "dropdown",
				name = GetString(SI_IJAWH_SETTING_PANELFONT),
				tooltip = GetString(SI_IJAWH_SETTING_PANELFONT_TOOLTIP),
				choices = {'16', '18', '20', '24'},
				choicesValues = {1, 2, 3, 4},
				getFunc = function()
					return self.savedVars.panelScale
				end,
				setFunc = function(value)
					self.savedVars.panelScale = value
					self.writPanel:SetPanelStyle()
					IJA_WritHelperWritPanel:SetHidden(false)
				end,
				width = "full",
			},
			{--optionsTable
				type = "slider",
				name = GetString(SI_IJAWH_SETTING_PANELTRANSPARENCY),
				tooltip = GetString(SI_IJAWH_SETTING_PANELTRANSPARENCY_TOOLTIP),
				min = 1,
				max = 100,
				step = 0.5,
				getFunc = function()
					return self.savedVars.transparency
				end,
				setFunc = function( value )
					self.savedVars.transparency = value
					self.writPanel:SetPanelStyle()
					IJA_WritHelperWritPanel:SetHidden(false)
				end,
				width = "full",
				default = self.defaultSettings.transparency,
			},
			{ 	-- hide while mounted
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_HIDEMOUNTED),
				tooltip = GetString(SI_IJAWH_SETTING_HIDEMOUNTED_TOOLTIP),
				getFunc = function()
					return self.savedVars.hideWhileMounted
				end,
				setFunc = function(value)
					self.savedVars.hideWhileMounted = value
				end,
				width = "full",
				default = self.defaultSettings.hideWhileMounted
			},
			{ 	-- SI_IJAWH_HEADER_OTHER
				type = "header",
				name = GetString(SI_IJAWH_HEADER_CRAFT),
				width = "full",
			},
			{ 	-- SI_IJAWH_SETTING_AUTOCRAFT
				type = "checkbox",
				name = GetString("SI_IJAWH_SETTING_AUTOCRAFT", CRAFTING_TYPE_ENCHANTING),
				tooltip = GetString("SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP", CRAFTING_TYPE_ENCHANTING),
				getFunc = function()
					return self.savedVars.autoCraft[CRAFTING_TYPE_ENCHANTING]
				end,
				setFunc = function(value)
					self.savedVars.autoCraft[CRAFTING_TYPE_ENCHANTING] = value
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end,
				width = "half"
			},
			{ 	-- SI_IJAWH_SETTING_AUTOCRAFT
				type = "checkbox",
				name = GetString("SI_IJAWH_SETTING_AUTOCRAFT", CRAFTING_TYPE_ALCHEMY),
				tooltip = GetString("SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP", CRAFTING_TYPE_ALCHEMY),
				getFunc = function()
					return self.savedVars.autoCraft[CRAFTING_TYPE_ALCHEMY]
				end,
				setFunc = function(value)
					self.savedVars.autoCraft[CRAFTING_TYPE_ALCHEMY] = value
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end,
				width = "half"
			},
			{ 	-- SI_IJAWH_SETTING_AUTOCRAFT
				type = "checkbox",
				name = GetString("SI_IJAWH_SETTING_AUTOCRAFT", CRAFTING_TYPE_PROVISIONING),
				tooltip = GetString("SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP", CRAFTING_TYPE_PROVISIONING),
				getFunc = function()
					return self.savedVars.autoCraft[CRAFTING_TYPE_PROVISIONING]
				end,
				setFunc = function(value)
					self.savedVars.autoCraft[CRAFTING_TYPE_PROVISIONING] = value
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end,
				width = "half"
			},
			{ 	-- SI_IJAWH_SETTING_AUTOCRAFT
				type = "checkbox",
				name = GetString("SI_IJAWH_SETTING_AUTOCRAFT", 1),
				tooltip = GetString("SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP", 1),
				getFunc = function()
					return self.savedVars.autoCraft[1]
				end,
				setFunc = function(value)
					self.savedVars.autoCraft[1] = value
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end,
				width = "half"
			},
			{ 	-- auto continue
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_AUTOCONTINUE),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOCONTINUE_TOOLTIP),
				getFunc = function()
					return self.savedVars.autoContinue
				end,
				setFunc = function(value)
					self.savedVars.autoContinue = value
				end,
				width = "full"
			},
			{
				type = "divider",
				height = 10,
			},			{ 	-- SI_IJAWH_SETTING_USEMOSTSTYLE
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_USEMOSTSTYLE),
				tooltip = GetString(SI_IJAWH_SETTING_USEMOSTSTYLE_TOOLTIP),
				getFunc = function()
					return self.savedVars.useMostStyle
				end,
				setFunc = function(value)
					self.savedVars.useMostStyle = value
					if value ~= true then self.savedVars.useRaceStyles = value end
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end,
				width = "half",
				default = self.defaultSettings.useMostStyle,
	--			disabled = function() return not IJAWH.savedVars.showCraftForWrit end,
			},
			{ 	-- SI_IJAWH_SETTING_USERACESTYLE
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_USERACESTYLE),
				tooltip = GetString(SI_IJAWH_SETTING_USERACESTYLE_TOOLTIP),
				getFunc = function()
					return self.savedVars.useRaceStyles
				end,
				setFunc = function(value)
					self.savedVars.useRaceStyles = value
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end,
				width = "half",
				default = self.defaultSettings.useRaceStyles,
	--			disabled = function() return not IJAWH.savedVars.useMostStyle end,
			},

			{ 	-- SI_IJAWH_SETTING_USERACESTYLE
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_AUTOIMPROVE),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOIMPROVE_TOOLTIP),
				getFunc = function()
					return self.savedVars.autoImprove
				end,
				setFunc = function(value)
					self.savedVars.autoImprove = value
				end,
				width = "full",
	--			disabled = function() return not IJAWH.savedVars.useMostStyle end,
			},

			{ 	-- SI_IJAWH_HEADER_OTHER
				type = "header",
				name = GetString(SI_IJAWH_HEADER_CERTS),
				width = "full",
				--{
			},
			{ 	-- SI_IJAWH_SETTING_USERACESTYLE
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_AUTOCRAFT6),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP6),
				getFunc = function()
					return self.savedVars.autoCraft[6]
				end,
				setFunc = function(value)
					self.savedVars.autoCraft[6] = value
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end,
				width = "half",
			},
			{ 	-- SI_IJAWH_SETTING_USERACESTYLE
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_AUTOCRAFT7),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOCRAFT_TOOLTIP7),
				getFunc = function()
					return self.savedVars.autoCraft[7]
				end,
				setFunc = function(value)
					self.savedVars.autoCraft[7] = value
					CALLBACK_MANAGER:FireCallbacks("IJA_WritHelper_Update_Writs_Panel")
				end,
				width = "half",
			},

			{
				type = "divider",
				height = 10,
			},
			{ 	-- SI_IJAWH_SETTING_AUTOEXIT
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_AUTOEXIT),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOEXIT_TOOLTIP),
				getFunc = function()
					return self.savedVars.autoExit
				end,
				setFunc = function(value)
					self.savedVars.autoExit = value
				end,
				width = "full",
				default = self.defaultSettings.autoExit,
	--			disabled = function() return not IJAWH.savedVars.showCraftForWrit end,
			},
			{ 	-- SI_IJAWH_SETTING_AUTOEXIT
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_AUTOCOLLAPSE),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOCOLLAPSE_TOOLTIP),
				getFunc = function()
					return self.savedVars.autoCollaps
				end,
				setFunc = function(value)
					self.savedVars.autoCollaps = value
				end,
				width = "full",
			},
			{ 	-- SI_IJAWH_SETTING_AUTOOPEN
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_AUTOOPEN),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOOPEN_TOOLTIP),
				getFunc = function()
					return self.savedVars.autoOpen
				end,
				setFunc = function(value)
					self.savedVars.autoOpen = value
				end,
				width = "half",
	--			default = self.defaultSettings.autoOpen,
			},
			{--optionsTable
				type = "slider",
				name = GetString(SI_IJAWH_SETTING_AUTOOPENDELAY),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOOPENDELAY_TOOLTIP),
				min = 0,
				max = 10,
				step = 0.5,
				getFunc = function()
					return self.savedVars.autoOpenDelay
				end,
				setFunc = function( value )
					self.savedVars.autoOpenDelay = value
				end,
				width = "half",
				default = self.defaultSettings.autoOpenDelay,
--				disabled = function() return not IJAWH.savedVars.autoOpen end,
			},
		
			{ 	-- SI_IJAWH_SETTING_AUTOACCEPT
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_AUTOACCEPT),
				tooltip = GetString(SI_IJAWH_SETTING_AUTOACCEPT_TOOLTIP),
				getFunc = function()
					return self.savedVars.autoAccept
				end,
				setFunc = function(value)
					self.savedVars.autoAccept = value
				end,
				width = "full",
				default = self.defaultSettings.autoAccept,
			},
			
			{ 	-- SI_IJAWH_HEADER_OTHER
				type = "header",
				name = GetString(SI_IJAWH_HEADER_OTHER),
				width = "full",
			},
			{ 	-- SI_IJAWH_SETTING_HANDLEWITHDRAW
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_HANDLEWITHDRAW),
				tooltip = GetString(SI_IJAWH_SETTING_HANDLEWITHDRAW_TOOLTIP),
				getFunc = function()
					return self.savedVars.handleWithdraw
				end,
				setFunc = function(value)
					self.savedVars.handleWithdraw = value
				end,
				width = "full",
				default = self.defaultSettings.handleWithdraw,
			},

		},
		[2] = {
				
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
					return self.savedVars.showInBankAlert
				end,
				setFunc = function(value)
					self.savedVars.showInBankAlert = value
				end,
				width = "full",
				default = self.defaultSettings.showWithdrawInChat,
			},
			{	-- SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT
				type = "checkbox",
				name = GetString(SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT),
				tooltip = GetString(SI_IJAWH_SETTING_SHOWWITHDRAWINCHAT_TOOLTIP),
				getFunc = function()
					return self.savedVars.showWithdrawInChat
				end,
				setFunc = function(value)
					self.savedVars.showWithdrawInChat = value
				end,
				width = "full",
				default = self.defaultSettings.showWithdrawInChat,
			},
		}
    }

	self:CreateOptionsPanel(optionsTable)
end
