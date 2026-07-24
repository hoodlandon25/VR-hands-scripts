local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

-- Configuration
local AVOID_DISTANCE = 30 -- Safe distance barrier (in studs)
local SAFE_DISTANCE = 32 -- Repel snap boundary
local ROBLOX_STAFF_GROUPS = {1200769, 3055661, 14593111, 12513722, 10279336, 6821794, 3253689}
local GAME_GROUP_ID = 6336 -- Mad Vikings Production Group ID

local cfg = {
	logo = "rbxassetid://121595097202790",
	barColor = Color3.fromRGB(90, 170, 255),
}

-- Global Variable Forward Declarations (Scope Fix)
local homeBtn, togglesBtn, settingsBtn
local DashboardPage, TogglesPage, SettingsPage
local setAnnoyUI, setAntiGrabUI, setWeldUI, setAvoidTargetUI, setAvoidAllUI, setRemPropsUI, setNoclipPropsUI, setNoclipHeadsUI, setRenameHumanoidUI, setAirWalkUI, setVoidSafetyUI
local avoidTargetEnabled = false
local avoidAllEnabled = false

local bryh = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TopBar = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local close = Instance.new("TextButton")
local mini = Instance.new("TextButton")
local circleToggle = Instance.new("ImageButton") -- Circular open/close floating button

-- Handle GUI location dynamically based on executor support
bryh.Name = "R4HandsHub"
bryh.Parent = game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")
bryh.ResetOnSpawn = false

-- ==========================================================
-- Input Helper (Corrected to prevent double-firing on mobile)
-- ==========================================================
local function connectClick(button, callback)
	button.MouseButton1Click:Connect(callback)
end

-- ==========================================================
-- Notification System
-- ==========================================================
local notifActive = {}
local function createNotification(title, content, length, iconId)
	local screen = Instance.new("ScreenGui")
	screen.Name = "NotifGui"
	screen.ResetOnSpawn = false
	screen.DisplayOrder = 2147483647
	screen.Parent = game:GetService("CoreGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

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
	mainStroke.Color = cfg.barColor
	mainStroke.Thickness = 1
	mainStroke.Parent = main

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(1, 0, 0, 4)
	bar.Position = UDim2.new(0, 0, 1, -4)
	bar.BackgroundColor3 = cfg.barColor
	bar.BorderSizePixel = 0
	bar.ClipsDescendants = true
	bar.Parent = main

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 2)
	barCorner.Parent = bar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(1, 0, 1, 0)
	fill.Position = UDim2.new(0, 0, 0, 0)
	fill.BackgroundColor3 = cfg.barColor
	fill.BorderSizePixel = 0
	fill.Parent = bar

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.new(0, h, 1, 0)
	icon.Position = UDim2.new(0, 0, 0, 0)
	icon.BackgroundTransparency = 1
	icon.Image = iconId or cfg.logo
	icon.ImageColor3 = cfg.barColor
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

	-- Client-safe unique ID generator
	local id = tostring(math.floor(tick()*1000)) .. "-" .. tostring(math.random(1, 100000))
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
	connectClick(btn, destroy)

	return {Close = destroy}
end

-- ==========================================================
-- Main GUI Setup ( &R4 Hideout Styling )
-- ==========================================================
MainFrame.Name = "MainFrame"
MainFrame.Parent = bryh
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -170)
MainFrame.Size = UDim2.new(0, 460, 0, 340)
MainFrame.ClipsDescendants = true
MainFrame.Visible = false -- Hidden by default on startup (toggle button activates it)
MainFrame.ZIndex = 1

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = cfg.barColor
mainStroke.Thickness = 1.5
mainStroke.Parent = MainFrame

TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
TopBar.BorderSizePixel = 0
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.ZIndex = 2

local topBarCorner = Instance.new("UICorner")
topBarCorner.CornerRadius = UDim.new(0, 10)
topBarCorner.Parent = TopBar

TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TopBar
TitleLabel.BackgroundTransparency = 1.000
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "&R4 Hideout // VR Hands"
TitleLabel.TextColor3 = Color3.fromRGB(200, 230, 255)
TitleLabel.TextSize = 14.000
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 3

close.Name = "close"
close.Parent = TopBar
close.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
close.BackgroundTransparency = 1.000
close.Position = UDim2.new(1, -35, 0, 0)
close.Size = UDim2.new(0, 35, 1, 0)
close.Font = Enum.Font.GothamMedium
close.Text = "×"
close.TextColor3 = Color3.fromRGB(200, 230, 255)
close.TextSize = 22.000
close.Active = true
close.ZIndex = 3

