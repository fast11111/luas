--/ services
local Stats = cloneref(game:GetService('Stats'))
local Players = cloneref(game:GetService('Players'))
local Lighting = cloneref(game:GetService('Lighting'))
local Workspace = cloneref(game:GetService('Workspace'))
local RunService = cloneref(game:GetService('RunService'))
local HttpService = cloneref(game:GetService('HttpService'))
local TweenService = cloneref(game:GetService('TweenService'))
local UserInputService = cloneref(game:GetService('UserInputService'))
local CoreGui = RunService:IsStudio() and Players.LocalPlayer.PlayerGui or cloneref(game:GetService("CoreGui"))

--/ game things
local Camera = Workspace.CurrentCamera

--/ custom font
local fontLink = 'https://github.com/fast11111/fonts/raw/refs/heads/main/Tahoma.ttf'
local loadedFont = nil
if not isfile('drain_font.ttf') then
    local success, data = pcall(function() return game:HttpGet(fontLink) end)

    if success and data then
        writefile('drain_font.ttf', data)
    end
end

if not isfile('drain_font.json') then
    local font = {
        name = 'drain_font',
        faces = {{
            name = "Regular",
            weight = 400,
            style = "normal",
            assetId = getcustomasset('drain_font.ttf')
        }}
    }

    writefile('drain_font.json', HttpService:JSONEncode(font))
end

loadedFont = Font.new(getcustomasset('drain_font.json'), Enum.FontWeight.Regular)

