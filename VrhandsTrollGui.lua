local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local AVOID_DISTANCE = 14
local AVOID_PUSH_SPEED = 1.8

local bryh = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local close = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local TargetSection = Instance.new("Frame")
local vrName = Instance.new("TextBox")
local refreshBtn = Instance.new("TextButton")
local dropdown = Instance.new("ScrollingFrame")
local TogglesContainer = Instance.new("ScrollingFrame")
local Shadow = Instance.new("Frame")

-- Handle GUI location dynamically based on executor support
bryh.Name = "NovolineVR"
bryh.Parent = game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
bryh.ResetOnSpawn = false

-- Main Frame Styling
MainFrame.Name = "MainFrame"
MainFrame.Parent = bryh
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -220)
MainFrame.Size = UDim2.new(0, 380, 0, 440)
MainFrame.ClipsDescendants = true

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(0, 180, 255)
mainStroke.Thickness = 1.5
mainStroke.Parent = MainFrame

-- Top Bar Styling
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 40)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 10)
topBarCorner.Parent = TopBar

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1.000
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Novoline // VR Hands"
TitleLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
TitleLabel.TextSize = 14.000
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

close.Name = "close"
close.Parent = TopBar
close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
close.BackgroundTransparency = 1.000
close.Position = UDim2.new(1, -35, 0, 0)
close.Size = UDim2.new(0, 35, 1, 0)
close.Font = Enum.Font.GothamMedium
close.Text = "×"
close.TextColor3 = Color3.fromRGB(150, 150, 150)
close.TextSize = 22.000

mini.Name = "mini"
mini.Parent = TopBar
mini.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mini.BackgroundTransparency = 1.000
mini.Position = UDim2.new(1, -70, 0, 0)
mini.Size = UDim2.new(0, 35, 1, 0)
mini.Font = Enum.Font.GothamMedium
mini.Text = "–"
mini.TextColor3 = Color3.fromRGB(150, 150, 150)
mini.TextSize = 18.000

-- Target Selection Panel
TargetSection.Name = "TargetSection"
TargetSection.Parent = MainFrame
TargetSection.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
TargetSection.BorderSizePixel = 0
TargetSection.Position = UDim2.new(0, 0, 0, 40)
TargetSection.Size = UDim2.new(1, 0, 0, 60)

vrName.Name = "vrName"
vrName.Parent = TargetSection
vrName.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
vrName.BorderSizePixel = 0
vrName.Position = UDim2.new(0.04, 0, 0.5, -18)
vrName.Size = UDim2.new(0, 290, 0, 36)
vrName.Font = Enum.Font.GothamSemibold
vrName.PlaceholderText = "Search VR Player..."
vrName.Text = ""
vrName.TextColor3 = Color3.fromRGB(255, 255, 255)
vrName.TextSize = 12.000
vrName.TextXAlignment = Enum.TextXAlignment.Left

local vrNameCorner = Instance.new("UICorner")
vrNameCorner.CornerRadius = UDim.new(0, 6)
vrNameCorner.Parent = vrName

local vrNamePadding = Instance.new("UIPadding")
vrNamePadding.PaddingLeft = UDim.new(0, 10)
vrNamePadding.Parent = vrName

refreshBtn.Name = "refreshBtn"
refreshBtn.Parent = TargetSection
refreshBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
refreshBtn.BackgroundTransparency = 1.000
refreshBtn.Position = UDim2.new(1, -50, 0.5, -18)
refreshBtn.Size = UDim2.new(0, 36, 0, 36)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
refreshBtn.TextSize = 14.000

-- Player Search Dropdown
dropdown.Name = "PlayerDropdown"
dropdown.Parent = MainFrame
dropdown.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
dropdown.BorderSizePixel = 0
dropdown.Position = UDim2.new(0.04, 0, 0, 96)
dropdown.Size = UDim2.new(0, 350, 0, 150)
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 4
dropdown.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
dropdown.Visible = false
dropdown.ZIndex = 100

local dropdownCorner = Instance.new("UICorner")
dropdownCorner.CornerRadius = UDim.new(0, 6)
dropdownCorner.Parent = dropdown

