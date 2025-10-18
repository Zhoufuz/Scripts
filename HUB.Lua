-- 加载 WindUI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- 创建窗口
local Window = WindUI:CreateWindow({
    Title = "ZF HUB",
    Icon = "settings",
    Author = "by 骤拂",
    Folder = "ZFHUB",
    Size = UDim2.fromOffset(600, 500),
})

-- =========================
-- 关于标签页
-- =========================
local AboutTab = Window:Tab({ Title = "关于", Icon = "info" })

AboutTab:Paragraph({ Title = "ZF HUB", Desc = "此脚本纯自制，无缝合" })
AboutTab:Paragraph({ Title = "作者", Desc = "骤拂" })
AboutTab:Paragraph({
    Title = "Discord",
    Desc = "https://discord.gg/FXDhyZzEdv",
    Buttons = {{
        Icon = "copy",
        Title = "复制链接",
        Callback = function()
            setclipboard("https://discord.gg/FXDhyZzEdv")
            WindUI:Notify({ Title = "复制成功", Content = "已复制Discord链接到剪贴板", Icon = "check", Duration = 1.5 })
        end
    }}
})
AboutTab:Paragraph({
    Title = "QQ群",
    Desc = "1048323382",
    Buttons = {{
        Icon = "copy",
        Title = "复制群号",
        Callback = function()
            setclipboard("1048323382")
            WindUI:Notify({ Title = "复制成功", Content = "已复制QQ群号到剪贴板", Icon = "check", Duration = 1.5 })
        end
    }}
})

-- 服务
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

-- =========================================
-- 避难所生活标签页
-- =========================================
local ShelterTab = Window:Tab({ Title = "避难所生活", Icon = "Bird" })

-- 自动逃脱
ShelterTab:Button({
    Title = "自动逃脱",
    Desc = "持续将玩家传送到隐藏地点直到下一次传送",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zhoufuz/Scripts/refs/heads/main/AutoEscape.Lua"))()
        WindUI:Notify({ Title = "脚本加载", Content = "自动逃脱已执行", Icon = "play", Duration = 1.5 })
    end
})

-- 自动逃脱(旧)
ShelterTab:Button({
    Title = "自动逃脱(旧)",
    Desc = "每120秒传送到逃脱点",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zhoufuz/Scripts/refs/heads/main/AutoEscapeOld.Lua"))()
        WindUI:Notify({ Title = "脚本加载", Content = "自动逃脱(旧)已执行", Icon = "play", Duration = 1.5 })
    end
})

-- 自动拖地
ShelterTab:Button({
    Title = "自动拖地",
    Desc = "自动拖地",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zhoufuz/Scripts/refs/heads/main/AutoMop.Lua"))()
        WindUI:Notify({ Title = "脚本加载", Content = "自动拖地已执行", Icon = "play", Duration = 1.5 })
    end
})

-- 原地复活
ShelterTab:Button({
    Title = "原地复活",
    Desc = "原地复活",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zhoufuz/Scripts/refs/heads/main/Autoros.Lua"))()
        WindUI:Notify({ Title = "脚本加载", Content = "原地复活已执行", Icon = "play", Duration = 1.5 })
    end
})

-- 防甩飞
ShelterTab:Button({
    Title = "防甩飞",
    Desc = "防止被甩飞",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Zhoufuz/ATF/refs/heads/main/AntiTouchFling.Lua"))()
        WindUI:Notify({ Title = "脚本加载", Content = "防甩飞已执行", Icon = "play", Duration = 1.5 })
    end
})

-- 传送到逃脱点
ShelterTab:Button({
    Title = "传送到逃脱点",
    Desc = "立即传送",
    Callback = function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(18.46, 517.48, 423.97)
        end
        WindUI:Notify({ Title = "传送成功", Content = "已传送到逃脱点", Icon = "play", Duration = 1.5 })
    end
})

-- ✅ 自动逮捕重制版
local AutoArrestEnabled = false

