-- Fly V4 Mobile (Маленький GUI без джойстика)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local flying = false
local speed = 55
local control = {F = 0, B = 0, L = 0, R = 0, U = 0, D = 0}
local bodyGyro, bodyVelocity

-- Маленький GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyV4_Small"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 170, 0, 260)
mainFrame.Position = UDim2.new(0, 15, 1, -280)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 23)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "🌀 Fly V4"
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -20, 0, 25)
status.Position = UDim2.new(0, 10, 0, 38)
status.BackgroundTransparency = 1
status.Text = "Выкл"
status.TextColor3 = Color3.fromRGB(255, 80, 80)
status.TextScaled = true
status.Font = Enum.Font.GothamSemibold
status.Parent = mainFrame

-- Кнопки
local function createBtn(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 42)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextScaled = true
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.Parent = mainFrame
    return btn
end

local flyBtn = createBtn("ВКЛЮЧИТЬ", 75, Color3.fromRGB(0, 170, 90))
local unflyBtn = createBtn("ВЫКЛЮЧИТЬ", 125, Color3.fromRGB(170, 30, 30))
local speedUpBtn = createBtn("Speed +", 175, Color3.fromRGB(70, 130, 255))
local speedDownBtn = createBtn("Speed -", 225, Color3.fromRGB(255, 140, 40))

-- Логика полёта
local function startFly()
    if flying then return end
    flying = true
    status.Text = "ВКЛ"
    status.TextColor3 = Color3.fromRGB(0, 255, 120)
    
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 90000
    bodyGyro.MaxTorque = Vector3.new(900000000, 900000000, 900000000)
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(900000000, 900000000, 900000000)
    bodyVelocity.Parent = hrp

    humanoid.PlatformStand = true
end

local function stopFly()
    flying = false
    status.Text = "Выкл"
    status.TextColor3 = Color3.fromRGB(255, 80, 80)
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVelocity then bodyVelocity:Destroy() end
    humanoid.PlatformStand = false
end

-- Обновление движения
RunService.RenderStepped:Connect(function()
    if flying and bodyVelocity and bodyGyro then
        local cam = workspace.CurrentCamera
        local moveVec = Vector3.new(0, 0, 0)
        
        moveVec += cam.CFrame.LookVector * (control.F - control.B)
        moveVec += cam.CFrame.RightVector * (control.R - control.L)
        moveVec += Vector3.new(0, control.U - control.D, 0)
        
        bodyVelocity.Velocity = moveVec.Unit * speed
        bodyGyro.CFrame = cam.CFrame
    end
end)

-- Кнопки
flyBtn.MouseButton1Click:Connect(startFly)
unflyBtn.MouseButton1Click:Connect(stopFly)

speedUpBtn.MouseButton1Click:Connect(function() speed = speed + 10 end)
speedDownBtn.MouseButton1Click:Connect(function() speed = math.max(20, speed - 10) end)

-- Управление клавиатурой / тачем
UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    local k = input.KeyCode
    if k == Enum.KeyCode.W then control.F = 1 end
    if k == Enum.KeyCode.S then control.B = 1 end
    if k == Enum.KeyCode.A then control.L = 1 end
    if k == Enum.KeyCode.D then control.R = 1 end
    if k == Enum.KeyCode.Space or k == Enum.KeyCode.E then control.U = 1 end
    if k == Enum.KeyCode.LeftControl or k == Enum.KeyCode.Q then control.D = 1 end
end)

UIS.InputEnded:Connect(function(input)
    local k = input.KeyCode
    if k == Enum.KeyCode.W then control.F = 0 end
    if k == Enum.KeyCode.S then control.B = 0 end
    if k == Enum.KeyCode.A then control.L = 0 end
    if k == Enum.KeyCode.D then control.R = 0 end
    if k == Enum.KeyCode.Space or k == Enum.KeyCode.E then control.U = 0 end
    if k == Enum.KeyCode.LeftControl or k == Enum.KeyCode.Q then control.D = 0 end
end)

-- Авторестарт при респавне
player.CharacterAdded:Connect(function(new)
    char = new
    hrp = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    if flying then
        task.wait(0.4)
        startFly()
    end
end)

print("✅ Fly V4 Small загружен (без джойстика)")
