local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local backpack = player:WaitForChild("Backpack")

--=====================
-- 🔧 安全路径查找函数
--=====================
local function safeFind(root, path)
	local node = root
	for _, name in ipairs(path) do
		if node then
			node = node:FindFirstChild(name)
		else
			return nil
		end
	end
	return node
end

--=====================
-- ⚙️ 配置部分
--=====================
local mopName = "Mop"
local mopGiverPosition = Vector3.new(134.10, 254.49, -703.71)
local spillsFolder = workspace:WaitForChild("Ignored"):WaitForChild("Spills")

local mopGiverPrompt = safeFind(workspace, {
	"A_MAP", "Infrastructure", "Facility", "UndergroundFacility", "CafeGrid", "Mop Giver", "Giver"
})
if mopGiverPrompt then
	mopGiverPrompt = mopGiverPrompt:FindFirstChildOfClass("ProximityPrompt")
end

--=====================
-- 🚶‍♂️ 角色与重生处理
--=====================
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(newChar)
	character = newChar
	humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
	task.wait(1)
	if autoMopEnabled then
		local mop = backpack:FindFirstChild(mopName)
		if mop then mop.Parent = character end
	end
end)

--=====================
-- 🖥️ GUI 创建
--=====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MopAutoGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 140, 0, 50)
mainFrame.Position = UDim2.new(0, 20, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 120, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "自动 Mop: 关闭"
toggleButton.Parent = mainFrame
Instance.new("UICorner", toggleButton).CornerRadius = UDim.new(0, 10)

local autoMopEnabled = false
toggleButton.MouseButton1Click:Connect(function()
	autoMopEnabled = not autoMopEnabled
	toggleButton.Text = autoMopEnabled and "自动 Mop: 开启" or "自动 Mop: 关闭"
end)

-- GUI 显示按钮
local toggleGUIButton = Instance.new("TextButton")
toggleGUIButton.Size = UDim2.new(0, 50, 0, 30)
toggleGUIButton.Position = UDim2.new(0, 20, 0, 80)
toggleGUIButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleGUIButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleGUIButton.Text = "GUI"
toggleGUIButton.Parent = screenGui
Instance.new("UICorner", toggleGUIButton).CornerRadius = UDim.new(0, 10)

toggleGUIButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

--=====================
-- 🖱️ 拖动 GUI
--=====================
do
	local dragging = false
	local dragStart, startPos

	mainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			mainFrame.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

--=====================
-- 🧠 功能函数
--=====================
local function hasMop()
	if character:FindFirstChild(mopName) then return true end
	for _, item in ipairs(backpack:GetChildren()) do
		if item.Name == mopName then return true end
	end
	return false
end

local function teleportTo(position)
	if humanoidRootPart and character and character.Parent then
		pcall(function()
			humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 3, 0))
		end)
	end
end

local function triggerPrompt(prompt)
	if prompt and prompt:IsA("ProximityPrompt") and prompt.Enabled then
		pcall(function()
			fireproximityprompt(prompt, 1)
		end)
	end
end

local function findPrompt(model)
	for _, obj in ipairs(model:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Enabled then
			return obj
		end
	end
end

--=====================
-- 🔄 主逻辑循环
--=====================
task.spawn(function()
	while task.wait(0.3) do
		if not autoMopEnabled then continue end

		-- 没 Mop 就去拿
		if not hasMop() then
			if mopGiverPrompt then
				teleportTo(mopGiverPosition)
				task.wait(1.5) -- 停留 1.5 秒
				triggerPrompt(mopGiverPrompt)
				local timeout = 0
				while not hasMop() and timeout < 10 do
					task.wait(0.3)
					timeout += 0.3
				end
			end
		end

		-- 确保 Mop 在手上
		local mopTool = backpack:FindFirstChild(mopName)
		if mopTool then mopTool.Parent = character end

		-- 自动清理污渍
		for _, spill in ipairs(spillsFolder:GetChildren()) do
			if not autoMopEnabled then break end
			if spill:IsA("Model") and spill.PrimaryPart then
				teleportTo(spill.PrimaryPart.Position)
				task.wait(1.5) -- ⏳ 停留 1.5 秒
				local prompt = findPrompt(spill)
				if prompt then
					triggerPrompt(prompt)
					local elapsed = 0
					while elapsed < 2.5 do
						if not spill:IsDescendantOf(workspace) then break end
						task.wait(0.2)
						elapsed += 0.2
					end
				end
				task.wait(0.5)
			end
		end
	end
end)