local function findAndFirePrompt(root, localRoot)
    for _, descendant in ipairs(root:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.Enabled then
            local action = string.lower(descendant.ActionText or "")
            if action == "arrest" or action == "逮捕" then
                local targetPos
                if descendant.Parent:IsA("BasePart") then
                    targetPos = descendant.Parent.Position
                elseif root:FindFirstChild("HumanoidRootPart") then
                    targetPos = root.HumanoidRootPart.Position
                end
                if targetPos and (targetPos - localRoot.Position).Magnitude <= 7 then
                    pcall(fireproximityprompt, descendant)
                    task.wait(0.15)
                end
            end
        end
    end
end

ShelterTab:Toggle({
    Title = "自动逮捕",
    Desc = "自动逮捕附近倒地病人",
    Default = false,
    Callback = function(state)
        AutoArrestEnabled = state
        if state then
            WindUI:Notify({ Title = "自动逮捕", Content = "已开启自动逮捕", Icon = "play", Duration = 1.5 })
            task.spawn(function()
                while AutoArrestEnabled do
                    task.wait(0.3)
                    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if not localRoot then continue end
                    for _, folder in ipairs({Workspace:FindFirstChild("Characters"), Workspace:FindFirstChild("Bodies"), Workspace:FindFirstChild("NPCs")}) do
                        if folder then
                            for _, char in ipairs(folder:GetChildren()) do
                                if char ~= LocalPlayer.Character then
                                    findAndFirePrompt(char, localRoot)
                                end
                            end
                        end
                    end
                end
            end)
        else
            WindUI:Notify({ Title = "自动逮捕", Content = "已关闭自动逮捕", Icon = "x", Duration = 1.5 })
        end
    end
})

-- =========================================
-- 设置标签页（管理员检测器）
-- =========================================
local SettingsTab = Window:Tab({ Title = "设置", Icon = "settings" })

local AdminCheckerEnabled = true
local AutoLeaveEnabled = false
local NotifiedAdmins = {}

local Admins = {
    ["45725813"] = "项目总监",
    ["421886192"] = "项目主管",
    ["123485736"] = "开发者开发者",
    ["119502667"] = "开发者",
    ["8859941842"] = "开发者",
    ["847628311"] = "开发者",
    ["783867157"] = "开发者",
    ["2373434191"] = "开发者",
    ["37947332"] = "开发者",
    ["403695898"] = "开发者",
    ["4170126961"] = "开发者",
    ["503184974"] = "开发者",
    ["1607192526"] = "开发者",
    ["97385789"] = "开发者",
    ["73893645"] = "开发者",
    ["434578716"] = "开发者",
    ["6138256770"] = "开发者",
    ["28117054"] = "社区主管"
}

local function checkAdmins()
    if not AdminCheckerEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        local uid = tostring(player.UserId)
        if Admins[uid] and not NotifiedAdmins[uid] then
            NotifiedAdmins[uid] = true
            WindUI:Notify({
                Title = "管理员已加入服务器",
                Content = string.format("%s（%s）\n职位：%s", player.DisplayName or player.Name, player.Name, Admins[uid]),
                Icon = "shield-alert",
                Duration = 10
            })
            if AutoLeaveEnabled then
                WindUI:Notify({
                    Title = "检测到管理员，自动退出",
                    Content = "检测到管理员加入，正在退出游戏...",
                    Icon = "log-out",
                    Duration = 3
                })
                task.wait(2)
                game:Shutdown()
            end
        end
    end
end

Players.PlayerAdded:Connect(function() task.wait(0.1) checkAdmins() end)
task.spawn(function() while true do task.wait(0.1) checkAdmins() end end)

SettingsTab:Toggle({
    Title = "管理员检查器",
    Desc = "检测到管理员加入时发送通知",
    Default = true,
    Callback = function(state)
        AdminCheckerEnabled = state
        WindUI:Notify({
            Title = "管理员检查器",
            Content = state and "已开启管理员检查器" or "已关闭管理员检查器",
            Icon = state and "shield-check" or "shield-off",
            Duration = 1.5
        })
    end
})

SettingsTab:Toggle({
    Title = "自动退出",
    Desc = "检测到管理员时自动退出游戏",
    Default = false,
    Callback = function(state)
        AutoLeaveEnabled = state
        WindUI:Notify({
            Title = "自动退出",
            Content = state and "已开启自动退出" or "已关闭自动退出",
            Icon = state and "log-out" or "x",
            Duration = 1.5
        })
    end
})

-- 快速自杀绑定
local QuickSuicideKeybind = "M"
local QuickSuicideConnection

SettingsTab:Keybind({
    Title = "快速自杀按键",
    Desc = "按下该键将本地玩家生命设为零（快速防甩飞）",
    Value = "M",
    Callback = function(key)
        QuickSuicideKeybind = key
        WindUI:Notify({ Title = "快速自杀按键", Content = "已设置为: " .. key, Icon = "keyboard", Duration = 1.5 })
        if QuickSuicideConnection then QuickSuicideConnection:Disconnect() end
        QuickSuicideConnection = UserInputService.InputBegan:Connect(function(input, gpe)
            if gpe then return end
            if input.KeyCode == Enum.KeyCode[QuickSuicideKeybind] then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.Health = 0
                    WindUI:Notify({ Title = "快速自杀", Content = "已执行快速自杀", Icon = "skull", Duration = 1.5 })
                end
            end
        end)
    end
})

QuickSuicideConnection = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode[QuickSuicideKeybind] then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
            WindUI:Notify({ Title = "快速自杀", Content = "已执行快速自杀", Icon = "skull", Duration = 1.5 })
        end
    end
end)