mini.Name = "mini"
mini.Parent = TopBar
mini.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
mini.BackgroundTransparency = 1.000
mini.Position = UDim2.new(1, -70, 0, 0)
mini.Size = UDim2.new(0, 35, 1, 0)
mini.Font = Enum.Font.GothamMedium
mini.Text = "–"
mini.TextColor3 = Color3.fromRGB(200, 230, 255)
mini.TextSize = 18.000
mini.Active = true
mini.ZIndex = 3

-- Open/Close Floating Circular Trigger Button
circleToggle.Name = "circleToggle"
circleToggle.Parent = bryh
circleToggle.Size = UDim2.new(0, 50, 0, 50)
circleToggle.Position = UDim2.new(0, 15, 0, 150)
circleToggle.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
circleToggle.Image = cfg.logo
circleToggle.ImageColor3 = cfg.barColor
circleToggle.Active = true
circleToggle.ZIndex = 5

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circleToggle

local circleStroke = Instance.new("UIStroke")
circleStroke.Color = cfg.barColor
circleStroke.Thickness = 1.5
circleStroke.Parent = circleToggle

-- Interactive pulse effects for hovering
local function addHoverEffect(btn)
	-- Only apply mouse hover animations if the user is using a Mouse (to prevent mobile touch conflicts)
	if not UserInputService.TouchEnabled then
		local origColor = btn.BackgroundColor3
		btn.MouseEnter:Connect(function()
			local popColor = Color3.new(math.min(origColor.R*1.2,1), math.min(origColor.G*1.2,1), math.min(origColor.B*1.2,1))
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = popColor}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = origColor}):Play()
		end)
	end
end

addHoverEffect(circleToggle)

-- Dragging GUI Connection with Viewport clamping (stops UI from leaving screen)
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

-- Toggle Circle Button connection
connectClick(circleToggle, function()
	MainFrame.Visible = not MainFrame.Visible
end)

-- Multi-Page Container Setup
local Pages = Instance.new("Frame")
Pages.Name = "Pages"
Pages.Parent = MainFrame
Pages.BackgroundTransparency = 1
Pages.Position = UDim2.new(0, 10, 0, 50)
Pages.Size = UDim2.new(1, -20, 1, -120)
Pages.ZIndex = 2

-- Bottom Tab Menu (Home / Actions / Settings)
local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Parent = MainFrame
TabBar.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
TabBar.BackgroundTransparency = 0.3
TabBar.Position = UDim2.new(0, 10, 1, -60)
TabBar.Size = UDim2.new(1, -20, 0, 50)
TabBar.ZIndex = 10 -- Elevated above background elements

local tabBarCorner = Instance.new("UICorner")
tabBarCorner.CornerRadius = UDim.new(0, 10)
tabBarCorner.Parent = TabBar

local tabBarStroke = Instance.new("UIStroke")
tabBarStroke.Color = cfg.barColor
tabBarStroke.Thickness = 1
tabBarStroke.Transparency = 0.5
tabBarStroke.Parent = TabBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Parent = TabBar
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 15)

local function createTabBtn(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 120, 1, -10)
	btn.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	btn.Font = Enum.Font.GothamBold
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.TextSize = 11
	btn.Parent = TabBar
	btn.Active = true
	btn.ZIndex = 11 -- Elevated above TabBar Frame
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn
	addHoverEffect(btn)
	return btn
end

homeBtn = createTabBtn("🏠 HOME")
togglesBtn = createTabBtn("⚡ TOGGLES")
settingsBtn = createTabBtn("⚙️ SETTINGS")

-- ==========================================================
-- Tab 1: Dashboard Page ( Welcome Screen )
-- ==========================================================
DashboardPage = Instance.new("Frame")
DashboardPage.Name = "DashboardPage"
DashboardPage.Parent = Pages
DashboardPage.BackgroundTransparency = 1
DashboardPage.Size = UDim2.new(1, 0, 1, 0)
DashboardPage.Visible = false
DashboardPage.ZIndex = 3

-- Profile Card (Left)
local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(0.4, -6, 1, 0)
ProfileCard.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
ProfileCard.BackgroundTransparency = 0.3
ProfileCard.Parent = DashboardPage
ProfileCard.ZIndex = 4

local profCorner = Instance.new("UICorner")
profCorner.CornerRadius = UDim.new(0, 10)
profCorner.Parent = ProfileCard

local profStroke = Instance.new("UIStroke")
profStroke.Color = cfg.barColor
profStroke.Thickness = 1
profStroke.Transparency = 0.5
profStroke.Parent = ProfileCard