local library = {
	['themes'] = {
		['activeMap'] = {
			accentPrimary = Color3.fromRGB(155, 125, 175),
			accentSecondary = Color3.fromRGB(100, 80, 115),

			contrastPrimary = Color3.fromRGB(42, 42, 56),
			contrastSecondary = Color3.fromRGB(36, 36, 48),

			inline = Color3.fromRGB(60, 55, 75),
			outline = Color3.fromRGB(32, 32, 38),

			textNormal = Color3.fromRGB(180, 180, 180),
			textDisabled = Color3.fromRGB(136, 136, 136),
			textOutline = Color3.fromRGB(0, 0, 0),
			textUnsafe = Color3.fromRGB(254, 139, 139)
		},
		['addedInstances'] = {},

		['findKey'] = function(input, key)
			return input[key] ~= nil
		end,

		['findValue'] = function(input, value)
			for _, val in input do
				if val == value then
					return true
				end
			end
			return false
		end,

		['getProperty'] = function(instance)
			local className = instance.ClassName
			if className == 'Frame' then
				return 'BackgroundColor3'
			elseif className == 'TextButton' or className == 'TextLabel' then
				return 'TextColor3'
			elseif className == 'TextBox' then
				return 'TextColor3'
			elseif className == 'ImageButton' or className == 'ImageLabel' then
				if instance.Image == '' then
					return 'BackgroundColor3'
				else
					return 'ImageColor3'
				end
			elseif className == 'UIGradient' or className == 'UIStroke' then
				return 'Color'
			elseif className == 'ScrollingFrame' then
				return 'ScrollBarImageColor3'
			end
		end,

		['getSequence'] = function(self, input)
			local keypoints = {}

			for keypoint, color in input do
				local newColor = self.activeMap[color]
				table.insert(keypoints, ColorSequenceKeypoint.new(tonumber(keypoint), newColor))
			end

			table.sort(keypoints, function(a, b)
				return a.Time < b.Time
			end)

			return ColorSequence.new(keypoints)
		end,

		['addInstance'] = function(self, input)
			self.addedInstances[#self.addedInstances + 1] = input
		end,

		['updateMap'] = function(self, input)
			if input then
				if type(input) == 'table' then
					if self.findKey(input, 'color') then -- single color
						self.activeMap[input.mapPath] = input.color
						for index, instance in self.addedInstances do
							if type(instance.mapPath) == 'string' then -- one color
								if instance.mapPath == input.mapPath then
									local realInstance = instance.instance
									local gotProperty = self.getProperty(realInstance)
									realInstance[gotProperty] = self.activeMap[instance.mapPath]
								end
							elseif type(instance.mapPath) == 'table' then -- multiple colors (gradient)
								if self.findValue(instance.mapPath, input.mapPath) then
									local realInstance = instance.instance
									local gotProperty = self.getProperty(realInstance)
									realInstance[gotProperty] = self:getSequence(instance.mapPath)
								end
							end
						end
					elseif self.findKey(input, 'accentPrimary') then -- full map change
						self.activeMap = input

						for _, instance in self.addedInstances do -- refresh instance colors
							local realInstance = instance.instance
							local gotProperty = self.getProperty(realInstance)

							if type(instance.mapPath) == 'string' then
								realInstance[gotProperty] = self.activeMap[instance.mapPath]
							elseif type(instance.mapPath) == 'table' then
								realInstance[gotProperty] = self:getSequence(instance.mapPath)
							end
						end
					end
				end
			else
				-- no input, refresh all instance colors
				for _, instance in self.addedInstances do
					local realInstance = instance.instance
					local gotProperty = self.getProperty(realInstance)

					if type(instance.mapPath) == 'string' then
						realInstance[gotProperty] = self.activeMap[instance.mapPath]
					elseif type(instance.mapPath) == 'table' then
						realInstance[gotProperty] = self:getSequence(instance.mapPath)
					end
				end
			end
		end

		-- adding instances, standard | library.themes:addInstance({instance = nil, mapPath = 'accentPrimary'})
		-- adding instances, gradients | library.themes:addInstance({instance = nil, mapPath = {['0'] = 'accentPrimary', ['1'] = 'accentSecondary'}})

		-- updating map, refresh | library.themes:updateMap()
		-- updating map, single color | library.themes:updateMap({color = Color3.fromRGB(), mapPath = 'accentPrimary'})
		-- updating map, setting full map | library.themes:updateMap({mapTable})
	},

	['keycodes'] = {
		[Enum.KeyCode.LeftShift] = "ls",
		[Enum.KeyCode.RightShift] = "rs",
		[Enum.KeyCode.LeftControl] = "lc",
		[Enum.KeyCode.RightControl] = "rc",
		[Enum.KeyCode.Insert] = "ins",
		[Enum.KeyCode.Backspace] = "bs",
		[Enum.KeyCode.Return] = "ent",
		[Enum.KeyCode.LeftAlt] = "la",
		[Enum.KeyCode.RightAlt] = "ra",
		[Enum.KeyCode.CapsLock] = "caps",
		[Enum.KeyCode.One] = "1",
		[Enum.KeyCode.Two] = "2",
		[Enum.KeyCode.Three] = "3",
		[Enum.KeyCode.Four] = "4",
		[Enum.KeyCode.Five] = "5",
		[Enum.KeyCode.Six] = "6",
		[Enum.KeyCode.Seven] = "7",
		[Enum.KeyCode.Eight] = "8",
		[Enum.KeyCode.Nine] = "9",
		[Enum.KeyCode.Zero] = "0",
		[Enum.KeyCode.KeypadOne] = "num1",
		[Enum.KeyCode.KeypadTwo] = "num2",
		[Enum.KeyCode.KeypadThree] = "num3",
		[Enum.KeyCode.KeypadFour] = "num4",
		[Enum.KeyCode.KeypadFive] = "num5",
		[Enum.KeyCode.KeypadSix] = "num6",
		[Enum.KeyCode.KeypadSeven] = "num7",
		[Enum.KeyCode.KeypadEight] = "num8",
		[Enum.KeyCode.KeypadNine] = "num9",
		[Enum.KeyCode.KeypadZero] = "num0",
		[Enum.KeyCode.Minus] = "-",
		[Enum.KeyCode.Equals] = "=",
		[Enum.KeyCode.Tilde] = "~",
		[Enum.KeyCode.LeftBracket] = "[",
		[Enum.KeyCode.RightBracket] = "]",
		[Enum.KeyCode.RightParenthesis] = ")",
		[Enum.KeyCode.LeftParenthesis] = "(",
		[Enum.KeyCode.Semicolon] = ",",
		[Enum.KeyCode.Quote] = "'",
		[Enum.KeyCode.BackSlash] = "\\",
		[Enum.KeyCode.Comma] = ",",
		[Enum.KeyCode.Period] = ".",
		[Enum.KeyCode.Slash] = "/",
		[Enum.KeyCode.Asterisk] = "*",
		[Enum.KeyCode.Plus] = "+",
		[Enum.KeyCode.Period] = ".",
		[Enum.KeyCode.Backquote] = "`",
		[Enum.UserInputType.MouseButton1] = "mb1",
		[Enum.UserInputType.MouseButton2] = "mb2",
		[Enum.UserInputType.MouseButton3] = "mmb",
		[Enum.KeyCode.Escape] = "esc",
		[Enum.KeyCode.Space] = "spce",
	},

	['flags'] = {},
	['config'] = {},
	['glowObjects'] = {},
	
	['toEnum'] = function(entry) -- from office's ui
		local enumParts = {}
		for part in string.gmatch(entry, "[%w_]+") do
			table.insert(enumParts, part)
		end

		local enumTable = Enum
		for i = 2, #enumParts do
			local enumItem = enumTable[enumParts[i]]

			enumTable = enumItem
		end

		return enumTable
	end,

	['create'] = function(className, properties, keypoints)
		local instance = Instance.new(className)
		instance.Name = '\0'

		if className == 'Frame' or className == 'ScrollingFrame' or className == 'TextLabel' or className == 'TextBox' or className == 'ImageLabel' then
			instance.BorderSizePixel = 0
		elseif className == 'TextButton' or className == 'ImageButton' then
			instance.BorderSizePixel = 0
			instance.AutoButtonColor = false
		elseif className == 'UIStroke' then
			instance.LineJoinMode = 'Miter'
		end

		if properties then
			for property, value in properties do
				instance[property] = value
			end
		end

		return instance
	end,

	['round'] = function(number, float)
		local multi = 1 / float
		return math.floor(number * multi + 0.5) / multi
	end,

	['inputOverFrame'] = function(input, frame)
		local inputPos = input.Position
		local absPos = frame.AbsolutePosition
		local absSize = frame.AbsoluteSize

		return inputPos.X >= absPos.X and inputPos.X <= absPos.X + absSize.X and inputPos.Y >= absPos.Y and inputPos.Y <= absPos.Y + absSize.Y
	end,

	['makeResizable'] = function(self, frame)
		if frame:IsA('Frame') then
			local hoverFrames = {}

			hoverFrames['Top'] = self.create('Frame', {
				Size = UDim2.new(1, 0, 0, 4),
				Position = UDim2.new(0, 0, 0, -4),
				BackgroundTransparency = 1,
				Parent = frame
			})

			hoverFrames['Bottom'] = self.create('Frame', {
				Size = UDim2.new(1, 0, 0, 4),
				Position = UDim2.new(0, 0, 1, 0),
				BackgroundTransparency = 1,
				Parent = frame
			})

			hoverFrames['Left'] = self.create('Frame', {
				Size = UDim2.new(0, 4, 1, 0),
				Position = UDim2.new(0, -4, 0, 0),
				BackgroundTransparency = 1,
				Parent = frame
			})

			hoverFrames['Right'] = self.create('Frame', {
				Size = UDim2.new(0, 4, 1, 0),
				Position = UDim2.new(1, 0, 0, 0),
				BackgroundTransparency = 1,
				Parent = frame
			})
		end
	end,

	['font'] = {font = loadedFont, size = 12},
}

do --/ library
	library.__index = library

	library.mainGui = library.create('ScreenGui', {
		Enabled = true,
		IgnoreGuiInset = true,
		DisplayOrder = 8,
		Parent = CoreGui
	})

	library.overlayGui = library.create('ScreenGui', {
		Enabled = true,
		IgnoreGuiInset = true,
		DisplayOrder = 9,
		Parent = CoreGui
	})
	
	function library:save()
		local tbl = {}

		for flag, element in library.config do
			local v = library.flags[flag]
			if element.class == 'colorpicker' then
				tbl[flag] = {color = v.color:ToHex(), alpha = v.alpha}
			elseif element.class == 'keypicker' then
				tbl[flag] = {key = tostring(element.key), mode = element.mode, value = element.value}
			else
				tbl[flag] = v
			end
		end

		return HttpService:JSONEncode(tbl)
	end

	function library:load(tbl)
		local tbl = HttpService:JSONDecode(tbl)

		for flag, v in tbl do
			local real = library.config[flag]
			if real then
				if real.class == 'colorpicker' then
					real.set({color = Color3.fromHex(v.color), alpha = v.alpha})
				elseif real.class == 'keypicker' then
					real.set({key = tostring(v.key), mode = tostring(v.mode)})
					real.set(v.value)
				else
					real.set(v)
				end
			end
		end
	end

	function library:watermark(config)
		local config = {
			name = config.name or 'config.name',
			position = config.position or 'right',
			visible = config.visible == nil and true or config.visible
		}

		local watermark = {
			instances = {},
			position = config.position
		}

		local holder = library.create('ImageButton', {
			Size = UDim2.fromOffset(0, 24),
			Position = UDim2.fromOffset(6, 6),
			Image = '',
			AutomaticSize = 'X',
			BackgroundColor3 = library.themes.activeMap.outline,
			Visible = config.visible,
			Parent = library.overlayGui
		})
		watermark.instances['holder'] = holder
		library.themes:addInstance({instance = holder, mapPath = 'outline'})

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = holder
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local nameLabel = library.create('TextLabel', {
			Size = UDim2.new(0, 0, 1, -2),
			Position = UDim2.fromOffset(0, 2),
			AutomaticSize = 'X',
			BackgroundTransparency = 1,
			Text = config.name,
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap.textNormal,
			Parent = contrast1
		}) 
		watermark.instances['nameLabel'] = nameLabel
		library.themes:addInstance({instance = nameLabel, mapPath = 'textNormal'})

		local nameLabelStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = nameLabel
		})
		library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

		local nameLabelPadding = library.create('UIPadding', {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 1),
			Parent = nameLabel
		})

		local accentPrimary1 = library.create('Frame', {
			Size = UDim2.new(1, -4, 0, 1),
			Position = UDim2.fromOffset(2, 2),
			BackgroundColor3 = library.themes.activeMap.accentPrimary,
			Parent = holder
		})
		library.themes:addInstance({instance = accentPrimary1, mapPath = 'accentPrimary'})

		local accentSecondary1 = library.create('Frame', {
			Size = UDim2.new(1, -4, 0, 1),
			Position = UDim2.fromOffset(2, 3),
			BackgroundColor3 = library.themes.activeMap.accentSecondary,
			Parent = holder
		})
		library.themes:addInstance({instance = accentSecondary1, mapPath = 'accentSecondary'})

		local updateConnection;
		updateConnection = RunService.RenderStepped:Connect(function()
			if watermark.position == 'left' then
				holder.Position = UDim2.fromOffset(6, 6)
			elseif watermark.position == 'right' then
				holder.Position = UDim2.new(1, -(holder.AbsoluteSize.X + 6), 0, 6)
			elseif watermark.position == 'middle' then
				holder.Position = UDim2.new(0.5, -(holder.AbsoluteSize.X / 2), 1, -30)
			end
		end)

		function watermark.setVisible(boolean)
			holder.Visible = boolean
		end

		function watermark.setPosition(string)
			watermark.position = string
		end

		function watermark.setText(string)
			nameLabel.Text = string
		end

		return setmetatable(watermark, library)
	end

	function library:dock()	
		local dock = {
			instances = {},
			windows = {}
		}

		local holder = library.create('ImageButton', {
			Size = UDim2.fromOffset(100, 39),
			Position = UDim2.new(0.5, 0, 0, 6),
			Image = '',
			BackgroundColor3 = library.themes.activeMap.outline,
			Visible = false,
			Parent = library.overlayGui
		})
		dock.instances['holder'] = holder
		library.themes:addInstance({instance = holder, mapPath = 'outline'})

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = holder
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local buttonHolder = library.create('Frame', {
			Size = UDim2.new(1, -8, 1, -10),
			Position = UDim2.fromOffset(4, 6),
			BackgroundTransparency = 1,
			Parent = contrast1
		})
		dock.instances['buttonHolder'] = buttonHolder

		local buttonHolderLayout = library.create('UIListLayout', {
			Padding = UDim.new(0, 5),
			FillDirection = 'Horizontal',
			HorizontalAlignment = 'Center',
			Parent = buttonHolder
		})

		local accentPrimary1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = library.themes.activeMap.accentPrimary,
			Parent = contrast1
		})
		library.themes:addInstance({instance = accentPrimary1, mapPath = 'accentPrimary'})

		local accentSecondary1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromOffset(0, 1),
			BackgroundColor3 = library.themes.activeMap.accentSecondary,
			Parent = contrast1
		})
		library.themes:addInstance({instance = accentSecondary1, mapPath = 'accentSecondary'})

		buttonHolder.ChildAdded:Connect(function(child)
			if child:IsA('ImageButton') or child:IsA('Frame') then
				local xSize = (#dock.windows * 25) + ((#dock.windows - 1) * 5) + 12
				holder.Size = UDim2.fromOffset(xSize, 39)
				holder.Position = UDim2.new(0.5, -(xSize / 2), 0, 6)
				holder.Visible = true
			end
		end)

		function dock.setVisible(boolean)
			holder.Visible = boolean
		end

		return setmetatable(dock, library)
	end

	function library:window(config)
		local config = {
			name = config.name or 'config.name',
			size = config.size or UDim2.fromOffset(600, 625),
			image = config.image or '', -- ignore unless this window is docked
			prefix = config.prefix or '',
			suffix = config.suffix or '',
			visible = config.visible == nil and true or config.visible,
			usetabs = config.usetabs == nil and true or config.usetabs
		}

		local window = {
			docked = false,
			visible = config.visible,
			usetabs = config.usetabs,
			instances = {},
			pages = {}
		}

		if self.windows then
			window.docked = true
			table.insert(self.windows, window)
		end

		local holder = library.create('ImageButton', {
			Size = config.size,
			Position = UDim2.fromOffset(Camera.ViewportSize.X / 2 - (config.size.X.Offset / 2), Camera.ViewportSize.Y / 2 - (config.size.Y.Offset / 2)),
			Image = '',
			BackgroundColor3 = library.themes.activeMap.outline,
			Active = true,
			Draggable = true,
			Visible = false,
			Parent = library.mainGui
		})
		window.instances['holder'] = holder
		library.glowObjects[#library.glowObjects + 1] = holder
		library.themes:addInstance({instance = holder, mapPath = 'outline'})

		task.spawn(function() -- uitablelayout fix
			holder.ClipsDescendants = true
			task.wait()
			holder.ClipsDescendants = false
		end)

		local accentPrimary1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.accentPrimary,
			Parent = holder	
		})
		library.themes:addInstance({instance = accentPrimary1, mapPath = 'accentPrimary'})

		local contrastPrimary1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.contrastPrimary,
			Parent = accentPrimary1
		})
		library.themes:addInstance({instance = contrastPrimary1, mapPath = 'contrastPrimary'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = contrastPrimary1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 270,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		do -- creating name
			local prefixLabel = library.create('TextLabel', {
				Size = UDim2.new(1, -5, 0, 18),
				Position = UDim2.fromOffset(5, 0),
				BackgroundTransparency = 1,
				Text = config.prefix,
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.textNormal,
				TextXAlignment = 'Left',
				Parent = contrast1
			})
			library.themes:addInstance({instance = prefixLabel, mapPath = 'textNormal'})

			local prefixLabelStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = prefixLabel
			})
			library.themes:addInstance({instance = prefixLabelStroke, mapPath = 'textOutline'})

			local prefixLabelPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = prefixLabel
			})

			local suffixOffset = 5
			if string.len(prefixLabel.Text) ~= 0 then
				suffixOffset += prefixLabel.TextBounds.X
			end

			local suffixLabel = library.create('TextLabel', {
				Size = UDim2.new(1, -suffixOffset, 0, 18),
				Position = UDim2.fromOffset(suffixOffset, 0),
				BackgroundTransparency = 1,
				Text = config.suffix,
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.accentPrimary,
				TextXAlignment = 'Left',
				Parent = contrast1
			})
			library.themes:addInstance({instance = suffixLabel, mapPath = 'accentPrimary'})

			local suffixLabelStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = suffixLabel
			})
			library.themes:addInstance({instance = suffixLabelStroke, mapPath = 'textOutline'})

			local suffixLabelPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = suffixLabel
			})

			local nameOffset = suffixOffset
			if string.len(suffixLabel.Text) ~= 0 then
				nameOffset += suffixLabel.TextBounds.X
			end

			local nameLabel = library.create('TextLabel', {
				Size = UDim2.new(1, -nameOffset, 0, 18),
				Position = UDim2.fromOffset(nameOffset, 0),
				BackgroundTransparency = 1,
				Text = config.name,
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.textNormal,
				TextXAlignment = 'Left',
				Parent = contrast1
			})
			window.instances['nameLabel'] = nameLabel
			library.themes:addInstance({instance = nameLabel, mapPath = 'textNormal'})

			local nameLabelStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = nameLabel
			})
			library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

			local nameLabelPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = nameLabel
			})
		end

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -8, 1, -22),
			Position = UDim2.fromOffset(4, 18),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = contrastPrimary1
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local outline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = inline1
		})
		library.themes:addInstance({instance = outline1, mapPath = 'outline'})

		local contrastSecondary1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.contrastSecondary,
			Parent = outline1
		})
		window.instances['contrastSecondary1'] = contrastSecondary1
		library.themes:addInstance({instance = contrastSecondary1, mapPath = 'contrastSecondary'})

		local outline2 = library.create('Frame', {
			Size = config.usetabs and UDim2.new(1, -8, 1, -28) or UDim2.new(1, -8, 1, -8),
			Position = config.usetabs and UDim2.fromOffset(4, 24) or UDim2.fromOffset(4, 4),
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = contrastSecondary1
		})
		window.instances['outline2'] = outline2
		library.themes:addInstance({instance = outline2, mapPath = 'outline'})

		local inline2 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = outline2
		})
		library.themes:addInstance({instance = inline2, mapPath = 'inline'})

		local contrastPrimary2 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.contrastPrimary,
			Parent = inline2
		})
		library.themes:addInstance({instance = contrastPrimary2, mapPath = 'contrastPrimary'})

		local pageHolder = library.create('Frame', {
			Size = UDim2.new(1, -8, 1, -8),
			Position = UDim2.fromOffset(4, 4),
			BackgroundTransparency = 1,
			Parent = contrastPrimary2
		})
		window.instances['pageHolder'] = pageHolder

		if config.usetabs then
			local tabHolder = library.create('Frame', {
				Size = UDim2.new(1, 0, 0, 21),
				Position = UDim2.fromOffset(0, -20),
				BackgroundTransparency = 1,
				Parent = outline2
			})
			window.instances['tabHolder'] = tabHolder

			local tabHolderLayout = library.create("UIListLayout", {
				Padding = UDim.new(0, 4),
				FillDirection = 'Horizontal',
				Parent = tabHolder
			})
			
			function window.sizeTabs()
				local frames = {}

				for _, child in tabHolder:GetChildren() do
					if child:IsA("ImageButton") then
						table.insert(frames, child)
					end
				end

				local padding = (#frames - 1) * 4
				local frameWidth = (tabHolder.AbsoluteSize.X - padding) / #frames
				local remainder = (tabHolder.AbsoluteSize.X - padding) % #frames

				for index, frame in frames do
					local extra = (index <= remainder) and 1 or 0
					frame.Size = UDim2.new(0, frameWidth + extra, 1, 0)
				end
			end
			
			tabHolder.ChildAdded:Connect(function()
				window.sizeTabs()
			end)
			
			holder.Changed:Connect(function(changed)
				if changed == 'AbsoluteSize' then
					window.sizeTabs()
				end
			end)
		end

		function window.setVisible(boolean)
			holder.Visible = boolean
			window.visible = boolean
		end

		if window.docked then
			local buttonInline1 = library.create('ImageButton', {
				Size = UDim2.fromOffset(25, 25),
				Image = '',
				BackgroundColor3 = library.themes.activeMap.inline,
				Parent = self.instances.buttonHolder
			})
			library.themes:addInstance({instance = buttonInline1, mapPath = 'inline'})

			do -- hover effect
				local hoverConnection = nil

				local enterConnection = buttonInline1.MouseEnter:Connect(function()
					hoverConnection = RunService.RenderStepped:Connect(function()
						buttonInline1.BackgroundColor3 = library.themes.activeMap.accentPrimary
					end)
				end)

				local leaveConnection = buttonInline1.MouseLeave:Connect(function()
					if hoverConnection then
						hoverConnection:Disconnect()
						hoverConnection = nil
					end

					buttonInline1.BackgroundColor3 = library.themes.activeMap.inline
				end)
			end

			local buttonOutline1 = library.create('Frame', {
				Size = UDim2.new(1, -2, 1, -2),
				Position = UDim2.fromOffset(1, 1),
				BackgroundColor3 = library.themes.activeMap.outline,
				Parent = buttonInline1
			})
			library.themes:addInstance({instance = buttonOutline1, mapPath = 'outline'})

			local buttonContrast1 = library.create('Frame', {
				Size = UDim2.new(1, -2, 1, -2),
				Position = UDim2.fromOffset(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = buttonOutline1
			})

			local buttonContrast1Gradient = library.create('UIGradient', {
				Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
				Rotation = 270,
				Parent = buttonContrast1
			})
			library.themes:addInstance({instance = buttonContrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

			local imageLabel = library.create('ImageLabel', {
				Size = UDim2.fromScale(1, 1),
				Image = config.image,
				ImageColor3 = library.themes.activeMap.accentSecondary,
				BackgroundTransparency = 1,
				Parent = buttonContrast1
			})

			buttonInline1.MouseButton1Down:Connect(function()
				if window.visible then
					imageLabel.ImageColor3 = library.themes.activeMap.accentSecondary
					window.setVisible(false)
				else
					imageLabel.ImageColor3 = library.themes.activeMap.accentPrimary
					window.setVisible(true)
				end
			end)

			RunService.RenderStepped:Connect(function()
				if window.visible then
					imageLabel.ImageColor3 = library.themes.activeMap.accentPrimary
				else
					imageLabel.ImageColor3 = library.themes.activeMap.accentSecondary
				end
			end)

			local closeButton = library.create('TextButton', {
				Size = UDim2.new(0, 6, 1, 0),
				Position = UDim2.new(1, -12, 0, 0),
				BackgroundTransparency = 1,
				Text = 'x',
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.textNormal,
				Parent = contrast1
			})
			library.themes:addInstance({instance = closeButton, mapPath = 'textNormal'})

			local closeButtonStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = closeButton
			})
			library.themes:addInstance({instance = closeButtonStroke, mapPath = 'textOutline'})

			local closeButtonPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = closeButton
			})

			do -- hover effect
				local hoverConnection = nil

				local enterConnection = closeButton.MouseEnter:Connect(function()
					hoverConnection = RunService.RenderStepped:Connect(function()
						closeButton.TextColor3 = library.themes.activeMap.textDisabled
					end)
				end)

				local leaveConnection = closeButton.MouseLeave:Connect(function()
					if hoverConnection then
						hoverConnection:Disconnect()
						hoverConnection = nil
					end

					closeButton.TextColor3 = library.themes.activeMap.textNormal
				end)
			end

			closeButton.MouseButton1Down:Connect(function()
				window.setVisible(false)
				imageLabel.ImageColor3 = library.themes.activeMap.accentSecondary
			end)

			window.setVisible(config.visible)
			if config.visible then
				imageLabel.ImageColor3 = library.themes.activeMap.accentPrimary
			end
		else
			window.setVisible(config.visible)
		end

		return setmetatable(window, library)
	end

	function library:page(config)
		local config = {
			name = config.name or 'config.name'
		}

		local page = {
			window = self,
			instances = {}
		}
		table.insert(page.window.pages, page)

		local holder = library.create('Frame', {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Visible = false,
			Parent = page.window.instances.pageHolder
		})

		local left = library.create('Frame', {
			Size = UDim2.new(0.5, -2, 1, 0),
			BackgroundTransparency = 1,
			Parent = holder
		})
		page.instances['left'] = left

		local leftLayout = library.create('UIListLayout', {
			Padding = UDim.new(0, 4),
			Parent = left
		})

		local right = library.create('Frame', {
			Size = UDim2.new(0.5, -2, 1, 0),
			Position = UDim2.new(0.5, 2, 0, 0),
			BackgroundTransparency = 1,
			Parent = holder
		})
		page.instances['right'] = right

		local rightLayout = library.create('UIListLayout', {
			Padding = UDim.new(0, 4),
			Parent = right
		})

		local middle = library.create('Frame', {
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			Parent = holder
		})
		page.instances['middle'] = middle

		local middleLayout = library.create('UIListLayout', {
			Padding = UDim.new(0, 4),
			Parent = middle
		})

		if page.window.usetabs then
			local holder2 = library.create('ImageButton', {
				Image = "",
				BackgroundTransparency = 1,
				Parent = page.window.instances.tabHolder
			})

			local outline1 = library.create('Frame', {
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = library.themes.activeMap.outline,
				Parent = holder2
			})
			library.themes:addInstance({instance = outline1, mapPath = 'outline'})

			local inline1 = library.create('Frame', {
				Size = UDim2.new(1, -2, 0, 20),
				Position = UDim2.fromOffset(1, 1),
				BackgroundColor3 = library.themes.activeMap.inline,
				Parent = outline1
			})
			library.themes:addInstance({instance = inline1, mapPath = 'inline'})

			local contrast1 = library.create('Frame', {
				Size = UDim2.new(1, -2, 0, 19),
				Position = UDim2.fromOffset(1, 1),
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				Parent = inline1
			})

			local contrast1Gradient = library.create('UIGradient', {
				Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
				Rotation = 90,
				Parent = contrast1
			})
			library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

			local nameLabel = library.create('TextLabel', {
				Size = UDim2.new(1, 0, 0, 18),
				BackgroundTransparency = 1,
				Text = config.name,
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.textDisabled,
				Parent = contrast1
			})
			page.instances['nameLabel'] = nameLabel

			local nameLabelStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = nameLabel
			})
			library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

			local nameLabelPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = nameLabel
			})

			function page.select()
				for _, otherPage in page.window.instances.pageHolder:GetChildren() do
					if otherPage:IsA('Frame') then
						otherPage.Visible = false
					end
				end

				for _, otherTab in page.window.instances.tabHolder:GetChildren() do
					if otherTab:IsA('ImageButton') then
						for _2, desc in otherTab:GetDescendants() do
							if desc:IsA('UIGradient') then
								desc.Parent.Size = UDim2.new(1, -2, 0, 19)
								desc.Rotation = 90
							elseif desc:IsA('TextLabel') then
								desc.TextColor3 = library.themes.activeMap.textDisabled
							end
						end
					end
				end

				holder.Visible = true
				contrast1.Size = UDim2.new(1, -2, 0, 20)
				nameLabel.TextColor3 = library.themes.activeMap.textNormal
				contrast1Gradient.Rotation = 270
			end

			holder2.MouseButton1Down:Connect(function()
				page.select()
			end)

			if #page.window.pages == 1 then
				page.select()
			end
		else
			holder.Visible = true
		end

		return setmetatable(page, library)
	end

	function library:section(config)
		local config = {
			name = config.name or 'config.name',
			size = config.size or UDim2.new(1, 0, 0, 250),
			position = config.position or UDim2.new(0, 0, 0, 0),
			side = config.side or 'left',
			parent = config.parent or nil,
			visible = config.visible == nil and true or config.visible
		}

		local section = {
			page = self,
			instances = {}
		}

		local holder = library.create('Frame', {
			Size = config.size,
			Position = config.position,
			BackgroundColor3 = library.themes.activeMap.inline,
			Visible = config.visible,
			Parent = config.parent or section.page.instances[config.side]
		})
		library.themes:addInstance({instance = holder, mapPath = 'inline'})

		local outline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = holder
		})
		library.themes:addInstance({instance = outline1, mapPath = 'outline'})

		local contrastSecondary1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.contrastSecondary,
			Parent = outline1
		})
		library.themes:addInstance({instance = contrastSecondary1, mapPath = 'contrastSecondary'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 18),
			Position = UDim2.fromOffset(0, 2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = contrastSecondary1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local nameLabel = library.create('TextLabel', {
			Size = UDim2.new(1, -5, 0, 18),
			Position = UDim2.fromOffset(5, 0),
			BackgroundTransparency = 1,
			Text = config.name,
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap.textNormal,
			TextXAlignment = 'Left',
			Parent = contrast1
		})
		section.instances['nameLabel'] = nameLabel
		library.themes:addInstance({instance = nameLabel, mapPath = 'textNormal'})

		local nameLabelStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = nameLabel
		})
		library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

		local nameLabelPadding = library.create('UIPadding', {
			PaddingBottom = UDim.new(0, 1),
			Parent = nameLabel
		})

		local contrast2 = library.create('Frame', {
			Size = UDim2.new(0, 4, 1, -22),
			Position = UDim2.new(1, -4, 0, 22),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Visible = false,
			Parent = contrastSecondary1
		})

		local contrast2Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 270,
			Parent = contrast2
		})
		library.themes:addInstance({instance = contrast2Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local realSection = library.create('ScrollingFrame', {
			Size = UDim2.new(1, -8, 1, -22),
			Position = UDim2.fromOffset(4, 22),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = 'Y',
			TopImage = 'rbxassetid://111011970761526',
			MidImage = 'rbxassetid://111011970761526',
			BottomImage = 'rbxassetid://111011970761526',
			ScrollBarImageColor3 = library.themes.activeMap.accentPrimary,
			ScrollBarThickness = 2,
			VerticalScrollBarInset = 'ScrollBar',
			BackgroundTransparency = 1,
			Parent = contrastSecondary1
		})
		section.instances['realSection'] = realSection
		library.themes:addInstance({instance = realSection, mapPath = 'accentPrimary'})

		local realSectionList = library.create('UIListLayout', {
			Padding = UDim.new(0, 4),
			Parent = realSection
		})

		local accentPrimary1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = library.themes.activeMap.accentPrimary,
			Parent = contrastSecondary1
		})
		library.themes:addInstance({instance = accentPrimary1, mapPath = 'accentPrimary'})

		local accentSecondary1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.fromOffset(0, 1),
			BackgroundColor3 = library.themes.activeMap.accentSecondary,
			Parent = contrastSecondary1
		})
		library.themes:addInstance({instance = accentSecondary1, mapPath = 'accentSecondary'})

		local function updateScrollBackground()
			if math.floor(realSection.AbsoluteCanvasSize.Y) > math.floor(realSection.AbsoluteSize.Y) then
				if not contrast2.Visible then
					contrast2.Visible = true
					realSection.Size = UDim2.new(1, -5, 1, -22)

					for _, objFrame in realSection:GetChildren() do
						if objFrame:IsA('Frame') then
							local oldSize = objFrame.Size
							objFrame.Size = UDim2.new(oldSize.X.Scale, -5, oldSize.Y.Scale, oldSize.Y.Offset)
						end
					end
				end
			else
				if contrast2.Visible then
					contrast2.Visible = false
					realSection.Size = UDim2.new(1, -8, 1, -22)

					for _, objFrame in realSection:GetChildren() do
						if objFrame:IsA('Frame') then
							local oldSize = objFrame.Size
							objFrame.Size = UDim2.new(oldSize.X.Scale, 0, oldSize.Y.Scale, oldSize.Y.Offset)
						end
					end 
				end
			end
		end

		realSection.Changed:Connect(function(property)
			if property == 'AbsoluteSize' or property == 'AbsoluteCanvasSize' then
				updateScrollBackground()
			end
		end)

		function section.setVisible(boolean)
			holder.Visible = boolean
		end

		return setmetatable(section, library)
	end

	function library:label(config)
		local config = {
			name = config.name or 'config.name',
			unsafe = config.unsafe or false,
			visible = config.visible == nil and true or config.visible
		}

		local label = {
			section = self.instances.realSection,
			instances = {}
		}

		local holder = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Visible = config.visible,
			Parent = label.section
		})
		label.instances['holder'] = holder

		local unsafeCheck = 'textNormal'
		if config.unsafe then
			unsafeCheck = 'textUnsafe'
		end
		local nameLabel = library.create('TextLabel', {
			Size = UDim2.new(1, -1, 0, 14),
			Position = UDim2.fromOffset(1, 0),
			BackgroundTransparency = 1,
			Text = config.name,
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap[unsafeCheck],
			TextXAlignment = 'Left',
			Parent = holder
		})
		label.instances['nameLabel'] = nameLabel
		library.themes:addInstance({instance = nameLabel, mapPath = unsafeCheck})

		local nameLabelStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = nameLabel
		})
		library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

		local nameLabelPadding = library.create('UIPadding', {
			PaddingBottom = UDim.new(0, 1),
			Parent = nameLabel
		})

		local container = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Parent = holder
		})
		label.instances['container'] = container

		local containerList = library.create('UIListLayout', {
			Padding = UDim.new(0, 4),
			FillDirection = 'Horizontal',
			HorizontalAlignment = 'Right',
			Parent = container
		})

		function label.setVisible(boolean)
			holder.Visible = boolean
		end

		return setmetatable(label, library)
	end

	function library:toggle(config)
		local config = {
			name = config.name or 'config.name',
			flag = config.flag or math.random(123456),
			value = config.value or false,
			unsafe = config.unsafe or false,
			visible = config.visible == nil and true or config.visible,
			callback = config.callback or nil
		}

		local toggle = {
			class = 'toggle',
			value = config.value,
			section = self.instances.realSection,
			instances = {}
		}

		local holder = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Parent = toggle.section
		})
		toggle.instances['holder'] = holder

		local unsafeCheck = 'textNormal'
		if config.unsafe then
			unsafeCheck = 'textUnsafe'
		end
		local nameLabel = library.create('TextLabel', {
			Size = UDim2.new(1, -19, 0, 14),
			Position = UDim2.fromOffset(19, 0),
			BackgroundTransparency = 1,
			Text = config.name,
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap[unsafeCheck],
			TextXAlignment = 'Left',
			Parent = holder
		})
		toggle.instances['nameLabel'] = nameLabel
		library.themes:addInstance({instance = nameLabel, mapPath = unsafeCheck})

		local nameLabelStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = nameLabel
		})
		library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

		local nameLabelPadding = library.create('UIPadding', {
			PaddingBottom = UDim.new(0, 1),
			Parent = nameLabel
		})

		local outline1 = library.create('Frame', {
			Size = UDim2.fromOffset(14, 14),
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = holder
		})
		library.themes:addInstance({instance = outline1, mapPath = 'outline'})

		do -- hover effect
			local hoverConnection = nil

			local enterConnection = holder.MouseEnter:Connect(function()
				hoverConnection = RunService.RenderStepped:Connect(function()
					outline1.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)
			end)

			local leaveConnection = holder.MouseLeave:Connect(function()
				if hoverConnection then
					hoverConnection:Disconnect()
					hoverConnection = nil
				end

				outline1.BackgroundColor3 = library.themes.activeMap.outline
			end)
		end

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = outline1
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local accent1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Visible = false,
			Parent = inline1
		})

		local accent1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.accentPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.accentSecondary)}),
			Rotation = 90,
			Parent = accent1
		})
		library.themes:addInstance({instance = accent1Gradient, mapPath = {['0'] = 'accentPrimary', ['1'] = 'accentSecondary'}})

		local clickDetector = library.create('ImageButton', {
			Size = UDim2.new(1, 0, 1, 0),
			Image = '',
			BackgroundTransparency = 1,
			Parent = holder
		})

		local container = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 14),
			BackgroundTransparency = 1,
			Parent = holder
		})
		toggle.instances['container'] = container

		local containerList = library.create('UIListLayout', {
			Padding = UDim.new(0, 4),
			FillDirection = 'Horizontal',
			HorizontalAlignment = 'Right',
			Parent = container
		})

		function toggle.set(boolean)
			toggle.value = boolean
			accent1.Visible = boolean
			library.flags[config.flag] = boolean
			if config.callback ~= nil then
				config.callback(boolean)
			end
		end

		function toggle.setVisible(boolean)
			holder.Visible = boolean
		end

		clickDetector.MouseButton1Down:Connect(function()
			toggle.set(not toggle.value)
		end)
		
		toggle.set(config.value)
		library.config[config.flag] = toggle
		return setmetatable(toggle, library)
	end

	function library:slider(config)
		local config = {
			min = config.min or -1,
			max = config.max or 1,
			name = config.name or 'config.name',
			flag = config.flag or math.random(123456),
			value = config.value or 1,
			float = config.float or 1,
			prefix = config.prefix or '',
			suffix = config.suffix or '',
			visible = config.visible == nil and true or config.visible,
			callback = config.callback or nil
		}

		local nameless = nil
		if config.name == 'none' then
			nameless = true
		end

		local slider = {
			class = 'slider',
			value = config.value,
			section = self.instances.realSection,
			instances = {}
		}

		local holder = library.create('Frame', {
			Size = nameless and UDim2.new(1, 0, 0, 12) or UDim2.new(1, 0, 0, 26),
			BackgroundTransparency = 1,
			Visible = config.visible,
			Parent = slider.section
		})
		slider.instances['holder'] = holder

		if nameless ~= true then
			local nameLabel = library.create('TextLabel', {
				Size = UDim2.new(1, -1, 0, 10),
				Position = UDim2.fromOffset(1, 0),
				BackgroundTransparency = 1,
				Text = config.name,
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.textNormal,
				TextXAlignment = 'Left',
				Parent = holder
			})
			slider.instances['nameLabel'] = nameLabel
			library.themes:addInstance({instance = nameLabel, mapPath = 'textNormal'})

			local nameLabelStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = nameLabel
			})
			library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

			local nameLabelPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = nameLabel
			})
		end

		local outline1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 12),
			Position = nameless and UDim2.new(0, 0, 0, 0) or UDim2.fromOffset(0, 14),
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = holder
		})
		library.themes:addInstance({instance = outline1, mapPath = 'outline'})

		do -- hover effect
			local hoverConnection = nil

			local enterConnection = holder.MouseEnter:Connect(function()
				hoverConnection = RunService.RenderStepped:Connect(function()
					outline1.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)
			end)

			local leaveConnection = holder.MouseLeave:Connect(function()
				if hoverConnection then
					hoverConnection:Disconnect()
					hoverConnection = nil
				end

				outline1.BackgroundColor3 = library.themes.activeMap.outline
			end)
		end

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = outline1
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local accent1 = library.create('Frame', {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = contrast1
		})

		local accent1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.accentPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.accentSecondary)}),
			Rotation = 90,
			Parent = accent1
		})
		library.themes:addInstance({instance = accent1Gradient, mapPath = {['0'] = 'accentPrimary', ['1'] = 'accentSecondary'}})

		local valueLabel = library.create('TextLabel', {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Text = '???',
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap.textNormal,
			Parent = contrast1
		})
		slider.instances['nameLabel'] = valueLabel
		library.themes:addInstance({instance = valueLabel, mapPath = 'textNormal'})

		local valueLabelStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = valueLabel
		})
		library.themes:addInstance({instance = valueLabelStroke, mapPath = 'textOutline'})

		local valueLabelPadding = library.create('UIPadding', {
			PaddingBottom = UDim.new(0, 1),
			Parent = valueLabel
		})

		local clickDetector = library.create('ImageButton', {
			Size = UDim2.new(1, 0, 1, 0),
			Image = '',
			BackgroundTransparency = 1,
			Parent = outline1
		})

		function slider.set(number)
			local newValue = math.clamp(library.round(number, config.float), config.min, config.max)

			slider.value = newValue
			library.flags[config.flag] = newValue
			if config.callback ~= nil then
				config.callback(newValue)
			end

			valueLabel.Text = config.prefix .. tostring(newValue) .. config.suffix

			local xScale = (newValue - config.min) / (config.max - config.min)
			accent1.Size = UDim2.new(xScale, 0, 1, 0)
		end

		function slider.setVisible(boolean)
			holder.Visible = boolean
		end

		local isHeld = false
		local hoverConnection
		clickDetector.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isHeld = true

				hoverConnection = RunService.RenderStepped:Connect(function()
					outline1.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)

				local size = (input.Position.X - clickDetector.AbsolutePosition.X) / clickDetector.AbsoluteSize.X
				local normalized = config.min + (size * (config.max - config.min))
				slider.set(normalized)
			end
		end)

		clickDetector.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				isHeld = false
				if hoverConnection then
					hoverConnection:Disconnect()
					hoverConnection = nil
				end
				outline1.BackgroundColor3 = library.themes.activeMap.outline
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement and isHeld then
				local size = (input.Position.X - clickDetector.AbsolutePosition.X) / clickDetector.AbsoluteSize.X
				local normalized = config.min + (size * (config.max - config.min))
				slider.set(normalized)
			end
		end)

		slider.set(config.value)
		library.config[config.flag] = slider
		return setmetatable(slider, library)
	end

	function library:dropdown(config)
		local config = {
			name = config.name or 'config.name',
			flag = config.flag or math.random(123456),
			value = config.value or 'none',
			items = config.items or {'config.items1', 'config.items2', 'config.items3', 'config.items4', 'config.items5'},
			multi = config.multi or false,
			visible = config.visible == nil and true or config.visible,
			callback = config.callback or nil
		}

		local nameless = nil
		if config.name == 'none' then
			nameless = true
		end

		local dropdown = {
			class = 'dropdown',
			value = config.value,
			section = self.instances.realSection,
			instances = {}
		}

		if config.multi then
			if type(dropdown.value) ~= 'table' then
				dropdown.value = {}
			end
		end

		local holder = library.create('Frame', {
			Size = nameless and UDim2.new(1, 0, 0, 18) or UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Visible = config.visible,
			Parent = dropdown.section
		})
		dropdown.instances['holder'] = holder

		if nameless ~= true then
			local nameLabel = library.create('TextLabel', {
				Size = UDim2.new(1, -1, 0, 10),
				Position = UDim2.fromOffset(1, 0),
				BackgroundTransparency = 1,
				Text = config.name,
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.textNormal,
				TextXAlignment = 'Left',
				Parent = holder
			})
			dropdown.instances['nameLabel'] = nameLabel
			library.themes:addInstance({instance = nameLabel, mapPath = 'textNormal'})

			local nameLabelStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = nameLabel
			})
			library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

			local nameLabelPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = nameLabel
			})
		end

		local outline1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 18),
			Position = nameless and UDim2.new(0, 0, 0, 0) or UDim2.fromOffset(0, 14),
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = holder
		})
		library.themes:addInstance({instance = outline1, mapPath = 'outline'})

		do -- hover effect
			local hoverConnection = nil

			local enterConnection = holder.MouseEnter:Connect(function()
				hoverConnection = RunService.RenderStepped:Connect(function()
					outline1.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)
			end)

			local leaveConnection = holder.MouseLeave:Connect(function()
				if hoverConnection then
					hoverConnection:Disconnect()
					hoverConnection = nil
				end

				outline1.BackgroundColor3 = library.themes.activeMap.outline
			end)
		end

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = outline1
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local valuesLabel = library.create('TextLabel', {
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.fromOffset(5, 0),
			BackgroundTransparency = 1,
			Text = 'Value',
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap.textNormal,
			TextXAlignment = 'Left',
			Parent = contrast1
		})
		dropdown.instances['valuesLabel'] = valuesLabel
		library.themes:addInstance({instance = valuesLabel, mapPath = 'textNormal'})

		local valuesLabelStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = valuesLabel
		})
		library.themes:addInstance({instance = valuesLabelStroke, mapPath = 'textOutline'})

		local valuesLabelPadding = library.create('UIPadding', {
			PaddingBottom = UDim.new(0, 1),
			Parent = valuesLabel
		})

		local openedImage = library.create('ImageLabel', {
			Size = UDim2.fromOffset(7, 7),
			Position = UDim2.new(1, -11, 0, 3),
			Image = 'rbxassetid://91416895750359',
			ImageColor3 = library.themes.activeMap.textNormal,
			BackgroundTransparency = 1,
			Parent = contrast1
		})
		library.themes:addInstance({instance = openedImage, mapPath = 'textNormal'})

		local clickDetector = library.create('ImageButton', {
			Size = UDim2.new(1, 0, 1, 0),
			Image = '',
			BackgroundTransparency = 1,
			Parent = outline1
		})

		function dropdown.set(value)
			do -- verify value/values
				if type(value) == 'table' then
					for index, value2 in value do
						if not library.themes.findValue(config.items, value2) then
							table.remove(value, index)
						end
					end
				else
					if not library.themes.findValue(config.items, value) then
						value = 'none'
					end
				end
			end

			if config.multi then
				if type(value) == 'table' then
					dropdown.value = value
				else
					local exists = nil
					for index, value2 in dropdown.value do
						if value2 == value then
							exists = index
							break
						end
					end

					if exists then
						table.remove(dropdown.value, exists)
					else
						table.insert(dropdown.value, value)
					end
				end

				if #dropdown.value > 0 then
					local order = {}
					for index, value2 in config.items do
						order[value2] = index
					end

					table.sort(dropdown.value, function(a, b)
						return (order[a] or math.huge) < (order[b] or math.huge)
					end)

					valuesLabel.Text = table.concat(dropdown.value, ", ")
				else
					valuesLabel.Text = 'none'
				end

				library.flags[config.flag] = dropdown.value

				if config.callback ~= nil then
					config.callback(dropdown.value)
				end
			else
				dropdown.value = value
				library.flags[config.flag] = value
				if config.callback ~= nil then
					config.callback(value)
				end
				valuesLabel.Text = tostring(value)
			end
		end

		function dropdown.setVisible(boolean)
			holder.Visible = boolean
		end

		local dropFrame = nil
		local dropConnects = {}
		local function dropRemove()
			openedImage.Image = 'rbxassetid://91416895750359'

			if dropFrame then
				dropFrame:Destroy()
				dropFrame = nil
			end

			for index, connection in dropConnects do
				if connection then
					connection:Disconnect()
					dropConnects[index] = nil
				end
			end

			outline1.BackgroundColor3 = library.themes.activeMap.outline
		end

		clickDetector.MouseButton1Down:Connect(function()
			if dropFrame == nil then
				local toDelete = {}
				-- (#config.items * 14) + ((#config.items - 1) * 4) + 4
				local dropSize = math.clamp((#config.items * 14) + ((#config.items - 1) * 4) + 9, 18, 185)
				openedImage.Image = 'rbxassetid://86257286212706'
				dropFrame = library.create('ImageButton', {
					Size = UDim2.fromOffset(outline1.AbsoluteSize.X, dropSize),
					Position = UDim2.fromOffset(outline1.AbsolutePosition.X, outline1.AbsolutePosition.Y + 78),
					BackgroundColor3 = library.themes.activeMap.outline,
					Image = '',
					Parent = library.overlayGui
				})
				toDelete[#toDelete + 1] = dropFrame
				library.themes:addInstance({instance = dropFrame, mapPath = 'outline'})

				local dropInline1 = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.inline,
					Parent = dropFrame
				})
				toDelete[#toDelete + 1] = dropInline1
				library.themes:addInstance({instance = dropInline1, mapPath = 'inline'})

				local dropContrast1 = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = dropInline1
				})

				local dropContrast1Gradient = library.create('UIGradient', {
					Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
					Rotation = 270,
					Parent = dropContrast1
				})
				toDelete[#toDelete + 1] = dropContrast1Gradient
				library.themes:addInstance({instance = dropContrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

				local scrollBackground = library.create('Frame', {
					Size = UDim2.new(0, 3, 1, 0),
					Position = UDim2.new(1, -3, 0, 0),
					BackgroundColor3 = library.themes.activeMap.inline,
					Visible = false,
					Parent = dropContrast1
				})
				toDelete[#toDelete + 1] = scrollBackground
				library.themes:addInstance({instance = scrollBackground, mapPath = 'inline'})

				local scrollFill = library.create('Frame', {
					Size = UDim2.new(0, 2, 0, 3),
					Position = UDim2.fromOffset(1, 0),
					BackgroundColor3 = library.themes.activeMap.accentPrimary,
					Visible = false,
					Parent = scrollBackground
				})
				toDelete[#toDelete + 1] = scrollFill
				library.themes:addInstance({instance = scrollFill, mapPath = 'accentPrimary'})

				local dropSection = library.create('ScrollingFrame', {
					Size = UDim2.new(1, -8, 1, -3),
					Position = UDim2.fromOffset(4, 3),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					AutomaticCanvasSize = 'Y',
					TopImage = 'rbxassetid://111011970761526',
					MidImage = 'rbxassetid://111011970761526',
					BottomImage = 'rbxassetid://111011970761526',
					ScrollBarImageColor3 = library.themes.activeMap.accentPrimary,
					ScrollBarThickness = 2,
					VerticalScrollBarInset = 'ScrollBar',
					BackgroundTransparency = 1,
					Parent = dropContrast1
				})
				toDelete[#toDelete + 1] = dropSection
				library.themes:addInstance({instance = dropSection, mapPath = 'accentPrimary'})

				local dropSectionList = library.create('UIListLayout', {
					Padding = UDim.new(0, 4),
					Parent = dropSection
				})

				local function updateScrollBackground()
					if dropSection.AbsoluteCanvasSize.Y > dropSection.AbsoluteSize.Y then
						scrollBackground.Visible = true
						dropSection.Size = UDim2.new(1, -4, 1, -3)

						local yPos = dropSection.CanvasPosition.Y
						if yPos == 0 then
							scrollFill.Visible = true
						else
							scrollFill.Visible = false
						end
					else
						scrollFill.Visible = false
						scrollBackground.Visible = false
						dropSection.Size = UDim2.new(1, -8, 1, -3)
					end
				end

				dropConnects[#dropConnects + 1] = dropSection.Changed:Connect(function(property)
					if property == 'AbsoluteSize' or property == 'AbsoluteCanvasSize' or property == 'CanvasPosition' then
						updateScrollBackground()
					end
				end)

				for _, item in config.items do
					local itemHolder = library.create('ImageButton', {
						Size = UDim2.new(1, 0, 0, 14),
						Image = '',
						BackgroundTransparency = 1,
						Parent = dropSection
					})

					local itemLabel = library.create('TextLabel', {
						Size = UDim2.new(1, -1, 1, 0),
						Position = UDim2.fromOffset(1, 0),
						BackgroundTransparency = 1,
						Text = tostring(item),
						FontFace = library.font.font,
						TextSize = library.font.size,
						TextColor3 = string.match(string.lower(valuesLabel.Text), "^" .. string.lower(item) .. "$") and library.themes.activeMap.accentPrimary or library.themes.activeMap.textNormal,
						TextXAlignment = 'Left',
						Parent = itemHolder
					})

					local itemLabelStroke = library.create('UIStroke', {
						Color = library.themes.activeMap.textOutline,
						Parent = itemLabel
					})
					toDelete[#toDelete + 1] = itemLabelStroke
					library.themes:addInstance({instance = itemLabelStroke, mapPath = 'textOutline'})

					local itemLabelPadding = library.create('UIPadding', {
						PaddingBottom = UDim.new(0, 1),
						Parent = itemLabel
					})

					itemHolder.MouseButton1Down:Connect(function()						
						dropdown.set(item)
						if not config.multi then
							for _, child in itemHolder.Parent:GetChildren() do
								if child:IsA('ImageButton') then
									local label = child:FindFirstChildOfClass('TextLabel')
									if label and label ~= itemLabel then
										label.TextColor3 = library.themes.activeMap.textNormal
									end
								end
							end
						end
					end)

					do -- hover connections
						local tempConnections = {}
						dropConnects[#dropConnects + 1] = itemHolder.MouseEnter:Connect(function()
							itemLabel.Position = UDim2.fromOffset(3, 0)

							tempConnections[#tempConnections + 1] = RunService.RenderStepped:Connect(function()
								if type(dropdown.value) == 'table' then
									local found = false

									for index, value in dropdown.value do
										if tostring(value) == itemLabel.Text then
											found = true
										end
									end

									if found then
										itemLabel.TextColor3 = library.themes.activeMap.accentSecondary
									else
										itemLabel.TextColor3 = library.themes.activeMap.textDisabled
									end
								else
									if dropdown.value == itemLabel.Text then
										itemLabel.TextColor3 = library.themes.activeMap.accentSecondary
									else
										itemLabel.TextColor3 = library.themes.activeMap.textDisabled
									end
								end
							end)
						end)

						dropConnects[#dropConnects + 1] = itemHolder.MouseLeave:Connect(function()
							itemLabel.Position = UDim2.fromOffset(1, 0)

							for index, connection in tempConnections do
								connection:Disconnect()
								tempConnections[index] = nil
							end

							if type(dropdown.value) == 'table' then
								local found = false

								for index, value in dropdown.value do
									if tostring(value) == itemLabel.Text then
										found = true
									end
								end

								if found then
									itemLabel.TextColor3 = library.themes.activeMap.accentPrimary
								else
									itemLabel.TextColor3 = library.themes.activeMap.textNormal
								end
							else
								if dropdown.value == itemLabel.Text then
									itemLabel.TextColor3 = library.themes.activeMap.accentPrimary
								else
									itemLabel.TextColor3 = library.themes.activeMap.textNormal
								end
							end
						end)
					end
				end

				task.spawn(function()
					dropConnects[#dropConnects + 1] = RunService.RenderStepped:Connect(function()
						outline1.BackgroundColor3 = library.themes.activeMap.accentPrimary
						dropFrame.Position = UDim2.fromOffset(outline1.AbsolutePosition.X, outline1.AbsolutePosition.Y + 78)
					end)
					task.wait()
					dropConnects[#dropConnects + 1] = UserInputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then							
							if not library.inputOverFrame(input, dropFrame) then
								dropRemove()
								
								for _, v1 in toDelete do
									local addedInstances = library.themes.addedInstances
									for i, v2 in addedInstances do
										if v2.instance == v1 then
											addedInstances[i] = nil
										end
									end
								end
							end
						end
					end)
				end)
			end
		end)

		dropdown.set(config.value)
		library.config[config.flag] = dropdown
		return setmetatable(dropdown, library)
	end

	function library:button(config)
		local config = {
			name = config.name or 'config.name',
			size = config.size or UDim2.new(1, 0, 0, 18),
			visible = config.visible == nil and true or config.visible,
			callback = config.callback or nil
		}

		local button = {
			class = 'button',
			section = self.instances.realSection,
			instances = {}
		}
		
		local canResize = true
		if self.class and self.class == 'button' then
			button.section = self.instances.holder
			canResize = false
		end

		local holder = library.create('Frame', {
			Size = config.size,
			BackgroundTransparency = 1,
			Visible = config.visible,
			Parent = button.section
		})
		button.instances['holder'] = holder

		local holderLayout = library.create('UIListLayout', {
			Padding = UDim.new(0, 4),
			FillDirection = 'Horizontal',
			HorizontalAlignment = 'Left',
			Parent = holder
		})
		
		function button.resize()
			local frames = {}

			for _, child in holder:GetChildren() do
				if child:IsA("ImageButton") or child:IsA("Frame") then
					table.insert(frames, child)
				end
			end

			local padding = (#frames - 1) * 4
			local frameWidth = (holder.AbsoluteSize.X - padding) / #frames
			local remainder = (holder.AbsoluteSize.X - padding) % #frames

			for index, frame in frames do
				local extra = (index <= remainder) and 1 or 0
				frame.Size = UDim2.new(0, frameWidth + extra, 1, 0)
			end
		end
		
		if canResize then
			holder.Changed:Connect(function(changed)
				if changed == 'AbsoluteSize' then
					button.resize()
				end
			end)
		end
			
		local outline1 = library.create('ImageButton', {
			Size = UDim2.new(1, 0, 1, 0),
			Image = '',
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = holder
		})
		library.themes:addInstance({instance = outline1, mapPath = 'outline'})

		do -- hover effect
			local hoverConnection = nil

			local enterConnection = outline1.MouseEnter:Connect(function()
				hoverConnection = RunService.RenderStepped:Connect(function()
					outline1.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)
			end)

			local leaveConnection = outline1.MouseLeave:Connect(function()
				if hoverConnection then
					hoverConnection:Disconnect()
					hoverConnection = nil
				end

				outline1.BackgroundColor3 = library.themes.activeMap.outline
			end)
		end

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = outline1
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local nameLabel = library.create('TextLabel', {
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			Text = config.name,
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap.textDisabled,
			Parent = outline1
		})
		button.instances['nameLabel'] = nameLabel
		library.themes:addInstance({instance = nameLabel, mapPath = 'textDisabled'})

		local nameLabelStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = nameLabel
		})
		library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

		local nameLabelPadding = library.create('UIPadding', {
			PaddingBottom = UDim.new(0, 1),
			Parent = nameLabel
		})

		outline1.MouseButton1Down:Connect(function()
			if config.callback ~= nil then
				config.callback()
			end
		end)

		function button.click()
			if config.callback ~= nil then
				config.callback()
			end
		end

		function button.setVisible(boolean)
			holder.Visible = boolean
		end

		return setmetatable(button, library)
	end

	function library:textbox(config)
		local config = {
			name = config.name or 'config.name',
			flag = config.flag or math.random(123456),
			value = config.value or '',
			unsafe = config.unsafe or false,
			visible = config.visible == nil and true or config.visible,
			callback = config.callback or nil,
			placeholder = config.placeholder or ''
		}

		local nameless = nil
		if config.name == 'none' then
			nameless = true
		end

		local textbox = {
			value = config.value,
			class = 'textbox',
			section = self.instances.realSection,
			instances = {}
		}

		local holder = library.create('Frame', {
			Size = nameless and UDim2.new(1, 0, 0, 18) or UDim2.new(1, 0, 0, 32),
			BackgroundTransparency = 1,
			Visible = config.visible,
			Parent = textbox.section
		})
		textbox.instances['holder'] = holder

		if nameless ~= true then
			local nameLabel = library.create('TextLabel', {
				Size = UDim2.new(1, -1, 0, 10),
				Position = UDim2.fromOffset(1, 0),
				BackgroundTransparency = 1,
				Text = config.name,
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.textNormal,
				TextXAlignment = 'Left',
				Parent = holder
			})
			textbox.instances['nameLabel'] = nameLabel
			library.themes:addInstance({instance = nameLabel, mapPath = 'textNormal'})

			local nameLabelStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = nameLabel
			})
			library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

			local nameLabelPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = nameLabel
			})
		end

		local outline1 = library.create('Frame', {
			Size = UDim2.new(1, 0, 0, 18),
			Position = nameless and UDim2.new(0, 0, 0, 0) or UDim2.fromOffset(0, 14),
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = holder
		})
		library.themes:addInstance({instance = outline1, mapPath = 'outline'})

		do -- hover effect
			local hoverConnection = nil

			local enterConnection = holder.MouseEnter:Connect(function()
				hoverConnection = RunService.RenderStepped:Connect(function()
					outline1.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)
			end)

			local leaveConnection = holder.MouseLeave:Connect(function()
				if hoverConnection then
					hoverConnection:Disconnect()
					hoverConnection = nil
				end

				outline1.BackgroundColor3 = library.themes.activeMap.outline
			end)
		end

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = outline1
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local realTextBox = library.create('TextBox', {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			Text = 'Text',
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap.textNormal,
			PlaceholderText = config.placeholder,
			PlaceholderColor3 = library.themes.activeMap.textDisabled,
			Parent = contrast1
		})
		textbox.instances['realTextBox'] = realTextBox
		library.themes:addInstance({instance = realTextBox, mapPath = 'textNormal'})

		local realTextBoxStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = realTextBox
		})
		library.themes:addInstance({instance = realTextBoxStroke, mapPath = 'textOutline'})

		local realTextBoxPadding = library.create('UIPadding', {
			PaddingBottom = UDim.new(0, 1),
			Parent = realTextBox
		})

		realTextBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = realTextBox.Text

			library.flags[config.flag] = text
			if config.callback ~= nil then
				config.callback(text)
			end

			config.value = text
		end)

		function textbox.setVisible(boolean)
			holder.Visible = boolean
		end

		function textbox.set(string)
			local converted = tostring(string)
			realTextBox.Text = converted

			library.flags[config.flag] = converted
			if config.callback ~= nil then
				config.callback(converted)
			end

			config.value = converted
		end

		textbox.set(config.value)
		library.config[config.flag] = textbox
		return setmetatable(textbox, library)
	end

	function library:list(config)
		local config = {
			name = config.name or 'config.name',
			size = config.size or UDim2.new(1, 0, 0, 200),
			flag = config.flag or math.random(123456),
			value = config.value or 'none',
			items = config.items or {'config.items1', 'config.items2', 'config.items3', 'config.items4', 'config.items5'},
			visible = config.visible == nil and true or config.visible,
			callback = config.callback or nil
		}

		local nameless = nil
		if config.name == 'none' then
			nameless = true
		end

		local list = {
			value = config.value,
			class = 'list',
			section = self.instances.realSection,
			instances = {}
		}

		local holder = library.create('Frame', {
			Size = nameless and UDim2.new(config.size.X.Scale, config.size.X.Offset, config.size.Y.Scale, config.size.Y.Offset) or UDim2.new(1, 0, config.size.Y.Scale, config.size.Y.Offset + 14),
			BackgroundTransparency = 1,
			Visible = config.visible,
			Parent = list.section
		})
		list.instances['holder'] = holder

		if nameless ~= true then
			local nameLabel = library.create('TextLabel', {
				Size = UDim2.new(1, -1, 0, 10),
				Position = UDim2.fromOffset(1, 0),
				BackgroundTransparency = 1,
				Text = config.name,
				FontFace = library.font.font,
				TextSize = library.font.size,
				TextColor3 = library.themes.activeMap.textNormal,
				TextXAlignment = 'Left',
				Parent = holder
			})
			list.instances['nameLabel'] = nameLabel
			library.themes:addInstance({instance = nameLabel, mapPath = 'textNormal'})

			local nameLabelStroke = library.create('UIStroke', {
				Color = library.themes.activeMap.textOutline,
				Parent = nameLabel
			})
			library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

			local nameLabelPadding = library.create('UIPadding', {
				PaddingBottom = UDim.new(0, 1),
				Parent = nameLabel
			})
		end

		local outline1 = library.create('Frame', {
			Size = config.size,
			Position = nameless and UDim2.new(0, 0, 0, 0) or UDim2.fromOffset(0, 14),
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = holder
		})
		library.themes:addInstance({instance = outline1, mapPath = 'outline'})

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = outline1
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 270,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local contrast2 = library.create('Frame', {
			Size = UDim2.new(0, 4, 1, 0),
			Position = UDim2.new(1, -4, 0, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Visible = false,
			Parent = contrast1
		})

		local contrast2Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast2
		})
		library.themes:addInstance({instance = contrast2Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local scrollFill = library.create('Frame', {
			Size = UDim2.fromOffset(2, 2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.accentPrimary,
			Visible = false,
			Parent = contrast2
		})
		library.themes:addInstance({instance = scrollFill, mapPath = 'accentPrimary'})

		local realSection = library.create('ScrollingFrame', {
			Size = UDim2.new(1, -1, 1, -4),
			Position = UDim2.fromOffset(0, 3),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = 'Y',
			TopImage = 'rbxassetid://111011970761526',
			MidImage = 'rbxassetid://111011970761526',
			BottomImage = 'rbxassetid://111011970761526',
			ScrollBarImageColor3 = library.themes.activeMap.accentPrimary,
			ScrollBarThickness = 2,
			VerticalScrollBarInset = 'ScrollBar',
			BackgroundTransparency = 1,
			Parent = contrast1
		})
		library.themes:addInstance({instance = realSection, mapPath = 'accentPrimary'})

		local realSectionList = library.create('UIListLayout', {
			Padding = UDim.new(0, 4),
			Parent = realSection
		})

		local function updateScrollBackground()
			if math.floor(realSection.AbsoluteCanvasSize.Y) > math.floor(realSection.AbsoluteSize.Y) then
				if not contrast2.Visible then
					contrast2.Visible = true
				end

				local yPos = realSection.CanvasPosition.Y
				if yPos == 0 then
					scrollFill.Visible = true
				else
					scrollFill.Visible = false
				end
			else
				scrollFill.Visible = false
				if contrast2.Visible then
					contrast2.Visible = false
				end
			end
		end

		realSection.Changed:Connect(function(property)
			if property == 'AbsoluteSize' or property == 'AbsoluteCanvasSize' or property == 'CanvasPosition' then
				updateScrollBackground()
			end
		end)
		
		local oldTextNormal = library.themes.activeMap.textNormal
		local oldAccentPrimary = library.themes.activeMap.accentPrimary
		
		RunService.RenderStepped:Connect(function()
			if library.themes.activeMap.textNormal ~= oldTextNormal or library.themes.activeMap.accentPrimary ~= oldAccentPrimary then
				oldTextNormal = library.themes.activeMap.textNormal
				oldAccentPrimary = library.themes.activeMap.accentPrimary
				for _, child in realSection:GetChildren() do
					if child:IsA('ImageButton') then
						local label = child:FindFirstChildOfClass('TextLabel')
						if label then
							label.TextColor3 = string.match(string.lower(string.lower(list.value)), "^" .. string.lower(label.Text) .. "$") and library.themes.activeMap.accentPrimary or library.themes.activeMap.textNormal
						end
					end
				end
			end
		end)
		
		function list.set(value)
			library.flags[config.flag] = value
			if config.callback ~= nil then
				config.callback(value)
			end

			list.value = value
		end

		function list.setVisible(boolean)
			holder.Visible = boolean
		end

		function list.setItems(tbl)
			for _, child in realSection:GetChildren() do
				if child:IsA('ImageButton') then
					child:Destroy()
				end
			end

			for _, item in tbl do
				local itemHolder = library.create('ImageButton', {
					Size = UDim2.new(1, 0, 0, 14),
					Image = '',
					BackgroundTransparency = 1,
					Parent = realSection
				})

				local itemLabel = library.create('TextLabel', {
					Size = UDim2.new(1, -1, 1, 0),
					Position = UDim2.fromOffset(1, 0),
					BackgroundTransparency = 1,
					Text = tostring(item),
					FontFace = library.font.font,
					TextSize = library.font.size,
					TextColor3 = string.match(string.lower(string.lower(list.value)), "^" .. string.lower(item) .. "$") and library.themes.activeMap.accentPrimary or library.themes.activeMap.textNormal,
					Parent = itemHolder
				})

				local itemLabelStroke = library.create('UIStroke', {
					Color = library.themes.activeMap.textOutline,
					Parent = itemLabel
				})

				local itemLabelPadding = library.create('UIPadding', {
					PaddingBottom = UDim.new(0, 1),
					Parent = itemLabel
				})

				itemHolder.MouseButton1Down:Connect(function()						
					list.set(item)

					for _, child in realSection:GetChildren() do
						if child:IsA('ImageButton') then
							local label = child:FindFirstChildOfClass('TextLabel')
							if label and label ~= itemLabel then
								label.TextColor3 = library.themes.activeMap.textNormal
							end
						end
					end
				end)

				do -- hover connections
					local tempConnections = {}
					itemHolder.MouseEnter:Connect(function()
						tempConnections[#tempConnections + 1] = RunService.RenderStepped:Connect(function()
							if list.value == itemLabel.Text then
								itemLabel.TextColor3 = library.themes.activeMap.accentSecondary
							else
								itemLabel.TextColor3 = library.themes.activeMap.textDisabled
							end
						end)
					end)

					itemHolder.MouseLeave:Connect(function()
						for index, connection in tempConnections do
							connection:Disconnect()
							tempConnections[index] = nil
						end

						if list.value == itemLabel.Text then
							itemLabel.TextColor3 = library.themes.activeMap.accentPrimary
						else
							itemLabel.TextColor3 = library.themes.activeMap.textNormal
						end
					end)
				end
			end
		end
		
		list.setItems(config.items)
		list.set(config.value)
		library.config[config.flag] = list
		return setmetatable(list, library)
	end

	function library:colorpicker(config)
		local config = {
			flag = config.flag or math.random(100000),
			color = config.color or Color3.fromRGB(255, 255, 255),
			alpha = config.alpha or 0,
			visible = config.visible == nil and true or config.visible,
			callback = config.callback or nil
		}

		local colorpicker = {
			value = {color = config.color, alpha = config.alpha},
			class = 'colorpicker',
			parent = self.instances.container,
			instances = {}
		}

		local dragging = {
			hue = false,
			alpha = false,
			picker = false
		}

		local holder = library.create('ImageButton', {
			Size = UDim2.fromOffset(24, 14),
			Image = '',
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = colorpicker.parent
		})
		library.themes:addInstance({instance = holder, mapPath = 'outline'})

		do -- hover effect
			local hoverConnection = nil

			local enterConnection = holder.MouseEnter:Connect(function()
				hoverConnection = RunService.RenderStepped:Connect(function()
					holder.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)
			end)

			local leaveConnection = holder.MouseLeave:Connect(function()
				if hoverConnection then
					hoverConnection:Disconnect()
					hoverConnection = nil
				end

				holder.BackgroundColor3 = library.themes.activeMap.outline
			end)
		end

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = holder
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local alphaFrame1 = library.create('ImageLabel', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundTransparency = 1,
			Image = 'rbxassetid://133536592159590',
			ImageColor3 = library.themes.activeMap.contrastSecondary,
			ScaleType = 'Tile',
			TileSize = UDim2.new(0, 8, 0, 8),
			Parent = inline1
		})
		library.themes:addInstance({instance = alphaFrame1, mapPath = 'contrastSecondary'})

		local colorFrame1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = config.color,
			BackgroundTransparency = config.alpha,
			Parent = inline1
		})

		local colorFrame1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(170, 170, 170))}),
			Rotation = 90,
			Parent = colorFrame1
		})

		local frames = {
			huePointer = nil,
			huePointerColor = nil,

			alphaColor = nil,
			alphaPointer = nil,
			alphaPointerColor = nil,

			pickerImage = nil,
			pickerPointer = nil,
			pickerPointerColor = nil
		}

		local dropFrame = nil
		local dropConnects = {}
		local function dropRemove()			
			if dropFrame then
				dropFrame:Destroy()
				dropFrame = nil
			end

			for index, connection in dropConnects do
				if connection then
					connection:Disconnect()
					dropConnects[index] = nil
				end
			end

			for index, frame in frames do
				if frame ~= nil then
					frames[index] = nil
				end
			end

			holder.BackgroundColor3 = library.themes.activeMap.outline
		end

		function colorpicker.setFrames(color, alpha)
			if color and alpha then
				local h, s, v = color:ToHSV()

				colorFrame1.BackgroundColor3 = color
				colorFrame1.BackgroundTransparency = alpha

				task.spawn(function()
					local huePointer, huePointerColor, alphaColor, alphaPointer, alphaPointerColor, pickerImage, pickerPointer, pickerPointerColor = frames.huePointer, frames.huePointerColor, frames.alphaColor, frames.alphaPointer, frames.alphaPointerColor, frames.pickerImage, frames.pickerPointer, frames.pickerPointerColor
					local hueColor = Color3.fromHSV(h, 1, 1)

					do -- hue
						if huePointer then
							local offset = 0
							if h < 0.5 then
								offset = 0
							else
								local solved = (h - 0.5) * 13.3333
								offset = math.min(solved, 6)
							end

							huePointer.Position = UDim2.new(0, -1, h, -offset)
						end

						if huePointerColor then
							huePointerColor.BackgroundColor3 = hueColor
						end
					end

					do -- alpha
						if alphaColor then
							alphaColor.BackgroundColor3 = color
						end

						if alphaPointer then
							local offset = 0
							if alpha < 0.5 then
								offset = 0
							else
								local solved = (alpha - 0.5) * 13.3333
								offset = math.min(solved, 6)
							end

							alphaPointer.Position = UDim2.new(alpha, -offset, 0, -1)
						end

						if alphaPointerColor then
							alphaPointerColor.BackgroundColor3 = hueColor
						end
					end

					do -- picker
						if pickerImage then
							pickerImage.ImageColor3 = hueColor
						end

						if pickerPointer then
							local minusOne = 1 - v

							local xOffset = 0
							if s < 0.5 then
								xOffset = 0
							else
								local solved = (s - 0.5) * 13.3333
								xOffset = math.min(solved, 6)
							end

							local yOffset = 0
							if minusOne < 0.5 then
								yOffset = 0
							else
								local solved = (minusOne - 0.5) * 13.3333
								yOffset = math.min(solved, 6)
							end

							pickerPointer.Position = UDim2.new(s, -xOffset, minusOne, -yOffset)
						end

						if pickerPointerColor then
							pickerPointerColor.BackgroundColor3 = color
						end
					end
				end)
			end
		end

		function colorpicker.set(value, alpha)
			if type(value) == 'table' then
				colorpicker.setFrames(value.color, value.alpha)

				colorpicker.value = value
				library.flags[config.flag] = value
				if config.callback ~= nil then
					config.callback(value)
				end
			else
				colorpicker.setFrames(value, alpha)

				colorpicker.value = {color = value, alpha = alpha}
				library.flags[config.flag] = {color = value, alpha = alpha}
				if config.callback ~= nil then
					config.callback({color = value, alpha = alpha})
				end
			end
		end

		function colorpicker.setVisible(boolean)
			holder.Visible = boolean
		end

		holder.MouseButton1Down:Connect(function()
			if not dropFrame then
				local toDelete = {}
				
				local containerSize = holder.Parent.AbsoluteSize
				local containerPos = holder.Parent.AbsolutePosition

				dropFrame = library.create('ImageButton', {
					Size = UDim2.fromOffset(containerSize.X, containerSize.X),
					Position = UDim2.fromOffset((containerPos.X), containerPos.Y + 74),
					Image = '',
					BackgroundColor3 = library.themes.activeMap.outline,
					Parent = library.overlayGui
				})
				toDelete[#toDelete + 1] = dropFrame
				library.themes:addInstance({instance = dropFrame, mapPath = 'outline'})

				local inline1 = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.inline,
					Parent = dropFrame
				})
				toDelete[#toDelete + 1] = inline1
				library.themes:addInstance({instance = inline1, mapPath = 'inline'})

				local contrastPrimary = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.contrastPrimary,
					Parent = inline1
				})
				toDelete[#toDelete + 1] = contrastPrimary
				library.themes:addInstance({instance = contrastPrimary, mapPath = 'contrastPrimary'})
				
				local contrastSecondary = library.create('Frame', {
					Size = UDim2.new(1, 0, 0, 15),
					Position = UDim2.fromOffset(0, 2),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = contrastPrimary
				})

				local contrastSecondaryGradient = library.create('UIGradient', {
					Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
					Rotation = 270,
					Parent = contrastSecondary
				})
				toDelete[#toDelete + 1] = contrastSecondaryGradient
				library.themes:addInstance({instance = contrastSecondaryGradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

				local nameLabel = library.create('TextLabel', {
					Size = UDim2.new(1, -5, 0, 18),
					Position = UDim2.fromOffset(5, 0),
					BackgroundTransparency = 1,
					Text = config.flag,
					FontFace = library.font.font,
					TextSize = library.font.size,
					TextColor3 = library.themes.activeMap.textNormal,
					TextXAlignment = 'Left',
					Parent = contrastSecondary
				})
				toDelete[#toDelete + 1] = nameLabel
				library.themes:addInstance({instance = nameLabel, mapPath = 'textNormal'})

				local nameLabelStroke = library.create('UIStroke', {
					Color = library.themes.activeMap.textOutline,
					Parent = nameLabel
				})
				toDelete[#toDelete + 1] = nameLabelStroke
				library.themes:addInstance({instance = nameLabelStroke, mapPath = 'textOutline'})

				local nameLabelPadding = library.create('UIPadding', {
					PaddingBottom = UDim.new(0, 1),
					Parent = nameLabel
				})

				local accentPrimary1 = library.create('Frame', {
					Size = UDim2.new(1, 0, 0, 1),
					BackgroundColor3 = library.themes.activeMap.accentPrimary,
					Parent = contrastPrimary
				})
				toDelete[#toDelete + 1] = accentPrimary1
				library.themes:addInstance({instance = accentPrimary1, mapPath = 'accentPrimary'})

				local accentSecondary1 = library.create('Frame', {
					Size = UDim2.new(1, 0, 0, 1),
					Position = UDim2.fromOffset(0, 1),
					BackgroundColor3 = library.themes.activeMap.accentSecondary,
					Parent = contrastPrimary
				})
				toDelete[#toDelete + 1] = accentSecondary1
				library.themes:addInstance({instance = accentSecondary1, mapPath = 'accentSecondary'})

				local hueOutline = library.create('Frame', {
					Size = UDim2.new(0, 15, 1, -43),
					Position = UDim2.fromOffset(4, 20),
					BackgroundColor3 = library.themes.activeMap.outline,
					Parent = contrastPrimary
				})
				toDelete[#toDelete + 1] = hueOutline
				library.themes:addInstance({instance = hueOutline, mapPath = 'outline'})

				local hueInline = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.inline,
					Parent = hueOutline
				})
				toDelete[#toDelete + 1] = hueInline
				library.themes:addInstance({instance = hueInline, mapPath = 'inline'})

				local hueFrame = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = hueInline
				})

				local hueFrameGradient = library.create('UIGradient', {
					Rotation = 270,
					Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
						ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
						ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
						ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
						ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
					}),
					Parent = hueFrame
				})

				local huePointer = library.create('Frame', {
					Size = UDim2.new(1, 2, 0, 6),
					Position = UDim2.new(0, -1, 0.5, -1),
					BackgroundColor3 = library.themes.activeMap.outline,
					Parent = hueOutline
				})
				frames.huePointer = huePointer
				toDelete[#toDelete + 1] = huePointer
				library.themes:addInstance({instance = huePointer, mapPath = 'outline'})

				local huePointerInline = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.inline,
					Parent = huePointer
				})
				toDelete[#toDelete + 1] = huePointerInline
				library.themes:addInstance({instance = huePointerInline, mapPath = 'inline'})

				local huePointerColor = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = Color3.fromRGB(0, 255, 255),
					Parent = huePointerInline
				})
				frames.huePointerColor = huePointerColor

				local alphaOutline = library.create('Frame', {
					Size = UDim2.new(1, -27, 0, 15),
					Position = UDim2.new(0, 23, 1, -19),
					BackgroundColor3 = library.themes.activeMap.outline,
					Parent = contrastPrimary
				})
				toDelete[#toDelete + 1] = alphaOutline
				library.themes:addInstance({instance = alphaOutline, mapPath = 'outline'})

				local alphaInline = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.inline,
					Parent = alphaOutline
				})
				toDelete[#toDelete + 1] = alphaInline
				library.themes:addInstance({instance = alphaInline, mapPath = 'inline'})

				local alphaImage = library.create('ImageLabel', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundTransparency = 1,
					Image = 'rbxassetid://133536592159590',
					ImageColor3 = library.themes.activeMap.contrastSecondary,
					ScaleType = 'Tile',
					TileSize = UDim2.new(0, 10, 0, 10),
					Parent = alphaInline
				})
				toDelete[#toDelete + 1] = alphaImage
				library.themes:addInstance({instance = alphaImage, mapPath = 'contrastSecondary'})

				local alphaFrame = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = Color3.fromRGB(0, 255, 255),
					Parent = alphaInline
				})
				frames.alphaColor = alphaFrame

				local alphaFrameGradient = library.create('UIGradient', {
					Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0, 0), NumberSequenceKeypoint.new(1, 1, 0)}),
					Parent = alphaFrame
				})

				local alphaPointer = library.create('Frame', {
					Size = UDim2.new(0, 6, 1, 2),
					Position = UDim2.new(0, 0, 0, -1),
					BackgroundColor3 = library.themes.activeMap.outline,
					Parent = alphaOutline
				})
				frames.alphaPointer = alphaPointer
				toDelete[#toDelete + 1] = alphaPointer
				library.themes:addInstance({instance = alphaPointer, mapPath = 'outline'})

				local alphaPointerInline = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.inline,
					Parent = alphaPointer
				})
				toDelete[#toDelete + 1] = alphaPointerInline
				library.themes:addInstance({instance = alphaPointerInline, mapPath = 'inline'})

				local alphaPointerColor = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = Color3.fromRGB(0, 255, 255),
					Parent = alphaPointerInline
				})
				frames.alphaPointerColor = alphaPointerColor

				local pickerOutline = library.create('Frame', {
					Size = UDim2.new(1, -27, 1, -43),
					Position = UDim2.fromOffset(23, 20),
					BackgroundColor3 = library.themes.activeMap.outline,
					Parent = contrastPrimary
				})
				toDelete[#toDelete + 1] = pickerOutline
				library.themes:addInstance({instance = pickerOutline, mapPath = 'outline'})

				local pickerInline = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.inline,
					Parent = pickerOutline
				})
				toDelete[#toDelete + 1] = pickerInline
				library.themes:addInstance({instance = pickerInline, mapPath = 'inline'})

				local pickerFrame = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Parent = pickerInline
				})

				local pickerImage = library.create('ImageLabel', {
					Size = UDim2.fromScale(1, 1),
					Image = 'rbxassetid://118747990634204',
					ImageColor3 = Color3.fromRGB(0, 255, 255),
					BackgroundTransparency = 1,
					Parent = pickerFrame
				})
				frames.pickerImage = pickerImage

				local pickerPointer = library.create('Frame', {
					Size = UDim2.new(0, 6, 0, 6),
					Position = UDim2.new(1, -6, 0, 0),
					BackgroundColor3 = library.themes.activeMap.outline,
					Parent = pickerOutline
				})
				frames.pickerPointer = pickerPointer
				toDelete[#toDelete + 1] = pickerPointer
				library.themes:addInstance({instance = pickerPointer, mapPath = 'outline'})

				local pickerPointerInline = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = library.themes.activeMap.inline,
					Parent = pickerPointer
				})
				toDelete[#toDelete + 1] = pickerPointerInline
				library.themes:addInstance({instance = pickerPointerInline, mapPath = 'inline'})

				local pickerPointerColor = library.create('Frame', {
					Size = UDim2.new(1, -2, 1, -2),
					Position = UDim2.fromOffset(1, 1),
					BackgroundColor3 = Color3.fromRGB(0, 255, 255),
					Parent = pickerPointerInline
				})
				frames.pickerPointerColor = pickerPointerColor

				local hueClick = library.create('ImageButton', {
					Size = UDim2.fromScale(1, 1),
					Image = '',
					BackgroundTransparency = 1,
					Parent = hueOutline
				})

				local alphaClick = library.create('ImageButton', {
					Size = UDim2.fromScale(1, 1),
					Image = '',
					BackgroundTransparency = 1,
					Parent = alphaOutline
				})

				local pickerClick = library.create('ImageButton', {
					Size = UDim2.fromScale(1, 1),
					Image = '',
					BackgroundTransparency = 1,
					Parent = pickerOutline
				})

				dropConnects[#dropConnects + 1] = hueClick.MouseButton1Down:Connect(function()
					dragging.hue = true
					local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 62)
					local hue = math.clamp((mousePos.Y - hueClick.AbsolutePosition.Y) / hueClick.AbsoluteSize.Y, 0, 1)

					local h, s, v = colorpicker.value.color:ToHSV()
					colorpicker.set(Color3.fromHSV(hue, s, v), colorpicker.value.alpha)
				end)

				dropConnects[#dropConnects + 1] = alphaClick.MouseButton1Down:Connect(function()
					dragging.alpha = true
					local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 62)
					local alpha = math.clamp((mousePos.X - alphaClick.AbsolutePosition.X) / alphaClick.AbsoluteSize.X, 0, 1)
					colorpicker.set(colorpicker.value.color, alpha)
				end)

				dropConnects[#dropConnects + 1] = pickerClick.MouseButton1Down:Connect(function()
					dragging.picker = true
					local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 62)
					local x = math.clamp((mousePos.X - pickerClick.AbsolutePosition.X) / pickerClick.AbsoluteSize.X, 0, 1)
					local y = 1 - math.clamp((mousePos.Y - pickerClick.AbsolutePosition.Y) / pickerClick.AbsoluteSize.Y, 0, 1)

					local h, s, v = colorpicker.value.color:ToHSV()
					colorpicker.set(Color3.fromHSV(h, x, y), colorpicker.value.alpha)
				end)

				dropConnects[#dropConnects + 1] = UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging.hue = false
						dragging.alpha = false
						dragging.picker = false
					end
				end)

				dropConnects[#dropConnects + 1] = UserInputService.InputChanged:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement then
						local mousePos = UserInputService:GetMouseLocation() - Vector2.new(0, 62)
						if dragging.hue then
							local hue = math.clamp((mousePos.Y - hueClick.AbsolutePosition.Y) / hueClick.AbsoluteSize.Y, 0, 1)
							local h, s, v = colorpicker.value.color:ToHSV()
							colorpicker.set(Color3.fromHSV(hue, s, v), colorpicker.value.alpha)
						elseif dragging.alpha then
							local alpha = math.clamp((mousePos.X - alphaClick.AbsolutePosition.X) / alphaClick.AbsoluteSize.X, 0, 1)
							colorpicker.set(colorpicker.value.color, alpha)
						elseif dragging.picker  then
							local x = math.clamp((mousePos.X - pickerClick.AbsolutePosition.X) / pickerClick.AbsoluteSize.X, 0, 1)
							local y = 1 - math.clamp((mousePos.Y - pickerClick.AbsolutePosition.Y) / pickerClick.AbsoluteSize.Y, 0, 1)

							local h, s, v = colorpicker.value.color:ToHSV()
							colorpicker.set(Color3.fromHSV(h, x, y), colorpicker.value.alpha)
						end
					end
				end)

				task.spawn(function()
					dropConnects[#dropConnects + 1] = RunService.RenderStepped:Connect(function()
						holder.BackgroundColor3 = library.themes.activeMap.accentPrimary

						local containerSize = holder.Parent.AbsoluteSize
						local containerPos = holder.Parent.AbsolutePosition

						dropFrame.Size = UDim2.fromOffset(containerSize.X, containerSize.X)
						dropFrame.Position = UDim2.fromOffset((containerPos.X), containerPos.Y + 74)
					end)
					task.wait()
					dropConnects[#dropConnects + 1] = UserInputService.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.MouseButton1 then
							if not library.inputOverFrame(input, dropFrame) then								
								dropRemove()
								
								for _, v1 in toDelete do
									local addedInstances = library.themes.addedInstances
									for i, v2 in addedInstances do
										if v2.instance == v1 then
											addedInstances[i] = nil
										end
									end
								end
							end
						end
					end)
				end)

				colorpicker.setFrames(colorpicker.value.color, colorpicker.value.alpha)
			end
		end)

		colorpicker.set(config.color, config.alpha)
		library.config[config.flag] = colorpicker
		return setmetatable(colorpicker, library)
	end
	
	function library:keypicker(config)
		local config = {
			key = config.key or 'none',
			mode = config.mode or 'toggle',
			flag = config.flag or math.random(100000),
			value = config.value or false,
			visible = config.visible == nil and true or config.visible,
			callback = config.callback or nil
		}

		local keypicker = {
			key = config.key,
			mode = config.mode,
			value = config.value,
			class = 'keypicker',
			parent = self.instances.container,
			listening = false,
			instances = {}
		}

		local holder = library.create('ImageButton', {
			Size = UDim2.fromOffset(30, 14),
			AutomaticSize = 'X',
			Image = '',
			BackgroundColor3 = library.themes.activeMap.outline,
			Parent = keypicker.parent
		})
		library.themes:addInstance({instance = holder, mapPath = 'outline'})

		do -- hover effect
			local hoverConnection = nil

			local enterConnection = holder.MouseEnter:Connect(function()
				hoverConnection = RunService.RenderStepped:Connect(function()
					holder.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)
			end)

			local leaveConnection = holder.MouseLeave:Connect(function()
				if hoverConnection then
					hoverConnection:Disconnect()
					hoverConnection = nil
				end

				holder.BackgroundColor3 = library.themes.activeMap.outline
			end)
		end

		local inline1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = library.themes.activeMap.inline,
			Parent = holder
		})
		library.themes:addInstance({instance = inline1, mapPath = 'inline'})

		local contrast1 = library.create('Frame', {
			Size = UDim2.new(1, -2, 1, -2),
			Position = UDim2.fromOffset(1, 1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Parent = inline1
		})

		local contrast1Gradient = library.create('UIGradient', {
			Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
			Rotation = 90,
			Parent = contrast1
		})
		library.themes:addInstance({instance = contrast1Gradient, mapPath = {['0'] = 'contrastPrimary', ['1'] = 'contrastSecondary'}})

		local keyName = library.create('TextLabel', {
			Size = UDim2.new(0, 28, 1, 0),
			AutomaticSize = 'X',
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 1,
			Text = 'none',
			FontFace = library.font.font,
			TextSize = library.font.size,
			TextColor3 = library.themes.activeMap.textNormal,
			Parent = contrast1
		})
		library.themes:addInstance({instance = keyName, mapPath = 'textNormal'})

		local keyNameStroke = library.create('UIStroke', {
			Color = library.themes.activeMap.textOutline,
			Parent = keyName
		})
		library.themes:addInstance({instance = keyNameStroke, mapPath = 'textOutline'})

		local keyNamePadding = library.create('UIPadding', {
			PaddingLeft = UDim.new(0, 5),
			PaddingRight = UDim.new(0, 5),
			PaddingBottom = UDim.new(0, 1),
			Parent = keyName
		})

		local clickDetector = library.create('ImageButton', {
			Size = UDim2.fromScale(1, 1),
			Image = '',
			BackgroundTransparency = 1,
			Parent = holder
		})

		function keypicker.set(entry)
			if type(entry) == 'boolean' then
				if keypicker.mode == 'always' then
					keypicker.value = true
				elseif keypicker.mode == 'on hold' then
					if tostring(keypicker.key):find('KeyCode') then
						keypicker.value = UserInputService:IsKeyDown(keypicker.key)
					elseif tostring(keypicker.key):find('UserInputType') then
						keypicker.value = UserInputService:IsMouseButtonPressed(keypicker.key)
					end
				elseif keypicker.mode == 'off hold' then
					if tostring(keypicker.key):find('KeyCode') then
						keypicker.value = not UserInputService:IsKeyDown(keypicker.key)
					elseif tostring(keypicker.key):find('UserInputType') then
						keypicker.value = not UserInputService:IsMouseButtonPressed(keypicker.key)
					end
				else
					keypicker.value = entry
				end
			elseif type(entry) == 'string' and string.find(entry, 'none') then
				keypicker.key = 'none'
			elseif type(entry) == 'userdata' then
				if entry.UserInputType == Enum.UserInputType.Keyboard then
					keypicker.key = entry.KeyCode
				elseif entry.UserInputType == Enum.UserInputType.MouseButton1 or entry.UserInputType == Enum.UserInputType.MouseButton2 or entry.UserInputType == Enum.UserInputType.MouseButton3 then
					keypicker.key = entry.UserInputType
				end
			elseif table.find({'on hold', 'off hold', 'toggle', 'always'}, entry) then
				keypicker.mode = entry
				if entry == 'always' then
					keypicker.set(true)
				elseif entry == 'on hold' or entry == 'off hold' then
					keypicker.set(false)
				elseif entry == 'toggle' then
					keypicker.set(false)
				end
			elseif type(entry) == 'table' then
				if entry.key and entry.mode then
					entry.key = type(entry.key) == 'string' and entry.key ~= 'none' and library:toEnum(entry.key) or entry.key

					keypicker.key = entry.key
					keypicker.mode = entry.mode
				else
					return
				end
			end

			keyName.Text = string.lower(library.keycodes[keypicker.key] or string.gsub(tostring(keypicker.key), "Enum.KeyCode.", ""))
			
			library.flags[config.flag] = keypicker.value

			if config.callback ~= nil then
				config.callback(keypicker.value)
			end
		end
		
		local dropFrame = nil
		local dropConnects = {}
		local function dropRemove()			
			if dropFrame then
				dropFrame:Destroy()
				dropFrame = nil
			end

			for index, connection in dropConnects do
				if connection then
					connection:Disconnect()
					dropConnects[index] = nil
				end
			end

			holder.BackgroundColor3 = library.themes.activeMap.outline
		end
		
		local colorConnection = nil
		clickDetector.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not keypicker.listening then
				task.wait()
				keyName.Text = '...'
				keypicker.listening = true
				
				colorConnection = RunService.RenderStepped:Connect(function()
					holder.BackgroundColor3 = library.themes.activeMap.accentPrimary
				end)
			end
			
			if input.UserInputType == Enum.UserInputType.MouseButton2 and not keypicker.listening then
				if not dropFrame then
					dropFrame = library.create('ImageButton', {
						Size = UDim2.fromOffset(50, 73),
						Position = UDim2.fromOffset((holder.AbsolutePosition.X + holder.AbsoluteSize.X) + 2, holder.AbsolutePosition.Y + 58),
						Image = '',
						BackgroundColor3 = library.themes.activeMap.outline,
						Parent = library.overlayGui
					})
					
					local inline1 = library.create('Frame', {
						Size = UDim2.new(1, -2, 1, -2),
						Position = UDim2.fromOffset(1, 1),
						BackgroundColor3 = library.themes.activeMap.inline,
						Parent = dropFrame
					})

					local contrast1 = library.create('Frame', {
						Size = UDim2.new(1, -2, 1, -2),
						Position = UDim2.fromOffset(1, 1),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Parent = inline1
					})

					local contrast1Gradient = library.create('UIGradient', {
						Color = ColorSequence.new({ColorSequenceKeypoint.new(0, library.themes.activeMap.contrastPrimary), ColorSequenceKeypoint.new(1, library.themes.activeMap.contrastSecondary)}),
						Rotation = 90,
						Parent = contrast1
					})
					
					local toggleButton = library.create('TextButton', {
						Size = UDim2.new(1, 0, 0, 14),
						Position = UDim2.fromOffset(0, 2),
						BackgroundTransparency = 1,
						Text = 'toggle',
						FontFace = library.font.font,
						TextSize = library.font.size,
						TextColor3 = string.match(string.lower(keypicker.mode), 'toggle') and library.themes.activeMap.accentPrimary or library.themes.activeMap.textNormal,
						Parent = contrast1
					})

					local toggleButtonStroke = library.create('UIStroke', {
						Color = library.themes.activeMap.textOutline,
						Parent = toggleButton
					})

					local toggleButtonPadding = library.create('UIPadding', {
						PaddingBottom = UDim.new(0, 1),
						Parent = toggleButton
					})
					
					local alwaysButton = library.create('TextButton', {
						Size = UDim2.new(1, 0, 0, 14),
						Position = UDim2.fromOffset(0, 19),
						BackgroundTransparency = 1,
						Text = 'always',
						FontFace = library.font.font,
						TextSize = library.font.size,
						TextColor3 = string.match(string.lower(keypicker.mode), 'always') and library.themes.activeMap.accentPrimary or library.themes.activeMap.textNormal,
						Parent = contrast1
					})

					local alwaysButtonStroke = library.create('UIStroke', {
						Color = library.themes.activeMap.textOutline,
						Parent = alwaysButton
					})

					local alwaysButtonPadding = library.create('UIPadding', {
						PaddingBottom = UDim.new(0, 1),
						Parent = alwaysButton
					})
					
					local onHoldButton = library.create('TextButton', {
						Size = UDim2.new(1, 0, 0, 14),
						Position = UDim2.fromOffset(0, 36),
						BackgroundTransparency = 1,
						Text = 'on hold',
						FontFace = library.font.font,
						TextSize = library.font.size,
						TextColor3 = string.match(string.lower(keypicker.mode), 'on hold') and library.themes.activeMap.accentPrimary or library.themes.activeMap.textNormal,
						Parent = contrast1
					})

					local onHoldButtonStroke = library.create('UIStroke', {
						Color = library.themes.activeMap.textOutline,
						Parent = onHoldButton
					})

					local onHoldButtonPadding = library.create('UIPadding', {
						PaddingBottom = UDim.new(0, 1),
						Parent = onHoldButton
					})
					
					local offHoldButton = library.create('TextButton', {
						Size = UDim2.new(1, 0, 0, 14),
						Position = UDim2.fromOffset(0, 53),
						BackgroundTransparency = 1,
						Text = 'off hold',
						FontFace = library.font.font,
						TextSize = library.font.size,
						TextColor3 = string.match(string.lower(keypicker.mode), 'off hold') and library.themes.activeMap.accentPrimary or library.themes.activeMap.textNormal,
						Parent = contrast1
					})

					local offHoldButtonStroke = library.create('UIStroke', {
						Color = library.themes.activeMap.textOutline,
						Parent = offHoldButton
					})

					local offHoldButtonPadding = library.create('UIPadding', {
						PaddingBottom = UDim.new(0, 1),
						Parent = offHoldButton
					})
					
					toggleButton.MouseButton1Down:Connect(function()						
						keypicker.set('toggle')
						
						for _, child in alwaysButton.Parent:GetChildren() do
							if child:IsA('TextButton') then
								if child ~= toggleButton then
									child.TextColor3 = library.themes.activeMap.textNormal
								end
							end
						end
					end)
					
					alwaysButton.MouseButton1Down:Connect(function()						
						keypicker.set('always')

						for _, child in alwaysButton.Parent:GetChildren() do
							if child:IsA('TextButton') then
								if child ~= alwaysButton then
									child.TextColor3 = library.themes.activeMap.textNormal
								end
							end
						end
					end)
					
					onHoldButton.MouseButton1Down:Connect(function()						
						keypicker.set('on hold')

						for _, child in alwaysButton.Parent:GetChildren() do
							if child:IsA('TextButton') then
								if child ~= onHoldButton then
									child.TextColor3 = library.themes.activeMap.textNormal
								end
							end
						end
					end)
					
					offHoldButton.MouseButton1Down:Connect(function()						
						keypicker.set('off hold')

						for _, child in alwaysButton.Parent:GetChildren() do
							if child:IsA('TextButton') then
								if child ~= offHoldButton then
									child.TextColor3 = library.themes.activeMap.textNormal
								end
							end
						end
					end)
					
					do -- hover connections
						do -- toggle
							local tempConnections = {}
							dropConnects[#dropConnects + 1] = toggleButton.MouseEnter:Connect(function()
								tempConnections[#tempConnections + 1] = RunService.RenderStepped:Connect(function()
									if keypicker.mode == 'toggle' then
										toggleButton.TextColor3 = library.themes.activeMap.accentSecondary
									else
										toggleButton.TextColor3 = library.themes.activeMap.textDisabled
									end
								end)
							end)

							dropConnects[#dropConnects + 1] = toggleButton.MouseLeave:Connect(function()
								for index, connection in tempConnections do
									connection:Disconnect()
									tempConnections[index] = nil
								end


								if keypicker.mode == 'toggle' then
									toggleButton.TextColor3 = library.themes.activeMap.accentPrimary
								else
									toggleButton.TextColor3 = library.themes.activeMap.textNormal
								end
							end)
						end
						
						do -- always
							local tempConnections = {}
							dropConnects[#dropConnects + 1] = alwaysButton.MouseEnter:Connect(function()
								tempConnections[#tempConnections + 1] = RunService.RenderStepped:Connect(function()
									if keypicker.mode == 'always' then
										alwaysButton.TextColor3 = library.themes.activeMap.accentSecondary
									else
										alwaysButton.TextColor3 = library.themes.activeMap.textDisabled
									end
								end)
							end)

							dropConnects[#dropConnects + 1] = alwaysButton.MouseLeave:Connect(function()
								for index, connection in tempConnections do
									connection:Disconnect()
									tempConnections[index] = nil
								end


								if keypicker.mode == 'always' then
									alwaysButton.TextColor3 = library.themes.activeMap.accentPrimary
								else
									alwaysButton.TextColor3 = library.themes.activeMap.textNormal
								end
							end)
						end
						
						do -- on hold
							local tempConnections = {}
							dropConnects[#dropConnects + 1] = onHoldButton.MouseEnter:Connect(function()
								tempConnections[#tempConnections + 1] = RunService.RenderStepped:Connect(function()
									if keypicker.mode == 'on hold' then
										onHoldButton.TextColor3 = library.themes.activeMap.accentSecondary
									else
										onHoldButton.TextColor3 = library.themes.activeMap.textDisabled
									end
								end)
							end)

							dropConnects[#dropConnects + 1] = onHoldButton.MouseLeave:Connect(function()
								for index, connection in tempConnections do
									connection:Disconnect()
									tempConnections[index] = nil
								end


								if keypicker.mode == 'on hold' then
									onHoldButton.TextColor3 = library.themes.activeMap.accentPrimary
								else
									onHoldButton.TextColor3 = library.themes.activeMap.textNormal
								end
							end)
						end
						
						do -- off hold
							local tempConnections = {}
							dropConnects[#dropConnects + 1] = offHoldButton.MouseEnter:Connect(function()
								tempConnections[#tempConnections + 1] = RunService.RenderStepped:Connect(function()
									if keypicker.mode == 'off hold' then
										offHoldButton.TextColor3 = library.themes.activeMap.accentSecondary
									else
										offHoldButton.TextColor3 = library.themes.activeMap.textDisabled
									end
								end)
							end)

							dropConnects[#dropConnects + 1] = offHoldButton.MouseLeave:Connect(function()
								for index, connection in tempConnections do
									connection:Disconnect()
									tempConnections[index] = nil
								end


								if keypicker.mode == 'off hold' then
									offHoldButton.TextColor3 = library.themes.activeMap.accentPrimary
								else
									offHoldButton.TextColor3 = library.themes.activeMap.textNormal
								end
							end)
						end
					end
					
					task.spawn(function()
						dropConnects[#dropConnects + 1] = RunService.RenderStepped:Connect(function()
							holder.BackgroundColor3 = library.themes.activeMap.accentPrimary

							local holderPos = holder.AbsolutePosition
							dropFrame.Position = UDim2.fromOffset((holderPos.X + holder.AbsoluteSize.X) + 2, holderPos.Y + 58)
						end)
						task.wait()
						dropConnects[#dropConnects + 1] = UserInputService.InputBegan:Connect(function(input)
							if input.UserInputType == Enum.UserInputType.MouseButton1 then
								if not library.inputOverFrame(input, dropFrame) then								
									dropRemove()
								end
							end
						end)
					end)
				else
					dropRemove()
				end
			end
		end)

		UserInputService.InputBegan:Connect(function(input)
			if keypicker.listening then
				if colorConnection then
					colorConnection:Disconnect()
				end
				holder.BackgroundColor3 = library.themes.activeMap.outline

				if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
					keypicker.set('none')
					keypicker.set(false)
					keypicker.listening = false
					return
				end

				if input.UserInputType == Enum.UserInputType.Keyboard or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.MouseButton3 then
					keypicker.set(input)
					keypicker.set(false)
					keypicker.listening = false
				end
			elseif input.KeyCode == keypicker.key or input.UserInputType == keypicker.key then
				if keypicker.mode == 'on hold' then
					keypicker.set(true)
					return
				elseif keypicker.mode == 'off hold' then
					keypicker.set(false)
					return
				end
				
				keypicker.set(not keypicker.value)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if keypicker.mode == 'on hold' and (input.KeyCode == keypicker.key or input.UserInputType == keypicker.key) and not keypicker.listening then
				keypicker.set(false)
			end

			if keypicker.mode == 'off hold' and (input.KeyCode == keypicker.key or input.UserInputType == keypicker.key) and not keypicker.listening then
				keypicker.set(true)
			end
		end)
		
		keypicker.set(config.value)
		keypicker.set({config.key, config.mode})
		library.config[config.flag] = keypicker
		return setmetatable(keypicker, library)
	end
	
	function library:glow(parent, layers, transparency, color)
		for _, child in parent:GetChildren() do
			if child.Name:match('glow') then
				child:Destroy()
			end
		end

		for index = 1, layers do
			local sigma = (1 - transparency) / layers

			local layer = library.create('Frame', {
				Name = 'glow ' .. index,
				Size = UDim2.new(1, index * 2, 1, index * 2),
				Position = UDim2.fromOffset(-index, -index),
				BackgroundColor3 = color,
				BackgroundTransparency = transparency + (sigma * (index - 1)),
				ZIndex = parent.ZIndex - 1,
				Parent = parent
			})

			local corner = library.create('UICorner', {
				CornerRadius = UDim.new(0, 8),
				Parent = layer
			})
		end
	end
end

return library
