local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local bryh = Instance.new("ScreenGui")
local Bar = Instance.new("Frame")
local Main = Instance.new("Frame")
local pg1 = Instance.new("Frame")
local vrName = Instance.new("TextBox")
local refreshBtn = Instance.new("TextButton")
local dropdown = Instance.new("ScrollingFrame")
local annoy = Instance.new("TextButton")
local plrpickup = Instance.new("TextButton")
local nocliphands = Instance.new("TextButton")
local weldtohands = Instance.new("TextButton")
local remprops = Instance.new("TextButton")
local nextp = Instance.new("TextButton")
local prev = Instance.new("TextButton")
local page = Instance.new("TextLabel")
local pg2 = Instance.new("Frame")
local noclipprops = Instance.new("TextButton")
local noclipheads = Instance.new("TextButton")
local TextLabel = Instance.new("TextLabel")
local close = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local Shadow = Instance.new("Frame")

bryh.Name = "bryh"
bryh.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
bryh.ResetOnSpawn = false

Bar.Name = "Bar"
Bar.Parent = bryh
Bar.BackgroundColor3 = Color3.fromRGB(124, 9, 9)
Bar.BorderSizePixel = 0
Bar.Position = UDim2.new(0.254468083, 0, 0.142506137, 0)
Bar.Size = UDim2.new(0, 375, 0, 35)
Bar.Selectable = true
Bar.Active = true

-- UI Draggable implementation using UserInputService
local dragging, dragInput, dragStart, startPos
local function update(input)
	local delta = input.Position - dragStart
	Bar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

Bar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = Bar.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Bar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

Main.Name = "Main"
Main.Parent = Bar
Main.BackgroundColor3 = Color3.fromRGB(172, 13, 13)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0, 0, 0.972270846, 0)
Main.Size = UDim2.new(0, 375, 0, 378)

pg1.Name = "pg1"
pg1.Parent = Main
pg1.BackgroundColor3 = Color3.fromRGB(153, 11, 11)
pg1.BorderSizePixel = 0
pg1.Position = UDim2.new(0, 0, -0.00127414928, 0)
pg1.Size = UDim2.new(0, 375, 0, 347)

-- Search input box
vrName.Name = "vrName"
vrName.Parent = pg1
vrName.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
vrName.BorderSizePixel = 0
vrName.Position = UDim2.new(0.032, 0, 0.0259, 0)
vrName.Size = UDim2.new(0, 290, 0, 50)
vrName.Font = Enum.Font.Gotham
vrName.Text = "VR Player's name"
vrName.TextColor3 = Color3.fromRGB(255, 255, 255)
vrName.TextScaled = true
vrName.TextSize = 14.000
vrName.TextWrapped = true

-- Refresh button next to search box
refreshBtn.Name = "refreshBtn"
refreshBtn.Parent = pg1
refreshBtn.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
refreshBtn.BorderSizePixel = 0
refreshBtn.Position = UDim2.new(0.032, 300, 0.0259, 0)
refreshBtn.Size = UDim2.new(0, 50, 0, 50)
refreshBtn.Font = Enum.Font.Gotham
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.TextScaled = true
refreshBtn.TextSize = 14.000

-- Scrollable Dropdown for player list
dropdown.Name = "PlayerDropdown"
dropdown.Parent = pg1
dropdown.BackgroundColor3 = Color3.fromRGB(40, 5, 5)
dropdown.BorderSizePixel = 0
dropdown.Position = UDim2.new(0.032, 0, 0.0259, 52)
dropdown.Size = UDim2.new(0, 350, 0, 150)
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 6
dropdown.Visible = false
dropdown.ZIndex = 10

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = dropdown
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local selectedPlayer = nil