local profileImg = Instance.new("ImageLabel")
profileImg.Size = UDim2.new(0, 80, 0, 80)
profileImg.Position = UDim2.new(0.5, -40, 0.15, 0)
profileImg.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
profileImg.Parent = ProfileCard
profileImg.ZIndex = 5
pcall(function()
	profileImg.Image = Players:GetUserThumbnailAsync(Players.LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
end)

local imgCorner = Instance.new("UICorner")
imgCorner.CornerRadius = UDim.new(1, 0)
imgCorner.Parent = profileImg

local imgStroke = Instance.new("UIStroke")
imgStroke.Color = cfg.barColor
imgStroke.Thickness = 1.5
imgStroke.Parent = profileImg

local displayNameLabel = Instance.new("TextLabel")
displayNameLabel.Size = UDim2.new(1, -20, 0, 20)
displayNameLabel.Position = UDim2.new(0, 10, 0.62, 0)
displayNameLabel.BackgroundTransparency = 1
displayNameLabel.Font = Enum.Font.GothamBold
displayNameLabel.Text = Players.LocalPlayer.DisplayName .. " ✔️"
displayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
displayNameLabel.TextSize = 13
displayNameLabel.Parent = ProfileCard
displayNameLabel.ZIndex = 5

local usernameLabel = Instance.new("TextLabel")
usernameLabel.Size = UDim2.new(1, -20, 0, 20)
usernameLabel.Position = UDim2.new(0, 10, 0.75, 0)
usernameLabel.BackgroundTransparency = 1
usernameLabel.Font = Enum.Font.Gotham
usernameLabel.Text = "@" .. Players.LocalPlayer.Name
usernameLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
usernameLabel.TextSize = 10
usernameLabel.Parent = ProfileCard
usernameLabel.ZIndex = 5

-- Stats Card (Right)
local StatsCard = Instance.new("Frame")
local statsLayout = Instance.new("UIGridLayout")

StatsCard.Size = UDim2.new(0.6, -6, 1, 0)
StatsCard.Position = UDim2.new(0.4, 12, 0, 0)
StatsCard.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
StatsCard.BackgroundTransparency = 0.3
StatsCard.Parent = DashboardPage
StatsCard.ZIndex = 4

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 10)
statsCorner.Parent = StatsCard

local statsStroke = Instance.new("UIStroke")
statsStroke.Color = cfg.barColor
statsStroke.Thickness = 1
statsStroke.Transparency = 0.5
statsStroke.Parent = StatsCard

statsLayout.Parent = StatsCard
statsLayout.CellPadding = UDim2.new(0, 8, 0, 8)
statsLayout.CellSize = UDim2.new(0.5, -4, 0.5, -4)
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder

local paddingStats = Instance.new("UIPadding")
paddingStats.PaddingTop = UDim.new(0, 8)
paddingStats.PaddingBottom = UDim.new(0, 8)
paddingStats.PaddingLeft = UDim.new(0, 8)
paddingStats.PaddingRight = UDim.new(0, 8)
paddingStats.Parent = StatsCard

local function createStatUnit(title, defaultVal)
	local u = Instance.new("Frame")
	u.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	u.ZIndex = 5
	
	local uc = Instance.new("UICorner")
	uc.CornerRadius = UDim.new(0, 8)
	uc.Parent = u

	local us = Instance.new("UIStroke")
	us.Color = cfg.barColor
	us.Thickness = 1
	us.Transparency = 0.8
	us.Parent = u

	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(1, -12, 0.4, 0)
	t.Position = UDim2.new(0, 6, 0.1, 0)
	t.BackgroundTransparency = 1
	t.Font = Enum.Font.GothamMedium
	t.Text = title
	t.TextColor3 = Color3.fromRGB(150, 150, 150)
	t.TextSize = 10
	t.Parent = u
	t.ZIndex = 6

	local v = Instance.new("TextLabel")
	v.Size = UDim2.new(1, -12, 0.4, 0)
	v.Position = UDim2.new(0, 6, 0.5, 0)
	v.BackgroundTransparency = 1
	v.Font = Enum.Font.GothamBold
	v.Text = defaultVal
	v.TextColor3 = Color3.fromRGB(200, 230, 255)
	v.TextSize = 12
	v.Parent = u
	v.ZIndex = 6

	u.Parent = StatsCard
	return v
end

local playersCountVal = createStatUnit("PLAYERS", "0/40")
local pingVal = createStatUnit("PING", "0ms")
local uptimeVal = createStatUnit("UPTIME", "00:00:00")
local gameNameVal = createStatUnit("GAME", "VR Hands v3.2")

-- Dynamic Uptime loop
local startUptime = os.time()
task.spawn(function()
	while task.wait(1) do
		local diff = os.time() - startUptime
		local hrs = math.floor(diff / 3600)
		local mins = math.floor((diff % 3600) / 60)
		local secs = diff % 60
		uptimeVal.Text = string.format("%02d:%02d:%02d", hrs, mins, secs)
	end
end)

