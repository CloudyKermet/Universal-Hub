local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local RunService = game:GetService("RunService")

local Window = WindUI:CreateWindow({
    Title = "Universal",
    Author = "By KermetDevelopment",
    User = {
        Enabled = true,
        Anonymous = false,
    },
})

local Tab1 = Window:Tab({Title = "Client"})
local Tab2 = Window:Tab({Title = "Visuals"})
Tab1:Select()

local MasterToggle = false
local SkeletonToggle = false
local NameToggle = false
local flying = false
local flySpeed = 60
local noclipEnabled = false
local noclipConnection = nil
local infiniteJumpEnabled = false

local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local HRP = character:WaitForChild("HumanoidRootPart")

local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)

local infiniteJumpConnection = nil

local NameCache = {}

local function createNameESP()
    local text = Drawing.new("Text")
    text.Visible = false
    text.Center = true
    text.Outline = true
    text.OutlineColor = Color3.new(0, 0, 0)
    text.Font = 3
    text.Size = 16
    text.Color = Color3.new(1, 1, 1)
    return text
end

local function updateNameESP(player)
    if player == LocalPlayer then return end
    if not MasterToggle or not NameToggle then
        if NameCache[player] then
            NameCache[player].Visible = false
        end
        return
    end

    local char = player.Character
    if not char then
        if NameCache[player] then
            NameCache[player].Visible = false
        end
        return
    end

    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChild("Humanoid")
    
    if not head or not hum or hum.Health <= 0 then
        if NameCache[player] then
            NameCache[player].Visible = false
        end
        return
    end

    if not NameCache[player] then
        NameCache[player] = createNameESP()
    end

    local text = NameCache[player]
    local headPos, onScreen = Camera:WorldToViewportPoint(head.Position)

    if onScreen then
        text.Position = Vector2.new(headPos.X, headPos.Y - 30)
        text.Text = player.Name
        text.Visible = true
    else
        text.Visible = false
    end
end

local Settings = {
    Color = Color3.new(1, 1, 1),
    Thickness = 2,
    Transparency = 1,
}

local SkeletonCache = {}

local function createSkeleton()
    local lines = {}
    for i = 1, 18 do
        local line = Drawing.new("Line")
        line.Color = Settings.Color
        line.Thickness = Settings.Thickness
        line.Transparency = Settings.Transparency
        line.Visible = false
        table.insert(lines, line)
    end
    return lines
end

local function updateSkeleton(player)
    if player == LocalPlayer then return end
    if not MasterToggle or not SkeletonToggle then 
        if SkeletonCache[player] then
            for _, line in ipairs(SkeletonCache[player]) do line.Visible = false end
        end
        return 
    end

    local char = player.Character
    if not char then
        if SkeletonCache[player] then
            for _, line in ipairs(SkeletonCache[player]) do line.Visible = false end
        end
        return
    end

    local hum = char:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then
        if SkeletonCache[player] then
            for _, line in ipairs(SkeletonCache[player]) do line.Visible = false end
        end
        return
    end

    if not SkeletonCache[player] then
        SkeletonCache[player] = createSkeleton()
    end

    local lines = SkeletonCache[player]
    local index = 1

    local function connect(p1, p2)
        if not p1 or not p2 then return end
        local v1 = Camera:WorldToViewportPoint(p1.Position)
        local v2 = Camera:WorldToViewportPoint(p2.Position)

        if v1.Z < 0 or v2.Z < 0 then return end

        local line = lines[index]
        line.From = Vector2.new(v1.X, v1.Y)
        line.To = Vector2.new(v2.X, v2.Y)
        line.Visible = true
        index = index + 1
    end

    local head   = char:FindFirstChild("Head")
    local utorso = char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    local ltorso = char:FindFirstChild("LowerTorso") or char:FindFirstChild("Torso")
    local hrp    = char:FindFirstChild("HumanoidRootPart")

    local lua = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
    local lla = char:FindFirstChild("LeftLowerArm") or char:FindFirstChild("Left Arm")
    local lhand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")

    local rua = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
    local rla = char:FindFirstChild("RightLowerArm") or char:FindFirstChild("Right Arm")
    local rhand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")

    local lul = char:FindFirstChild("LeftUpperLeg") or char:FindFirstChild("Left Leg")
    local lll = char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Left Leg")
    local lfoot = char:FindFirstChild("LeftFoot") or char:FindFirstChild("Left Leg")

    local rul = char:FindFirstChild("RightUpperLeg") or char:FindFirstChild("Right Leg")
    local rll = char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg")
    local rfoot = char:FindFirstChild("RightFoot") or char:FindFirstChild("Right Leg")

    connect(head, utorso)
    connect(utorso, ltorso)
    connect(utorso, hrp)

    connect(utorso, lua)  connect(lua, lla)  connect(lla, lhand)
    connect(utorso, rua)  connect(rua, rla)  connect(rla, rhand)

    connect(ltorso or hrp, lul)  connect(lul, lll)  connect(lll, lfoot)
    connect(ltorso or hrp, rul)  connect(rul, rll)  connect(rll, rfoot)

    for i = index, #lines do
        lines[i].Visible = false
    end