-- Update the dropdown list dynamically
local function updateDropdown()
	for _, child in ipairs(dropdown:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local searchText = vrName.Text:lower()
	if searchText == "vr player's name" then
		searchText = ""
	end

	local count = 0
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer then
			local username = p.Name:lower()
			local displayname = p.DisplayName:lower()

			if searchText == "" or username:find(searchText, 1, true) or displayname:find(searchText, 1, true) then
				count = count + 1
				local btn = Instance.new("TextButton")
				btn.Name = p.Name
				btn.Size = UDim2.new(1, -6, 0, 30)
				btn.BackgroundColor3 = Color3.fromRGB(60, 10, 10)
				btn.BorderSizePixel = 0
				btn.Font = Enum.Font.Gotham
				btn.TextColor3 = Color3.fromRGB(255, 255, 255)
				btn.Text = " " .. p.DisplayName .. " (@" .. p.Name .. ")"
				btn.TextSize = 12
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.ZIndex = 11
				btn.Parent = dropdown

				btn.MouseButton1Down:Connect(function()
					selectedPlayer = p
					vrName.Text = p.Name
					dropdown.Visible = false
				end)
			end
		end
	end
	dropdown.CanvasSize = UDim2.new(0, 0, 0, count * 30)
end

vrName:GetPropertyChangedSignal("Text"):Connect(function()
	if vrName:IsFocused() then
		dropdown.Visible = true
		updateDropdown()
	end
end)

vrName.Focused:Connect(function()
	dropdown.Visible = true
	updateDropdown()
end)

refreshBtn.MouseButton1Down:Connect(function()
	updateDropdown()
end)

-- Hide dropdown when clicking elsewhere
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		task.wait(0.15)
		if not vrName:IsFocused() then
			dropdown.Visible = false
		end
	end
end)

-- Helper: Get VR Player's Head Part
local function getVRHeadPart(targetPlayer)
	if not targetPlayer then return nil end
	
	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		local playerFolder = vrPlayersFolder:FindFirstChild(tostring(targetPlayer.UserId))
		if playerFolder then
			local vrHead = playerFolder:FindFirstChild("VRHead")
			if vrHead then
				return vrHead:FindFirstChild("Collider") or vrHead:FindFirstChild("HeadsetPart") or vrHead:FindFirstChild("Base")
			end
		end
	end
	
	local char = targetPlayer.Character
	if char then
		local vrHead = char:FindFirstChild("VRHead")
		if vrHead then
			return vrHead:FindFirstChild("Collider") or vrHead:FindFirstChild("HeadsetPart") or vrHead:FindFirstChild("Base")
		end
	end
	return nil
end

-- Helper: Get VR Player's Right Hand Part
local function getVRHandPart(targetPlayer)
	if not targetPlayer then return nil end

	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		local playerFolder = vrPlayersFolder:FindFirstChild(tostring(targetPlayer.UserId))
		if playerFolder then
			local rightHand = playerFolder:FindFirstChild("RightHand")
			if rightHand then
				return rightHand:FindFirstChild("ControllerPart") or rightHand:FindFirstChildOfClass("BasePart")
			end
		end
	end

	local char = targetPlayer.Character
	if char then
		local rightHand = char:FindFirstChild("RightHand")
		if rightHand then
			return rightHand:FindFirstChild("ControllerPart") or rightHand:FindFirstChildOfClass("BasePart")
		end
	end
	return nil
end

local annoying = false
local annoyConnection = nil
local annoyPart = nil