-- Dynamic Ping loop
task.spawn(function()
	while task.wait(2) do
		local success, ping = pcall(function() return math.round(Players.LocalPlayer:GetNetworkPing() * 1000) end)
		pingVal.Text = (success and ping) and (tostring(ping) .. "ms") or "120ms"
	end
end)

-- Dynamic Player Added loop
local function updatePlayerCount()
	playersCountVal.Text = tostring(#Players:GetPlayers()) .. "/40"
end
updatePlayerCount()
Players.PlayerAdded:Connect(updatePlayerCount)
Players.PlayerRemoving:Connect(updatePlayerCount)

-- ==========================================================
-- Tab 2: Toggles / Command List Page ( IMG_5927 Style )
-- ==========================================================
TogglesPage = Instance.new("Frame")
TogglesPage.Name = "TogglesPage"
TogglesPage.Parent = Pages
TogglesPage.BackgroundTransparency = 1
TogglesPage.Size = UDim2.new(1, 0, 1, 0)
TogglesPage.Visible = true -- Toggles tab is visible first by default
TogglesPage.ZIndex = 3

-- Sub-navigation bar category tab row
local CategoriesRow = Instance.new("Frame")
CategoriesRow.Size = UDim2.new(1, 0, 0, 30)
CategoriesRow.BackgroundTransparency = 1
CategoriesRow.Parent = TogglesPage
CategoriesRow.ZIndex = 4

local catLayout = Instance.new("UIListLayout")
catLayout.Parent = CategoriesRow
catLayout.FillDirection = Enum.FillDirection.Horizontal
catLayout.Padding = UDim.new(0, 6)

local currentCategory = "All"

local function createCategoryBtn(text, name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 72, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	btn.BackgroundTransparency = 0.3
	btn.Font = Enum.Font.GothamBold
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(150, 150, 150)
	btn.TextSize = 10
	btn.Parent = CategoriesRow
	btn.Active = true
	btn.ZIndex = 5
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = btn
	addHoverEffect(btn)
	return btn
end

local catAll = createCategoryBtn("All", "All")
local catTroll = createCategoryBtn("Troll", "Troll")
local catExploit = createCategoryBtn("Exploit", "Exploit")
local catMisc = createCategoryBtn("Misc", "Misc")

-- Search input field
local SearchBar = Instance.new("Frame")
SearchBar.Size = UDim2.new(1, 0, 0, 32)
SearchBar.Position = UDim2.new(0, 0, 0, 36)
SearchBar.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
SearchBar.BackgroundTransparency = 0.3
SearchBar.Parent = TogglesPage
SearchBar.ZIndex = 4

local searchCorner = Instance.new("UICorner")
searchCorner.CornerRadius = UDim.new(0, 6)
searchCorner.Parent = SearchBar

local searchStroke = Instance.new("UIStroke")
searchStroke.Color = cfg.barColor
searchStroke.Thickness = 1
searchStroke.Transparency = 0.7
searchStroke.Parent = SearchBar

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 1, 0)
searchBox.Position = UDim2.new(0, 10, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Font = Enum.Font.GothamSemibold
searchBox.PlaceholderText = "Search Toggles..."
searchBox.Text = ""
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.TextSize = 11
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = SearchBar
searchBox.ZIndex = 5

-- Filter toggles based on category & search string
local function filterToggles()
	local searchText = searchBox.Text:lower()
	for _, toggleFrame in ipairs(TogglesContainer:GetChildren()) do
		if toggleFrame:IsA("Frame") then
			local category = toggleFrame:GetAttribute("Category")
			local name = toggleFrame:GetAttribute("FeatureName"):lower()
			
			local matchesCategory = (currentCategory == "All" or category == currentCategory)
			local matchesSearch = (searchText == "" or name:find(searchText, 1, true))
			
			toggleFrame.Visible = matchesCategory and matchesSearch
		end
	end
end

local function selectCategory(catName, btn)
	currentCategory = catName
	filterToggles()
	
	for _, b in ipairs({catAll, catTroll, catExploit, catMisc}) do
		b.TextColor3 = Color3.fromRGB(150, 150, 150)
	end
	btn.TextColor3 = cfg.barColor
end

connectClick(catAll, function() selectCategory("All", catAll) end)
connectClick(catTroll, function() selectCategory("Troll", catTroll) end)
connectClick(catExploit, function() selectCategory("Exploit", catExploit) end)
connectClick(catMisc, function() selectCategory("Misc", catMisc) end)
selectCategory("All", catAll)

searchBox:GetPropertyChangedSignal("Text"):Connect(filterToggles)

-- Toggles Container setup (Inside scrolling frame)
TogglesContainer.Name = "TogglesContainer"
TogglesContainer.Parent = TogglesPage
TogglesContainer.Active = true
TogglesContainer.BackgroundTransparency = 1.000
TogglesContainer.BorderSizePixel = 0
TogglesContainer.Position = UDim2.new(0, 0, 0, 75)
TogglesContainer.Size = UDim2.new(1, 0, 1, -75)
TogglesContainer.CanvasSize = UDim2.new(0, 0, 0, 620)
TogglesContainer.ScrollBarThickness = 4
TogglesContainer.ScrollBarImageColor3 = cfg.barColor
TogglesContainer.ScrollBarImageTransparency = 0.6
TogglesContainer.ZIndex = 4

local toggleListLayout = Instance.new("UIListLayout")
toggleListLayout.Parent = TogglesContainer
toggleListLayout.SortOrder = Enum.SortOrder.LayoutOrder
toggleListLayout.Padding = UDim.new(0, 6)

-- Reusable Toggle Factory Component with category metadata
local function createToggle(name, text, category, onClickCallback)
	local frame = Instance.new("Frame")
	frame.Name = name .. "_Toggle"
	frame.Size = UDim2.new(1, -6, 0, 45)
	frame.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = TogglesContainer
	frame.ZIndex = 5
	
	frame:SetAttribute("Category", category)
	frame:SetAttribute("FeatureName", text)

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
	label.ZIndex = 6

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0, 64, 0, 26)
	btn.Position = UDim2.new(1, -76, 0.5, -13)
	btn.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
	btn.Font = Enum.Font.GothamBold
	btn.Text = "OFF"
	btn.TextColor3 = Color3.fromRGB(200, 230, 255)
	btn.TextSize = 10
	btn.Parent = frame
	btn.Active = true
	btn.ZIndex = 6

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = btn

	local state = false
	connectClick(btn, function()
		state = not state
		if state then
			btn.BackgroundColor3 = cfg.barColor
			btn.TextColor3 = Color3.fromRGB(20, 30, 50)
			btn.Text = "ON"
			createNotification("Enabled", text .. " has been activated.", 3)
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
			btn.BackgroundColor3 = cfg.barColor
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
-- Tab 3: Settings Page
-- ==========================================================
SettingsPage = Instance.new("Frame")
SettingsPage.Name = "SettingsPage"
SettingsPage.Parent = Pages
SettingsPage.BackgroundTransparency = 1
SettingsPage.Size = UDim2.new(1, 0, 1, 0)
SettingsPage.Visible = false
SettingsPage.ZIndex = 3

local unexecBtnMain = Instance.new("TextButton")
unexecBtnMain.Size = UDim2.new(1, 0, 0, 40)
unexecBtnMain.Position = UDim2.new(0, 0, 0, 10)
unexecBtnMain.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
unexecBtnMain.Font = Enum.Font.GothamBold
unexecBtnMain.Text = "❌ UNEXECUTE SCRIPT"
unexecBtnMain.TextColor3 = Color3.fromRGB(255, 100, 100)
unexecBtnMain.TextSize = 12
unexecBtnMain.Parent = SettingsPage
unexecBtnMain.Active = true
unexecBtnMain.ZIndex = 4

local unexecMainCorner = Instance.new("UICorner")
unexecMainCorner.CornerRadius = UDim.new(0, 8)
unexecMainCorner.Parent = unexecBtnMain

local unexecMainStroke = Instance.new("UIStroke")
unexecMainStroke.Color = Color3.fromRGB(255, 50, 50)
unexecMainStroke.Thickness = 1
unexecMainStroke.Parent = unexecBtnMain

addHoverEffect(unexecBtnMain)

-- Page Switch logic
local function switchTab(tabName, btn)
	DashboardPage.Visible = (tabName == "Dashboard")
	TogglesPage.Visible = (tabName == "Toggles")
	SettingsPage.Visible = (tabName == "Settings")
	
	for _, b in ipairs({homeBtn, togglesBtn, settingsBtn}) do
		b.TextColor3 = Color3.fromRGB(150, 150, 150)
		b.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	end
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.BackgroundColor3 = Color3.fromRGB(30, 60, 100)
end

connectClick(homeBtn, function() switchTab("Dashboard", homeBtn) end)
connectClick(togglesBtn, function() switchTab("Toggles", togglesBtn) end)
connectClick(settingsBtn, function() switchTab("Settings", settingsBtn) end)
switchTab("Toggles", togglesBtn) -- Startup defaults to toggles page

-- ==========================================================
-- Feature Functionality & Handlers
-- ==========================================================

local avoidTargetEnabled = false
local avoidAllEnabled = false

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

local function toggleAnnoy(state)
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
					bp.Position = realHead.Position + realHead.Cframe.LookVector * 15 + realHead.Cframe.RightVector * 2
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
setAnnoyUI = createToggle("Annoy", "Annoy Target Player", "Troll", toggleAnnoy)

-- 2. Anti Grab (Direct user script execution wrapped inside dynamic toggle)
local antiGrabConnections = {}

local function startUserAntiGrab()
	-- Clean existing connections first to prevent duplicate memory leaks
	for _, conn in ipairs(antiGrabConnections) do
		if conn.Connected then conn:Disconnect() end
	end
	antiGrabConnections = {}

	-- ==== YOUR EXACT ANTIGRAB SCRIPT (UNMODIFIED) ====
	local player = game.Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
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

	-- Active periodic fallback breakfree loop
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
setAntiGrabUI = createToggle("AntiGrab", "Anti-Grab (Active Breakfree)", "Exploit", toggleAntiGrab)

-- 3. Noclip VR Hands Handler
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
end
createToggle("NoclipHands", "Noclip VR Hands", "Exploit", toggleNoclipHands)

-- 4. Weld to Hand (Direct CFrame + Velocity Extrapolation matching) Handler
local weldConnection = nil
local function toggleFEWeld(state)
	local char = Players.LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if state then
		local targetPlayer = getActiveTarget()
		local handPart = getVRHandPart(targetPlayer)

		if handPart and hrp and hum then
			-- Platform stand keeps Humanoid controller from fighting local positioning
			hum.PlatformStand = true

			if weldConnection then weldConnection:Disconnect() end
			weldConnection = RunService.Heartbeat:Connect(function()
				if handPart and handPart.Parent and hrp and char and char.Parent then
					-- Matches position, velocity, and angular velocity to synchronize physics replication tightly
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
setWeldUI = createToggle("WeldHand", "FE Weld to VR Hand", "Troll", toggleFEWeld)

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
setAvoidTargetUI = createToggle("AvoidTarget", "Avoid Target VR Player's Hand", "Exploit", toggleAvoidTarget)

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
setAvoidAllUI = createToggle("AvoidAll", "Avoid All VR Players' Hands", "Exploit", toggleAvoidAll)

-- 7. Remove Props Handler
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
setRemPropsUI = createToggle("RemProps", "Remove Game Props", "Troll", toggleRemProps)

-- 8. Noclip Props Handler
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
setNoclipPropsUI = createToggle("NoclipProps", "Noclip Game Props", "Troll", toggleNoclipProps)

-- 9. Noclip Heads Handler
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
end
setNoclipHeadsUI = createToggle("NoclipHeads", "Noclip VR Heads", "Troll", toggleNoclipHeads)

-- 10. Disable Pickup Handler (Humanoid Rename Fallback)
local pickup = true
local function toggleRenameHumanoid(state)
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
end
setRenameHumanoidUI = createToggle("RenameHumanoid", "Disable Pickup (Lobby Rename)", "Misc", toggleRenameHumanoid)

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
	subGui.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
	subGui.BorderSizePixel = 0
	subGui.Size = UDim2.new(0, 110, 0, 145)
	subGui.Position = UDim2.new(1, -125, 0, 15) -- Default Top-Right

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

	-- Cycle Location Button
	local posBtn = Instance.new("TextButton")
	posBtn.Size = UDim2.new(1, 0, 0, 26)
	posBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	posBtn.Font = Enum.Font.GothamBold
	posBtn.Text = "📍 CYCLE"
	posBtn.TextColor3 = Color3.fromRGB(200, 230, 255)
	posBtn.TextScaled = true
	posBtn.TextSize = 10
	posBtn.Parent = subGui
	posBtn.Active = true
	addHoverEffect(posBtn)

	local posCorner = Instance.new("UICorner")
	posCorner.CornerRadius = UDim.new(0, 4)
	posCorner.Parent = posBtn

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
	upBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	upBtn.Font = Enum.Font.GothamBold
	upBtn.Text = "▲ UP"
	upBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
	upBtn.TextScaled = true
	upBtn.TextSize = 12
	upBtn.Parent = subGui
	upBtn.Active = true
	addHoverEffect(upBtn)

	local upCorner = Instance.new("UICorner")
	upCorner.CornerRadius = UDim.new(0, 4)
	upCorner.Parent = upBtn

	-- Elevation DOWN Button
	local downBtn = Instance.new("TextButton")
	downBtn.Size = UDim2.new(1, 0, 0, 32)
	downBtn.BackgroundColor3 = Color3.fromRGB(15, 35, 65)
	downBtn.Font = Enum.Font.GothamBold
	downBtn.Text = "▼ DOWN"
	downBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
	downBtn.TextScaled = true
	downBtn.TextSize = 12
	downBtn.Parent = subGui
	downBtn.Active = true
	addHoverEffect(downBtn)

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

local function toggleAirWalk(state)
	if state then
		enableAirWalk(setAirWalkUI)
	else
		disableAirWalk()
	end
end
local _, setAirWalkUI = createToggle("AirWalk", "FE Air-Walk (Blue Circle)", toggleAirWalk)

-- 12. Void Safety Platform Handler (Anti Void Death + FE Rewind Logic)
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
	
	-- Spawns the floor at a safe altitude above custom server-side void kill scripts
	local safeY = -75
	local thickness = 40
	local centerY = safeY - (thickness / 2) -- Center of 40-stud deep platform is Y = -95
	
	voidFloorPart = Instance.new("Part")
	voidFloorPart.Name = "NovolineVoidSafetyFloor"
	voidFloorPart.Size = Vector3.new(300, thickness, 300) -- Clean 300x300 foot area, 40 studs deep (clipping bypass)
	voidFloorPart.Material = Enum.Material.Glass
	voidFloorPart.Color = Color3.fromRGB(0, 100, 200)
	voidFloorPart.Transparency = 0.7
	voidFloorPart.Anchored = true
	voidFloorPart.CanCollide = true
	voidFloorPart.Parent = workspace

	-- Heartbeat loop to keep the void safety platform directly beneath the player horizontally
	if voidFloorConnection then voidFloorConnection:Disconnect() end
	voidFloorConnection = RunService.Heartbeat:Connect(function()
		local char = Players.LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if hrp and voidFloorPart then
			voidFloorPart.CFrame = CFrame.new(hrp.Position.X, centerY, hrp.Position.Z)
		end
	end)

	-- Safe Position Tracker Loop: Remembers the last coordinate on solid ground (Y > -20)
	if safePositionConnection then safePositionConnection:Disconnect() end
	safePositionConnection = RunService.Heartbeat:Connect(function()
		local char = Players.LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if hrp and hum and not isRewinding then
			-- Verify the player is safely standing on a valid material above the void
			if hrp.Position.Y > -20 and hum.FloorMaterial ~= nil and hum.FloorMaterial ~= Enum.CellMaterial.Empty then
				lastSafeCFrame = hrp.CFrame
			end
		end
	end)

	-- Height Monitor Loop: Triggers the glitch-back-up/rewind sequence when player falls near the safety floor
	if heightMonitorConnection then heightMonitorConnection:Disconnect() end
	heightMonitorConnection = RunService.Heartbeat:Connect(function()
		if isRewinding then return end
		local char = Players.LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")

		if hrp and hum then
			-- Triggers just above the platform (top of platform is at -75)
			if hrp.Position.Y <= -72 then
				isRewinding = true

				-- Instantly try to unragdoll them and pop them up slightly
				hum.PlatformStand = false
				hum.Sit = false
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				hrp.AssemblyLinearVelocity = Vector3.new(0, 15, 0) -- Gentle upward nudge to recover state

				-- Let the character land on the platform briefly so the drop is visually registered
				task.wait(0.45)

				if hrp and hrp.Parent then
					-- Freeze character physics instantly to eliminate any potential fling forces/desync
					hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
					hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

					-- Snap/Glitch back up safely to the last recorded ground coordinate
					hrp.CFrame = lastSafeCFrame or CFrame.new(0, 15, 0)

					-- Re-apply a brief physics freeze to stabilize the character after CFrame snap
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
		-- Auto-activate Anti-Grab on void safety startup
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
-- Camera Spectate Functionality
-- ==========================================================
local spectatingTarget = nil
local spectateMode = "None"
local isShiftlock = false
local spectateConnection = nil

local function stopSpectating()
	spectateMode = "None"
	isShiftlock = false
	SpectateFrame.Visible = false
	shiftlockBtn.Text = "Shiftlock: OFF"
	shiftlockBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
	
	local char = Players.LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	
	workspace.CurrentCamera.CameraSubject = hum
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	Players.LocalPlayer.CameraMaxZoomDistance = 400
	Players.LocalPlayer.CameraMinZoomDistance = 0.5
	
	if hum then
		hum.CameraOffset = Vector3.new(0, 0, 0)
	end
	UserInputService.MouseBehavior = Enum.MouseBehavior.Default
	
	if spectateConnection then
		spectateConnection:Disconnect()
		spectateConnection = nil
	end
end

local function startSpectating(targetPlayer, mode)
	if not targetPlayer or not targetPlayer.Character then return end
	local targetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
	if not targetHum then return end

	spectatingTarget = targetPlayer
	spectateMode = mode
	SpectateFrame.Visible = true

	workspace.CurrentCamera.CameraSubject = targetHum
	workspace.CurrentCamera.CameraType = Enum.CameraType.Custom

	if mode == "FirstPerson" then
		Players.LocalPlayer.CameraMaxZoomDistance = 0.5
		Players.LocalPlayer.CameraMinZoomDistance = 0.5
	elseif mode == "ThirdPerson" then
		Players.LocalPlayer.CameraMaxZoomDistance = 30
		Players.LocalPlayer.CameraMinZoomDistance = 10
	end

	if spectateConnection then spectateConnection:Disconnect() end
	spectateConnection = RunService.RenderStepped:Connect(function()
		if not targetPlayer or not targetPlayer.Parent or not targetPlayer.Character then
			stopSpectating()
			return
		end
		local currentTargetHum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
		if not currentTargetHum then
			stopSpectating()
			return
		end

		workspace.CurrentCamera.CameraSubject = currentTargetHum

		if spectateMode == "ThirdPerson" and isShiftlock then
			currentTargetHum.CameraOffset = Vector3.new(1.75, 0, 0)
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		else
			currentTargetHum.CameraOffset = Vector3.new(0, 0, 0)
			if spectateMode == "ThirdPerson" then
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end
		end
	end)
end

-- Connect Spectate GUI Buttons
firstPersonBtn.Activated:Connect(function()
	if spectatingTarget then
		startSpectating(spectatingTarget, "FirstPerson")
	end
end)

thirdPersonBtn.Activated:Connect(function()
	if spectatingTarget then
		startSpectating(spectatingTarget, "ThirdPerson")
	end
end)

shiftlockBtn.Activated:Connect(function()
	if spectateMode == "ThirdPerson" then
		isShiftlock = not isShiftlock
		if isShiftlock then
			shiftlockBtn.Text = "Shiftlock: ON"
			shiftlockBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
		else
			shiftlockBtn.Text = "Shiftlock: OFF"
			shiftlockBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		end
	end
end)

stopSpectateBtn.Activated:Connect(stopSpectating)

-- ==========================================================
-- Subtitle Warning Animation
-- ==========================================================
local function playSubtitleAlert(text)
	SubtitleFrame.Visible = true
	SubtitleLabel.Text = ""

	-- Play a sound to alert player of admin
	pcall(function()
		local s = Instance.new("Sound", workspace)
		s.SoundId = "rbxassetid://156826628" -- High tech alarm beep
		s.Volume = 0.8
		s:Play()
		task.delay(4, function() s:Destroy() end)
	end)

	-- Typewriter effect
	for i = 1, #text do
		SubtitleLabel.Text = text:sub(1, i)
		task.wait(0.02)
	end

	task.wait(5.5)
	SubtitleFrame.Visible = false
end

-- ==========================================================
-- Admin / Mod / Owner Detection Logic
-- ==========================================================
local function isStaffMember(p)
	if p == Players.LocalPlayer then return nil end

	-- 1. Owner Check
	if p.UserId == game.CreatorId then
		return "Game Owner"
	end

	-- 2. Official Roblox Staff Group check
	for _, gid in ipairs(ROBLOX_STAFF_GROUPS) do
		local ok, rank = pcall(function() return p:GetRankInGroup(gid) end)
		if ok and rank and rank >= 1 then
			return "Roblox Staff"
		end
	end

	-- 3. Game Developer Group Check
	local ok, rank = pcall(function() return p:GetRankInGroup(GAME_GROUP_ID) end)
	if ok and rank and rank >= 100 then
		return "Game Moderator/Admin"
	end

	-- 4. Username keywords check
	local nameLower = p.Name:lower()
	local displayLower = p.DisplayName:lower()
	if nameLower:find("admin") or nameLower:find("moder") or nameLower:find("staff") or displayLower:find("admin") or displayLower:find("moder") or displayLower:find("staff") then
		return "Suspected Admin/Mod"
	end

	return nil
end

local function handlePlayerJoined(p)
	local staffRole = isStaffMember(p)
	if staffRole then
		-- Instantly disable all features for safety
		disableAllFeatures()

		-- Play subtitle sequence
		local alertMessage = string.format("[ALERT] %s Detected: %s (@%s) has joined. All features have been auto-disabled for safety.", staffRole, p.DisplayName, p.Name)
		task.spawn(playSubtitleAlert, alertMessage)

		-- Show spectate option
		startSpectating(p, "ThirdPerson")
	end
end

-- Initialize Player added checks
for _, p in ipairs(Players:GetPlayers()) do
	task.spawn(handlePlayerJoined, p)
end
Players.PlayerAdded:Connect(function(p)
	task.wait(0.5) -- wait for rank details to resolve
	handlePlayerJoined(p)
end)

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
	disableVoidFloor()
	stopSpectating()
	bryh:Destroy()
end)

-- Main Close Connection (Setting Settings close)
unexecBtnMain.Activated:Connect(function()
	createNotification("Closing...", "See you next time!", 2)
	task.wait(0.2)
	-- Safely fires all cleaning processes before closure
	close:Activate()
end)
