-- ==========================================================
-- Shared Cross-Client Admin Memory (Server-Wide)
-- ==========================================================
_G.R4HandsShared = _G.R4HandsShared or {}
_G.R4HandsShared.Blacklist = _G.R4HandsShared.Blacklist or {
	["Rizz-327_tom"] = { reason = "Initial test blacklist", expire = nil }
}
_G.R4HandsShared.Admins = _G.R4HandsShared.Admins or {
	["zxLostAngelxz"] = true,
	["Eysss427"] = true,
}
_G.R4HandsShared.Logs = _G.R4HandsShared.Logs or {}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Blacklist and Expiration Guard
local blacklistData = _G.R4HandsShared.Blacklist[localPlayer.Name] or _G.R4HandsShared.Blacklist[tostring(localPlayer.UserId)]
if blacklistData then
	if not blacklistData.expire or blacklistData.expire > os.time() then
		-- Prompt Cover Frame
		local screen = Instance.new("ScreenGui")
		screen.Name = "R4_Blacklisted"
		screen.ResetOnSpawn = false
		screen.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")

		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 1, 0)
		frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		frame.Parent = screen

		local container = Instance.new("Frame")
		container.Size = UDim2.new(0, 500, 0, 300)
		container.Position = UDim2.new(0.5, -250, 0.5, -150)
		container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		container.Parent = frame
		
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = container

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 50, 50)
		stroke.Thickness = 2
		stroke.Parent = container

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 50)
		title.Text = "🛑 EXECUTION BLOCKED"
		title.TextColor3 = Color3.fromRGB(255, 50, 50)
		title.Font = Enum.Font.GothamBold
		title.TextSize = 22
		title.BackgroundTransparency = 1
		title.Parent = container

		local msg = Instance.new("TextLabel")
		msg.Size = UDim2.new(1, -40, 1, -80)
		msg.Position = UDim2.new(0, 20, 0, 60)
		msg.BackgroundTransparency = 1
		msg.Font = Enum.Font.GothamMedium
		msg.TextSize = 14
		msg.TextColor3 = Color3.fromRGB(220, 220, 220)
		msg.TextWrapped = true
		
		local reasonText = blacklistData.reason or ""
		if reasonText == "" then
			msg.Text = "You have been blacklisted from this script.\n\nReason: You have abused this script or didn't listen to the mods when they told you to/not do somthing please take this as a warning you may be unblacklisted if you join the discord and send a request ticket"
		else
			msg.Text = "You have been blacklisted from this script.\n\nReason: " .. reasonText
		end
		msg.Parent = container
		return -- Immediately prevent loading the rest of the script
	end
end

-- ==========================================================
-- Core Execution Continues
-- ==========================================================
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Configuration
local AVOID_DISTANCE = 30
local SAFE_DISTANCE = 32
local ROBLOX_STAFF_GROUPS = {1200769, 3055661, 14593111, 12513722, 10279336, 6821794, 3253689}
local GAME_GROUP_ID = 6336

local cfg = {
	logo = "rbxassetid://121595097202790",
	barColor = Color3.fromRGB(90, 170, 255),
	adminColor = Color3.fromRGB(255, 60, 60),
}

-- Session Administrative State
local isAdmin = _G.R4HandsShared.Admins[localPlayer.Name] or false
local activeTab = "Main" -- Tracks whether viewing "Main" features or "Admin" features
local selectedPlayer = nil

-- Logs Setup
local function logExecution()
	local entry = _G.R4HandsShared.Logs[localPlayer.Name]
	if not entry then
		entry = {
			Name = localPlayer.Name,
			UserId = localPlayer.UserId,
			RunTimes = {},
			FeaturesUsed = {},
			ExternalScripts = {}
		}
		_G.R4HandsShared.Logs[localPlayer.Name] = entry
	end
	table.insert(entry.RunTimes, 1, os.date("%Y-%m-%d %H:%M:%S"))
end
logExecution()

-- Meta-Hook to detect HTTP script executions run after loading
local function logExternalScript(url)
	local entry = _G.R4HandsShared.Logs[localPlayer.Name]
	if entry then
		table.insert(entry.ExternalScripts, 1, {
			url = tostring(url),
			time = os.date("%Y-%m-%d %H:%M:%S")
		})
	end
end

-- Safely Hook Namecall/HttpGet without crashing standard executors
task.spawn(function()
	pcall(function()
		local mt = getrawmetatable(game)
		if mt and setreadonly then
			setreadonly(mt, false)
			local oldNamecall = mt.__namecall
			mt.__namecall = newcclosure(function(self, ...)
				local method = getnamecallmethod()
				if method == "HttpGet" or method == "HttpGetAsync" then
					local args = {...}
					if args[1] then
						logExternalScript(args[1])
					end
				end
				return oldNamecall(self, ...)
			end)
			setreadonly(mt, true)
		end
	end)
end)

local function logFeature(name)
	local entry = _G.R4HandsShared.Logs[localPlayer.Name]
	if entry then
		if not table.find(entry.FeaturesUsed, name) then
			table.insert(entry.FeaturesUsed, name)
		end
	end
end

-- Setup Master Screens
local bryh = Instance.new("ScreenGui")
bryh.Name = "R4HandsHub"
bryh.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")
bryh.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local close = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local adminToggleBtn = Instance.new("TextButton") 

-- Correct instantiation of input boxes/buttons
local vrName = Instance.new("TextBox") 
local refreshBtn = Instance.new("TextButton") 

-- UI Layout Configuration
local mainCorner = Instance.new("UICorner")
local mainStroke = Instance.new("UIStroke")
local dropdown = Instance.new("ScrollingFrame")
local TogglesContainer = Instance.new("ScrollingFrame")
local AdminContainer = Instance.new("ScrollingFrame") -- Unique container for Admins
local circleToggle = Instance.new("ImageButton")

-- Upvalues for connections and clean teardown
local handWeld, grabConnection, descConnection, charAddedConnection
local alignPos, alignRot, localAttachment, targetAttachment

-- Setup UI Containers
MainFrame.Name = "MainFrame"
MainFrame.Parent = bryh
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -220)
MainFrame.Size = UDim2.new(0, 380, 0, 440)
MainFrame.ClipsDescendants = true

mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

mainStroke.Color = cfg.barColor
mainStroke.Thickness = 1.5
mainStroke.Parent = MainFrame

-- Topbar
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 40)

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 10)
topBarCorner.Parent = TopBar

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1.000
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0.5, 0, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "&R4 Hideout // VR Hands"
TitleLabel.TextColor3 = cfg.barColor
TitleLabel.TextSize = 14.000
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

close.Name = "close"
close.Parent = TopBar
close.BackgroundTransparency = 1.000
close.Position = UDim2.new(1, -35, 0, 0)
close.Size = UDim2.new(0, 35, 1, 0)
close.Font = Enum.Font.GothamMedium
close.Text = "×"
close.TextColor3 = Color3.fromRGB(200, 230, 255)
close.TextSize = 22.000

mini.Name = "mini"
mini.Parent = TopBar
mini.BackgroundTransparency = 1.000
mini.Position = UDim2.new(1, -70, 0, 0)
mini.Size = UDim2.new(0, 35, 1, 0)
mini.Font = Enum.Font.GothamMedium
mini.Text = "–"
mini.TextColor3 = Color3.fromRGB(200, 230, 255)
mini.TextSize = 18.000

adminToggleBtn.Name = "adminToggleBtn"
adminToggleBtn.Parent = TopBar
adminToggleBtn.BackgroundTransparency = 1.000
adminToggleBtn.Position = UDim2.new(1, -115, 0, 0)
adminToggleBtn.Size = UDim2.new(0, 45, 1, 0)
adminToggleBtn.Font = Enum.Font.GothamBold
adminToggleBtn.Text = isAdmin and "🛡️" or "🔒"
adminToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
adminToggleBtn.TextSize = 14.000

-- Main Toggles View Setup
TogglesContainer.Name = "TogglesContainer"
TogglesContainer.Parent = MainFrame
TogglesContainer.Active = true
TogglesContainer.BackgroundTransparency = 1.000
TogglesContainer.BorderSizePixel = 0
TogglesContainer.Position = UDim2.new(0, 10, 0, 105)
TogglesContainer.Size = UDim2.new(1, -20, 1, -115)
TogglesContainer.CanvasSize = UDim2.new(0, 0, 0, 620)
TogglesContainer.ScrollBarThickness = 4
TogglesContainer.ScrollBarImageColor3 = cfg.barColor
TogglesContainer.Visible = true

local toggleListLayout = Instance.new("UIListLayout")
toggleListLayout.Parent = TogglesContainer
toggleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
toggleListLayout.Padding = UDim.new(0, 6)