SettingsTab:Button({
    Title = "自杀",
    Desc = "将本地玩家的血量设为零",
    Callback = function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.Health = 0
            WindUI:Notify({ Title = "自杀", Content = "已执行自杀", Icon = "skull", Duration = 1.5 })
        else
            WindUI:Notify({ Title = "错误", Content = "找不到Humanoid或角色未加载", Icon = "x", Duration = 1.5 })
        end
    end
})

-- =========================================
-- 调试标签页
-- =========================================
local DebugTab = Window:Tab({ Title = "调试", Icon = "code" })

local PositionParagraph = DebugTab:Paragraph({
    Title = "玩家坐标",
    Desc = "等待获取...",
    Buttons = {{
        Icon = "copy",
        Title = "复制坐标",
        Callback = function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local pos = LocalPlayer.Character.HumanoidRootPart.Position
                setclipboard(string.format("X: %.3f, Y: %.3f, Z: %.3f", pos.X, pos.Y, pos.Z))
                WindUI:Notify({ Title = "复制成功", Content = "已复制坐标", Icon = "check", Duration = 1.5 })
            end
        end
    }}
})

DebugTab:Paragraph({
    Title = "玩家UID",
    Desc = tostring(LocalPlayer.UserId),
    Buttons = {{
        Icon = "copy",
        Title = "复制",
        Callback = function()
            setclipboard(tostring(LocalPlayer.UserId))
            WindUI:Notify({ Title = "复制成功", Content = "已复制玩家UID", Icon = "check", Duration = 1.5 })
        end
    }}
})

DebugTab:Paragraph({
    Title = "游戏UID",
    Desc = tostring(game.JobId),
    Buttons = {{
        Icon = "copy",
        Title = "复制",
        Callback = function()
            setclipboard(tostring(game.JobId))
            WindUI:Notify({ Title = "复制成功", Content = "已复制游戏UID", Icon = "check", Duration = 1.5 })
        end
    }}
})

DebugTab:Paragraph({ Title = "用户名", Desc = LocalPlayer.Name })
DebugTab:Paragraph({ Title = "显示名", Desc = LocalPlayer.DisplayName })

local ServerCountParagraph = DebugTab:Paragraph({
    Title = "服务器人数",
    Desc = tostring(#Players:GetPlayers()).."/"..tostring(Players.MaxPlayers)
})

DebugTab:Paragraph({
    Title = "服务器名称",
    Desc = MarketplaceService:GetProductInfo(game.PlaceId).Name or "未知"
})

local RuntimeParagraph = DebugTab:Paragraph({ Title = "运行时间", Desc = "00:00:00:00" })

local function formatTime(sec)
    local d=math.floor(sec/86400)
    local h=math.floor((sec%86400)/3600)
    local m=math.floor((sec%3600)/60)
    local s=math.floor(sec%60)
    return string.format("%02d:%02d:%02d:%02d",d,h,m,s)
end

spawn(function()
    local startTime = tick()
    while true do
        task.wait(0.1)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local pos = LocalPlayer.Character.HumanoidRootPart.Position
            PositionParagraph:SetDesc(string.format("X: %.3f, Y: %.3f, Z: %.3f", pos.X, pos.Y, pos.Z))
        else
            PositionParagraph:SetDesc("角色未加载")
        end
        RuntimeParagraph:SetDesc(formatTime(tick()-startTime))
        ServerCountParagraph:SetDesc(tostring(#Players:GetPlayers()).."/"..tostring(Players.MaxPlayers))
    end
end)

-- =========================================
-- 加载完成提示
-- =========================================
WindUI:Notify({ Title = "ZF HUB 加载成功", Content = "欢迎使用 ZF HUB！", Icon = "check", Duration = 1.5 })