local dropdownStroke = Instance.new("UIStroke")
dropdownStroke.Color = Color3.fromRGB(45, 45, 45)
dropdownStroke.Thickness = 1
dropdownStroke.Parent = dropdown

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Parent = dropdown
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Scrolling Toggles Container
TogglesContainer.Name = "TogglesContainer"
TogglesContainer.Parent = MainFrame
TogglesContainer.Active = true
TogglesContainer.BackgroundTransparency = 1.000
TogglesContainer.BorderSizePixel = 0
TogglesContainer.Position = UDim2.new(0, 10, 0, 105)
TogglesContainer.Size = UDim2.new(1, -20, 1, -115)
TogglesContainer.CanvasSize = UDim2.new(0, 0, 0, 570) -- Expanded canvas size to fit all 11 options
TogglesContainer.ScrollBarThickness = 4
TogglesContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 180, 255)
TogglesContainer.ScrollBarImageTransparency = 0.6

local toggleListLayout = Instance.new("UIListLayout")
toggleListLayout.Parent = TogglesContainer
toggleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
toggleListLayout.Padding = UDim.new(0, 6)

-- Dragging GUI Connection
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

TopBar.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		updateDrag(input)
	end
end)

-- Minimize/Maximize Animation
local minimized = false
local originalHeight = 440
mini.MouseButton1Down:Connect(function()
	minimized = not minimized
	local targetHeight = minimized and 40 or originalHeight
	
	MainFrame:TweenSize(
		UDim2.new(0, 380, 0, targetHeight),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quart,
		0.3,
		true,
		function()
			if minimized then
				TogglesContainer.Visible = false
				TargetSection.Visible = false
				dropdown.Visible = false
			else
				TogglesContainer.Visible = true
				TargetSection.Visible = true
			end
		end
	)
	
	if not minimized then
		TogglesContainer.Visible = true
		TargetSection.Visible = true
	end
end)

-- Target Handling Helper Functions
local selectedPlayer = nil

local function getActiveTarget()
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
	return targetPlayer
end

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

-- Dropdown Logic
local function updateDropdown()
	for _, child in ipairs(dropdown:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local searchText = vrName.Text:lower()
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
				btn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
				btn.BorderSizePixel = 0
				btn.Font = Enum.Font.Gotham
				btn.TextColor3 = Color3.fromRGB(220, 220, 220)
				btn.Text = "  " .. p.DisplayName .. " (@" .. p.Name .. ")"
				btn.TextSize = 11
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.ZIndex = 101
				btn.Parent = dropdown

				local btnCorner = Instance.new("UICorner")
				btnCorner.CornerRadius = UDim.new(0, 4)
				btnCorner.Parent = btn

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

refreshBtn.MouseButton1Down:Connect(updateDropdown)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		task.wait(0.15)
		if not vrName:IsFocused() then dropdown.Visible = false end
	end
end)

-- Reusable Toggle Factory Component
local function createToggle(name, text, onClickCallback)
	local frame = Instance.new("Frame")
	frame.Name = name .. "_Toggle"
	frame.Size = UDim2.new(1, -10, 0, 45)
	frame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	frame.BorderSizePixel = 0
	frame.Parent = TogglesContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(35, 35, 35)
	stroke.Thickness = 1
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.Text = text
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.2, 0, 0.6, 0)
	btn.Position = UDim2.new(0.75, 0, 0.2, 0)
	btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	btn.Font = Enum.Font.GothamBold
	btn.Text = "OFF"
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.TextSize = 10
	btn.Parent = frame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = btn

	local state = false
	btn.MouseButton1Down:Connect(function()
		state = not state
		if state then
			btn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Text = "ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			btn.TextColor3 = Color3.fromRGB(150, 150, 150)
			btn.Text = "OFF"
		end
		onClickCallback(state)
	end)

	local function setUIState(forceState)
		state = forceState
		if state then
			btn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.Text = "ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			btn.TextColor3 = Color3.fromRGB(150, 150, 150)
			btn.Text = "OFF"
		end
	end

	return frame, setUIState
end

-- ==========================================================
-- Feature Functionality & Handlers
-- ==========================================================

-- 1. Annoy Player Handler
local annoying = false
local annoyConnection = nil
local annoyPart = nil