-- Admin Controls Scroll View
AdminContainer.Name = "AdminContainer"
AdminContainer.Parent = MainFrame
AdminContainer.Active = true
AdminContainer.BackgroundTransparency = 1.000
AdminContainer.BorderSizePixel = 0
AdminContainer.Position = UDim2.new(0, 10, 0, 105)
AdminContainer.Size = UDim2.new(1, -20, 1, -115)
AdminContainer.CanvasSize = UDim2.new(0, 0, 0, 850)
AdminContainer.ScrollBarThickness = 4
AdminContainer.ScrollBarImageColor3 = cfg.adminColor
AdminContainer.Visible = false

local adminListLayout = Instance.new("UIListLayout")
adminListLayout.Parent = AdminContainer
adminListLayout.SortOrder = Enum.SortOrder.LayoutOrder
adminListLayout.Padding = UDim.new(0, 8)

-- Target Panel
local TargetSection = Instance.new("Frame")
TargetSection.Name = "TargetSection"
TargetSection.Parent = MainFrame
TargetSection.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
TargetSection.BackgroundTransparency = 0.3
TargetSection.BorderSizePixel = 0
TargetSection.Position = UDim2.new(0, 0, 0, 40)
TargetSection.Size = UDim2.new(1, 0, 0, 60)

local targetSectionStroke = Instance.new("UIStroke")
targetSectionStroke.Color = cfg.barColor
targetSectionStroke.Thickness = 1
targetSectionStroke.Transparency = 0.5
targetSectionStroke.Parent = TargetSection

vrName.Name = "vrName"
vrName.Parent = TargetSection
vrName.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
vrName.BackgroundTransparency = 0.3
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

local vrNameStroke = Instance.new("UIStroke")
vrNameStroke.Color = cfg.barColor
vrNameStroke.Thickness = 1
vrNameStroke.Transparency = 0.5
vrNameStroke.Parent = vrName

local vrNamePadding = Instance.new("UIPadding")
vrNamePadding.PaddingLeft = UDim.new(0, 10)
vrNamePadding.Parent = vrName

refreshBtn.Name = "refreshBtn"
refreshBtn.Parent = TargetSection
refreshBtn.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
refreshBtn.BorderSizePixel = 0
refreshBtn.Position = UDim2.new(1, -50, 0.5, -18)
refreshBtn.Size = UDim2.new(0, 36, 0, 36)
refreshBtn.Font = Enum.Font.GothamBold
refreshBtn.Text = "🔄"
refreshBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
refreshBtn.TextSize = 14.000

-- Circular Overlay Toggle
circleToggle.Name = "circleToggle"
circleToggle.Parent = bryh
circleToggle.Size = UDim2.new(0, 50, 0, 50)
circleToggle.Position = UDim2.new(0, 15, 0, 150)
circleToggle.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
circleToggle.Image = cfg.logo
circleToggle.ImageColor3 = cfg.barColor
circleToggle.Active = true

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circleToggle

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = cfg.barColor
circleStroke.Thickness = 1.5
circleStroke.Parent = circleToggle

-- Keypad Modal Structure
local KeypadModal = Instance.new("Frame")
local keyScreen = Instance.new("TextLabel")
local keyGrid = Instance.new("Frame")

KeypadModal.Name = "KeypadModal"
KeypadModal.Size = UDim2.new(0, 240, 0, 310)
KeypadModal.Position = UDim2.new(0.5, -120, 0.5, -155)
KeypadModal.BackgroundColor3 = Color3.fromRGB(15, 20, 35)
KeypadModal.BorderSizePixel = 0
KeypadModal.Visible = false
KeypadModal.Parent = bryh

local keypadCorner = Instance.new("UICorner")
keypadCorner.CornerRadius = UDim.new(0, 10)
keypadCorner.Parent = KeypadModal

local keypadStroke = Instance.new("UIStroke")
keypadStroke.Color = cfg.barColor
keypadStroke.Thickness = 2
keypadStroke.Parent = KeypadModal

keyScreen.Name = "keyScreen"
keyScreen.Size = UDim2.new(1, -20, 0, 45)
keyScreen.Position = UDim2.new(0, 10, 0, 15)
keyScreen.BackgroundColor3 = Color3.fromRGB(10, 12, 22)
keyScreen.Font = Enum.Font.Code
keyScreen.Text = ""
keyScreen.TextColor3 = Color3.fromRGB(255, 255, 255)
keyScreen.TextSize = 18
keyScreen.Parent = KeypadModal

local screenCorner = Instance.new("UICorner")
screenCorner.CornerRadius = UDim.new(0, 6)
screenCorner.Parent = keyScreen

keyGrid.Name = "keyGrid"
keyGrid.Size = UDim2.new(1, -20, 0, 220)
keyGrid.Position = UDim2.new(0, 10, 0, 75)
keyGrid.BackgroundTransparency = 1
keyGrid.Parent = KeypadModal

local keyGridLayout = Instance.new("UIGridLayout")
keyGridLayout.CellSize = UDim2.new(0, 65, 0, 45)
keyGridLayout.CellPadding = UDim2.new(0, 12, 0, 10)
keyGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
keyGridLayout.Parent = keyGrid

-- Dynamic Color Theme Transition
local function applyThemeTransition(targetColor, frameBg, topbarBg)
	TweenService:Create(mainStroke, TweenInfo.new(0.4), {Color = targetColor}):Play()
	TweenService:Create(circleStroke, TweenInfo.new(0.4), {Color = targetColor}):Play()
	TweenService:Create(circleToggle, TweenInfo.new(0.4), {ImageColor3 = targetColor}):Play()
	TweenService:Create(TitleLabel, TweenInfo.new(0.4), {TextColor3 = targetColor}):Play()
	TweenService:Create(MainFrame, TweenInfo.new(0.4), {BackgroundColor3 = frameBg}):Play()
	TweenService:Create(TopBar, TweenInfo.new(0.4), {BackgroundColor3 = topbarBg}):Play()
	targetSectionStroke.Color = targetColor
end

-- ==========================================================
-- Notification Handler
-- ==========================================================
local notifActive = {}
local function createNotification(title, content, length, iconId)
	local screen = Instance.new("ScreenGui")
	screen.Name = "NotifGui"
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 2147483647
	screen.Parent = game:GetService("CoreGui") or localPlayer:WaitForChild("PlayerGui")

	local scale = math.clamp(math.min(workspace.CurrentCamera.ViewportSize.X, workspace.CurrentCamera.ViewportSize.Y)/1366, 0.6, 1.6)
	local w = math.clamp(320*scale, 200, 520)
	local h = math.clamp(72*scale, 54, 140)

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, w, 0, h)
	main.Position = UDim2.new(1, -12, 1, -12-h-16)
	main.AnchorPoint = Vector2.new(1, 1)
	main.BackgroundColor3 = Color3.fromRGB(20, 40, 70)
	main.BorderSizePixel = 0
	main.Parent = screen

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = main

	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = isAdmin and cfg.adminColor or cfg.barColor
	mainStroke.Thickness = 1
	mainStroke.Transparency = 0.5
	mainStroke.Parent = main

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 4)
	bar.Position = UDim2.new(0, 0, 1, -4)
	bar.BackgroundColor3 = isAdmin and cfg.adminColor or cfg.barColor
	bar.BorderSizePixel = 0
	bar.ClipsDescendants = true
	bar.Parent = main

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 2)
	barCorner.Parent = bar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.BackgroundColor3 = isAdmin and cfg.adminColor or cfg.barColor
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, h, 1, 0)
	icon.Position = UDim2.new(0, 0, 0, 0)
	icon.BackgroundTransparency = 1
	icon.Image = iconId or cfg.logo
	icon.ImageColor3 = isAdmin and cfg.adminColor or cfg.barColor
	icon.ScaleType = Enum.ScaleType.Stretch
	icon.Parent = main

	local txt = Instance.new("TextLabel")
	txt.BackgroundTransparency = 1
	txt.Size = UDim2.new(1, -h-8, 0.4, 0)
	txt.Position = UDim2.new(0, h+8, 0, 0)
	txt.Font = Enum.Font.Code
	txt.TextSize = math.clamp(14*scale, 12, 20)
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.TextYAlignment = Enum.TextYAlignment.Top
	txt.TextColor3 = Color3.new(1, 1, 1)
	txt.Text = title
	txt.Parent = main

	local sub = Instance.new("TextLabel")
	sub.BackgroundTransparency = 1
	sub.Size = UDim2.new(1, -h-8, 0.5, 0)
	sub.Position = UDim2.new(0, h+8, 0.4, 0)
	sub.Font = Enum.Font.Code
	sub.TextSize = math.clamp(12*scale, 10, 16)
	sub.TextXAlignment = Enum.TextXAlignment.Left
	sub.TextYAlignment = Enum.TextYAlignment.Top
	sub.TextColor3 = Color3.fromRGB(200, 200, 200)
	sub.Text = content
	sub.TextWrapped = true
	sub.Parent = main

	local id = tostring(math.floor(tick()*1000)) .. "-" .. HttpService:GenerateGUID(false)
	table.insert(notifActive, {id = id, frame = main, sizeY = h})

	local function restack()
		local spacing = 8 * scale
		local yoff = 0
		for i = #notifActive, 1, -1 do
			local node = notifActive[i]
			if node and node.frame and node.frame.Parent then
				local target = -12 - yoff - node.sizeY
				TweenService:Create(node.frame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(1, -12, 1, target)}):Play()
				yoff = yoff + node.sizeY + spacing
			end
		end
	end

	restack()

	local function destroy()
		for i = 1, #notifActive do
			if notifActive[i].id == id then
				table.remove(notifActive, i)
				break
			end
		end
		TweenService:Create(main, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 16, main.Position.Y.Scale, main.Position.Y.Offset), BackgroundTransparency = 1}):Play()
		TweenService:Create(txt, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
		TweenService:Create(sub, TweenInfo.new(0.35), {TextTransparency = 1}):Play()
		TweenService:Create(icon, TweenInfo.new(0.35), {ImageTransparency = 1}):Play()
		task.wait(0.35)
		pcall(function() screen:Destroy() end)
		restack()
	end

	if length and length > 0 then
		TweenService:Create(fill, TweenInfo.new(length, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0, 0, 1, 0)}):Play()
		task.delay(length, destroy)
	end

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.ZIndex = 10
	btn.Parent = main
	btn.Activated:Connect(destroy)

	return {Close = destroy}