annoy.Name = "annoy"
annoy.Parent = pg1
annoy.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
annoy.BorderSizePixel = 0
annoy.Position = UDim2.new(0.0320000015, 0, 0.18731989, 0)
annoy.Size = UDim2.new(0, 350, 0, 50)
annoy.Font = Enum.Font.Gotham
annoy.Text = "Annoy Player"
annoy.TextColor3 = Color3.fromRGB(255, 255, 255)
annoy.TextScaled = true
annoy.TextSize = 14.000
annoy.TextWrapped = true
annoy.MouseButton1Down:Connect(function()
	if not annoying then
		local targetPlayer = selectedPlayer
		if not targetPlayer or targetPlayer.Parent == nil then
			local typedText = vrName.Text:lower()
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name:lower() == typedText or p.DisplayName:lower() == typedText then
					targetPlayer = p
					break
				end
			end
		end

		if targetPlayer then
			local realHead = getVRHeadPart(targetPlayer)
			local character = Players.LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")

			if realHead and hrp then
				annoying = true
				annoy.Text = "Stop Annoying Player"
				
				annoyPart = Instance.new("Part")
				annoyPart.Size = Vector3.new(1, 1, 1)
				annoyPart.CanCollide = false
				
				local w = Instance.new("Weld")
				w.Part0 = annoyPart
				w.Part1 = hrp
				w.Parent = annoyPart

				local bp = Instance.new("BodyPosition")
				bp.D = 10000
				bp.P = 1000000
				bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bp.Parent = annoyPart
				
				annoyPart.Parent = workspace

				annoyConnection = RunService.Heartbeat:Connect(function()
					if realHead and annoyPart and bp then
						bp.Position = realHead.Position + realHead.CFrame.LookVector * 15 + realHead.CFrame.RightVector * 2
					else
						annoying = false
						annoy.Text = "Annoy Player"
						if annoyConnection then annoyConnection:Disconnect() annoyConnection = nil end
						if annoyPart then annoyPart:Destroy() annoyPart = nil end
					end
				end)
			else
				annoy.Text = "Target VR Head parts not found!"
				task.wait(1.5)
				annoy.Text = "Annoy Player"
			end
		else
			annoy.Text = "Please select or type a player!"
			task.wait(1.5)
			annoy.Text = "Annoy Player"
		end
	else
		annoying = false
		annoy.Text = "Annoy Player"
		if annoyConnection then annoyConnection:Disconnect() annoyConnection = nil end
		if annoyPart then annoyPart:Destroy() annoyPart = nil end
	end
end)

-- Direct Remote Anti-Grab Integration
local antiGrabEnabled = false
local grabConnection = nil
local charAddedConnection = nil

local pinchRemote = ReplicatedStorage:WaitForChild("COM", 5)
if pinchRemote then
	pinchRemote = pinchRemote:WaitForChild("Pinch", 5)
	if pinchRemote then
		pinchRemote = pinchRemote:WaitForChild("LetMeGo", 5)
	end
end

local function checkAndRelease(character)
	if antiGrabEnabled and character and character:GetAttribute("Grabbed") then
		if pinchRemote then
			pinchRemote:FireServer()
		end
	end
end

local function setupCharConnections(character)
	if grabConnection then
		grabConnection:Disconnect()
		grabConnection = nil
	end
	if not character then return end
	
	checkAndRelease(character)
	grabConnection = character:GetAttributeChangedSignal("Grabbed"):Connect(function()
		checkAndRelease(character)
	end)
end

plrpickup.Name = "plrpickup"
plrpickup.Parent = pg1
plrpickup.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
plrpickup.BorderSizePixel = 0
plrpickup.Position = UDim2.new(0.0320000015, 0, 0.348703176, 0)
plrpickup.Size = UDim2.new(0, 350, 0, 50)
plrpickup.Font = Enum.Font.Gotham
plrpickup.Text = "Disable VR Pickup"
plrpickup.TextColor3 = Color3.fromRGB(255, 255, 255)
plrpickup.TextScaled = true
plrpickup.TextSize = 14.000
plrpickup.TextWrapped = true
plrpickup.MouseButton1Down:Connect(function()
	antiGrabEnabled = not antiGrabEnabled
	if antiGrabEnabled then
		plrpickup.Text = "Enable VR Pickup"
		local char = Players.LocalPlayer.Character
		setupCharConnections(char)
		
		if not charAddedConnection then
			charAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(function(chara)
				setupCharConnections(chara)
			end)
		end
	else
		plrpickup.Text = "Disable VR Pickup"
		if grabConnection then
			grabConnection:Disconnect()
			grabConnection = nil
		end
		if charAddedConnection then
			charAddedConnection:Disconnect()
			charAddedConnection = nil
		end
	end
end)

