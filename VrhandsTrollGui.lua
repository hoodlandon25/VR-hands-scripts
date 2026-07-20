local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Configuration
local AVOID_DISTANCE = 30 -- Safe distance barrier (in studs)
local SAFE_DISTANCE = 32 -- Repel snap boundary

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
close.Active = true

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
mini.Active = true

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
refreshBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
refreshBtn.BorderSizePixel = 0
refreshBtn.Position = UDim2.new(1, -50, 0.5, -18)
refreshBtn.Size = UDim2.new(0, 36, 0, 36)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
refreshBtn.TextSize = 14.000
refreshBtn.Active = true

local refreshCorner = Instance.new("UICorner")
refreshCorner.CornerRadius = UDim.new(0, 6)
refreshCorner.Parent = refreshBtn

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
TogglesContainer.CanvasSize = UDim2.new(0, 0, 0, 620)
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
mini.Activated:Connect(function()
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

local function getVRHandModel(targetPlayer, handName)
	if not targetPlayer then return nil end
	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		local playerFolder = vrPlayersFolder:FindFirstChild(tostring(targetPlayer.UserId))
		if playerFolder then
			return playerFolder:FindFirstChild(handName)
		end
	end
	local char = targetPlayer.Character
	if char then
		return char:FindFirstChild(handName)
	end
	return nil
end

local function getVRHandPart(targetPlayer)
	local handModel = getVRHandModel(targetPlayer, "RightHand")
	if handModel then
		return handModel:FindFirstChild("ControllerPart") or handModel:FindFirstChild("Base") or handModel:FindFirstChildOfClass("BasePart")
	end
	return nil
end

-- Scans a VR Hand model and returns the part physically closest to your character (used for accurate finger-tip avoidance)
local function getClosestHandPart(handModel, characterHrp)
	if not handModel or not characterHrp then return nil, math.huge end
	local closestPart = nil
	local minDistance = math.huge
	for _, part in ipairs(handModel:GetDescendants()) do
		if part:IsA("BasePart") then
			local dist = (characterHrp.Position - part.Position).Magnitude
			if dist < minDistance then
				minDistance = dist
				closestPart = part
			end
		end
	end
	return closestPart, minDistance
end

-- Resets your character's collisions and touch triggers back to default
local function restoreCharacterCollisions()
	local char = Players.LocalPlayer.Character
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Name ~= "HumanoidRootPart" then
				part.CanCollide = true
			end
			part.CanTouch = true
		end
	end
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
				btn.Active = true

				local btnCorner = Instance.new("UICorner")
				btnCorner.CornerRadius = UDim.new(0, 4)
				btnCorner.Parent = btn

				btn.Activated:Connect(function()
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

refreshBtn.Activated:Connect(updateDropdown)

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
	btn.Active = true

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = btn

	local state = false
	btn.Activated:Connect(function()
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

-- Client-Side TouchInterest Destroyer (prevents fast touch grabbing)
local touchInterestConnection = nil
local function startTouchInterestDestroyer()
	if touchInterestConnection then return end
	touchInterestConnection = RunService.Heartbeat:Connect(function()
		local char = Players.LocalPlayer.Character
		if char then
			for _, child in ipairs(char:GetDescendants()) do
				if child:IsA("TouchTransmitter") or child.Name == "TouchInterest" then
					child:Destroy()
				end
			end
		end
	end)
end

local function stopTouchInterestDestroyer()
	if touchInterestConnection then
		touchInterestConnection:Disconnect()
		touchInterestConnection = nil
	end
end

-- Activates / Deactivates the touchinterest loop depending on toggled actions
local function updateTouchInterestDestroyerState()
	if antiGrabEnabled or avoidTargetEnabled or avoidAllEnabled then
		startTouchInterestDestroyer()
	else
		stopTouchInterestDestroyer()
	end
end

-- Client-Side Joint Destroyer (instantly cuts grabs by deleting target welds before they desync)
local jointConnection = nil
local function startJointDestroyer()
	if jointConnection then return end
	jointConnection = RunService.Heartbeat:Connect(function()
		local char = Players.LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					-- Scan legacy joints (Weld, Motor6D, etc.)
					for _, joint in ipairs(part:GetJoints()) do
						local otherPart = (joint.Part0 == part) and joint.Part1 or joint.Part0
						if otherPart and not otherPart:IsDescendantOf(char) then
							joint:Destroy()
						end
					end
					-- Scan WeldConstraints
					for _, child in ipairs(part:GetChildren()) do
						if child:IsA("WeldConstraint") then
							local otherPart = (child.Part0 == part) and child.Part1 or child.Part0
							if otherPart and not otherPart:IsDescendantOf(char) then
								child:Destroy()
							end
						end
					end
				end
			end
		end
	end)
end

local function stopJointDestroyer()
	if jointConnection then
		jointConnection:Disconnect()
		jointConnection = nil
	end
end

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
		-- Destroys existing welds to prevent dragging
		for _, part in ipairs(character:GetChildren()) do
			if part:IsA("BasePart") then
				for _, joint in ipairs(part:GetJoints()) do
					local otherPart = (joint.Part0 == part) and joint.Part1 or joint.Part0
					if otherPart and not otherPart:IsDescendantOf(character) then
						joint:Destroy()
					end
				end
			end
		end
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
	updateTouchInterestDestroyerState()
	if state then
		local char = Players.LocalPlayer.Character
		setupCharConnections(char)
		startJointDestroyer() -- Launches background joint cutter
		if not charAddedConnection then
			charAddedConnection = Players.LocalPlayer.CharacterAdded:Connect(function(chara)
				setupCharConnections(chara)
			end)
		end
	else
		stopJointDestroyer()
		if grabConnection then grabConnection:Disconnect() grabConnection = nil end
		if charAddedConnection then charAddedConnection:Disconnect() charAddedConnection = nil end
		restoreCharacterCollisions()
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

-- 4. Weld to Hand (Physics Constraint-Based FE Weld) Handler
local localAttachment = nil
local targetAttachment = nil
local alignPos = nil
local alignRot = nil

local _, setWeldUI = createToggle("WeldHand", "FE Weld to VR Hand", function(state)
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if state then
		local targetPlayer = getActiveTarget()
		local handPart = getVRHandPart(targetPlayer)

		if handPart and hrp and hum then
			if alignPos then alignPos:Destroy() end
			if alignRot then alignRot:Destroy() end
			if localAttachment then localAttachment:Destroy() end
			if targetAttachment then targetAttachment:Destroy() end

			localAttachment = Instance.new("Attachment")
			localAttachment.Name = "NovolineWeldLocal"
			localAttachment.Parent = hrp

			targetAttachment = Instance.new("Attachment")
			targetAttachment.Name = "NovolineWeldTarget"
			targetAttachment.Parent = handPart

			alignPos = Instance.new("AlignPosition")
			alignPos.Name = "NovolineAlignPos"
			alignPos.Mode = Enum.PositionAlignmentMode.TwoAttachment
			alignPos.Attachment0 = localAttachment
			alignPos.Attachment1 = targetAttachment
			alignPos.MaxForce = 10000000
			alignPos.Responsiveness = 200
			alignPos.Parent = hrp

			alignRot = Instance.new("AlignOrientation")
			alignRot.Name = "NovolineAlignRot"
			alignRot.Mode = Enum.OrientationAlignmentMode.TwoAttachment
			alignRot.Attachment0 = localAttachment
			alignRot.Attachment1 = targetAttachment
			alignRot.MaxTorque = 10000000
			alignRot.Responsiveness = 200
			alignRot.Parent = hrp

			hum.PlatformStand = true
		else
			setWeldUI(false)
		end
	else
		if alignPos then alignPos:Destroy() alignPos = nil end
		if alignRot then alignRot:Destroy() alignRot = nil end
		if localAttachment then localAttachment:Destroy() localAttachment = nil end
		if targetAttachment then targetAttachment:Destroy() targetAttachment = nil end
		if hum then hum.PlatformStand = false end
	end
end)

-- 5. Avoid Target Hand Handler (Snap Safe-Zone + Ghost Bypass)
local avoidTargetConnection = nil

local function handleAvoidTarget()
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local targetPlayer = getActiveTarget()
	if targetPlayer then
		local handModels = {}
		local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
		if vrPlayersFolder then
			local playerFolder = vrPlayersFolder:FindFirstChild(tostring(targetPlayer.UserId))
			if playerFolder then
				local lh = playerFolder:FindFirstChild("LeftHand")
				local rh = playerFolder:FindFirstChild("RightHand")
				if lh then table.insert(handModels, lh) end
				if rh then table.insert(handModels, rh) end
			end
		end
		
		if #handModels == 0 and targetPlayer.Character then
			local lh = targetPlayer.Character:FindFirstChild("LeftHand")
			local rh = targetPlayer.Character:FindFirstChild("RightHand")
			if lh then table.insert(handModels, lh) end
			if rh then table.insert(handModels, rh) end
		end

		local insideDangerZone = false

		for _, handModel in ipairs(handModels) do
			local closestPart, dist = getClosestHandPart(handModel, hrp)
			if closestPart and dist < AVOID_DISTANCE then
				insideDangerZone = true
				local dir = (hrp.Position - closestPart.Position)
				local pushDir = Vector3.new(dir.X, 0, dir.Z).Unit
				if pushDir.Magnitude == 0 then pushDir = Vector3.new(1, 0, 0) end
				
				-- Snaps your character out of range immediately. Linear velocity is reset to 0 to prevent flinging
				local safePos = Vector3.new(closestPart.Position.X, hrp.Position.Y, closestPart.Position.Z) + (pushDir * SAFE_DISTANCE)
				hrp.CFrame = CFrame.new(safePos)
				hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
		end

		-- Activates ghost-mode while in the threat area so grab touched-triggers fail to connect
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				if part.Name ~= "HumanoidRootPart" then
					part.CanCollide = not insideDangerZone
				end
				part.CanTouch = not insideDangerZone
			end
		end
	end
end

createToggle("AvoidTarget", "Avoid Target VR Player's Hand", function(state)
	avoidTargetEnabled = state
	updateTouchInterestDestroyerState()
	if state then
		if avoidTargetConnection then avoidTargetConnection:Disconnect() end
		avoidTargetConnection = RunService.RenderStepped:Connect(handleAvoidTarget)
	else
		if avoidTargetConnection then avoidTargetConnection:Disconnect() avoidTargetConnection = nil end
		restoreCharacterCollisions()
	end
end)

-- 6. Avoid All Hands Handler (Snap Safe-Zone + Ghost Bypass)
local avoidAllConnection = nil

local function handleAvoidAll()
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local handModels = {}

	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		for _, playerFolder in ipairs(vrPlayersFolder:GetChildren()) do
			if playerFolder.Name ~= tostring(Players.LocalPlayer.UserId) then
				local lh = playerFolder:FindFirstChild("LeftHand")
				local rh = playerFolder:FindFirstChild("RightHand")
				if lh then table.insert(handModels, lh) end
				if rh then table.insert(handModels, rh) end
			end
		end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= Players.LocalPlayer and p.Character then
			local lh = p.Character:FindFirstChild("LeftHand")
			local rh = p.Character:FindFirstChild("RightHand")
			if lh and lh:IsA("Model") then table.insert(handModels, lh) end
			if rh and rh:IsA("Model") then table.insert(handModels, rh) end
		end
	end

	local insideDangerZone = false

	for _, handModel in ipairs(handModels) do
		local closestPart, dist = getClosestHandPart(handModel, hrp)
		if closestPart and dist < AVOID_DISTANCE then
			insideDangerZone = true
			local dir = (hrp.Position - closestPart.Position)
			local pushDir = Vector3.new(dir.X, 0, dir.Z).Unit
			if pushDir.Magnitude == 0 then pushDir = Vector3.new(1, 0, 0) end
			
			local safePos = Vector3.new(closestPart.Position.X, hrp.Position.Y, closestPart.Position.Z) + (pushDir * SAFE_DISTANCE)
			hrp.CFrame = CFrame.new(safePos)
			hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		end
	end

	-- Activates ghost-mode while in the threat area so grab touched-triggers fail to connect
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Name ~= "HumanoidRootPart" then
				part.CanCollide = not insideDangerZone
			end
			part.CanTouch = not insideDangerZone
		end
	end
end

createToggle("AvoidAll", "Avoid All VR Players' Hands", function(state)
	avoidAllEnabled = state
	updateTouchInterestDestroyerState()
	if state then
		if avoidAllConnection then avoidAllConnection:Disconnect() end
		avoidAllConnection = RunService.RenderStepped:Connect(handleAvoidAll)
	else
		if avoidAllConnection then avoidAllConnection:Disconnect() avoidAllConnection = nil end
		restoreCharacterCollisions()
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

-- 11. FE Air-Walk Handler (Pop-up Sub-GUI Feature)
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
	posBtn.TextScaled = true
	posBtn.TextSize = 10
	posBtn.Parent = subGui
	posBtn.Active = true

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

	posBtn.Activated:Connect(function()
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
	upBtn.TextScaled = true
	upBtn.TextSize = 12
	upBtn.Parent = subGui
	upBtn.Active = true

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
	downBtn.TextScaled = true
	downBtn.TextSize = 12
	downBtn.Parent = subGui
	downBtn.Active = true

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
	unexecBtn.TextScaled = true
	unexecBtn.TextSize = 10
	unexecBtn.Parent = subGui
	unexecBtn.Active = true

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
	upBtn.MouseLeave:Connect(function()
		goingUp = false
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
	downBtn.MouseLeave:Connect(function()
		goingDown = false
	end)

	unexecBtn.Activated:Connect(function()
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

-- 12. Void Safety Platform Handler (Anti Void Death)
local voidFloorPart = nil
local voidFloorEnabled = false

createToggle("VoidSafety", "Void Safety Platform", function(state)
	voidFloorEnabled = state
	if state then
		if voidFloorPart then voidFloorPart:Destroy() end
		
		-- Raised to exactly -75 studs to capture character completely above the detected -105.6 server death barrier
		local safeY = -75
		
		voidFloorPart = Instance.new("Part")
		voidFloorPart.Name = "NovolineVoidSafetyFloor"
		voidFloorPart.Size = Vector3.new(4000, 5, 4000)
		voidFloorPart.Position = Vector3.new(0, safeY, 0)
		voidFloorPart.Material = Enum.Material.Glass
		voidFloorPart.Color = Color3.fromRGB(0, 100, 200)
		voidFloorPart.Transparency = 0.7
		voidFloorPart.Anchored = true
		voidFloorPart.CanCollide = true
		voidFloorPart.Parent = workspace
	else
		if voidFloorPart then
			voidFloorPart:Destroy()
			voidFloorPart = nil
		end
	end
end)

-- Close Button Connection Cleanup
close.Activated:Connect(function()
	if annoyConnection then annoyConnection:Disconnect() end
	if annoyPart then annoyPart:Destroy() end
	if handWeld then handWeld:Destroy() end
	if grabConnection then grabConnection:Disconnect() end
	if charAddedConnection then charAddedConnection:Disconnect() end
	if weldConnection then weldConnection:Disconnect() end
	if avoidTargetConnection then avoidTargetConnection:Disconnect() end
	if avoidAllConnection then avoidAllConnection:Disconnect() end
	
	-- Clean up physical weld elements
	if alignPos then alignPos:Destroy() end
	if alignRot then alignRot:Destroy() end
	if localAttachment then localAttachment:Destroy() end
	if targetAttachment then targetAttachment:Destroy() end
	local localChar = Players.LocalPlayer.Character
	local hum = localChar and localChar:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end

	disableAirWalk()
	stopTouchInterestDestroyer()
	stopJointDestroyer()
	restoreCharacterCollisions()
	
	if voidFloorPart then voidFloorPart:Destroy() end
	bryh:Destroy()
end)