end

-- Interactive pulse effects for hovering
local function addHoverEffect(btn)
	local origColor = btn.BackgroundColor3
	btn.MouseEnter:Connect(function()
		local popColor = Color3.new(math.min(origColor.R*1.2,1), math.min(origColor.G*1.2,1), math.min(origColor.B*1.2,1))
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = popColor}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = origColor}):Play()
	end)
end

addHoverEffect(circleToggle)
addHoverEffect(refreshBtn)

-- Dragging GUI Connection with Viewport clamping
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
	local delta = input.Position - dragStart
	local camera = workspace.CurrentCamera
	local viewportSize = camera.ViewportSize
	
	local targetX = startPos.X + delta.X
	local targetY = startPos.Y + delta.Y
	
	local maxX = viewportSize.X - MainFrame.AbsoluteSize.X
	local maxY = viewportSize.Y - MainFrame.AbsoluteSize.Y
	
	targetX = math.clamp(targetX, 0, maxX)
	targetY = math.clamp(targetY, 0, maxY)
	
	MainFrame.Position = UDim2.new(0, targetX, 0, targetY)
end

TopBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.AbsolutePosition
		
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

circleToggle.Activated:Connect(function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- Player Dropdown UI
dropdown.Name = "PlayerDropdown"
dropdown.Parent = MainFrame
dropdown.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
dropdown.BorderSizePixel = 0
dropdown.Position = UDim2.new(0.04, 0, 0, 96)
dropdown.Size = UDim2.new(0, 350, 0, 150)
dropdown.CanvasSize = UDim2.new(0, 0, 0, 0)
dropdown.ScrollBarThickness = 4
dropdown.ScrollBarImageColor3 = cfg.barColor
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

-- Subtitles Frame
local SubtitleFrame = Instance.new("Frame")
local SubtitleLabel = Instance.new("TextLabel")

SubtitleFrame.Name = "SubtitleFrame"
SubtitleFrame.Parent = bryh
SubtitleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
SubtitleFrame.BackgroundTransparency = 0.4
SubtitleFrame.BorderSizePixel = 0
SubtitleFrame.Position = UDim2.new(0.5, -250, 1, -100)
SubtitleFrame.Size = UDim2.new(0, 500, 0, 60)
SubtitleFrame.Visible = false
SubtitleFrame.ZIndex = 150

local subCorner = Instance.new("UICorner")
subCorner.CornerRadius = UDim.new(0, 6)
subCorner.Parent = SubtitleFrame

local subStroke = Instance.new("UIStroke")
subStroke.Color = Color3.fromRGB(255, 50, 50)
subStroke.Thickness = 1
subStroke.Parent = SubtitleFrame

SubtitleLabel.Name = "SubtitleLabel"
SubtitleLabel.Parent = SubtitleFrame
SubtitleLabel.BackgroundTransparency = 1
SubtitleLabel.Size = UDim2.new(1, -16, 1, -16)
SubtitleLabel.Position = UDim2.new(0, 8, 0, 8)
SubtitleLabel.Font = Enum.Font.GothamMedium
SubtitleLabel.Text = ""
SubtitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SubtitleLabel.TextSize = 13
SubtitleLabel.TextWrapped = true

-- Spectate Menu Setup
local SpectateFrame = Instance.new("Frame")
local spectateTitle = Instance.new("TextLabel")
local firstPersonBtn = Instance.new("TextButton")
local thirdPersonBtn = Instance.new("TextButton")
local shiftlockBtn = Instance.new("TextButton")
local stopSpectateBtn = Instance.new("TextButton")

SpectateFrame.Name = "SpectateFrame"
SpectateFrame.Parent = bryh
SpectateFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
SpectateFrame.BorderSizePixel = 0
SpectateFrame.Position = UDim2.new(0, 15, 0.5, -80)
SpectateFrame.Size = UDim2.new(0, 130, 0, 160)
SpectateFrame.Visible = false
SpectateFrame.ZIndex = 80

local specCorner = Instance.new("UICorner")
specCorner.CornerRadius = UDim.new(0, 8)
specCorner.Parent = SpectateFrame

local specStroke = Instance.new("UIStroke")
specStroke.Color = cfg.barColor
specStroke.Thickness = 1.2
specStroke.Parent = SpectateFrame

local specLayout = Instance.new("UIListLayout")
specLayout.Parent = SpectateFrame
specLayout.SortOrder = Enum.SortOrder.LayoutOrder
specLayout.Padding = UDim.new(0, 4)

local specPadding = Instance.new("UIPadding")
specPadding.PaddingTop = UDim.new(0, 6)
specPadding.PaddingBottom = UDim.new(0, 6)
specPadding.PaddingLeft = UDim.new(0, 6)
specPadding.PaddingRight = UDim.new(0, 6)
specPadding.Parent = SpectateFrame

spectateTitle.Name = "Title"
spectateTitle.Parent = SpectateFrame
spectateTitle.BackgroundTransparency = 1
spectateTitle.Size = UDim2.new(1, 0, 0, 20)
spectateTitle.Font = Enum.Font.GothamBold
spectateTitle.Text = "SPECTATE"
spectateTitle.TextColor3 = cfg.barColor
spectateTitle.TextSize = 11

local function styleSpecBtn(btn, text)
	btn.Size = UDim2.new(1, 0, 0, 24)
	btn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	btn.Font = Enum.Font.GothamBold
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.TextSize = 10
	btn.Parent = SpectateFrame
	btn.Active = true
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 4)
	c.Parent = btn
	addHoverEffect(btn)
end

styleSpecBtn(firstPersonBtn, "1st Person")
styleSpecBtn(thirdPersonBtn, "3rd Person")
styleSpecBtn(shiftlockBtn, "Shiftlock: OFF")
styleSpecBtn(stopSpectateBtn, "❌ STOP")
stopSpectateBtn.TextColor3 = Color3.fromRGB(255, 100, 100)

-- Dropdown update logic
local function updateDropdown()
	for _, child in ipairs(dropdown:GetChildren()) do
		if child:IsA("TextButton") then child:Destroy() end
	end

	local searchText = vrName.Text:lower()
	local count = 0
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= localPlayer then
			local username = p.Name:lower()
			local displayname = p.DisplayName:lower()

			if searchText == "" or username:find(searchText, 1, true) or displayname:find(searchText, 1, true) then
				count = count + 1
				local btn = Instance.new("TextButton")
				btn.Name = p.Name
				btn.Size = UDim2.new(1, -6, 0, 30)
				btn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
				btn.BackgroundTransparency = 0.3
				btn.BorderSizePixel = 0
				btn.Font = Enum.Font.Gotham
				btn.TextColor3 = Color3.fromRGB(200, 230, 255)
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

-- Track all toggles globally
local activeFeatures = {}

local function disableAllFeatures()
	for name, feature in pairs(activeFeatures) do
		feature.setter(false)
		feature.callback(false)
	end
end

