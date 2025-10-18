--=== 服务 ===--
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--=== 参数 ===--
local stayPosition = Vector3.new(-2.18, 493.52, 457.15) -- 持续位置
local teleportPosition = Vector3.new(-18.46, 517.48, 423.97) -- 每120秒传送位置
local teleportInterval = 120 -- 每两分钟
local warningTime = 10 -- 倒计时闪烁时间

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

--=== 函数 ===--
local function getHRP()
	local character = player.Character or player.CharacterAdded:Wait()
	return character:WaitForChild("HumanoidRootPart")
end

local function teleportToStay()
	local hrp = getHRP()
	hrP.CFrame = CFrame.new(stayPosition)
end

local function teleportToTarget()
	local hrp = getHRP()
	hrP.CFrame = CFrame.new(teleportPosition)
end

--=== 控制变量 ===--
local escapeCount = 0
local canStayTeleport = true

--=== 持续传送逻辑 ===--
RunService.Heartbeat:Connect(function()
	if canStayTeleport then
		local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrP.CFrame = CFrame.new(stayPosition)
		end
	end
end)

--=== 倒计时与传送逻辑 ===--
task.spawn(function()
	task.wait(2) -- 等待角色加载完成

	while true do
		for remaining = teleportInterval, 1, -1 do
			countdownLabel.Text = string.format("传送倒计时: %ds", remaining)

			if remaining <= warningTime then
				local tweenRed = TweenService:Create(countdownLabel, TweenInfo.new(0.25), {TextColor3 = Color3.new(1, 0.3, 0.3)})
				local tweenWhite = TweenService:Create(countdownLabel, TweenInfo.new(0.25), {TextColor3 = Color3.new(1, 1, 1)})
				tweenRed:Play()
				tweenRed.Completed:Wait()
				tweenWhite:Play()
			end

			task.wait(1)
		end

		-- ======== 执行传送 ========
		countdownLabel.Text = "正在传送..."
		countdownLabel.TextColor3 = Color3.new(1, 1, 1)

		canStayTeleport = false -- 暂停持续传送
		task.wait() -- 让Heartbeat完成当前帧

		teleportToTarget() -- 传送到目标位置
		task.wait(0.5) -- 停留 0.5 秒

		teleportToStay() -- 回到持续位置
		task.wait(0.1) -- 防止Heartbeat立即覆盖

		canStayTeleport = true -- 恢复持续传送

		-- ======== 更新状态 ========
		escapeCount += 1
		escapeLabel.Text = string.format("逃脱次数: %d", escapeCount)
		task.wait(3)
	end
end)
