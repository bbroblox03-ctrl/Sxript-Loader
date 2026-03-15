local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local sellRemote = ReplicatedStorage:WaitForChild("RemotesEvent"):WaitForChild("SellPetEvent")

local selectedFolder = "Common"
local selectedPets = {}
local autoSell = false
local sellDelay = 1
local rarities = {"Common", "Rare", "Epic", "Legendary", "Mythic"}

local rarityColors = {
	common    = Color3.fromRGB(160, 160, 160),
	rare      = Color3.fromRGB(80, 140, 255),
	epic      = Color3.fromRGB(180, 80, 255),
	legendary = Color3.fromRGB(255, 180, 40),
	mythic    = Color3.fromRGB(255, 80, 120),
}

local gui = Instance.new("ScreenGui")
gui.Name = "AutoSellGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

-- ===================== PLAIN BLACK BORDER =====================
local function createBlackStroke(parent, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(0, 0, 0)  -- PLAIN BLACK
	stroke.Thickness = thickness or 2
	stroke.Parent = parent
	return stroke
end

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 220, 0, 154)
main.AnchorPoint = Vector2.new(0.5, 0)
main.Position = UDim2.new(0.5, 0, 0, -15)
main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- BLACK BACKGROUND
main.BackgroundTransparency = 0.15  -- SLIGHTLY TRANSPARENT
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 11)
mainCorner.Parent = main

-- PLAIN BLACK BORDER
local mainStroke = createBlackStroke(main, 2)

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 31)
titleBar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- BLACK
titleBar.BackgroundTransparency = 0.1
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 11)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
titleFix.BackgroundTransparency = 0.1
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

-- TITLE LABEL - WHITE TEXT
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -100, 1, 0)
titleLabel.Position = UDim2.new(0, 9, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)  -- WHITE TEXT
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Text = "Auto Sell Pets"
titleLabel.Parent = titleBar

-- DESTROY GUI BUTTON - BLACK AND WHITE
local destroyBtn = Instance.new("TextButton")
destroyBtn.Name = "DestroyBtn"
destroyBtn.Size = UDim2.new(0, 65, 0, 22)
destroyBtn.Position = UDim2.new(1, -70, 0, 4)
destroyBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- BLACK
destroyBtn.BackgroundTransparency = 0.2
destroyBtn.BorderSizePixel = 0
destroyBtn.Text = "Destroy GUI"
destroyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)  -- WHITE TEXT
destroyBtn.Font = Enum.Font.GothamBold
destroyBtn.TextSize = 9
destroyBtn.Parent = titleBar

local destroyCorner = Instance.new("UICorner")
destroyCorner.CornerRadius = UDim.new(0, 6)
destroyCorner.Parent = destroyBtn

-- PLAIN BLACK BORDER
local destroyStroke = createBlackStroke(destroyBtn, 1.5)

-- MINIMIZE BUTTON - BLACK AND WHITE
local minBtn = Instance.new("TextButton")
minBtn.Name = "MinBtn"
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -95, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- BLACK
destroyBtn.BackgroundTransparency = 0.2
minBtn.BorderSizePixel = 0
minBtn.Text = "–"
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)  -- WHITE TEXT
destroyBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 13
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(1, 0)
minCorner.Parent = minBtn

-- DESTROY BUTTON FUNCTIONALITY
destroyBtn.MouseEnter:Connect(function()
	TweenService:Create(destroyBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(40, 40, 40),  -- DARK GRAY ON HOVER
		BackgroundTransparency = 0.1
	}):Play()
end)

destroyBtn.MouseLeave:Connect(function()
	TweenService:Create(destroyBtn, TweenInfo.new(0.15), {
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.2
	}):Play()
end)

destroyBtn.MouseButton1Click:Connect(function()
	TweenService:Create(main, TweenInfo.new(0.2), {
		Size = UDim2.new(0, 220, 0, 0),
		BackgroundTransparency = 1
	}):Play()

	for _, child in pairs(main:GetDescendants()) do
		if child:IsA("GuiObject") then
			TweenService:Create(child, TweenInfo.new(0.15), {
				BackgroundTransparency = 1,
				TextTransparency = 1,
				ImageTransparency = 1
			}):Play()
		end
	end

	task.delay(0.25, function()
		gui:Destroy()
	end)
end)

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -31)
content.Position = UDim2.new(0, 0, 0, 31)
content.BackgroundTransparency = 1
content.Parent = main

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.PaddingTop = UDim.new(0, 7)
pad.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function makeButton(text, color, layoutOrder)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 29)
	btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- BLACK BACKGROUND
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)  -- WHITE TEXT
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 11
	btn.LayoutOrder = layoutOrder or 0
	btn.Parent = content

	-- PLAIN BLACK BORDER
	local btnStroke = createBlackStroke(btn, 1.5)

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(40, 40, 40),  -- DARK GRAY HOVER
			BackgroundTransparency = 0.1
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 0.2
		}):Play()
	end)
	return btn