local _, setAnnoyUI = createToggle("Annoy", "Annoy Target Player", function(state)
	if state then
		local targetPlayer = getActiveTarget()
		local realHead = getVRHeadPart(targetPlayer)
		local character = Players.LocalPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")

		if realHead and hrp then
			annoying = true
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
					setAnnoyUI(false)
					if annoyConnection then annoyConnection:Disconnect() annoyConnection = nil end
					if annoyPart then annoyPart:Destroy() annoyPart = nil end
				end
			end)
		else
			setAnnoyUI(false)
		end
	else
		annoying = false
		if annoyConnection then annoyConnection:Disconnect() annoyConnection = nil end
		if annoyPart then annoyPart:Destroy() annoyPart = nil end
	end
end)

-- 2. Anti Grab (LetMeGo method) Handler
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
		if pinchRemote then pinchRemote:FireServer() end
	end
end

local function setupCharConnections(character)
	if grabConnection then grabConnection:Disconnect() grabConnection = nil end
	if not character then return end
	
	checkAndRelease(character)
	grabConnection = character:GetAttributeChangedSignal("Grabbed"):Connect(function()
		checkAndRelease(character)
	end)
end

createToggle("AntiGrab", "Anti-Grab (Active Breakfree)", function(state)
	antiGrabEnabled = state
	if state then
		local char = Players.LocalPlayer.Character
		setupCharConnections(char)
		if not charAddedConnection then
			charAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(function(chara)
				setupCharConnections(chara)
			end)
		end
	else
		if grabConnection then grabConnection:Disconnect() grabConnection = nil end
		if charAddedConnection then charAddedConnection:Disconnect() charAddedConnection = nil end
	end
end)

-- 3. Noclip VR Hands Handler
local nocliphand = false
createToggle("NoclipHands", "Noclip VR Hands", function(state)
	nocliphand = state
	
	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		for _, playerFolder in ipairs(vrPlayersFolder:GetChildren()) do
			for _, handName in ipairs({"RightHand", "LeftHand"}) do
				local hand = playerFolder:FindFirstChild(handName)
				if hand then
					for _, item in ipairs(hand:GetDescendants()) do
						if item:IsA("BasePart") then item.CanCollide = not nocliphand end
					end
				end
			end
		end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			for _, handName in ipairs({"RightHand", "LeftHand"}) do
				local hand = p.Character:FindFirstChild("RightHand") or p.Character:FindFirstChild("LeftHand")
				if hand and hand:IsA("Model") then
					for _, item in ipairs(hand:GetDescendants()) do
						if item:IsA("BasePart") then item.CanCollide = not nocliphand end
					end
				end
			end
		end
	end
end)

-- 4. Weld to Hand (Replicating CFrame Method) Handler
local weldConnection = nil
local _, setWeldUI = createToggle("WeldHand", "FE Weld to VR Hand", function(state)
	if state then
		local targetPlayer = getActiveTarget()
		local handPart = getVRHandPart(targetPlayer)
		local character = Players.LocalPlayer.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")

		if handPart and hrp then
			weldConnection = RunService.RenderStepped:Connect(function()
				if handPart and hrp and character and character.Parent then
					hrp.CFrame = handPart.CFrame
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
				else
					setWeldUI(false)
					if weldConnection then weldConnection:Disconnect() weldConnection = nil end
				end
			end)
		else
			setWeldUI(false)
		end
	else
		if weldConnection then weldConnection:Disconnect() weldConnection = nil end
	end
end)

-- 5. Avoid Target Hand Handler
local avoidTargetEnabled = false
local avoidTargetConnection = nil

local function handleAvoidTarget()
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local targetPlayer = getActiveTarget()
	if targetPlayer then
		local hands = {}
		local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
		if vrPlayersFolder then
			local playerFolder = vrPlayersFolder:FindFirstChild(tostring(targetPlayer.UserId))
			if playerFolder then
				local lh = playerFolder:FindFirstChild("LeftHand")
				local rh = playerFolder:FindFirstChild("RightHand")
				if lh then table.insert(hands, lh:FindFirstChild("ControllerPart") or lh:FindFirstChildOfClass("BasePart")) end
				if rh then table.insert(hands, rh:FindFirstChild("ControllerPart") or rh:FindFirstChildOfClass("BasePart")) end
			end
		end
		
		if #hands == 0 and targetPlayer.Character then
			local lh = targetPlayer.Character:FindFirstChild("LeftHand")
			local rh = targetPlayer.Character:FindFirstChild("RightHand")
			if lh then table.insert(hands, lh:FindFirstChild("ControllerPart") or lh:FindFirstChildOfClass("BasePart")) end
			if rh then table.insert(hands, rh:FindFirstChild("ControllerPart") or rh:FindFirstChildOfClass("BasePart")) end
		end

		for _, handPart in ipairs(hands) do
			if handPart then
				local dist = (hrp.Position - handPart.Position).Magnitude
				if dist < AVOID_DISTANCE then
					local dir = (hrp.Position - handPart.Position)
					local pushDir = Vector3.new(dir.X, 0, dir.Z).Unit
					if pushDir.Magnitude == 0 then pushDir = Vector3.new(1, 0, 0) end
					hrp.CFrame = hrp.CFrame + (pushDir * AVOID_PUSH_SPEED)
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
			end
		end
	end