-- Reusable Toggle Factory Component
local function createToggle(name, text, onClickCallback)
	local frame = Instance.new("Frame")
	frame.Name = name .. "_Toggle"
	frame.Size = UDim2.new(1, -10, 0, 45)
	frame.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = TogglesContainer

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = cfg.barColor
	stroke.Thickness = 1
	stroke.Transparency = 0.7
	stroke.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 230, 255)
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.2, 0, 0.6, 0)
	btn.Position = UDim2.new(0.75, 0, 0.2, 0)
	btn.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
	btn.Font = Enum.Font.GothamBold
	btn.Text = "OFF"
	btn.TextColor3 = Color3.fromRGB(200, 230, 255)
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
			btn.BackgroundColor3 = isAdmin and cfg.adminColor or cfg.barColor
			btn.TextColor3 = Color3.fromRGB(20, 30, 50)
			btn.Text = "ON"
			createNotification("Enabled", text .. " has been activated.", 3)
			logFeature(text)
		else
			btn.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
			btn.TextColor3 = Color3.fromRGB(200, 230, 255)
			btn.Text = "OFF"
			createNotification("Disabled", text .. " has been deactivated.", 3)
		end
		onClickCallback(state)
	end)

	local function setUIState(forceState)
		state = forceState
		if state then
			btn.BackgroundColor3 = isAdmin and cfg.adminColor or cfg.barColor
			btn.TextColor3 = Color3.fromRGB(20, 30, 50)
			btn.Text = "ON"
		else
			btn.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
			btn.TextColor3 = Color3.fromRGB(200, 230, 255)
			btn.Text = "OFF"
		end
	end

	activeFeatures[name] = { setter = setUIState, callback = onClickCallback }
	return frame, setUIState
end

-- ==========================================================
-- Core VR Controls Functionality & Handlers
-- ==========================================================
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

local function restoreCharacterCollisions()
	local char = localPlayer.Character
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

-- TouchInterest loops
local touchInterestConnection = nil
local function startTouchInterestDestroyer()
	if touchInterestConnection then return end
	touchInterestConnection = RunService.Heartbeat:Connect(function()
		local char = localPlayer.Character
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

local function updateTouchInterestDestroyerState()
	if antiGrabEnabled or avoidTargetEnabled or avoidAllEnabled then
		startTouchInterestDestroyer()
	else
		stopTouchInterestDestroyer()
	end
end

-- Joint Destroyer
local jointConnection = nil
local function startJointDestroyer()
	if jointConnection then return end
	jointConnection = RunService.Heartbeat:Connect(function()
		local char = localPlayer.Character
		if char then
			for _, part in ipairs(char:GetChildren()) do
				if part:IsA("BasePart") then
					for _, joint in ipairs(part:GetJoints()) do
						local otherPart = (joint.Part0 == part) and joint.Part1 or joint.Part0
						if otherPart and not otherPart:IsDescendantOf(char) then
							joint:Destroy()
						end
					end
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

-- Feature: Annoy Target
local annoying = false
local annoyConnection = nil
local annoyPart = nil
local function toggleAnnoy(state)
	if state then
		local targetPlayer = getActiveTarget()
		local realHead = getVRHeadPart(targetPlayer)
		local character = localPlayer.Character
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
end
local _, setAnnoyUI = createToggle("Annoy", "Annoy Target Player", toggleAnnoy)

-- Feature: Anti Grab
local antiGrabConnections = {}
local function startUserAntiGrab()
	for _, conn in ipairs(antiGrabConnections) do
		if conn.Connected then conn:Disconnect() end
	end
	antiGrabConnections = {}

	local player = localPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local pinchRemote = ReplicatedStorage.COM.Pinch.LetMeGo

	local function onchar()
		if char:GetAttribute("Grabbed") then
			pinchRemote:FireServer()
		end
		local attrConn = char:GetAttributeChangedSignal("Grabbed"):Connect(function()
			if char:GetAttribute("Grabbed") then
				pinchRemote:FireServer()
			end
		end)
		table.insert(antiGrabConnections, attrConn)
	end
	onchar()
	
	local charAddedConn = player.CharacterAdded:Connect(function(chara)
		char = chara
		onchar()
	end)
	table.insert(antiGrabConnections, charAddedConn)

	task.spawn(function()
		while antiGrabEnabled do
			if pinchRemote then
				pinchRemote:FireServer()
			end
			task.wait(0.1)
		end
	end)
end

local function stopUserAntiGrab()
	for _, conn in ipairs(antiGrabConnections) do
		if conn.Connected then conn:Disconnect() end
	end
	antiGrabConnections = {}
end

local function toggleAntiGrab(state)
	antiGrabEnabled = state
	updateTouchInterestDestroyerState()
	if state then
		startUserAntiGrab()
	else
		stopUserAntiGrab()
	end
end
local _, setAntiGrabUI = createToggle("AntiGrab", "Anti-Grab (Active Breakfree)", toggleAntiGrab)

-- Feature: Noclip Hands
local nocliphand = false
local function toggleNoclipHands(state)
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
end
createToggle("NoclipHands", "Noclip VR Hands", toggleNoclipHands)

-- Feature: FE Weld to Hand
local weldConnection = nil
local function toggleFEWeld(state)
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if state then
		local targetPlayer = getActiveTarget()
		local handPart = getVRHandPart(targetPlayer)

		if handPart and hrp and hum then
			hum.PlatformStand = true
			if weldConnection then weldConnection:Disconnect() end
			weldConnection = RunService.Heartbeat:Connect(function()
				if handPart and handPart.Parent and hrp and char and char.Parent then
					hrp.CFrame = handPart.CFrame
					hrp.AssemblyLinearVelocity = handPart.AssemblyLinearVelocity
					hrp.AssemblyAngularVelocity = handPart.AssemblyAngularVelocity
				else
					setWeldUI(false)
					toggleFEWeld(false)
				end
			end)
		else
			setWeldUI(false)
		end
	else
		if weldConnection then weldConnection:Disconnect() weldConnection = nil end
		if hum then hum.PlatformStand = false end
	end
end
local _, setWeldUI = createToggle("WeldHand", "FE Weld to VR Hand", toggleFEWeld)

-- Feature: Avoid Target
local avoidTargetConnection = nil
local function handleAvoidTarget()
	local char = localPlayer.Character
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

		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				if part.Name ~= "HumanoidRootPart" then part.CanCollide = not insideDangerZone end
				part.CanTouch = not insideDangerZone
			end
		end
	end
end

local function toggleAvoidTarget(state)
	avoidTargetEnabled = state
	updateTouchInterestDestroyerState()
	if state then
		if avoidTargetConnection then avoidTargetConnection:Disconnect() end
		avoidTargetConnection = RunService.RenderStepped:Connect(handleAvoidTarget)
	else
		if avoidTargetConnection then avoidTargetConnection:Disconnect() avoidTargetConnection = nil end
		restoreCharacterCollisions()
	end
end
createToggle("AvoidTarget", "Avoid Target Hand", toggleAvoidTarget)

-- Feature: Avoid All
local avoidAllConnection = nil
local function handleAvoidAll()
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local handModels = {}
	local vrPlayersFolder = workspace:FindFirstChild("VRPlayers")
	if vrPlayersFolder then
		for _, playerFolder in ipairs(vrPlayersFolder:GetChildren()) do
			if playerFolder.Name ~= tostring(localPlayer.UserId) then
				local lh = playerFolder:FindFirstChild("LeftHand")
				local rh = playerFolder:FindFirstChild("RightHand")
				if lh then table.insert(handModels, lh) end
				if rh then table.insert(handModels, rh) end
			end
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

	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			if part.Name ~= "HumanoidRootPart" then part.CanCollide = not insideDangerZone end
			part.CanTouch = not insideDangerZone
		end
	end
end

local function toggleAvoidAll(state)
	avoidAllEnabled = state
	updateTouchInterestDestroyerState()
	if state then
		if avoidAllConnection then avoidAllConnection:Disconnect() end
		avoidAllConnection = RunService.RenderStepped:Connect(handleAvoidAll)
	else
		if avoidAllConnection then avoidAllConnection:Disconnect() avoidAllConnection = nil end
		restoreCharacterCollisions()
	end
end
createToggle("AvoidAll", "Avoid All Hands", toggleAvoidAll)

-- Feature: Remove Props
local removedprops = false
local function toggleRemProps(state)
	removedprops = state
	if removedprops then
		local props = workspace:FindFirstChild("Props")
		if props then props.Parent = Lighting end
	else
		local props = Lighting:FindFirstChild("Props")
		if props then props.Parent = workspace end
	end
end
createToggle("RemProps", "Remove Game Props", toggleRemProps)

-- Feature: Noclip Props
local propnoclip = false
local function toggleNoclipProps(state)
	propnoclip = state
	local props = workspace:FindFirstChild("Props")
	if props then
		for _, item in ipairs(props:GetDescendants()) do
			if item:IsA("BasePart") then item.CanCollide = not propnoclip end
		end
	end
end
createToggle("NoclipProps", "Noclip Game Props", toggleNoclipProps)

-- Feature: Noclip Heads
local headnoclip = false
local function toggleNoclipHeads(state)
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
end
createToggle("NoclipHeads", "Noclip VR Heads", toggleNoclipHeads)

-- Feature: Disable Pickup
local pickup = true
local function toggleRenameHumanoid(state)
	local localChar = localPlayer.Character
	if not localChar then return end
	pickup = not state
	if not pickup then
		local hum = localChar:FindFirstChildOfClass("Humanoid")
		if hum then hum.Name = "lol" end
	else
		local hum = localChar:FindFirstChild("lol")
		if hum then hum.Name = "Humanoid" end
	end
end
createToggle("RenameHumanoid", "Disable Pickup (Lobby Rename)", toggleRenameHumanoid)

-- Feature: FE Air-Walk
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
	local char = localPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	airWalkEnabled = true
	platformHeight = hrp.Position.Y - 3.1

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

	if subGui then subGui:Destroy() end
	subGui = Instance.new("Frame")
	subGui.Name = "AirWalkControl"
	subGui.Parent = bryh
	subGui.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	subGui.BorderSizePixel = 0
	subGui.Size = UDim2.new(0, 110, 0, 145)
	subGui.Position = UDim2.new(1, -125, 0, 15)

	local subCorner = Instance.new("UICorner")
	subCorner.CornerRadius = UDim.new(0, 8)
	subCorner.Parent = subGui

	local subStroke = Instance.new("UIStroke")
	subStroke.Color = cfg.barColor
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

	local posBtn = Instance.new("TextButton")
	posBtn.Size = UDim2.new(1, 0, 0, 26)
	posBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	posBtn.Font = Enum.Font.GothamBold
	posBtn.Text = "📍 CYCLE"
	posBtn.TextColor3 = Color3.fromRGB(200, 230, 255)
	posBtn.TextScaled = true
	posBtn.Parent = subGui
	addHoverEffect(posBtn)

	local positions = {
		UDim2.new(0, 15, 0, 15),
		UDim2.new(1, -125, 0, 15),
		UDim2.new(0, 15, 1, -160),
		UDim2.new(1, -125, 1, -160)
	}

	posBtn.Activated:Connect(function()
		posIndex = (posIndex % 4) + 1
		subGui.Position = positions[posIndex]
	end)

	local upBtn = Instance.new("TextButton")
	upBtn.Size = UDim2.new(1, 0, 0, 32)
	upBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	upBtn.Font = Enum.Font.GothamBold
	upBtn.Text = "▲ UP"
	upBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
	upBtn.TextScaled = true
	upBtn.Parent = subGui
	addHoverEffect(upBtn)

	local downBtn = Instance.new("TextButton")
	downBtn.Size = UDim2.new(1, 0, 0, 32)
	downBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	downBtn.Font = Enum.Font.GothamBold
	downBtn.Text = "▼ DOWN"
	downBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
	downBtn.TextScaled = true
	downBtn.Parent = subGui
	addHoverEffect(downBtn)

	local unexecBtn = Instance.new("TextButton")
	unexecBtn.Size = UDim2.new(1, 0, 0, 26)
	unexecBtn.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
	unexecBtn.Font = Enum.Font.GothamBold
	unexecBtn.Text = "❌ UNEXEC"
	unexecBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	unexecBtn.TextScaled = true
	unexecBtn.Parent = subGui

	upBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then goingUp = true end
	end)
	upBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then goingUp = false end
	end)
	downBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then goingDown = true end
	end)
	downBtn.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then goingDown = false end
	end)

	unexecBtn.Activated:Connect(function()
		setMainToggleUI(false)
		disableAirWalk()
	end)

	if airWalkConnection then airWalkConnection:Disconnect() end
	airWalkConnection = RunService.Heartbeat:Connect(function()
		local curChar = localPlayer.Character
		local curHrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
		if curHrp and platformPart then
			if goingUp then
				platformHeight = platformHeight + 0.35
				curHrp.CFrame = curHrp.CFrame + Vector3.new(0, 0.35, 0)
			elseif goingDown then
				platformHeight = platformHeight - 0.35
				curHrp.CFrame = curHrp.CFrame - Vector3.new(0, 0.35, 0)
			end
			platformPart.CFrame = CFrame.new(curHrp.Position.X, platformHeight, curHrp.Position.Z) * CFrame.Angles(0, 0, math.rad(90))
		end
	end)