end

local toggleBtn = makeButton("Auto Sell:  OFF", Color3.fromRGB(0, 0, 0), 1)
local folderBtn = makeButton("📁  Folder: Common", Color3.fromRGB(0, 0, 0), 2)
local petBtn    = makeButton("🐾  Select Pets ▾", Color3.fromRGB(0, 0, 0), 3)

local dropFrame = Instance.new("Frame")
dropFrame.Name = "DropFrame"
dropFrame.Size = UDim2.new(0, 220, 0, 0)
dropFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- BLACK
dropFrame.BackgroundTransparency = 0.1
dropFrame.BorderSizePixel = 0
dropFrame.ClipsDescendants = true
dropFrame.Visible = false
dropFrame.ZIndex = 10
dropFrame.Parent = gui

local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0, 9)
dropCorner.Parent = dropFrame

-- PLAIN BLACK BORDER
local dropStroke = createBlackStroke(dropFrame, 2)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)  -- GRAY SCROLLBAR
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ZIndex = 10
scroll.Parent = dropFrame

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 2)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = scroll

local scrollPad = Instance.new("UIPadding")
scrollPad.PaddingLeft = UDim.new(0, 6)
scrollPad.PaddingRight = UDim.new(0, 6)
scrollPad.PaddingTop = UDim.new(0, 6)
scrollPad.PaddingBottom = UDim.new(0, 6)
scrollPad.Parent = scroll

local function positionDropBelow(btn)
	local absPos = btn.AbsolutePosition
	local absSize = btn.AbsoluteSize
	dropFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
end

local function openDrop(height)
	dropFrame.Visible = true
	TweenService:Create(dropFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 220, 0, math.min(height, 176))
	}):Play()
end

local function closeDrop()
	TweenService:Create(dropFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 220, 0, 0)
	}):Play()
	task.delay(0.16, function() dropFrame.Visible = false end)
end

local function clearScroll()
	for _, c in pairs(scroll:GetChildren()) do
		if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
			c:Destroy()
		end
	end
end

local function makeDropItem(text, color, onClick)
	local item = Instance.new("TextButton")
	item.Size = UDim2.new(1, 0, 0, 29)
	item.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- BLACK
	item.BackgroundTransparency = 0.2
	item.BorderSizePixel = 0
	item.Text = text
	item.TextColor3 = color or Color3.fromRGB(255, 255, 255)  -- WHITE TEXT
	item.Font = Enum.Font.Gotham
	item.TextSize = 11
	item.ZIndex = 10
	item.Parent = scroll

	-- PLAIN BLACK BORDER
	local itemStroke = createBlackStroke(item, 1)

	local ic = Instance.new("UICorner")
	ic.CornerRadius = UDim.new(0, 6)
	ic.Parent = item

	item.MouseEnter:Connect(function() 
		item.BackgroundColor3 = Color3.fromRGB(40, 40, 40)  -- DARK GRAY HOVER
		item.BackgroundTransparency = 0.1
	end)
	item.MouseLeave:Connect(function() 
		item.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		item.BackgroundTransparency = 0.2
	end)
	item.MouseButton1Click:Connect(onClick)
	return item
end

