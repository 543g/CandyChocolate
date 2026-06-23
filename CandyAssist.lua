--[[
═══════════════════════════════════════════════════════════════
  🍫 Candy & Chocolate Game Assistant
  Quality of Life improvements for keyboard escape games
  Version: 1.0.0
  Created by: Kiro Development Team
═══════════════════════════════════════════════════════════════
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LP = Players.LocalPlayer

-- Prevent multiple instances
if getgenv().CandyAssistActive then
    for _, gui in pairs(LP.PlayerGui:GetChildren()) do
        if gui.Name == "CandyAssistGUI" then gui:Destroy() end
    end
end
getgenv().CandyAssistActive = true

-- Settings
getgenv().AssistSettings = getgenv().AssistSettings or {
    AutoWalk = false,
    SpeedAdjust = false,
    IdlePrevention = false,
    AutoProgress = false,
    CameraZoom = false,
    WalkSpeed = 60,
    CameraFOV = 120
}
local Settings = getgenv().AssistSettings

-- Utility functions
local function GetCharacter() return LP.Character end
local function GetRoot() local char = GetCharacter() return char and char:FindFirstChild("HumanoidRootPart") end
local function GetHumanoid() local char = GetCharacter() return char and char:FindFirstChildOfClass("Humanoid") end

-- Player statistics
local PlayerStats = {Speed=0, Progress=0, Wins=0, StartTime=tick()}

local function ParseValue(value)
    if type(value) == "string" then
        local num = tonumber(value:match("^[%d%.]+"))
        if value:match("K") then return math.floor((num or 0) * 1000)
        elseif value:match("M") then return math.floor((num or 0) * 1000000)
        elseif value:match("B") then return math.floor((num or 0) * 1000000000)
        else return tonumber(value) or 0 end
    end
    return tonumber(value) or 0
end

local function UpdateStats()
    local leaderstats = LP:FindFirstChild("leaderstats")
    if leaderstats then
        local speedStat = leaderstats:FindFirstChild("Speed")
        local progressStat = leaderstats:FindFirstChild("Rebirths")
        local winsStat = leaderstats:FindFirstChild("Wins")
        
        PlayerStats.Speed = speedStat and ParseValue(speedStat.Value) or 0
        PlayerStats.Progress = progressStat and tonumber(progressStat.Value) or 0
        PlayerStats.Wins = winsStat and tonumber(winsStat.Value) or 0
    end
end

-- Idle prevention
LP.Idled:Connect(function()
    if Settings.IdlePrevention then
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end
end)

-- Auto-walk feature (moves character forward periodically)
task.spawn(function()
    while true do
        task.wait(0.2)
        if Settings.AutoWalk and getgenv().CandyAssistActive then
            local root = GetRoot()
            local humanoid = GetHumanoid()
            
            if root and humanoid and humanoid.Health > 0 then
                local lookVector = root.CFrame.LookVector
                root.CFrame = root.CFrame + (lookVector * 0.5)
            end
        end
    end
end)

-- Speed adjustment feature
task.spawn(function()
    while true do
        task.wait(1)
        if Settings.SpeedAdjust and getgenv().CandyAssistActive then
            local humanoid = GetHumanoid()
            if humanoid then 
                humanoid.WalkSpeed = Settings.WalkSpeed
            end
        end
    end
end)

-- Auto-progress feature
task.spawn(function()
    while true do
        task.wait(5)
        if Settings.AutoProgress and getgenv().CandyAssistActive then
            UpdateStats()
            local remotes = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
            if remotes then
                local progressRemote = remotes:FindFirstChild("Rebirth")
                if progressRemote and PlayerStats.Speed >= 1000 then
                    pcall(function() progressRemote:FireServer() end)
                end
            end
        end
    end
end)

-- Camera zoom feature
local camera = workspace.CurrentCamera
local defaultFOV = camera.FieldOfView

task.spawn(function()
    while true do
        task.wait(1)
        if Settings.CameraZoom and getgenv().CandyAssistActive then
            camera.FieldOfView = Settings.CameraFOV
        else
            camera.FieldOfView = defaultFOV
        end
    end
end)

-- USER INTERFACE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CandyAssistGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LP.PlayerGui

-- Color theme
local ColorDark = Color3.fromRGB(20, 20, 25)
local ColorMid = Color3.fromRGB(30, 30, 38)
local ColorLight = Color3.fromRGB(40, 40, 50)
local ColorAccent = Color3.fromRGB(138, 43, 226)
local ColorAccentLight = Color3.fromRGB(186, 85, 211)
local ColorText = Color3.fromRGB(255, 255, 255)
local ColorTextDim = Color3.fromRGB(170, 170, 180)
local ColorSuccess = Color3.fromRGB(46, 204, 113)
local ColorDanger = Color3.fromRGB(231, 76, 60)

-- Shadow effect
local Shadow = Instance.new("ImageLabel")
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(1, -330, 0.5, -260)
Shadow.Size = UDim2.new(0, 320, 0, 520)
Shadow.Image = "rbxassetid://5554236805"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(23, 23, 277, 277)
Shadow.ZIndex = 999
Shadow.Parent = ScreenGui

-- Main container
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 500)
MainFrame.Position = UDim2.new(1, -320, 0.5, -250)
MainFrame.BackgroundColor3 = ColorDark
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.ZIndex = 1000
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = MainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 32)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 23))
}
gradient.Rotation = 45
gradient.Parent = MainFrame