end

local function toggleAirWalk(state)
	if state then enableAirWalk(setAirWalkUI) else disableAirWalk() end
end
local _, setAirWalkUI = createToggle("AirWalk", "FE Air-Walk (Blue Circle)", toggleAirWalk)

-- Feature: Void Safety Platform
local voidFloorPart = nil
local voidFloorEnabled = false
local voidFloorConnection = nil
local safePositionConnection = nil
local heightMonitorConnection = nil
local lastSafeCFrame = nil
local isRewinding = false

local function disableVoidFloor()
	if voidFloorConnection then voidFloorConnection:Disconnect() voidFloorConnection = nil end
	if safePositionConnection then safePositionConnection:Disconnect() safePositionConnection = nil end
	if heightMonitorConnection then heightMonitorConnection:Disconnect() heightMonitorConnection = nil end
	if voidFloorPart then voidFloorPart:Destroy() voidFloorPart = nil end
	voidFloorEnabled = false
	isRewinding = false
end

local function enableVoidFloor()
	voidFloorEnabled = true
	isRewinding = false
	if voidFloorPart then voidFloorPart:Destroy() end
	
	local safeY = -75
	local thickness = 40
	local centerY = safeY - (thickness / 2)
	
	voidFloorPart = Instance.new("Part")
	voidFloorPart.Name = "NovolineVoidSafetyFloor"
	voidFloorPart.Size = Vector3.new(300, thickness, 300)
	voidFloorPart.Material = Enum.Material.Glass
	voidFloorPart.Color = Color3.fromRGB(0, 100, 200)
	voidFloorPart.Transparency = 0.7
	voidFloorPart.Anchored = true
	voidFloorPart.CanCollide = true
	voidFloorPart.Parent = workspace

	voidFloorConnection = RunService.Heartbeat:Connect(function()
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and voidFloorPart then
			voidFloorPart.CFrame = CFrame.new(hrp.Position.X, centerY, hrp.Position.Z)
		end
	end)

	safePositionConnection = RunService.Heartbeat:Connect(function()
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hrp and hum and not isRewinding then
			if hrp.Position.Y > -20 and hum.FloorMaterial ~= nil and hum.FloorMaterial ~= Enum.CellMaterial.Empty then
				lastSafeCFrame = hrp.CFrame
			end
		end
	end)

	heightMonitorConnection = RunService.Heartbeat:Connect(function()
		if isRewinding then return end
		local char = localPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hrp and hum then
			if hrp.Position.Y <= -72 then
				isRewinding = true
				hum.PlatformStand = false
				hum.Sit = false
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				hrp.AssemblyLinearVelocity = Vector3.new(0, 15, 0)
				task.wait(0.45)
				if hrp and hrp.Parent then
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					hrp.CFrame = lastSafeCFrame or CFrame.new(0, 15, 0)
					task.wait(0.1)
					if hrp and hrp.Parent then
						hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
						hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
					end
				end
				task.wait(0.2)
				isRewinding = false
			end
		end
	end)
end

local function toggleVoidSafety(state)
	if state then
		enableVoidFloor()
		setAntiGrabUI(true)
		toggleAntiGrab(true)
	else
		disableVoidFloor()
		setAntiGrabUI(false)
		toggleAntiGrab(false)
	end
end
local _, setVoidSafetyUI = createToggle("VoidSafety", "Void Safety Platform", toggleVoidSafety)

-- ==========================================================
-- Admin Feature Definitions
-- ==========================================================