-- ===================== FOLDER DROPDOWN =====================
folderBtn.MouseButton1Click:Connect(function()
	clearScroll()
	positionDropBelow(folderBtn)
	for _, rarity in pairs(rarities) do
		local col = rarityColors[rarity] or Color3.fromRGB(200, 200, 200)
		makeDropItem("📁  "..rarity:sub(1,1):upper()..rarity:sub(2), col, function()
			selectedFolder = rarity
			folderBtn.Text = "📁  "..rarity:sub(1,1):upper()..rarity:sub(2)
			closeDrop()
		end)
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, #rarities * 31 + 11)
	openDrop(#rarities * 31 + 11)
end)

-- ===================== PET DROPDOWN =====================
local function getPetsFolder()
	return player.PlayerGui:WaitForChild("LuckyOpenPets")
		:WaitForChild(selectedFolder)
		:WaitForChild("PetsMenuFrame")
		:WaitForChild("PetsScrolllist")
end

local function refreshPetDrop()
	clearScroll()
	positionDropBelow(petBtn)

	local ok, petsFolder = pcall(getPetsFolder)
	if not ok then
		makeDropItem("⚠  Buka menu pets dulu!", Color3.fromRGB(255, 120, 120), function() end)
		scroll.CanvasSize = UDim2.new(0, 0, 0, 35)
		openDrop(35)
		return
	end

	local petLabels = {}
	for _, v in pairs(petsFolder:GetChildren()) do
		if v:IsA("ImageLabel") then
			table.insert(petLabels, v)
		end
	end
	table.sort(petLabels, function(a, b) return a.Name < b.Name end)

	if #petLabels == 0 then
		makeDropItem("⚠  Tidak ada pet", Color3.fromRGB(255, 180, 80), function() end)
		scroll.CanvasSize = UDim2.new(0, 0, 0, 35)
		openDrop(35)
		return
	end

	for _, petLabel in pairs(petLabels) do
		local petName = petLabel.Name
		local isSelected = selectedPets[petName] ~= nil

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 34)
		row.BackgroundColor3 = isSelected
			and Color3.fromRGB(40, 40, 40)   -- DARK GRAY when selected
			or  Color3.fromRGB(0, 0, 0)      -- BLACK normal
		row.BackgroundTransparency = 0.2
		row.BorderSizePixel = 0
		row.ZIndex = 10
		row.Parent = scroll

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 6)
		rowCorner.Parent = row

		-- PLAIN BLACK BORDER
		local rowStroke = createBlackStroke(row, 1)

		local imgClone = petLabel:Clone()
		imgClone.Size = UDim2.new(0, 26, 0, 26)
		imgClone.Position = UDim2.new(0, 4, 0.5, -13)
		imgClone.BackgroundTransparency = 1
		imgClone.BorderSizePixel = 0
		imgClone.ZIndex = 11
		imgClone.Parent = row

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -36, 1, 0)
		nameLabel.Position = UDim2.new(0, 34, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = isSelected and "🗑️  "..petName or petName
		nameLabel.TextColor3 = isSelected
			and Color3.fromRGB(255, 100, 100)   -- LIGHT RED when selected
			or  Color3.fromRGB(255, 255, 255)   -- WHITE normal
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextSize = 11
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.ZIndex = 11
		nameLabel.Parent = row

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.ZIndex = 12
		btn.Parent = row

		btn.MouseEnter:Connect(function()
			row.BackgroundColor3 = selectedPets[petName]
				and Color3.fromRGB(60, 60, 60)
				or  Color3.fromRGB(40, 40, 40)
			row.BackgroundTransparency = 0.1
		end)
		btn.MouseLeave:Connect(function()
			row.BackgroundColor3 = selectedPets[petName]
				and Color3.fromRGB(40, 40, 40)
				or  Color3.fromRGB(0, 0, 0)
			row.BackgroundTransparency = 0.2
		end)
		btn.MouseButton1Click:Connect(function()
			if selectedPets[petName] then
				selectedPets[petName] = nil
				nameLabel.Text = petName
				nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				row.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			else
				selectedPets[petName] = true
				nameLabel.Text = "🗑️  "..petName
				nameLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
				row.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			end
		end)
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, #petLabels * 36 + 12)
	openDrop(#petLabels * 36 + 12)
end

petBtn.MouseButton1Click:Connect(function()
	if dropFrame.Visible then
		closeDrop()
	else
		refreshPetDrop()
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		local pos = input.Position
		local dp = dropFrame.AbsolutePosition
		local ds = dropFrame.AbsoluteSize
		if not (pos.X >= dp.X and pos.X <= dp.X + ds.X and pos.Y >= dp.Y and pos.Y <= dp.Y + ds.Y) then
			if dropFrame.Visible then closeDrop() end
		end
	end
end)

-- ===================== AUTO SELL LOGIC =====================
toggleBtn.MouseButton1Click:Connect(function()
	autoSell = not autoSell
	if autoSell then
		toggleBtn.Text = "Auto Sell:  ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		task.spawn(function()
			local firstSell = true
			while autoSell do
				for name, _ in pairs(selectedPets) do
					if not autoSell then break end
					for _, v in pairs(player.PlayerGui:GetDescendants()) do
						if not autoSell then break end
						if v:IsA("ImageLabel") and v.Name == name then
							sellRemote:FireServer(v)
							if firstSell then firstSell = false
							else task.wait(sellDelay) end
						end
					end
				end
				if autoSell then task.wait(0.5) end
			end
		end)
	else
		toggleBtn.Text = "Auto Sell:  OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end)

-- ===================== MINIMIZE =====================
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 220, 0, 31)
		}):Play()
		minBtn.Text = "+"
		closeDrop()
	else
		TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 220, 0, 154)
		}):Play()
		minBtn.Text = "–"
	end
end)

-- ===================== DRAG =====================
local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
	if dragging then
		local delta = input.Position - dragStart
		local newPos = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
		main.Position = newPos
		if dropFrame.Visible then
			local anchor = (dropFrame.Position.Y.Offset < main.AbsolutePosition.Y + main.AbsoluteSize.Y / 2)
				and folderBtn or petBtn
			positionDropBelow(anchor)
		end
	end
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		updateDrag(input)
	end
end)
