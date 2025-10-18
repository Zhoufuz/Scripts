local Players = game:GetService("Players")
local player = Players.LocalPlayer

--=== 存储死亡位置与开关状态 ===--
local lastDeathPosition = nil
local teleportEnabled = false

--=== 创建GUI ===--
local gui = Instance.new("ScreenGui")
gui.Name = "DeathTeleportGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 120, 0, 32)
button.Position = UDim2.new(0, 20, 0, 20)
button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Font = Enum.Font.SourceSansBold
button.TextSize = 16
button.Text = "原地复活：关闭"
button.Parent = gui
button.Draggable = true
button.AutoButtonColor = true
button.Active = true

-- 圆角
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = button

-- 更新按钮状态
local function updateButton()
	if teleportEnabled then
		button.BackgroundColor3 = Color3.fromRGB(70, 200, 70)
		button.Text = "原地复活：开启"
	else
		button.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
		button.Text = "原地复活：关闭"
	end
end
updateButton()

button.MouseButton1Click:Connect(function()
	teleportEnabled = not teleportEnabled
	updateButton()
end)

--=== 核心逻辑 ===--
local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart", 10)

	-- 若启用功能且有死亡位置，则原地复活
	if teleportEnabled and lastDeathPosition then
		task.wait(0.5)
		root.CFrame = CFrame.new(lastDeathPosition)
	end

	-- 死亡时记录坐标
	humanoid.Died:Connect(function()
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			lastDeathPosition = hrp.Position
		end
	end)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then
	onCharacterAdded(player.Character)
end