end

createToggle("AvoidTarget", "Avoid Target VR Player's Hand", function(state)
	avoidTargetEnabled = state
	if state then
		if avoidTargetConnection then avoidTargetConnection:Disconnect() end
		avoidTargetConnection = RunService.RenderStepped:Connect(handleAvoidTarget)
	else
		if avoidTargetConnection then avoidTargetConnection:Disconnect() avoidTargetConnection = nil end
	end
end)

-- 6. Avoid All Hands Handler
local avoidAllEnabled = false
local avoidAllConnection = nil

local function handleAvoidAll()
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		for _, playerFolder in ipairs(vrPlayersFolder:GetChildren()) do
			if playerFolder.Name ~= tostring(Players.LocalPlayer.UserId) then
				for _, handName in ipairs({"LeftHand", "RightHand"}) do
					local hand = playerFolder:FindFirstChild(handName)
					local handPart = hand and (hand:FindFirstChild("ControllerPart") or hand:FindFirstChildOfClass("BasePart"))
					if handPart then
						local dist = (hrp.Position - handPart.Position).Magnitude
						if dist < AVOID_DISTANCE then
							local dir = (hrp.Position - handPart.Position)
							local pushDir = Vector3.new(dir.X, 0, dir.Z).Unit
							if pushDir.Magnitude == 0 then pushDir = Vector3.new(1, 0, 0) end
							hrp.CFrame = hrp.CFrame + (pushDir * AVOID_PUSH_SPEED)
							hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						end
					end
				end
			end
		end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			for _, handName in ipairs({"LeftHand", "RightHand"}) do
				local hand = p.Character:FindFirstChild(handName)
				if hand and hand:IsA("Model") then
					local handPart = hand:FindFirstChild("ControllerPart") or hand:FindFirstChildOfClass("BasePart")
					if handPart then
						local dist = (hrp.Position - handPart.Position).Magnitude
						if dist < AVOID_DISTANCE then
							local dir = (hrp.Position - handPart.Position)
							local pushDir = Vector3.new(dir.X, 0, dir.Z).Unit
							if pushDir.Magnitude == 0 then pushDir = Vector3.new(1, 0, 0) end
							hrp.CFrame = hrp.CFrame + (pushDir * AVOID_PUSH_SPEED)
							hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						end
					end
				end
			end
		end
	end
end

createToggle("AvoidAll", "Avoid All VR Players' Hands", function(state)
	avoidAllEnabled = state
	if state then
		if avoidAllConnection then avoidAllConnection:Disconnect() end
		avoidAllConnection = RunService.RenderStepped:Connect(handleAvoidAll)
	else
		if avoidAllConnection then avoidAllConnection:Disconnect() avoidAllConnection = nil end
	end
end)

-- 7. Remove Props Handler
local removedprops = false
createToggle("RemProps", "Remove Game Props", function(state)
	removedprops = state
	if removedprops then
		local props = workspace:FindFirstChild("Props")
		if props then props.Parent = Lighting end
	else
		local props = Lighting:FindFirstChild("Props")
		if props then props.Parent = workspace end
	end
end)

-- 8. Noclip Props Handler
local propnoclip = false
createToggle("NoclipProps", "Noclip Game Props", function(state)
	propnoclip = state
	local props = workspace:FindFirstChild("Props")
	if props then
		for _, item in ipairs(props:GetDescendants()) do
			if item:IsA("BasePart") then item.CanCollide = not propnoclip end
		end
	end
end)