local nocliphand = false
nocliphands.Name = "nocliphands"
nocliphands.Parent = pg1
nocliphands.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
nocliphands.BorderSizePixel = 0
nocliphands.Position = UDim2.new(0.0320000015, 0, 0.510086477, 0)
nocliphands.Size = UDim2.new(0, 350, 0, 50)
nocliphands.Font = Enum.Font.Gotham
nocliphands.Text = "Noclip VR Hands"
nocliphands.TextColor3 = Color3.fromRGB(255, 255, 255)
nocliphands.TextScaled = true
nocliphands.TextSize = 14.000
nocliphands.TextWrapped = true
nocliphands.MouseButton1Down:Connect(function()
	nocliphand = not nocliphand
	nocliphands.Text = nocliphand and "Clip VR Hands" or "Noclip VR Hands"

	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		for _, playerFolder in ipairs(vrPlayersFolder:GetChildren()) do
			for _, handName in ipairs({"RightHand", "LeftHand"}) do
				local hand = playerFolder:FindFirstChild(handName)
				if hand then
					for _, item in ipairs(hand:GetDescendants()) do
						if item:IsA("BasePart") then
							item.CanCollide = not nocliphand
						end
					end
				end
			end
		end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			for _, handName in ipairs({"RightHand", "LeftHand"}) do
				local hand = p.Character:FindFirstChild(handName)
				if hand and hand:IsA("Model") then
					for _, item in ipairs(hand:GetDescendants()) do
						if item:IsA("BasePart") then
							item.CanCollide = not nocliphand
						end
					end
				end
			end
		end
	end
end)

local weldtohand = false
local handWeld = nil
weldtohands.Name = "weldtohands"
weldtohands.Parent = pg1
weldtohands.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
weldtohands.BorderSizePixel = 0
weldtohands.Position = UDim2.new(0.0320000015, 0, 0.668587923, 0)
weldtohands.Size = UDim2.new(0, 350, 0, 50)
weldtohands.Font = Enum.Font.Gotham
weldtohands.Text = "Weld to a VR Players hand"
weldtohands.TextColor3 = Color3.fromRGB(255, 255, 255)
weldtohands.TextScaled = true
weldtohands.TextSize = 14.000
weldtohands.TextWrapped = true
weldtohands.MouseButton1Down:Connect(function()
	local localChar = Players.LocalPlayer.Character
	local hrp = localChar and localChar:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	if not weldtohand then
		local targetPlayer = selectedPlayer
		if not targetPlayer or targetPlayer.Parent == nil then
			local typedText = vrName.Text:lower()
			for _, p in ipairs(Players:GetPlayers()) do
				if p.Name:lower() == typedText or p.DisplayName:lower() == typedText then
					targetPlayer = p
					break
				end
			end
		end

		local handPart = getVRHandPart(targetPlayer)

		if handPart then
			weldtohand = true
			handWeld = Instance.new("Weld")
			handWeld.Part0 = hrp
			handWeld.Part1 = handPart
			handWeld.Parent = hrp
			weldtohands.Text = "Remove weld"
		else
			weldtohands.Text = "No VR player hand detected!"
			task.wait(1.5)
			weldtohands.Text = "Weld to a VR Players hand"
		end
	else
		weldtohands.Text = "Weld to a VR Players hand"
		if handWeld then
			handWeld:Destroy()
			handWeld = nil
		end
		weldtohand = false
	end
end)

