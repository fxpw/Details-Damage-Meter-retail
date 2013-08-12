--File Revision: 1
--Last Modification: 27/07/2013
-- Change Log:
	-- 27/07/2013: Finished alpha version.
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

	local _detalhes = _G._detalhes
	local Loc = LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	local SharedMedia = LibStub:GetLibrary ("LibSharedMedia-3.0")
	
	local DEFAULT_CHILD_WIDTH = 60
	local DEFAULT_CHILD_HEIGHT = 16
	local DEFAULT_CHILD_FONTFACE = "Friz Quadrata TT"
	local DEFAULT_CHILD_FONTCOLOR = {1, 0.7333333333333333, 0, 1}
	local DEFAULT_CHILD_FONTSIZE = 10
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers

	local _math_floor = math.floor --> api local
	local _ipairs = ipairs --> api local


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> status bar core functions
--[[	This file contains Api and Internal functions, plus 4 built-in plugins  
	You can use this four plugins to learn how they works--]]

	--> create a plugin child for an instance
	function _detalhes.StatusBar:CreateStatusBarChildForInstance (instance, pluginName)
		local PluginObject = _detalhes.StatusBar.NameTable [pluginName]
		if (PluginObject) then
			local new_child = PluginObject:CreateChildObject (instance)
			if (new_child) then
				instance.StatusBar [#instance.StatusBar+1] = new_child
				new_child.enabled = false
				return new_child
			end
		end
		return nil
	end

	function _detalhes.StatusBar:AlignPluginText (child, default)
		local side = child.options.textAlign
		if (child.options.textAlign == 0) then
			side = default
		end
		
		child.text:ClearAllPoints()
		if (side == 1) then
			child.text:SetPoint ("left", child.frame, "left", child.options.textXMod, child.options.textYMod)
		elseif (side == 2) then
			child.text:SetPoint ("center", child.frame, "center", child.options.textXMod, child.options.textYMod)
		elseif (side == 3) then
			child.text:SetPoint ("right", child.frame, "right", child.options.textXMod, child.options.textYMod)
		end
	end
	
	--> functions to set the three statusbar places: left, center and right
		function _detalhes.StatusBar:SetCenterPlugin (instance, childObject)
			childObject.frame:Show()
			childObject.frame:SetPoint ("center", instance.baseframe.rodape.StatusBarCenterAnchor, "center")
			_detalhes.StatusBar:AlignPluginText (childObject, 2)
			
			instance.StatusBar.center = childObject
			childObject.anchor = "center"
			childObject.enabled = true
			if (childObject.OnEnable) then
				childObject:OnEnable()
			end
			return true
		end

		function _detalhes.StatusBar:SetLeftPlugin (instance, childObject)
		
			childObject.frame:Show()
			childObject.frame:SetPoint ("left", instance.baseframe.rodape.StatusBarLeftAnchor,  "left")
			_detalhes.StatusBar:AlignPluginText (childObject, 1)
			
			instance.StatusBar.left = childObject
			childObject.anchor = "left"
			childObject.enabled = true
			if (childObject.OnEnable) then
				childObject:OnEnable()
			end
			return true
		end

		function _detalhes.StatusBar:SetRightPlugin (instance, childObject)
			childObject.frame:Show()
			childObject.frame:SetPoint ("right", instance.baseframe.rodape.direita, "right", -20, 10)
			_detalhes.StatusBar:AlignPluginText (childObject, 3)
			
			instance.StatusBar.right = childObject
			childObject.anchor = "right"
			childObject.enabled = true
			if (childObject.OnEnable) then
				childObject:OnEnable()
			end
			return true
		end

	--> disable all plugin childs attached to an specified instance and reactive the childs taking the instance statusbar anchors
	function _detalhes.StatusBar:ReloadAnchors (instance)
		for _, child in _ipairs (instance.StatusBar) do
			child.frame:ClearAllPoints()
			child.frame:Hide()
			child.anchor = nil
			child.enabled = false
			if (child.OnDisable) then
				child:OnDisable()
			end
		end
		--> enable only needed plugins
		if (instance.StatusBar.right) then
			_detalhes.StatusBar:SetRightPlugin (instance, instance.StatusBar.right)
		end
		if (instance.StatusBar.center) then
			_detalhes.StatusBar:SetCenterPlugin (instance, instance.StatusBar.center)
		end
		if (instance.StatusBar.left) then
			_detalhes.StatusBar:SetLeftPlugin (instance, instance.StatusBar.left)
		end
	end

	--> select a new plugin in for an instance anchor
	local ChoosePlugin = function (_, _, index, current_child, anchor)
		local pluginMestre = _detalhes.StatusBar.Plugins [index]
		local instance = current_child.instance -- instance que estamos usando agora
		
		local chosenChild = nil
		
		for _, child_created in _ipairs (instance.StatusBar) do 
			if (child_created.mainPlugin == pluginMestre) then
				chosenChild = child_created
				break
			end
		end
		
		if (not chosenChild) then
			chosenChild = _detalhes.StatusBar:CreateStatusBarChildForInstance (current_child.instance, pluginMestre.real_name)
		end

		instance.StatusBar [anchor] = chosenChild
		if (chosenChild.anchor) then
			instance.StatusBar [chosenChild.anchor] = current_child
		end
		
		_detalhes.StatusBar:ReloadAnchors (instance)
		
		_detalhes.popup:ShowMe (false)
	end

	--> on enter
	local onEnterCooltipTexts = { 
			{text = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:14:0:1:512:512:8:70:224:306|t " .. Loc ["STRING_PLUGIN_TOOLTIP_LEFTBUTTON"]},
			{text = "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:14:0:1:512:512:8:70:328:409|t " .. Loc ["STRING_PLUGIN_TOOLTIP_RIGHTBUTTON"]}}

	local OnEnter = function (frame)
		
		--|TTexturePath:							size X: size Y: point offset Y X : texture size : coordx1 L : coordx2 R : coordy1 T : coordy2 B |t 
		-- left click: 0.0019531:0.1484375:0.4257813:0.6210938 right click: 0.0019531:0.1484375:0.6269531:0.8222656
		local passou = 0
		frame:SetScript ("OnUpdate", function (self, elapsed)
			passou = passou + elapsed
			if (passou > 0.5) then
				if (not _detalhes.popup.mouseOver and not _detalhes.popup.buttonOver and not _detalhes.popup.active) then
					GameCooltip:Reset()
					GameCooltip:AddFromTable (onEnterCooltipTexts)
					GameCooltip:SetOption ("TextSize", 9.5)
					GameCooltip:ShowCooltip (frame, "tooltip")
				end
				self:SetScript ("OnUpdate", nil)
				_detalhes.popup.active = true
			end
		end)

		return true
	end

	--> on leave
	local OnLeave = function (frame)
		if (_detalhes.popup.active) then
			local passou = 0
			frame:SetScript ("OnUpdate", function (self, elapsed)
				passou = passou+elapsed
				if (passou > 0.3) then
					if (not _detalhes.popup.mouseOver and not _detalhes.popup.buttonOver and _detalhes.popup.Host == frame) then
						_detalhes.popup:ShowMe (false)
					end
					_detalhes.popup.active = false
					self:SetScript ("OnUpdate", nil)
				end
			end)
		else
			_detalhes.popup.active = false
			frame:SetScript ("OnUpdate", nil)
		end
		return true
	end

	local OnMouseUp = function (frame, mouse)

		if (mouse == "LeftButton") then
			if (not frame.child.Setup) then
				print (Loc ["STRING_STATUSBAR_NOOPTIONS"])
				return
			end
			frame.child:Setup()
		else
			GameCooltip:Reset()
			for index, _name_and_icon in _ipairs (_detalhes.StatusBar.Menu) do 
				GameCooltip:AddMenu (1, ChoosePlugin, index, frame.child, frame.child.anchor, _name_and_icon [1], _name_and_icon [2], true)
			end
			GameCooltip:SetOption ("NoLastSelectedBar", true)
			GameCooltip:SetOption ("HeightAnchorMod", -12)
			GameCooltip:ShowCooltip (frame, "menu")
		end
		return true
	end

	--> build-in function for create a frame for an plugin child
	function _detalhes.StatusBar:CreateChildFrame (instance, name, w, h)
		local frame = _detalhes.gump:NewPanel (instance.baseframe.cabecalho.fechar, nil, name..instance:GetInstanceId(), nil, w or DEFAULT_CHILD_WIDTH, h or DEFAULT_CHILD_HEIGHT, false)

		--create widgets
		local text = _detalhes.gump:NewLabel (frame, _, "$parentText", "text", "0")
		text:SetPoint ("right", frame, "right", 0, 0)
		text:SetJustifyH ("right")
		_detalhes:SetFontSize (text, 9.8)
		
		frame:SetHook ("OnEnter", OnEnter)
		frame:SetHook ("OnLeave", OnLeave)
		frame:SetHook ("OnMouseUp", OnMouseUp)
		return frame
	end

	--> built-in function for create an table for the plugin child
	function _detalhes.StatusBar:CreateChildTable (instance, mainObject, frame)
	
		local _table = {}
		
		--> treat as a class
		setmetatable (_table, mainObject)
		
		--> default members
		_table.instance = instance
		_table.frame = frame
		_table.text = frame.text
		_table.mainPlugin = mainObject
		
		--> options table
		_table.options = instance.StatusBar.options [mainObject.real_name]
		if (not _table.options) then
			_table.options = {
			textStyle = 2,
			textColor = {unpack (DEFAULT_CHILD_FONTCOLOR)},
			textSize = DEFAULT_CHILD_FONTSIZE,
			textAlign = 0,
			textXMod = 0,
			textYMod = 0,
			textFace = DEFAULT_CHILD_FONTFACE}
			instance.StatusBar.options [mainObject.real_name] = _table.options
		end
		
		_detalhes.StatusBar:ApplyOptions (_table, "textcolor")
		_detalhes.StatusBar:ApplyOptions (_table, "textsize")
		_detalhes.StatusBar:ApplyOptions (_table, "textface")
		
		_detalhes.StatusBar:ReloadAnchors (instance)
		
		--> table reference on frame widget
		frame.frame.child = _table
		
		--> adds this new child to parent child container
		mainObject.childs [#mainObject.childs+1] = _table
		
		return _table
	end

	function _detalhes.StatusBar:ApplyOptions (child, option, value)

		option = string.lower (option)
		
		if (option == "textxmod") then
			if (value) then
				child.options.textXMod = value
			end
			_detalhes.StatusBar:ReloadAnchors (child.instance)
		elseif (option == "textymod") then
			if (value) then
				child.options.textYMod = value
			end
			_detalhes.StatusBar:ReloadAnchors (child.instance)
		elseif (option == "textcolor") then
			if (value) then
				child.options.textColor = value
			end
			child.text:SetTextColor (unpack (child.options.textColor))
		elseif (option == "textsize") then
			if (value) then
				child.options.textSize = value
			end
			child:SetFontSize (child.text, child.options.textSize)
		elseif (option == "textface") then
			if (value) then
				child.options.textFace = value
			end
			child:SetFontFace (child.text, SharedMedia:Fetch ("font", child.options.textFace))
		else
			if (child [option] and type (child [option]) == "function") then
				child [option] (_, child, value)
			end
		end
	end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> BUILT-IN DPS PLUGIN
do

		--> Create the plugin Object [1] = frame name on _G [2] options [3] plugin type
		local PDps = _detalhes:NewPluginObject ("Details_StatusBarDps", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")

		--[[ Note: Declare all functions using : not . if you use . make sure to ignore first parameter and move all parameters 1 position to right ]]
		
		-- handle event "COMBAT_PLAYER_ENTER"
		function PDps:PlayerEnterCombat()
			for index, child in _ipairs (PDps.childs) do
				if (child.enabled and child.instance:GetSegment() == 0) then
					child.tick = _detalhes:ScheduleRepeatingTimer ("PluginDpsUpdate", 1, child)
				end
			end
		end
		
		-- handle event "COMBAT_PLAYER_LEAVE"
		function PDps:PlayerLeaveCombat()
			for index, child in _ipairs (PDps.childs) do
				if (child.tick) then
					_detalhes:CancelTimer (child.tick)
					child.tick = nil
				end
			end
		end

		-- handle event "DETAILS_INSTANCE_CHANGESEGMENT" 
		function PDps:ChangeSegment (instance, segment)
			for index, child in _ipairs (PDps.childs) do 
				if (child.enabled and child.instance == instance) then
					_detalhes:PluginDpsUpdate (child)
				end
			end
		end
		
		--handle event "DETAILS_DATA_RESET"
		function PDps:DataReset()
			for index, child in _ipairs (PDps.childs) do 
				if (child.enabled) then
					child.text:SetText ("0")
				end
			end
		end

		function PDps:Refresh (child)
			_detalhes:PluginDpsUpdate (child)
		end
		
		--still a little buggy, working on
		function _detalhes:PluginDpsUpdate (child)
		
			--> showing is the combat table which is current shown on instance
			if (child.instance.showing) then
				--GetCombatTime() return the time length of combat
				local combatTime = child.instance.showing:GetCombatTime()
				if (combatTime == 0) then
					return child.text:SetText ("0")
				end
				--GetTotal (attribute, sub attribute, onlyGroup) return the total of requested attribute
				local total = child.instance.showing:GetTotal (child.instance.atributo, child.instance.sub_atributo, true)
				
				local dps = _math_floor (total / combatTime)
				
				local textStyle = child.options.textStyle
				if (textStyle == 1) then
					child.text:SetText (_detalhes:ToK (dps))
				elseif (textStyle == 2) then
					child.text:SetText (_detalhes:comma_value (dps))
				else
					child.text:SetText (dps)
				end
			end
		end
		
		--> Create Plugin Frames
		function PDps:CreateChildObject (instance)
		
			--> create main frame and widgets
			--> a statusbar frame is made of a panel with a member called 'text' which is a label
			local myframe = _detalhes.StatusBar:CreateChildFrame (instance, "DetailsStatusBarDps", DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)

			--> create the table for the child
			--> a child table are the table which will hold parameters, default members: 
			-- ["instance"] = instance where this child are, 
			-- ["frame"] = myframe, 
			-- ["text"] = myframe.text, 
			-- ["mainPlugin"] = parent plugin
			local new_child = _detalhes.StatusBar:CreateChildTable (instance, PDps, myframe)
			
			return new_child
		end
		
		--> Handle events (must have, we'll use direct call to functions)
		function PDps:OnDetailsEvent (event)
			return
		end
	
		--> standard on enable and disable functions, this is for hook model. If isn't declared, details will auto modify member .enabled state
		--function PDps:OnEnable()
		--	self.enabled = true
		--end
		--function PDps:OnDisable()
		--	self.enabled = false
		--end
		
		--> setup function runs when player click with left mouse over plugin frame
		--> this is internal, but member Setup can be overwrite
		--> for exclude any options panel, set Setup to nil
		--function PDps:Setup()
		--	_detalhes.StatusBar:OpenOptionsForChild (self)
		--end
		
		--> Install
		-- _detalhes:InstallPlugin ( Plugin Type | Plugin Display Name | Plugin Icon | Plugin Object | Plugin Real Name )
		local install = _detalhes:InstallPlugin ("STATUSBAR", Loc ["STRING_PLUGIN_PDPSNAME"], "Interface\\Icons\\Achievement_brewery_3", PDps, "DETAILS_STATUSBAR_PLUGIN_PDPS")
		if (type (install) == "table" and install.error) then
			print (install.errortext)
			return
		end
		
		--> Register needed events
		-- here we are redirecting the event to an specified function, otherwise events need to be handle inside "PDps:OnDetailsEvent (event)"
		_detalhes:RegisterEvent (PDps, "DETAILS_INSTANCE_CHANGESEGMENT", PDps.ChangeSegment)
		_detalhes:RegisterEvent (PDps, "COMBAT_PLAYER_ENTER", PDps.PlayerEnterCombat)
		_detalhes:RegisterEvent (PDps, "COMBAT_PLAYER_LEAVE", PDps.PlayerLeaveCombat)
		_detalhes:RegisterEvent (PDps, "DETAILS_DATA_RESET", PDps.DataReset)

end

---------> BUILT-IN SEGMENT PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do
		--> Create the plugin Object
		local PSegment = _detalhes:NewPluginObject ("Details_Segmenter", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
		--> Handle events (must have)
		function PSegment:OnDetailsEvent (event)
			return
		end

		function PSegment:Change ()
			for index, child in _ipairs (PSegment.childs) do
				if (child.enabled and child.instance:IsEnabled()) then
					if (child.instance.segmento == -1) then --> overall
						child.text:SetText (Loc ["STRING_OVERALL"])
					elseif (child.instance.segmento == 0) then --> combate atual
						child.text:SetText (Loc ["STRING_CURRENT"])
					else --> alguma tabela do hist�rico
						child.text:SetText (Loc ["STRING_FIGHTNUMBER"]..child.instance.segmento)
					end
				end
			end
		end
		
		--> Create Plugin Frames (must have)
		function PSegment:CreateChildObject (instance)
			local myframe = _detalhes.StatusBar:CreateChildFrame (instance, "DetailsPSegmentInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
			local new_child = _detalhes.StatusBar:CreateChildTable (instance, PSegment, myframe)
			return new_child
		end
		
		--> Install
		local install = _detalhes:InstallPlugin ("STATUSBAR", Loc ["STRING_PLUGIN_PSEGMENTNAME"], "Interface\\Icons\\inv_misc_enchantedscroll", PSegment, "DETAILS_STATUSBAR_PLUGIN_PSEGMENT")
		if (type (install) == "table" and install.error) then
			print (install.errortext)
			return
		end
		
		--> Register needed events
		_detalhes:RegisterEvent (PSegment, "DETAILS_INSTANCE_CHANGESEGMENT", PSegment.Change)
		
end

---------> BUILT-IN ATTRIBUTE PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do
		--> Create the plugin Object
		local PAttribute = _detalhes:NewPluginObject ("Details_Attribute", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
		--> Handle events (must have)
		function PAttribute:OnDetailsEvent (event)
			return
		end

		function PAttribute:Change (instance, attribute, subAttribute)
			if (not instance) then
				instance, attribute, subAttribute = self.instance, self.instance.atributo, self.instance.sub_atributo
			end
			
			for index, child in _ipairs (PAttribute.childs) do
				if (child.instance == instance and child.enabled and child.instance:IsEnabled()) then
					local sName = _detalhes:GetSubAttributeName (attribute, subAttribute)
					child.text:SetText (sName)
				end
			end
		end
		
		function PAttribute:OnEnable()
			self:Change()
		end
		
		--> Create Plugin Frames (must have)
		function PAttribute:CreateChildObject (instance)
			local myframe = _detalhes.StatusBar:CreateChildFrame (instance, "DetailsPAttributeInstance" .. instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
			local new_child = _detalhes.StatusBar:CreateChildTable (instance, PAttribute, myframe)
			return new_child
		end
		
		--> Install
		local install = _detalhes:InstallPlugin ("STATUSBAR", Loc ["STRING_PLUGIN_PATTRIBUTENAME"], "Interface\\Icons\\inv_misc_emberclothbolt", PAttribute, "DETAILS_STATUSBAR_PLUGIN_PATTRIBUTE")
		if (type (install) == "table" and install.error) then
			print (install.errortext)
			return
		end
		
		--> Register needed events
		_detalhes:RegisterEvent (PAttribute, "DETAILS_INSTANCE_CHANGEATTRIBUTE", PAttribute.Change)
		
end

---------> BUILT-IN CLOCK PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do

		--> Create the plugin Object
		local Clock = _detalhes:NewPluginObject ("Details_Clock", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
		--> Handle events --must have this function
		function Clock:OnDetailsEvent (event)
			return
		end

		--enter combat
		function Clock:PlayerEnterCombat()
			Clock.tick = _detalhes:ScheduleRepeatingTimer ("ClockPluginTick", 1) 
		end
		--leave combat
		function Clock:PlayerLeaveCombat()
			_detalhes:CancelTimer (Clock.tick)
		end
		
		--1 sec tick
		function _detalhes:ClockPluginTick()
			for index, child in _ipairs (Clock.childs) do
				local instance = child.instance
				if (child.enabled and instance:IsEnabled()) then
					if (instance.showing) then
						
						local timeType = child.options.timeType
						if (timeType == 1) then
							local combatTime = instance.showing:GetCombatTime()
							local minutos, segundos = _math_floor (combatTime/60), _math_floor (combatTime%60)
							child.text:SetText (minutos .. "m " .. segundos .. "s")
							
						elseif (timeType == 2) then
							local combatTime = instance.showing:GetCombatTime()
							child.text:SetText (combatTime .. "s")
							
						elseif (timeType == 3) then
						
							local getSegment = instance.segmento
							
							if (getSegment < 1) then
								getSegment = 1
							elseif (getSegment > _detalhes.segments_amount) then
								getSegment = _detalhes.segments_amount
							else
								getSegment = getSegment+1
							end
							
							local lastFight = _detalhes:GetCombat (getSegment)
							local currentCombatTime = instance.showing:GetCombatTime()
							
							if (lastFight) then
								child.text:SetText (currentCombatTime - lastFight:GetCombatTime() .. "s")
							else
								child.text:SetText (currentCombatTime .. "s")
							end
						end
						

					end
				end
			end
		end
		
		--on reset
		function Clock:DataReset()
			for index, child in _ipairs (Clock.childs) do
				if (child.enabled and child.instance:IsEnabled()) then
					child.text:SetText ("0m 0s")
				end
			end
		end
		
		--> this is a fixed member, put all your widgets for custom options inside this function
		--> if ExtraOptions isn't preset, secondary options box will be hided and only default options will be show
		function Clock:ExtraOptions()
			
			--> all widgets need to be placed on a table
			local widgets = {}
			--> reference of extra window for custom options
			local window = _G.DetailsStatusBarOptions2.MyObject
			
			--> build all your widgets -----------------------------------------------------------------------------------------------------------------------------
				_detalhes.gump:NewLabel (window, _, "$parentClockTypeLabel", "ClockTypeLabel", Loc ["STRING_PLUGIN_CLOCKTYPE"])
				window.ClockTypeLabel:SetPoint (10, -15)
				
				local onSelectClockType = function (_, child, thistype)
					child.options.timeType = thistype
					_detalhes:ClockPluginTick()
				end
				
				local clockTypes = {{value = 1, label = Loc ["STRING_PLUGIN_MINSEC"], onclick = onSelectClockType},
				{value = 2, label = Loc ["STRING_PLUGIN_SECONLY"], onclick = onSelectClockType},
				{value = 3, label = Loc ["STRING_PLUGIN_TIMEDIFF"], onclick = onSelectClockType}}
				
				_detalhes.gump:NewDropDown (window, _, "$parentClockTypeDropdown", "ClockTypeDropdown", 200, 20, function() return clockTypes end, 1) -- func, default
				window.ClockTypeDropdown:SetPoint ("left", window.ClockTypeLabel, "right", 2)
			-----------------------------------------------------------------------------------------------------------------------------
			
			--> now we insert all widgets created on widgets table
			table.insert (widgets, window.ClockTypeLabel)
			table.insert (widgets, window.ClockTypeDropdown)

			--> after first call we replace this function with widgets table
			Clock.ExtraOptions = widgets
		end
		
		--> ExtraOptionsOnOpen is called when options are opened and plugin have custom options
		--> here we setup options widgets for get the values of clicked child and also for tell options window what child we are configuring
		function Clock:ExtraOptionsOnOpen (child)
			_G.DetailsStatusBarOptions2ClockTypeDropdown.MyObject:SetFixedParameter (child)
			_G.DetailsStatusBarOptions2ClockTypeDropdown.MyObject:Select (child.options.timeType, true)
		end
		
		--> Create Plugin Frames
		function Clock:CreateChildObject (instance)

			local myframe = _detalhes.StatusBar:CreateChildFrame (instance, "DetailsClockInstance"..instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
			
			--> we place custom frame, widgets inside this function
			local texture = myframe:CreateTexture (nil, "overlay")
			texture:SetTexture ("Interface\\AddOns\\Details\\images\\clock")
			texture:SetPoint ("right", myframe.text.widget, "left")

			local new_child = _detalhes.StatusBar:CreateChildTable (instance, Clock, myframe)
			
			--> default text
			new_child.text:SetText ("0m 0s")
			
			--> some changes from default options
			if (new_child.options.textXMod == 0) then
				new_child.options.textXMod = 6
			end
			
			--> here we are adding a new option member
			new_child.options.timeType = new_child.options.timeType or 1
			
			return new_child
		end

		--> Install
		local install = _detalhes:InstallPlugin ("STATUSBAR", Loc ["STRING_PLUGIN_CLOCKNAME"], "Interface\\Icons\\Achievement_BG_grab_cap_flagunderXseconds", Clock, "DETAILS_STATUSBAR_PLUGIN_CLOCK")
		if (type (install) == "table" and install.error) then
			print (install.errortext)
			return
		end
		
		--> Register needed events
		_detalhes:RegisterEvent (Clock, "COMBAT_PLAYER_ENTER", Clock.PlayerEnterCombat)
		_detalhes:RegisterEvent (Clock, "COMBAT_PLAYER_LEAVE", Clock.PlayerLeaveCombat)
		_detalhes:RegisterEvent (Clock, "DETAILS_INSTANCE_CHANGESEGMENT", _detalhes.ClockPluginTick)
		_detalhes:RegisterEvent (Clock, "DETAILS_DATA_SEGMENTREMOVED", _detalhes.ClockPluginTick)
		_detalhes:RegisterEvent (Clock, "DETAILS_DATA_RESET", Clock.DataReset)

end

---------> BUILT-IN THREAT PLUGIN ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

do

		local _UnitDetailedThreatSituation = UnitDetailedThreatSituation --> wow api
		local _cstr = string.format --> lua api
		local _math_abs = math.abs --> lua api
		
		--> Create the plugin Object
		local Threat = _detalhes:NewPluginObject ("Details_TargetThreat", DETAILSPLUGIN_ALWAYSENABLED, "STATUSBAR")
		--> Handle events
		function Threat:OnDetailsEvent (event)
			return
		end

		Threat.isTank = nil

		function Threat:PlayerEnterCombat()
			local role = UnitGroupRolesAssigned ("player")
			if (role == "TANK") then
				Threat.isTank = true
			else
				Threat.isTank = nil
			end
			Threat.tick = _detalhes:ScheduleRepeatingTimer ("ThreatPluginTick", 1) 
		end
		
		function Threat:PlayerLeaveCombat()
			_detalhes:CancelTimer (Threat.tick)
		end
		
		function _detalhes:ThreatPluginTick()
			for index, child in _ipairs (Threat.childs) do
				local instance = child.instance
				if (child.enabled and instance:IsEnabled()) then
					-- atualiza a threat
					local isTanking, status, threatpct, rawthreatpct, threatvalue = _UnitDetailedThreatSituation ("player", "target")
					if (threatpct) then
						child.text:SetText (_math_floor (threatpct).."%")
						if (Threat.isTank) then
							child.text:SetTextColor (_math_abs (threatpct-100)*0.01, threatpct*0.01, 0, 1)
						else
							child.text:SetTextColor (threatpct*0.01, _math_abs (threatpct-100)*0.01, 0, 1)
						end
					else
						child.text:SetText ("0%")
						child.text:SetTextColor (1, 1, 1, 1)
					end
				end
			end
		end
		
		--> Create Plugin Frames
		function Threat:CreateChildObject (instance)

			local myframe = _detalhes.StatusBar:CreateChildFrame (instance, "DetailsThreatInstance"..instance:GetInstanceId(), DEFAULT_CHILD_WIDTH, DEFAULT_CHILD_HEIGHT)
			
			local new_child = _detalhes.StatusBar:CreateChildTable (instance, Threat, myframe)

			myframe.widget:RegisterEvent ("PLAYER_TARGET_CHANGED")
			myframe.widget:SetScript ("OnEvent", function()
				_detalhes:ThreatPluginTick()
			end)
			
			return new_child
		end

		--> Install
		local install = _detalhes:InstallPlugin ("STATUSBAR", Loc ["STRING_PLUGIN_THREATNAME"], "Interface\\Icons\\Ability_Hunter_ResistanceIsFutile", Threat, "DETAILS_STATUSBAR_PLUGIN_THREAT")
		if (type (install) == "table" and install.error) then
			print (install.errortext)
			return
		end
		
		--> Register needed events
		_detalhes:RegisterEvent (Threat, "COMBAT_PLAYER_ENTER", Threat.PlayerEnterCombat)
		_detalhes:RegisterEvent (Threat, "COMBAT_PLAYER_LEAVE", Threat.PlayerLeaveCombat)


end

---------> default options panel ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local window = _detalhes.gump:NewPanel (UIParent, nil, "DetailsStatusBarOptions", nil, 300, 160)
tinsert (UISpecialFrames, "DetailsStatusBarOptions")
window:SetPoint ("center", UIParent, "center")
window.locked = false
window.close_with_right = true
window.child = nil
window.instance = nil

local extraWindow = _detalhes.gump:NewPanel (window, nil, "DetailsStatusBarOptions2", "extra", 300, 160)
extraWindow:SetPoint ("left", window, "right")
extraWindow.close_with_right = true
extraWindow.locked = false
extraWindow:SetHook ("OnHide", function()
	window:Hide()
end)

--> text style
	_detalhes.gump:NewLabel (window, _, "$parentTextStyleLabel", "textstyle", Loc ["STRING_PLUGINOPTIONS_TEXTSTYLE"])
	window.textstyle:SetPoint (10, -15)
	
	local onSelectTextStyle = function (_, child, style)
		child.options.textStyle = style
		if (child.Refresh and type (child.Refresh) == "function") then
			child:Refresh (child)
		end
	end
	local textStyle = {{value = 1, label = Loc ["STRING_PLUGINOPTIONS_ABBREVIATE"] .. " (105.5K)", onclick = onSelectTextStyle},
	{value = 2, label = Loc ["STRING_PLUGINOPTIONS_COMMA"] .. " (105.500)", onclick = onSelectTextStyle},
	{value = 3, label = Loc ["STRING_PLUGINOPTIONS_NOFORMAT"] .. " (105500)", onclick = onSelectTextStyle}}
	
	_detalhes.gump:NewDropDown (window, _, "$parentTextStyleDropdown", "textstyleDropdown", 200, 20, function() return textStyle end, 1) -- func, default
	window.textstyleDropdown:SetPoint ("left", window.textstyle, "right", 2)

--> text color
	_detalhes.gump:NewLabel (window, _, "$parentTextColorLabel", "textcolor", Loc ["STRING_PLUGINOPTIONS_TEXTCOLOR"])
	window.textcolor:SetPoint (10, -35)
	local selectedColor = function()
		local r, g, b, a = ColorPickerFrame:GetColorRGB()
		window.textcolortexture:SetTexture (r, g, b, a)
		_detalhes.StatusBar:ApplyOptions (window.child, "textcolor", {r, g, b, a})
	end
	local canceledColor = function()
		window.textcolortexture:SetTexture (unpack (ColorPickerFrame.previousValues))
		_detalhes.StatusBar:ApplyOptions (window.child, "textcolor", {r, g, b, a})
	end
	local colorpick = function()
		ColorPickerFrame:SetColorRGB (unpack (window.child.options.textColor))
		ColorPickerFrame.hasOpacity = false
		ColorPickerFrame.previousValues = window.child.options.textColor
		ColorPickerFrame.func = selectedColor
		ColorPickerFrame.cancelFunc = canceledColor
		ColorPickerFrame:Show()
	end

	_detalhes.gump:NewImage (window, _, "$parentTextColorTexture", "textcolortexture", 200, 16)
	window.textcolortexture:SetPoint ("left", window.textcolor, "right", 2)
	window.textcolortexture:SetTexture (1, 1, 1)
	
	_detalhes.gump:NewButton (window, _, "$parentTextColorButton", "textcolorbutton", 200, 20, colorpick)
	window.textcolorbutton:SetPoint ("left", window.textcolor, "right", 2)

	
--> text size
	_detalhes.gump:NewLabel (window, _, "$parentFontSizeLabel", "fonsizeLabel", Loc ["STRING_PLUGINOPTIONS_TEXTSIZE"])
	window.fonsizeLabel:SetPoint (10, -55)
	--
	_detalhes.gump:NewSlider (window, _, "$parentSliderFontSize", "fonsizeSlider", 170, 20, 9, 15, .5, 1)
	window.fonsizeSlider:SetPoint ("left", window.fonsizeLabel, "right", 2)
	window.fonsizeSlider:SetThumbSize (50)
	window.fonsizeSlider.useDecimals = true
	window.fonsizeSlider:SetHook ("OnValueChange", function (self, child, amount) 
		_detalhes.StatusBar:ApplyOptions (child, "textsize", amount)
	end)
	
--> align
	_detalhes.gump:NewLabel (window, _, "$parentTextAlignLabel", "textalign", Loc ["STRING_PLUGINOPTIONS_TEXTALIGN"])
	window.textalign:SetPoint (10, -95)
	--
	_detalhes.gump:NewSlider (window, _, "$parentSliderAlign", "alignSlider", 180, 20, 0, 3, 1)
	window.alignSlider:SetPoint ("left", window.textalign, "right")
	window.alignSlider:SetThumbSize (75)
	window.alignSlider:SetHook ("OnValueChange", function (self, child, side)
		
		child.options.textAlign = side
		
		if (side == 0) then
			window.alignSlider.amt:SetText (Loc ["STRING_AUTO"])
		elseif (side == 1) then
			window.alignSlider.amt:SetText (Loc ["STRING_LEFT"])
		elseif (side == 2) then
			window.alignSlider.amt:SetText (Loc ["STRING_CENTER"])
		elseif (side == 3) then
			window.alignSlider.amt:SetText (Loc ["STRING_RIGHT"])
		end
		
		_detalhes.StatusBar:ReloadAnchors (child.instance)
		
		return true
	end)
	
--> text font
	local onSelectFont = function (_, child, fontName)
		_detalhes.StatusBar:ApplyOptions (child, "textface", fontName)
	end

	local fontObjects = SharedMedia:HashTable ("font")
	local fontTable = {}
	for name, fontPath in pairs (fontObjects) do 
		fontTable[#fontTable+1] = {value = name, label = name, onclick = onSelectFont, font = fontPath}
	end
	local buildFontMenu = function() return fontTable end
	
	_detalhes.gump:NewLabel (window, _, "$parentFontFaceLabel", "fontfaceLabel", Loc ["STRING_PLUGINOPTIONS_FONTFACE"])
	window.fontfaceLabel:SetPoint (10, -75)
	--
	_detalhes.gump:NewDropDown (window, _, "$parentFontDropdown", "fontDropdown", 170, 20, buildFontMenu, nil)
	window.fontDropdown:SetPoint ("left", window.fontfaceLabel, "right", 2)
	
	window:Hide()
	
--> align mod X
	_detalhes.gump:NewLabel (window, _, "$parentAlignXLabel", "alignXLabel", Loc ["STRING_PLUGINOPTIONS_TEXTALIGN_X"])
	window.alignXLabel:SetPoint (10, -115)
	--
	_detalhes.gump:NewSlider (window, _, "$parentSliderAlignX", "alignXSlider", 160, 20, -20, 20, 1, 0)
	window.alignXSlider:SetPoint ("left", window.alignXLabel, "right", 2)
	window.alignXSlider:SetThumbSize (40)
	window.alignXSlider:SetHook ("OnValueChange", function (self, child, amount) 
		_detalhes.StatusBar:ApplyOptions (child, "textxmod", amount)
	end)
	
--> align modY
	_detalhes.gump:NewLabel (window, _, "$parentAlignYLabel", "alignYLabel", Loc ["STRING_PLUGINOPTIONS_TEXTALIGN_Y"])
	window.alignYLabel:SetPoint (10, -135)
	--
	_detalhes.gump:NewSlider (window, _, "$parentSliderAlignY", "alignYSlider", 160, 20, -10, 10, 1, 0)
	window.alignYSlider:SetPoint ("left", window.alignYLabel, "right", 2)
	window.alignYSlider:SetThumbSize (40)
	window.alignYSlider:SetHook ("OnValueChange", function (self, child, amount) 
		_detalhes.StatusBar:ApplyOptions (child, "textymod", amount)
	end)
	
--> open options
	function _detalhes.StatusBar:OpenOptionsForChild (child)
		
		window.child = child
		window.instance = child.instance
		
		_G.DetailsStatusBarOptionsTextStyleDropdown.MyObject:SetFixedParameter (child)
		
		_G.DetailsStatusBarOptionsTextColorTexture:SetTexture (child.options.textColor[1], child.options.textColor[2], child.options.textColor[3], child.options.textColor[4])

		_G.DetailsStatusBarOptionsSliderFontSize.MyObject:SetFixedParameter (child)
		_G.DetailsStatusBarOptionsSliderFontSize.MyObject:SetValue (child.options.textSize)
		
		_G.DetailsStatusBarOptionsSliderAlign.MyObject:SetFixedParameter (child)
		_G.DetailsStatusBarOptionsSliderAlign.MyObject:SetValue (child.options.textAlign)

		_G.DetailsStatusBarOptionsFontDropdown.MyObject:SetFixedParameter (child)
		_G.DetailsStatusBarOptionsFontDropdown.MyObject:Select (child.options.textFace)
		
		_G.DetailsStatusBarOptionsSliderAlignX.MyObject:SetFixedParameter (child)
		_G.DetailsStatusBarOptionsSliderAlignX.MyObject:SetValue (child.options.textXMod)
		
		_G.DetailsStatusBarOptionsSliderAlignY.MyObject:SetFixedParameter (child)
		_G.DetailsStatusBarOptionsSliderAlignY.MyObject:SetValue (child.options.textYMod)
		
		_G.DetailsStatusBarOptions:Show()
		
		if (child.ExtraOptions) then
		
			if (type (child.ExtraOptions) == "function") then
				child.ExtraOptions()
			end
			
			extraWindow:HideWidgets()
			
			for _, widget in pairs (child.ExtraOptions) do
				widget:Show()
			end
			
			child:ExtraOptionsOnOpen (child)
			
			extraWindow:Show()
		else
			extraWindow:Hide()
		end
	end