-- Function 1: Invisibility Script Loader (Integrated Bundling)
local function launchInvisibilityTool()
	local CONFIG = {
		TOGGLE_KEY = Enum.KeyCode.X,
		DEFAULT_SPEED = 16,
		BOOSTED_SPEED = 48,
		SOUND_ID = "rbxassetid://942127495",
		INVISIBILITY_POSITION = Vector3.new(-25.95, 84, 3537.55),
		NOTIFICATION_DURATION = 3,
		BACKGROUND_COLOR = Color3.fromRGB(25, 25, 25),
		ACCENT_COLOR = Color3.fromRGB(45, 45, 45),
		PRIMARY_COLOR = Color3.fromRGB(0, 170, 255),
		SUCCESS_COLOR = Color3.fromRGB(46, 204, 113),
		DANGER_COLOR = Color3.fromRGB(231, 76, 60),
		TEXT_COLOR = Color3.fromRGB(255, 255, 255),
		SECONDARY_TEXT_COLOR = Color3.fromRGB(189, 195, 199),
	}

	local player = localPlayer
	local playerState = {
		isInvisible = false,
		isSpeedBoosted = false,
		originalSpeed = CONFIG.DEFAULT_SPEED,
	}

	local screenGui, mainFrame, toggleButton, speedButton, closeButton, sound

	local function setCharacterTransparency(character, transparency)
		for _, descendant in character:GetDescendants() do
			if descendant:IsA("BasePart") or descendant:IsA("Decal") then
				descendant.Transparency = transparency
			end
		end
	end

	local function getHumanoid() return player.Character and player.Character:FindFirstChildOfClass("Humanoid") end
	local function getHumanoidRootPart() return player.Character and player.Character:FindFirstChild("HumanoidRootPart") end

	local function toggleInvisibility()
		if not player.Character then return end
		playerState.isInvisible = not playerState.isInvisible
		if sound then sound:Play() end

		if playerState.isInvisible then
			local hrp = getHumanoidRootPart()
			if not hrp then return end
			local savedPosition = hrp.CFrame
			player.Character:MoveTo(CONFIG.INVISIBILITY_POSITION)
			task.wait(0.15)

			local seat = Instance.new("Seat")
			seat.Name = "invischair"
			seat.Anchored = false
			seat.CanCollide = false
			seat.Transparency = 1
			seat.Position = CONFIG.INVISIBILITY_POSITION
			seat.Parent = workspace

			local weld = Instance.new("Weld")
			weld.Part0 = seat
			weld.Part1 = player.Character:FindFirstChild("Torso") or player.Character:FindFirstChild("UpperTorso")
			weld.Parent = seat

			task.wait()
			seat.CFrame = savedPosition
			setCharacterTransparency(player.Character, 0.5)

			toggleButton.BackgroundColor3 = CONFIG.SUCCESS_COLOR
			toggleButton.Text = "VISIBLE"
		else
			local invisChair = workspace:FindFirstChild("invischair")
			if invisChair then invisChair:Destroy() end
			if player.Character then setCharacterTransparency(player.Character, 0) end
			toggleButton.BackgroundColor3 = CONFIG.PRIMARY_COLOR
			toggleButton.Text = "INVISIBLE"
		end
	end

	local function toggleSpeedBoost()
		local hum = getHumanoid()
		if not hum then return end
		playerState.isSpeedBoosted = not playerState.isSpeedBoosted
		if sound then sound:Play() end

		if playerState.isSpeedBoosted then
			hum.WalkSpeed = CONFIG.BOOSTED_SPEED
			speedButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			speedButton.Text = "SPEED ON"
		else
			hum.WalkSpeed = playerState.originalSpeed
			speedButton.BackgroundColor3 = CONFIG.DANGER_COLOR
			speedButton.Text = "SPEED BOOST"
		end
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "InvisibilityGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0, 160, 0, 180)
	mainFrame.Position = UDim2.new(0.5, -80, 0.5, -90)
	mainFrame.BackgroundColor3 = CONFIG.BACKGROUND_COLOR
	mainFrame.Active = true
	mainFrame.Draggable = true
	mainFrame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = mainFrame

	toggleButton = Instance.new("TextButton")
	toggleButton.Size = UDim2.new(1, -20, 0, 35)
	toggleButton.Position = UDim2.new(0, 10, 0, 45)
	toggleButton.Text = "INVISIBLE"
	toggleButton.BackgroundColor3 = CONFIG.PRIMARY_COLOR
	toggleButton.TextColor3 = CONFIG.TEXT_COLOR
	toggleButton.Font = Enum.Font.GothamBold
	toggleButton.Parent = mainFrame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 8)
	toggleCorner.Parent = toggleButton

	speedButton = Instance.new("TextButton")
	speedButton.Size = UDim2.new(1, -20, 0, 35)
	speedButton.Position = UDim2.new(0, 10, 0, 90)
	speedButton.Text = "SPEED BOOST"
	speedButton.BackgroundColor3 = CONFIG.DANGER_COLOR
	speedButton.TextColor3 = CONFIG.TEXT_COLOR
	speedButton.Font = Enum.Font.GothamBold
	speedButton.Parent = mainFrame

	local speedCorner = Instance.new("UICorner")
	speedCorner.CornerRadius = UDim.new(0, 8)
	speedCorner.Parent = speedButton

	closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 25, 0, 25)
	closeButton.Position = UDim2.new(1, -30, 0, 5)
	closeButton.Text = "×"
	closeButton.BackgroundColor3 = CONFIG.DANGER_COLOR
	closeButton.TextColor3 = CONFIG.TEXT_COLOR
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = mainFrame

	sound = Instance.new("Sound")
	sound.SoundId = CONFIG.SOUND_ID
	sound.Volume = 0.5
	sound.Parent = screenGui

	toggleButton.MouseButton1Click:Connect(toggleInvisibility)
	speedButton.MouseButton1Click:Connect(toggleSpeedBoost)
	closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)
end

-- ==========================================================
-- Admin Interface Setup & Layouts
-- ==========================================================

local function createAdminField(parent, titleText, placeholderText, yOffset)
	local wrapper = Instance.new("Frame")
	wrapper.Size = UDim2.new(1, 0, 0, 55)
	wrapper.BackgroundTransparency = 1
	wrapper.LayoutOrder = yOffset
	wrapper.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 15)
	label.Text = titleText
	label.TextColor3 = Color3.fromRGB(220, 220, 220)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 10
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.BackgroundTransparency = 1
	label.Parent = wrapper

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, 0, 0, 32)
	box.Position = UDim2.new(0, 0, 0, 18)
	box.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
	box.PlaceholderText = placeholderText
	box.Text = ""
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.Font = Enum.Font.Gotham
	box.TextSize = 11
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.Parent = wrapper

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = box

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 10)
	padding.Parent = box

	local stroke = Instance.new("UIStroke")
	stroke.Color = cfg.adminColor
	stroke.Thickness = 1
	stroke.Transparency = 0.7
	stroke.Parent = box

	return box
end