local removedprops = false
remprops.Name = "remprops"
remprops.Parent = pg1
remprops.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
remprops.BorderSizePixel = 0
remprops.Position = UDim2.new(0.0320000015, 0, 0.829971194, 0)
remprops.Size = UDim2.new(0, 350, 0, 50)
remprops.Font = Enum.Font.Gotham
remprops.Text = "Remove props"
remprops.TextColor3 = Color3.fromRGB(255, 255, 255)
remprops.TextScaled = true
remprops.TextSize = 14.000
remprops.TextWrapped = true
remprops.MouseButton1Down:Connect(function()
	if not removedprops then
		local props = workspace:FindFirstChild("Props")
		if props then
			removedprops = true
			props.Parent = Lighting
			remprops.Text = "Add props"
		end
	else
		local props = Lighting:FindFirstChild("Props")
		if props then
			removedprops = false
			props.Parent = workspace
			remprops.Text = "Remove props"
		end
	end
end)

nextp.Name = "next"
nextp.Parent = Main
nextp.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
nextp.BackgroundTransparency = 1.000
nextp.Position = UDim2.new(0.901333332, 0, 0.91534394, 0)
nextp.Size = UDim2.new(0, 37, 0, 32)
nextp.Font = Enum.Font.SourceSans
nextp.Text = ">"
nextp.TextColor3 = Color3.fromRGB(255, 255, 255)
nextp.TextScaled = true
nextp.TextSize = 14.000
nextp.TextWrapped = true
nextp.MouseButton1Down:Connect(function()
	pg1.Visible = false
	pg2.Visible = true
end)

prev.Name = "prev"
prev.Parent = Main
prev.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
prev.BackgroundTransparency = 1.000
prev.Position = UDim2.new(0, 0, 0.91534394, 0)
prev.Size = UDim2.new(0, 37, 0, 32)
prev.Font = Enum.Font.SourceSans
prev.Text = "<"
prev.TextColor3 = Color3.fromRGB(255, 255, 255)
prev.TextScaled = true
prev.TextSize = 14.000
prev.TextWrapped = true
prev.MouseButton1Down:Connect(function()
	pg1.Visible = true
	pg2.Visible = false
end)

page.Name = "page"
page.Parent = Main
page.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
page.BackgroundTransparency = 1.000
page.Position = UDim2.new(0.0986666679, 0, 0.916715264, 0)
page.Size = UDim2.new(0, 301, 0, 31)
page.Font = Enum.Font.Gotham
page.Text = "v.1.1.0 - IsaaaKK"
page.TextColor3 = Color3.fromRGB(255, 255, 255)
page.TextScaled = true
page.TextSize = 14.000
page.TextWrapped = true

pg2.Name = "pg2"
pg2.Parent = Main
pg2.BackgroundColor3 = Color3.fromRGB(153, 11, 11)
pg2.BorderSizePixel = 0
pg2.Position = UDim2.new(0, 0, -0.00127414928, 0)
pg2.Size = UDim2.new(0, 375, 0, 347)
pg2.Visible = false

local propnoclip = false
noclipprops.Name = "noclipprops"
noclipprops.Parent = pg2
noclipprops.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
noclipprops.BorderSizePixel = 0
noclipprops.Position = UDim2.new(0.0320000015, 0, 0.0230547637, 0)
noclipprops.Size = UDim2.new(0, 350, 0, 50)
noclipprops.Font = Enum.Font.Gotham
noclipprops.Text = "Noclip Props"
noclipprops.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipprops.TextScaled = true
noclipprops.TextSize = 14.000
noclipprops.TextWrapped = true
noclipprops.MouseButton1Down:Connect(function()
	local props = workspace:FindFirstChild("Props")
	if props then
		propnoclip = not propnoclip
		noclipprops.Text = propnoclip and "Clip Props" or "Noclip Props"
		for _, item in ipairs(props:GetDescendants()) do
			if item:IsA("BasePart") then
				item.CanCollide = not propnoclip
			end
		end
	end
end)

