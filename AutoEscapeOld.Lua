--=== 服务 ===--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--=== 参数 ===--
local teleportPosition = Vector3.new(-18.46, 517.48, 423.97)
local teleportInterval = 120 -- 每两分钟
local warningTime = 10 -- 最后10秒闪烁

--=== 创建GUI ===--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportCountdownUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- 逃脱次数文本
local escapeLabel = Instance.new("TextLabel")
escapeLabel.AnchorPoint = Vector2.new(0, 1)
escapeLabel.Position = UDim2.new(0, 10, 1, -60)
escapeLabel.Size = UDim2.new(0, 320, 0, 40)
escapeLabel.BackgroundTransparency = 1
escapeLabel.TextColor3 = Color3.new(0.8, 1, 0.8)
escapeLabel.TextStrokeTransparency = 0.3
escapeLabel.Font = Enum.Font.Code
escapeLabel.TextScaled = true
escapeLabel.TextXAlignment = Enum.TextXAlignment.Left
escapeLabel.TextYAlignment = Enum.TextYAlignment.Center
escapeLabel.Text = "逃脱次数: 0"
escapeLabel.Parent = screenGui

-- 倒计时文本
local countdownLabel = Instance.new("TextLabel")
countdownLabel.AnchorPoint = Vector2.new(0, 1)
countdownLabel.Position = UDim2.new(0, 10, 1, -10)
countdownLabel.Size = UDim2.new(0, 320, 0, 40)
countdownLabel.BackgroundTransparency = 1
countdownLabel.TextColor3 = Color3.new(1, 1, 1)
countdownLabel.TextStrokeTransparency = 0.3
countdownLabel.Font = Enum.Font.Code
countdownLabel.TextScaled = true
countdownLabel.TextXAlignment = Enum.TextXAlignment.Left
countdownLabel.TextYAlignment = Enum.TextYAlignment.Center
countdownLabel.Text = "加载中..."
countdownLabel.Parent = screenGui

--=== 控制变量 ===--
local escapeCount = 0

--=== 传送函数 ===--
local function teleportPlayer()
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart", 5)
	if root then
		root.CFrame = CFrame.new(teleportPosition)
	end
end

--=== 倒计时逻辑 ===--
task.defer(function()
	task.wait(2) -- 确保加载完成后再开始倒计时

	while true do
		for remaining = teleportInterval, 1, -1 do
			countdownLabel.Text = string.format("传送倒计时: %ds", remaining)

			if remaining <= warningTime then
				-- 红色闪烁
				local tweenRed = TweenService:Create(countdownLabel, TweenInfo.new(0.25), {TextColor3 = Color3.new(1, 0.3, 0.3)})
				local tweenWhite = TweenService:Create(countdownLabel, TweenInfo.new(0.25), {TextColor3 = Color3.new(1, 1, 1)})
				tweenRed:Play()
				tweenRed.Completed:Wait()
				tweenWhite:Play()
			end

			task.wait(1)
		end

		countdownLabel.Text = "正在传送..."
		countdownLabel.TextColor3 = Color3.new(1, 1, 1)

		-- 执行传送
		teleportPlayer()

		-- 增加逃脱次数
		escapeCount += 1
		escapeLabel.Text = string.format("逃脱次数: %d", escapeCount)

		task.wait(3)
	end
end)