local function buildAdminControls()
	-- Clean existing layouts
	for _, child in ipairs(AdminContainer:GetChildren()) do
		if not child:IsA("UIListLayout") then child:Destroy() end
	end

	-- Part 1: Blacklist & Admin Management Control Block
	local toolFrame = Instance.new("Frame")
	toolFrame.Size = UDim2.new(1, 0, 0, 190)
	toolFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
	toolFrame.LayoutOrder = 1
	toolFrame.Parent = AdminContainer

	local toolCorner = Instance.new("UICorner")
	toolCorner.CornerRadius = UDim.new(0, 8)
	toolCorner.Parent = toolFrame

	local toolStroke = Instance.new("UIStroke")
	toolStroke.Color = cfg.adminColor
	toolStroke.Thickness = 1
	toolStroke.Parent = toolFrame

	local userBox = createAdminField(toolFrame, "TARGET PLAYER USERNAME", "Enter Roblox Username...", 1)
	userBox.Position = UDim2.new(0, 10, 0, 10)
	userBox.Size = UDim2.new(1, -20, 0, 32)

	local reasonBox = createAdminField(toolFrame, "REASON", "Enter warning details (Leave blank for default fallback)...", 2)
	reasonBox.Position = UDim2.new(0, 10, 0, 65)
	reasonBox.Size = UDim2.new(1, -20, 0, 32)

	-- Actions Buttons Wrapper
	local actionRow = Instance.new("Frame")
	actionRow.Size = UDim2.new(1, -20, 0, 35)
	actionRow.Position = UDim2.new(0, 10, 0, 135)
	actionRow.BackgroundTransparency = 1
	actionRow.Parent = toolFrame

	local blacklistBtn = Instance.new("TextButton")
	blacklistBtn.Size = UDim2.new(0.48, 0, 1, 0)
	blacklistBtn.BackgroundColor3 = cfg.adminColor
	blacklistBtn.Font = Enum.Font.GothamBold
	blacklistBtn.Text = "🛑 BLACKLIST"
	blacklistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	blacklistBtn.TextSize = 11
	blacklistBtn.Parent = actionRow

	local blacklistCorner = Instance.new("UICorner")
	blacklistCorner.CornerRadius = UDim.new(0, 6)
	blacklistCorner.Parent = blacklistBtn

	local whitelistBtn = Instance.new("TextButton")
	whitelistBtn.Size = UDim2.new(0.48, 0, 1, 0)
	whitelistBtn.Position = UDim2.new(0.52, 0, 0, 0)
	whitelistBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
	whitelistBtn.Font = Enum.Font.GothamBold
	whitelistBtn.Text = "🛡️ ADD ADMIN"
	whitelistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	whitelistBtn.TextSize = 11
	whitelistBtn.Parent = actionRow

	local whitelistCorner = Instance.new("UICorner")
	whitelistCorner.CornerRadius = UDim.new(0, 6)
	whitelistCorner.Parent = whitelistBtn

	-- Part 2: Quick Exec Utility Controls
	local utilityFrame = Instance.new("Frame")
	utilityFrame.Size = UDim2.new(1, 0, 0, 80)
	utilityFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
	utilityFrame.LayoutOrder = 2
	utilityFrame.Parent = AdminContainer

	local utilCorner = Instance.new("UICorner")
	utilCorner.CornerRadius = UDim.new(0, 8)
	utilCorner.Parent = utilityFrame

	local utilStroke = Instance.new("UIStroke")
	utilStroke.Color = cfg.adminColor
	utilStroke.Thickness = 1
	utilStroke.Parent = utilityFrame

	local flyBtn = Instance.new("TextButton")
	flyBtn.Size = UDim2.new(0.46, 0, 0, 40)
	flyBtn.Position = UDim2.new(0.03, 0, 0.5, -20)
	flyBtn.BackgroundColor3 = Color3.fromRGB(40, 50, 80)
	flyBtn.Font = Enum.Font.GothamBold
	flyBtn.Text = "🚀 MOBILE FLY"
	flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	flyBtn.TextSize = 11
	flyBtn.Parent = utilityFrame

	local flyCorner = Instance.new("UICorner")
	flyCorner.CornerRadius = UDim.new(0, 6)
	flyCorner.Parent = flyBtn

	local invisToolBtn = Instance.new("TextButton")
	invisToolBtn.Size = UDim2.new(0.46, 0, 0, 40)
	invisToolBtn.Position = UDim2.new(0.51, 0, 0.5, -20)
	invisToolBtn.BackgroundColor3 = Color3.fromRGB(80, 40, 80)
	invisToolBtn.Font = Enum.Font.GothamBold
	invisToolBtn.Text = "👤 INVIS TOOL"
	invisToolBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	invisToolBtn.TextSize = 11
	invisToolBtn.Parent = utilityFrame

	local invisCorner = Instance.new("UICorner")
	invisCorner.CornerRadius = UDim.new(0, 6)
	invisCorner.Parent = invisToolBtn

	-- Part 3: Realtime Logs System
	local logsSection = Instance.new("Frame")
	logsSection.Size = UDim2.new(1, 0, 0, 500)
	logsSection.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	logsSection.LayoutOrder = 3
	logsSection.Parent = AdminContainer

	local logSectionCorner = Instance.new("UICorner")
	logSectionCorner.CornerRadius = UDim.new(0, 8)
	logSectionCorner.Parent = logsSection

	local logsSectionStroke = Instance.new("UIStroke")
	logsSectionStroke.Color = cfg.adminColor
	logsSectionStroke.Thickness = 1
	logsSectionStroke.Parent = logsSection

	local logTitle = Instance.new("TextLabel")
	logTitle.Size = UDim2.new(1, -20, 0, 35)
	logTitle.Position = UDim2.new(0, 10, 0, 5)
	logTitle.Text = "📈 RUNTIME SESSION LOGS"
	logTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
	logTitle.Font = Enum.Font.GothamBold
	logTitle.TextSize = 12
	logTitle.BackgroundTransparency = 1
	logTitle.Parent = logsSection

	local searchBar = Instance.new("TextBox")
	searchBar.Size = UDim2.new(1, -20, 0, 30)
	searchBar.Position = UDim2.new(0, 10, 0, 40)
	searchBar.BackgroundColor3 = Color3.fromRGB(22, 22, 35)
	searchBar.PlaceholderText = "Search Users in Logs..."
	searchBar.Text = ""
	searchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
	searchBar.Font = Enum.Font.Gotham
	searchBar.TextSize = 11
	searchBar.TextXAlignment = Enum.TextXAlignment.Left
	searchBar.Parent = logsSection

	local searchPadding = Instance.new("UIPadding")
	searchPadding.PaddingLeft = UDim.new(0, 10)
	searchPadding.Parent = searchBar

	local searchCorner = Instance.new("UICorner")
	searchCorner.CornerRadius = UDim.new(0, 5)
	searchCorner.Parent = searchBar

	local logScroll = Instance.new("ScrollingFrame")
	logScroll.Size = UDim2.new(1, -20, 1, -85)
	logScroll.Position = UDim2.new(0, 10, 0, 75)
	logScroll.BackgroundTransparency = 1
	logScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	logScroll.ScrollBarThickness = 3
	logScroll.ScrollBarImageColor3 = cfg.adminColor
	logScroll.Parent = logsSection

	local logLayout = Instance.new("UIListLayout")
	logLayout.Parent = logScroll
	logLayout.Padding = UDim.new(0, 6)
	logLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Populates and renders list entries inside logs viewer
	local function populateLogs(filterText)
		for _, child in ipairs(logScroll:GetChildren()) do
			if not child:IsA("UIListLayout") then child:Destroy() end
		end

		local layoutSizeY = 0
		for name, logData in pairs(_G.R4HandsShared.Logs) do
			if filterText == "" or name:lower():find(filterText) then
				local logEntry = Instance.new("Frame")
				logEntry.Size = UDim2.new(1, 0, 0, 50)
				logEntry.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
				logEntry.BorderSizePixel = 0
				logEntry.Parent = logScroll

				local entryCorner = Instance.new("UICorner")
				entryCorner.CornerRadius = UDim.new(0, 6)
				entryCorner.Parent = logEntry

				-- Headshot Loader via native Roblox thumb format
				local pfp = Instance.new("ImageLabel")
				pfp.Size = UDim2.new(0, 40, 0, 40)
				pfp.Position = UDim2.new(0, 5, 0.5, -20)
				pfp.BackgroundTransparency = 1
				pfp.Image = "rbxthumb://type=AvatarHeadShot&id=" .. logData.UserId .. "&w=150&h=150"
				pfp.Parent = logEntry

				local userText = Instance.new("TextLabel")
				userText.Size = UDim2.new(0.6, 0, 0, 20)
				userText.Position = UDim2.new(0, 52, 0, 5)
				userText.Text = name
				userText.TextColor3 = Color3.fromRGB(240, 240, 240)
				userText.Font = Enum.Font.GothamBold
				userText.TextSize = 12
				userText.BackgroundTransparency = 1
				userText.TextXAlignment = Enum.TextXAlignment.Left
				userText.Parent = logEntry

				local dateText = Instance.new("TextLabel")
				dateText.Size = UDim2.new(0.6, 0, 0, 15)
				dateText.Position = UDim2.new(0, 52, 0, 23)
				dateText.Text = "Last run: " .. (logData.RunTimes[1] or "N/A")
				dateText.TextColor3 = Color3.fromRGB(150, 150, 150)
				dateText.Font = Enum.Font.Gotham
				dateText.TextSize = 10
				dateText.BackgroundTransparency = 1
				dateText.TextXAlignment = Enum.TextXAlignment.Left
				dateText.Parent = logEntry

				local dropdownToggle = Instance.new("TextButton")
				dropdownToggle.Size = UDim2.new(0, 30, 0, 30)
				dropdownToggle.Position = UDim2.new(1, -35, 0.5, -15)
				dropdownToggle.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
				dropdownToggle.Font = Enum.Font.GothamBold
				dropdownToggle.Text = "▼"
				dropdownToggle.TextColor3 = Color3.fromRGB(200, 200, 200)
				dropdownToggle.TextSize = 10
				dropdownToggle.Parent = logEntry

				local ddCorner = Instance.new("UICorner")
				ddCorner.CornerRadius = UDim.new(0, 4)
				ddCorner.Parent = dropdownToggle

				-- Dropdown Options Frame
				local optionsFrame = Instance.new("Frame")
				optionsFrame.Size = UDim2.new(1, 0, 0, 120)
				optionsFrame.Position = UDim2.new(0, 0, 0, 50)
				optionsFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 30)
				optionsFrame.BorderSizePixel = 0
				optionsFrame.Visible = false
				optionsFrame.Parent = logEntry

				local optionsLayout = Instance.new("UIGridLayout")
				optionsLayout.CellSize = UDim2.new(0.46, 0, 0, 32)
				optionsLayout.CellPadding = UDim2.new(0, 10, 0, 8)
				optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
				optionsLayout.Parent = optionsFrame

				local optionPadding = Instance.new("UIPadding")
				optionPadding.PaddingTop = UDim.new(0, 10)
				optionPadding.PaddingLeft = UDim.new(0, 10)
				optionPadding.Parent = optionsFrame

				local optBlacklist = Instance.new("TextButton")
				optBlacklist.BackgroundColor3 = cfg.adminColor
				optBlacklist.Text = "🚫 Blacklist"
				optBlacklist.TextColor3 = Color3.fromRGB(255, 255, 255)
				optBlacklist.Font = Enum.Font.GothamBold
				optBlacklist.TextSize = 10
				optBlacklist.Parent = optionsFrame

				local optBan = Instance.new("TextButton")
				optBan.BackgroundColor3 = Color3.fromRGB(241, 196, 15)
				optBan.Text = "⏳ Ban Days"
				optBan.TextColor3 = Color3.fromRGB(255, 255, 255)
				optBan.Font = Enum.Font.GothamBold
				optBan.TextSize = 10
				optBan.Parent = optionsFrame

				local optFeatures = Instance.new("TextButton")
				optFeatures.BackgroundColor3 = Color3.fromRGB(46, 117, 204)
				optFeatures.Text = "📈 Run Features"
				optFeatures.TextColor3 = Color3.fromRGB(255, 255, 255)
				optFeatures.Font = Enum.Font.GothamBold
				optFeatures.TextSize = 10
				optFeatures.Parent = optionsFrame

				local optExt = Instance.new("TextButton")
				optExt.BackgroundColor3 = Color3.fromRGB(142, 68, 173)
				optExt.Text = "🌐 Ext Scripts"
				optExt.TextColor3 = Color3.fromRGB(255, 255, 255)
				optExt.Font = Enum.Font.GothamBold
				optExt.TextSize = 10
				optExt.Parent = optionsFrame

				local function styleOpt(btn)
					local c = Instance.new("UICorner")
					c.CornerRadius = UDim.new(0, 4)
					c.Parent = btn
				end
				styleOpt(optBlacklist) styleOpt(optBan) styleOpt(optFeatures) styleOpt(optExt)

				dropdownToggle.Activated:Connect(function()
					optionsFrame.Visible = not optionsFrame.Visible
					if optionsFrame.Visible then
						logEntry.Size = UDim2.new(1, 0, 0, 170)
						dropdownToggle.Text = "▲"
					else
						logEntry.Size = UDim2.new(1, 0, 0, 50)
						dropdownToggle.Text = "▼"
					end
					-- Automatically resize canvas of list view dynamically
					logScroll.CanvasSize = UDim2.new(0, 0, 0, logLayout.AbsoluteContentSize.Y + 20)
				end)

				-- Dropdown option Actions
				optBlacklist.Activated:Connect(function()
					local blockReason = reasonBox.Text
					_G.R4HandsShared.Blacklist[name] = { reason = blockReason, expire = nil }
					createNotification("Blacklisted", name .. " has been script blacklisted.", 4)
				end)

				optBan.Activated:Connect(function()
					local days = tonumber(reasonBox.Text) or 1
					local expireTime = os.time() + (days * 86400)
					_G.R4HandsShared.Blacklist[name] = { reason = "Temporary Ban from Script", expire = expireTime }
					createNotification("Banned", name .. " banned for " .. days .. " days.", 4)
				end)

				optFeatures.Activated:Connect(function()
					local list = table.concat(logData.FeaturesUsed, "\n")
					if list == "" then list = "No features used yet." end
					createNotification("Features Used - " .. name, list, 8)
				end)

				optExt.Activated:Connect(function()
					local list = ""
					for _, sc in ipairs(logData.ExternalScripts) do
						list = list .. string.format("[%s] %s\n", sc.time:sub(12), sc.url:sub(1, 30))
					end
					if list == "" then list = "No HTTP script calls detected." end
					createNotification("Ext Scripts - " .. name, list, 8)
				end)

				layoutSizeY = layoutSizeY + logEntry.AbsoluteSize.Y + 6
			end
		end
		logScroll.CanvasSize = UDim2.new(0, 0, 0, layoutSizeY + 40)
	end

	searchBar:GetPropertyChangedSignal("Text"):Connect(function()
		populateLogs(searchBar.Text:lower())
	end)

	-- Actions Setup
	blacklistBtn.Activated:Connect(function()
		local username = userBox.Text
		local blockReason = reasonBox.Text
		if username ~= "" then
			_G.R4HandsShared.Blacklist[username] = { reason = blockReason, expire = nil }
			createNotification("Success", username .. " is now blacklisted.", 4)
			populateLogs("")
		end
	end)

	whitelistBtn.Activated:Connect(function()
		local username = userBox.Text
		if username ~= "" then
			_G.R4HandsShared.Admins[username] = true
			createNotification("Success", username .. " has been whitelisted.", 4)
			populateLogs("")
		end
	end)

	flyBtn.Activated:Connect(function()
		task.spawn(function()
			pcall(function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
			end)
		end)
	end)

	invisToolBtn.Activated:Connect(function()
		task.spawn(launchInvisibilityTool)
	end)

	populateLogs("")