local headnoclip = false
noclipheads.Name = "noclipheads"
noclipheads.Parent = pg2
noclipheads.BackgroundColor3 = Color3.fromRGB(218, 36, 36)
noclipheads.BorderSizePixel = 0
noclipheads.Position = UDim2.new(0.0320000015, 0, 0.187319919, 0)
noclipheads.Size = UDim2.new(0, 350, 0, 50)
noclipheads.Font = Enum.Font.Gotham
noclipheads.Text = "Noclip VR Heads"
noclipheads.TextColor3 = Color3.fromRGB(255, 255, 255)
noclipheads.TextScaled = true
noclipheads.TextSize = 14.000
noclipheads.TextWrapped = true
noclipheads.MouseButton1Down:Connect(function()
	headnoclip = not headnoclip
	noclipheads.Text = headnoclip and "Clip VR Heads" or "Noclip VR Heads"
	
	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		for _, playerFolder in ipairs(vrPlayersFolder:GetChildren()) do
			local vrHead = playerFolder:FindFirstChild("VRHead")
			if vrHead then
				for _, item in ipairs(vrHead:GetDescendants()) do
					if item:IsA("BasePart") then
						item.CanCollide = not headnoclip
					end
				end
			end
		end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			local vrHead = p.Character:FindFirstChild("VRHead")
			if vrHead and vrHead:IsA("Model") then
				for _, item in ipairs(vrHead:GetDescendants()) do
					if item:IsA("BasePart") then
						item.CanCollide = not headnoclip
					end
				end
			end
		end
	end
end)

TextLabel.Parent = Bar
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.Position = UDim2.new(-0.00232625334, 0, -0.000350952148, 0)
TextLabel.Size = UDim2.new(0, 302, 0, 35)
TextLabel.Font = Enum.Font.Gotham
TextLabel.Text = "VR Hands Trolling GUI"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true

close.Name = "close"
close.Parent = Bar
close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
close.BackgroundTransparency = 1.000
close.Position = UDim2.new(0.901333332, 0, 0, 0)
close.Size = UDim2.new(0, 37, 0, 34)
close.Font = Enum.Font.SourceSans
close.Text = "x"
close.TextColor3 = Color3.fromRGB(255, 255, 255)
close.TextScaled = true
close.TextSize = 14.000
close.TextWrapped = true
close.MouseButton1Down:Connect(function()
	if annoyConnection then annoyConnection:Disconnect() end
	if annoyPart then annoyPart:Destroy() end
	if handWeld then handWeld:Destroy() end
	if grabConnection then grabConnection:Disconnect() end
	if charAddedConnection then charAddedConnection:Disconnect() end
	bryh:Destroy()
end)

local minimized = false
mini.Name = "mini"
mini.Parent = Bar
mini.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mini.BackgroundTransparency = 1.000
mini.Position = UDim2.new(0.802666664, 0, -0.0285714287, 0)
mini.Size = UDim2.new(0, 37, 0, 34)
mini.Font = Enum.Font.SourceSans
mini.Text = "-"
mini.TextColor3 = Color3.fromRGB(255, 255, 255)
mini.TextScaled = true
mini.TextSize = 14.000
mini.TextWrapped = true
mini.MouseButton1Down:Connect(function()
	if minimized == false then
		minimized = true
		Main.Visible = false
		Shadow.Visible = false
	else
		minimized = false
		Main.Visible = true
		Shadow.Visible = true
	end
end)

Shadow.Name = "Shadow"
Shadow.Parent = Bar
Shadow.BackgroundColor3 = Color3.fromRGB(34, 2, 2)
Shadow.BackgroundTransparency = 0.500
Shadow.BorderSizePixel = 0
Shadow.Position = UDim2.new(0.0320000015, 0, 0.224789754, 0)
Shadow.Size = UDim2.new(0, 374, 0, 418)
Shadow.ZIndex = 0