end

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        updateNameESP(player)
        updateSkeleton(player)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    if NameCache[plr] then
        NameCache[plr]:Remove()
        NameCache[plr] = nil
    end
    if SkeletonCache[plr] then
        for _, line in ipairs(SkeletonCache[plr]) do
            line:Remove()
        end
        SkeletonCache[plr] = nil
    end
end)

local function startFlying()
    flying = true
    bodyVelocity.Parent = HRP
    bodyGyro.Parent = HRP
    humanoid.PlatformStand = true
end

local function stopFlying()
    flying = false
    bodyVelocity.Parent = nil
    bodyGyro.Parent = nil
    humanoid.PlatformStand = false
end

local function enableNoclip()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    noclipEnabled = true
    noclipConnection = RunService.Stepped:Connect(function()
        if not noclipEnabled then return end
        if LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)
end

local function disableNoclip()
    noclipEnabled = false
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
end

local function enableInfiniteJump()
    infiniteJumpEnabled = true
    if not infiniteJumpConnection then
        infiniteJumpConnection = UIS.JumpRequest:Connect(function()
            if infiniteJumpEnabled and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState("Jumping")
                end
            end
        end)
    end
end

local function disableInfiniteJump()
    infiniteJumpEnabled = false
end

local wse = false
local ws = 16

RunService.RenderStepped:Connect(function()
    for _, player in ipairs(Players:GetPlayers()) do
        updateNameESP(player)
        updateSkeleton(player)
    end
    if wse and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = ws
    end
    if not flying then return end
    local moveDirection = Vector3.new(0, 0, 0)
    local camCF = Camera.CFrame
    local localMove = camCF:VectorToObjectSpace(humanoid.MoveDirection)
    moveDirection = moveDirection + (camCF.LookVector * -localMove.Z)
    moveDirection = moveDirection + (camCF.RightVector * localMove.X)
    if UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonR2) then
        moveDirection = moveDirection + Vector3.new(0, 1, 0)
    end
    if UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.C) or UIS:IsGamepadButtonDown(Enum.UserInputType.Gamepad1, Enum.KeyCode.ButtonL2) then
        moveDirection = moveDirection - Vector3.new(0, 1, 0)
    end
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
    end
    bodyVelocity.Velocity = moveDirection * flySpeed
    bodyGyro.CFrame = camCF
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    HRP = newChar:WaitForChild("HumanoidRootPart")
    if flying then
        flying = false
    end
end)

local Toggle1 = Tab1:Toggle({
    Title = "WalkSpeed",
    Callback = function(state)
        wse = state
        if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = 16
        end
    end
})

local Slider1 = Tab1:Slider({
    Title = "Speed",
    Value = {
        Min = 16,
        Max = 100,
        Default = 16
    },
    Callback = function(value)
        ws = value
    end
})

Tab1:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(state)
        if state then
            startFlying()
        else
            stopFlying()
        end
    end
})

Tab1:Slider({
    Title = "Fly Speed",
    Value = {
        Min = 10,
        Max = 200,
        Default = 60
    },
    Callback = function(value)
        flySpeed = value
    end
})

Tab1:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(state)
        if state then
            enableNoclip()
        else
            disableNoclip()
        end
    end
})

Tab1:Toggle({
    Title = "Infinite Jump",
    Value = false,
    Callback = function(state)
        if state then
            enableInfiniteJump()
        else
            disableInfiniteJump()
        end
    end
})

local Toggle2 = Tab2:Toggle({
    Title = "Master ESP",
    Callback = function(state)
        MasterToggle = state
    end
})

Tab2:Toggle({
    Title = "Name Esp",
    Value = false,
    Callback = function(state)
        NameToggle = state
    end
})

Tab2:Toggle({
    Title = "Skeleton Esp",
    Value = false,
    Callback = function(state)
        SkeletonToggle = state
    end
})