end

-- ==========================================================
-- Keypad and Mode Triggers
-- ==========================================================
local function transitionToAdminMode()
	isAdmin = true
	adminToggleBtn.Text = "🛡️"
	applyThemeTransition(cfg.adminColor, Color3.fromRGB(35, 15, 25), Color3.fromRGB(70, 30, 45))
	buildAdminControls()
	createNotification("Welcome Back Admin", "Panel successfully elevated.", 4)
end

-- Keypad Inputs Handling
local keys = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "C", "0", "E"}
for idx, char in ipairs(keys) do
	local btn = Instance.new("TextButton")
	btn.Text = char
	btn.TextColor3 = Color3.fromRGB(240, 240, 240)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 14
	btn.BackgroundColor3 = Color3.fromRGB(25, 30, 50)
	btn.LayoutOrder = idx
	btn.Parent = keyGrid

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 6)
	btnCorner.Parent = btn

	btn.Activated:Connect(function()
		if char == "C" then
			keyScreen.Text = ""
		elseif char == "E" then
			if keyScreen.Text == "03112009" then
				KeypadModal.Visible = false
				_G.R4HandsShared.Admins[localPlayer.Name] = true
				transitionToAdminMode()
			else
				keyScreen.Text = ""
				createNotification("Error", "Access Denied. Incorrect Passcode.", 3)
			end
		else
			if #keyScreen.Text < 12 then
				keyScreen.Text = keyScreen.Text .. char
			end
		end
	end)
end

adminToggleBtn.Activated:Connect(function()
	if activeTab == "Main" then
		if isAdmin then
			-- Switch directly to Admin tab
			TogglesContainer.Visible = false
			AdminContainer.Visible = true
			activeTab = "Admin"
			buildAdminControls()
		else
			-- Toggle prompt
			KeypadModal.Visible = not KeypadModal.Visible
		end
	else
		-- Go back to Main tab
		TogglesContainer.Visible = true
		AdminContainer.Visible = false
		activeTab = "Main"
	end
end)

-- Execute Admin Style automatically if pre-whitelisted
if isAdmin then
	task.spawn(transitionToAdminMode)
end

-- Close Button Connection Cleanup
close.Activated:Connect(function()
	if annoyConnection then annoyConnection:Disconnect() end
	if annoyPart then annoyPart:Destroy() end
	if handWeld then handWeld:Destroy() end
	if grabConnection then grabConnection:Disconnect() end
	if descConnection then descConnection:Disconnect() end
	if charAddedConnection then charAddedConnection:Disconnect() end
	if weldConnection then weldConnection:Disconnect() end
	if avoidTargetConnection then avoidTargetConnection:Disconnect() end
	if avoidAllConnection then avoidAllConnection:Disconnect() end
	
	if alignPos then alignPos:Destroy() end
	if alignRot then alignRot:Destroy() end
	if localAttachment then localAttachment:Destroy() end
	if targetAttachment then targetAttachment:Destroy() end
	local localChar = localPlayer.Character
	local hum = localChar and localChar:FindFirstChildOfClass("Humanoid")
	if hum then hum.PlatformStand = false end

	disableAirWalk()
	stopTouchInterestDestroyer()
	stopJointDestroyer()
	restoreCharacterCollisions()
	disableVoidFloor()
	stopSpectating()
	bryh:Destroy()
end)

-- Minimize/Maximize UI Handling
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
				AdminContainer.Visible = false
				TargetSection.Visible = false
				dropdown.Visible = false
				KeypadModal.Visible = false
			else
				if activeTab == "Main" then
					TogglesContainer.Visible = true
				else
					AdminContainer.Visible = true
				end
				TargetSection.Visible = true
			end
		end
	)
end)