-- 9. Noclip Heads Handler
local headnoclip = false
createToggle("NoclipHeads", "Noclip VR Heads", function(state)
	headnoclip = state
	
	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		for _, playerFolder in ipairs(vrPlayersFolder:GetChildren()) do
			local vrHead = playerFolder:FindFirstChild("VRHead")
			if vrHead then
				for _, item in ipairs(vrHead:GetDescendants()) do
					if item:IsA("BasePart") then item.CanCollide = not headnoclip end
				end
			end
		end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			local vrHead = p.Character:FindFirstChild("VRHead")
			if vrHead and vrHead:IsA("Model") then
				for _, item in ipairs(vrHead:GetDescendants()) do
					if item:IsA("BasePart") then item.CanCollide = not headnoclip end
				end
			end
		end
	end
end)

-- 10. Disable Pickup Handler (Humanoid Rename Fallback)
local pickup = true
createToggle("RenameHumanoid", "Disable Pickup (Lobby Rename)", function(state)
	local localChar = Players.LocalPlayer.Character
	if not localChar then return end
	pickup = not state

	if not pickup then
		local hum = localChar:FindFirstChildOfClass("Humanoid")
		if hum then hum.Name = "lol" end
	else
		local hum = localChar:FindFirstChild("lol")
		if hum then hum.Name = "Humanoid" end
	end
end)

-- 11. FE Air-Walk Handler (New Pop-up Sub-GUI Feature)
local airWalkEnabled = false
local platformPart = nil
local airWalkConnection = nil
local subGui = nil
local platformHeight = 0
local goingUp = false
local goingDown = false

local function disableAirWalk()
	goingUp = false
	goingDown = false
	if airWalkConnection then airWalkConnection:Disconnect() airWalkConnection = nil end
	if platformPart then platformPart:Destroy() platformPart = nil end
	if subGui then subGui:Destroy() subGui = nil end
	airWalkEnabled = false
end