local border = Instance.new("UIStroke")
border.Color = ColorAccent
border.Thickness = 2
border.Transparency = 0.3
border.Parent = MainFrame

-- Header section
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = ColorMid
Header.BorderSizePixel = 0
Header.ZIndex = 1001
Header.Parent = MainFrame

-- Drag functionality (header only)
local dragging = false
local dragInput, mousePos, framePos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

RunService.Heartbeat:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - mousePos
        MainFrame.Position = UDim2.new(
            framePos.X.Scale, framePos.X.Offset + delta.X,
            framePos.Y.Scale, framePos.Y.Offset + delta.Y
        )
    end
end)

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 16)
headerCorner.Parent = Header

local headerBottom = Instance.new("Frame")
headerBottom.Size = UDim2.new(1, 0, 0, 20)
headerBottom.Position = UDim2.new(0, 0, 1, -20)
headerBottom.BackgroundColor3 = ColorMid
headerBottom.BorderSizePixel = 0
headerBottom.ZIndex = 1001
headerBottom.Parent = Header

-- Icon
local Icon = Instance.new("TextLabel")
Icon.Size = UDim2.new(0, 40, 0, 40)
Icon.Position = UDim2.new(0, 12, 0, 10)
Icon.BackgroundColor3 = ColorAccent
Icon.Text = "🍫"
Icon.TextSize = 22
Icon.BorderSizePixel = 0
Icon.ZIndex = 1002
Icon.Parent = Header

local iconCorner = Instance.new("UICorner")
iconCorner.CornerRadius = UDim.new(0, 10)
iconCorner.Parent = Icon

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -140, 0, 25)
Title.Position = UDim2.new(0, 58, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "GAME ASSISTANT"
Title.TextColor3 = ColorText
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 1002
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -140, 0, 15)
Subtitle.Position = UDim2.new(0, 58, 0, 35)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Candy & Chocolate Edition"
Subtitle.TextColor3 = ColorTextDim
Subtitle.TextSize = 11
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.ZIndex = 1002
Subtitle.Parent = Header

-- Close button
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 40, 0, 40)
CloseButton.Position = UDim2.new(1, -50, 0, 10)
CloseButton.BackgroundColor3 = ColorDanger
CloseButton.Text = "✕"
CloseButton.TextColor3 = ColorText
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 1002
CloseButton.Parent = Header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = CloseButton

CloseButton.MouseButton1Click:Connect(function()
    getgenv().CandyAssistActive = false
    Settings.AutoWalk = false
    Settings.SpeedAdjust = false
    Settings.CameraZoom = false
    camera.FieldOfView = defaultFOV
    
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {Position = UDim2.new(1, 50, 0.5, -250)}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

-- Stats panel
local StatsPanel = Instance.new("Frame")
StatsPanel.Size = UDim2.new(1, -24, 0, 90)
StatsPanel.Position = UDim2.new(0, 12, 0, 72)
StatsPanel.BackgroundColor3 = ColorLight
StatsPanel.BorderSizePixel = 0
StatsPanel.ZIndex = 1001
StatsPanel.Parent = MainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 12)
statsCorner.Parent = StatsPanel

