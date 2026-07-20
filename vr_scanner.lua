-- Workspace VR Detector and Dumper for VR Hands v3.2
local log = {}
table.insert(log, "=== Workspace VR Scanner Logs ===")

local function logStruct(obj, depth)
	local indent = string.rep("  ", depth or 0)
	return indent .. obj.ClassName .. " : " .. obj.Name
end

-- Scan the Workspace for components resembling VR structures
for _, child in ipairs(workspace:GetChildren()) do
	if child.Name ~= "Terrain" and child.Name ~= "Camera" then
		local nameLower = child.Name:lower()
		if nameLower:find("hand") or nameLower:find("head") or nameLower:find("vr") or child:FindFirstChild("REAL") or child:FindFirstChild("Base") or tonumber(child.Name) then
			table.insert(log, "\nFound potential VR container: " .. child.Name .. " (" .. child.ClassName .. ")")
			local function dumpChildren(parent, currentDepth)
				if currentDepth > 3 then return end
				for _, sub in ipairs(parent:GetChildren()) do
					table.insert(log, logStruct(sub, currentDepth))
					dumpChildren(sub, currentDepth + 1)
				end
			end
			dumpChildren(child, 1)
		end
	end
end

-- Scan player models as a fallback
for _, p in ipairs(game.Players:GetPlayers()) do
	if p.Character then
		table.insert(log, "\nScanning Character of " .. p.Name)
		for _, child in ipairs(p.Character:GetChildren()) do
			if child.Name:lower():find("hand") or child.Name:lower():find("head") or child.Name:lower():find("vr") then
				table.insert(log, "  " .. child.Name .. " (" .. child.ClassName .. ")")
			end
		end
	end
end

local fullLog = table.concat(log, "\n")
print(fullLog)

-- Copy findings to the clipboard
if setclipboard then
	setclipboard(fullLog)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Scanner Done!",
		Text = "VR structure copied to clipboard! Paste it back here.",
		Duration = 5
	})
else
	-- Display a GUI copy fallback if the executor does not support setclipboard
	local sg = Instance.new("ScreenGui", game.CoreGui or game.Players.LocalPlayer:WaitForChild("PlayerGui"))
	local frame = Instance.new("Frame", sg)
	frame.Size = UDim2.new(0.5, 0, 0.5, 0)
	frame.Position = UDim2.new(0.25, 0, 0.25, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
	
	local tb = Instance.new("TextBox", frame)
	tb.Size = UDim2.new(1, 0, 0.85, 0)
	tb.ClearTextOnFocus = false
	tb.TextWrapped = true
	tb.TextScaled = false
	tb.MultiLine = true
	tb.Text = fullLog
	tb.TextColor3 = Color3.fromRGB(255,255,255)
	tb.BackgroundColor3 = Color3.fromRGB(20,20,20)
	
	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.new(1, 0, 0.15, 0)
	btn.Position = UDim2.new(0, 0, 0.85, 0)
	btn.Text = "Close (Copy text above manually if needed)"
	btn.MouseButton1Down:Connect(function()
		sg:Destroy()
	end)
end