local function enableAirWalk(setMainToggleUI)
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	airWalkEnabled = true
	platformHeight = hrp.Position.Y - 3.1

	-- Create Neon Cylinder Platform
	if platformPart then platformPart:Destroy() end
	platformPart = Instance.new("Part")
	platformPart.Name = "AirWalkPlatform"
	platformPart.Shape = Enum.PartType.Cylinder
	platformPart.Size = Vector3.new(0.2, 8, 8)
	platformPart.Material = Enum.Material.Neon
	platformPart.Color = Color3.fromRGB(0, 180, 255)
	platformPart.Transparency = 0.5
	platformPart.Anchored = true
	platformPart.CanCollide = true
	platformPart.Parent = workspace

	-- Sub-GUI Construction
	if subGui then subGui:Destroy() end
	subGui = Instance.new("Frame")
	subGui.Name = "AirWalkControl"
	subGui.Parent = bryh
	subGui.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	subGui.BorderSizePixel = 0
	subGui.Size = UDim2.new(0, 110, 0, 145)
	subGui.Position = UDim2.new(1, -125, 0, 15) -- Default Top-Right

	local subCorner = Instance.new("UICorner")
	subCorner.CornerRadius = UDim.new(0, 8)
	subCorner.Parent = subGui

	local subStroke = Instance.new("UIStroke")
	subStroke.Color = Color3.fromRGB(0, 180, 255)
	subStroke.Thickness = 1.2
	subStroke.Parent = subGui

	local subLayout = Instance.new("UIListLayout")
	subLayout.Parent = subGui
	subLayout.SortOrder = Enum.SortOrder.LayoutOrder
	subLayout.Padding = UDim.new(0, 4)

	local subPadding = Instance.new("UIPadding")
	subPadding.PaddingTop = UDim.new(0, 6)
	subPadding.PaddingBottom = UDim.new(0, 6)
	subPadding.PaddingLeft = UDim.new(0, 6)
	subPadding.PaddingRight = UDim.new(0, 6)
	subPadding.Parent = subGui

	-- Cycle Location Button
	local posBtn = Instance.new("TextButton")
	posBtn.Size = UDim2.new(1, 0, 0, 26)
	posBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	posBtn.Font = Enum.Font.GothamBold
	posBtn.Text = "📍 CYCLE"
	posBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
	posBtn.TextSize = 10
	posBtn.Parent = subGui

	local posCorner = Instance.new("UICorner")
	posCorner.CornerRadius = UDim.new(0, 4)
	posCorner.Parent = posBtn

	local posIndex = 2 -- Default Top-Right
	local positions = {
		UDim2.new(0, 15, 0, 15),     -- TL
		UDim2.new(1, -125, 0, 15),   -- TR
		UDim2.new(0, 15, 1, -160),   -- BL
		UDim2.new(1, -125, 1, -160)  -- BR
	}

	posBtn.MouseButton1Down:Connect(function()
		posIndex = (posIndex % 4) + 1
		subGui.Position = positions[posIndex]
	end)

	-- Elevation UP Button
	local upBtn = Instance.new("TextButton")
	upBtn.Size = UDim2.new(1, 0, 0, 32)
	upBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	upBtn.Font = Enum.Font.GothamBold
	upBtn.Text = "▲ UP"
	upBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
	upBtn.TextSize = 12
	upBtn.Parent = subGui

	local upCorner = Instance.new("UICorner")
	upCorner.CornerRadius = UDim.new(0, 4)
	upCorner.Parent = upBtn

	-- Elevation DOWN Button
	local downBtn = Instance.new("TextButton")
	downBtn.Size = UDim2.new(1, 0, 0, 32)
	downBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	downBtn.Font = Enum.Font.GothamBold
	downBtn.Text = "▼ DOWN"
	downBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
	downBtn.TextSize = 12
	downBtn.Parent = subGui

	local downCorner = Instance.new("UICorner")
	downCorner.CornerRadius = UDim.new(0, 4)
	downCorner.Parent = downBtn

	-- Unexecute Button
	local unexecBtn = Instance.new("TextButton")
	unexecBtn.Size = UDim2.new(1, 0, 0, 26)
	unexecBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
	unexecBtn.Font = Enum.Font.GothamBold
	unexecBtn.Text = "❌ UNEXEC"
	unexecBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	unexecBtn.TextSize = 10
	unexecBtn.Parent = subGui

	local unexecCorner = Instance.new("UICorner")
	unexecCorner.CornerRadius = UDim.new(0, 4)
	unexecCorner.Parent = unexecBtn

	-- Setup input hold detections (Touch/Mobile Friendly)
	upBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			goingUp = true
		end
	end)
	upBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			goingUp = false
		end
	end)

	downBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			goingDown = true
		end
	end)
	downBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			goingDown = false
		end
	end)

	unexecBtn.MouseButton1Down:Connect(function()
		setMainToggleUI(false) -- Updates toggle menu state
		disableAirWalk()       -- Disables script and removes assets
	end)

	-- Heartbeat Loop: horizontally center platform directly below the player
	if airWalkConnection then airWalkConnection:Disconnect() end
	airWalkConnection = RunService.Heartbeat:Connect(function()
		local curChar = Players.LocalPlayer.Character
		local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
		if curHrp and platformPart then
			if goingUp then
				platformHeight = platformHeight + 0.35
				curHrp.CFrame = curHrp.CFrame + Vector3.new(0, 0.35, 0)
			elseif goingDown then
				platformHeight = platformHeight - 0.35
				curHrp.CFrame = curHrp.CFrame - Vector3.new(0, 0.35, 0)
			end
			-- Position horizontally beneath the character HRP
			platformPart.CFrame = CFrame.new(curHrp.Position.X, platformHeight, curHrp.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
		end
	end)
end

local _, setAirWalkUI = createToggle("AirWalk", "FE Air-Walk (Blue Circle)", function(state)
	if state then
		enableAirWalk(setAirWalkUI)
	else
		disableAirWalk()
	end
end)

-- Close Button Connection Cleanup
close.MouseButton1Down:Connect(function()
	if annoyConnection then annoyConnection:Disconnect() end
	if annoyPart then annoyPart:Destroy() end
	if handWeld then handWeld:Destroy() end
	if grabConnection then grabConnection:Disconnect() end
	if charAddedConnection then charAddedConnection:Disconnect() end
	if weldConnection then weldConnection:Disconnect() end
	if avoidTargetConnection then avoidTargetConnection:Disconnect() end
	if avoidAllConnection then avoidAllConnection:Disconnect() end
	disableAirWalk()
	bryh:Destroy()
end)