local StatsText = Instance.new("TextLabel")
StatsText.Size = UDim2.new(1, -16, 1, -16)
StatsText.Position = UDim2.new(0, 8, 0, 8)
StatsText.BackgroundTransparency = 1
StatsText.Text = "Loading statistics..."
StatsText.TextColor3 = ColorText
StatsText.TextSize = 13
StatsText.Font = Enum.Font.GothamMedium
StatsText.TextXAlignment = Enum.TextXAlignment.Left
StatsText.TextYAlignment = Enum.TextYAlignment.Top
StatsText.ZIndex = 1002
StatsText.Parent = StatsPanel

-- Scrolling container
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -24, 1, -180)
Container.Position = UDim2.new(0, 12, 0, 170)
Container.BackgroundTransparency = 1
Container.BorderSizePixel = 0
Container.ScrollBarThickness = 4
Container.ScrollBarImageColor3 = ColorAccent
Container.CanvasSize = UDim2.new(0, 0, 0, 0)
Container.AutomaticCanvasSize = Enum.AutomaticSize.Y
Container.ZIndex = 1001
Container.Parent = MainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = Container

-- Toggle switch creator
local function CreateToggle(name, desc, settingKey, icon, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 70)
    frame.BackgroundColor3 = ColorLight
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.ZIndex = 1001
    frame.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 35, 0, 35)
    iconLabel.Position = UDim2.new(0, 10, 0, 10)
    iconLabel.BackgroundColor3 = ColorMid
    iconLabel.Text = icon
    iconLabel.TextSize = 18
    iconLabel.BorderSizePixel = 0
    iconLabel.ZIndex = 1002
    iconLabel.Parent = frame
    
    local iconCorner2 = Instance.new("UICorner")
    iconCorner2.CornerRadius = UDim.new(0, 8)
    iconCorner2.Parent = iconLabel
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -140, 0, 20)
    nameLabel.Position = UDim2.new(0, 52, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = ColorText
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 1002
    nameLabel.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -140, 0, 15)
    descLabel.Position = UDim2.new(0, 52, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = ColorTextDim
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 1002
    descLabel.Parent = frame
    
    local toggleBg = Instance.new("Frame")
    toggleBg.Size = UDim2.new(0, 50, 0, 26)
    toggleBg.Position = UDim2.new(1, -60, 0.5, -13)
    toggleBg.BackgroundColor3 = ColorMid
    toggleBg.BorderSizePixel = 0
    toggleBg.ZIndex = 1002
    toggleBg.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBg
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = UDim2.new(0, 3, 0.5, -10)
    toggleKnob.BackgroundColor3 = ColorTextDim
    toggleKnob.BorderSizePixel = 0
    toggleKnob.ZIndex = 1003
    toggleKnob.Parent = toggleBg
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = toggleKnob
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 1, 0)
    button.BackgroundTransparency = 1
    button.Text = ""
    button.ZIndex = 1004
    button.Parent = frame
    
    local function updateToggle()
        local isOn = Settings[settingKey]
        TweenService:Create(toggleBg, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and ColorSuccess or ColorMid
        }):Play()
        TweenService:Create(toggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = isOn and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
            BackgroundColor3 = ColorText
        }):Play()
        TweenService:Create(iconLabel, TweenInfo.new(0.2), {
            BackgroundColor3 = isOn and ColorAccent or ColorMid
        }):Play()
    end
    
    button.MouseButton1Click:Connect(function()
        Settings[settingKey] = not Settings[settingKey]
        updateToggle()
    end)
    
    updateToggle()
end

-- Slider creator
local function CreateSlider(name, desc, settingKey, minVal, maxVal, defaultVal, icon, order)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -8, 0, 80)
    frame.BackgroundColor3 = ColorLight
    frame.BorderSizePixel = 0
    frame.LayoutOrder = order
    frame.ZIndex = 1001
    frame.Parent = Container
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 35, 0, 35)
    iconLabel.Position = UDim2.new(0, 10, 0, 10)
    iconLabel.BackgroundColor3 = ColorMid
    iconLabel.Text = icon
    iconLabel.TextSize = 18
    iconLabel.BorderSizePixel = 0
    iconLabel.ZIndex = 1002
    iconLabel.Parent = frame
    
    local iconCorner2 = Instance.new("UICorner")
    iconCorner2.CornerRadius = UDim.new(0, 8)
    iconCorner2.Parent = iconLabel
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -140, 0, 20)
    nameLabel.Position = UDim2.new(0, 52, 0, 12)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name .. ": " .. defaultVal
    nameLabel.TextColor3 = ColorText
    nameLabel.TextSize = 14
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.ZIndex = 1002
    nameLabel.Parent = frame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -60, 0, 15)
    descLabel.Position = UDim2.new(0, 52, 0, 35)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = desc
    descLabel.TextColor3 = ColorTextDim
    descLabel.TextSize = 10
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.ZIndex = 1002
    descLabel.Parent = frame
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 1, -20)
    track.BackgroundColor3 = ColorMid
    track.BorderSizePixel = 0
    track.ZIndex = 1002
    track.Parent = frame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = ColorAccent
    fill.BorderSizePixel = 0
    fill.ZIndex = 1003
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = UDim2.new((defaultVal - minVal) / (maxVal - minVal), -8, 0.5, -8)
    knob.BackgroundColor3 = ColorText
    knob.BorderSizePixel = 0
    knob.ZIndex = 1004
    knob.Parent = track
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local knobBorder = Instance.new("UIStroke")
    knobBorder.Color = ColorAccent
    knobBorder.Thickness = 3
    knobBorder.Parent = knob
    
    local draggingSlider = false
    
    local function updateSlider(input)
        local relX = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * relX)
        Settings[settingKey] = value
        nameLabel.Text = name .. ": " .. value
        fill.Size = UDim2.new(relX, 0, 1, 0)
        knob.Position = UDim2.new(relX, -8, 0.5, -8)
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
            updateSlider(input)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
end

-- Create interface elements
CreateToggle("Auto Walk", "Automated forward movement", "AutoWalk", "🚀", 1)
CreateToggle("Speed Adjust", "Customize walk speed", "SpeedAdjust", "⚡", 2)
CreateToggle("Idle Prevention", "Stay active automatically", "IdlePrevention", "💤", 3)
CreateToggle("Auto Progress", "Automatic advancement", "AutoProgress", "🔄", 4)
CreateToggle("Camera Zoom", "Enhanced field of view", "CameraZoom", "👁️", 5)
CreateSlider("Walk Speed", "Movement speed control", "WalkSpeed", 16, 150, 60, "🏃", 6)
CreateSlider("Camera FOV", "Field of view adjustment", "CameraFOV", 70, 120, 120, "📷", 7)

-- Statistics update loop
task.spawn(function()
    while getgenv().CandyAssistActive and ScreenGui.Parent do
        pcall(function()
            UpdateStats()
            local sessionTime = tick() - PlayerStats.StartTime
            local hours = math.floor(sessionTime/3600)
            local mins = math.floor((sessionTime%3600)/60)
            local secs = math.floor(sessionTime%60)
            
            local speedDisplay
            if PlayerStats.Speed >= 1000000 then
                speedDisplay = string.format("%.2fM", PlayerStats.Speed / 1000000)
            elseif PlayerStats.Speed >= 1000 then
                speedDisplay = string.format("%.2fK", PlayerStats.Speed / 1000)
            else
                speedDisplay = tostring(PlayerStats.Speed)
            end
            
            StatsText.Text = string.format(
                "⚡ Speed: %s     🔄 Progress: %s\n🏆 Wins: %s     ⏱️ Session: %02d:%02d:%02d",
                speedDisplay, tostring(PlayerStats.Progress),
                tostring(PlayerStats.Wins), hours, mins, secs
            )
        end)
        task.wait(1)
    end
end)

-- Entry animation
MainFrame.Position = UDim2.new(1, 50, 0.5, -250)
TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
    Position = UDim2.new(1, -320, 0.5, -250)
}):Play()

print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("🍫 Candy & Chocolate Game Assistant")
print("📦 Version 1.0.0 loaded successfully")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
