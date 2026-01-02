-- HUB MOVEMENT + AUTOCLICK (FLOAT + FLY + NOCLIP + AUTOCLICK + MINIMIZAR)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local cam = workspace.CurrentCamera

local floating, infJump, noclip, autoclick, speedOn = false,false,false,false,false

-- FLY
local flying = false
local flyBV, flyBG, flyConn
local flySpeed = 20 -- VELOCIDADE DO FLY

-- AUTOCLICK
local clickRunning = false

-- CORES
local OFF  = Color3.fromRGB(35,35,35)
local ON   = Color3.fromRGB(0,170,0)
local TXT  = Color3.new(1,1,1)
local PINK = Color3.fromRGB(255,105,180)

-- GUI
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,160,0,230)
frame.Position = UDim2.new(0,8,0,170)
frame.BackgroundColor3 = Color3.fromRGB(18,18,18)
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,24)
title.BackgroundTransparency = 1
title.Text = "<3"
title.TextColor3 = PINK
title.TextSize = 14
title.Font = Enum.Font.GothamBold

local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0,24,0,24)
closeBtn.Position = UDim2.new(1,-24,0,0)
closeBtn.Text = "X"

local minBtn = Instance.new("TextButton", frame)
minBtn.Size = UDim2.new(0,24,0,24)
minBtn.Position = UDim2.new(1,-48,0,0)
minBtn.Text = "-"

local function mkBtn(text, y)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(1,-14,0,26)
	b.Position = UDim2.new(0,7,0,y)
	b.Text = text
	b.BackgroundColor3 = OFF
	b.TextColor3 = TXT
	b.TextSize = 12
	return b
end

local floatBtn = mkBtn("FLOAT: OFF", 30)
local jumpBtn  = mkBtn("INF JUMP: OFF", 60)
local speedBtn = mkBtn("SPEED: OFF", 90)
local noclipBtn= mkBtn("NOCLIP: OFF", 120)
local flyBtn   = mkBtn("FLY: OFF", 150)
local autoBtn  = mkBtn("AUTOCLICK: OFF", 180)

-- FLOAT
local floatBV
local function startFloat()
	floatBV = Instance.new("BodyVelocity")
	floatBV.MaxForce = Vector3.new(0, math.huge, 0)
	floatBV.Velocity = Vector3.zero
	floatBV.Parent = hrp
end

local function stopFloat()
	if floatBV then floatBV:Destroy() floatBV = nil end
end

floatBtn.MouseButton1Click:Connect(function()
	floating = not floating
	floatBtn.Text = floating and "FLOAT: ON" or "FLOAT: OFF"
	floatBtn.BackgroundColor3 = floating and ON or OFF
	if floating then startFloat() else stopFloat() end
end)

-- INF JUMP
UIS.JumpRequest:Connect(function()
	if infJump then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

jumpBtn.MouseButton1Click:Connect(function()
	infJump = not infJump
	jumpBtn.Text = infJump and "INF JUMP: ON" or "INF JUMP: OFF"
	jumpBtn.BackgroundColor3 = infJump and ON or OFF
end)

-- SPEED
speedBtn.MouseButton1Click:Connect(function()
	speedOn = not speedOn
	speedBtn.Text = speedOn and "SPEED: ON" or "SPEED: OFF"
	speedBtn.BackgroundColor3 = speedOn and ON or OFF
	hum.WalkSpeed = speedOn and 17.8 or 16
end)

-- NOCLIP
local noclipConn
local function startNoclip()
	noclipConn = RunService.Stepped:Connect(function()
		for _,v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then v.CanCollide = false end
		end
	end)
end

local function stopNoclip()
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = noclip and "NOCLIP: ON" or "NOCLIP: OFF"
	noclipBtn.BackgroundColor3 = noclip and ON or OFF
	if noclip then startNoclip() else stopNoclip() end
end)

-- AUTOCLICK
local function getTool()
	for _,v in pairs((lp.Character or char):GetChildren()) do
		if v:IsA("Tool") then return v end
	end
end

local function clickLoop()
	if clickRunning then return end
	clickRunning = true
	task.spawn(function()
		while autoclick do
			local tool = getTool()
			if tool and tool.Activate then tool:Activate() end
			task.wait(0.04)
		end
		clickRunning = false
	end)
end

autoBtn.MouseButton1Click:Connect(function()
	autoclick = not autoclick
	autoBtn.Text = autoclick and "AUTOCLICK: ON" or "AUTOCLICK: OFF"
	autoBtn.BackgroundColor3 = autoclick and ON or OFF
	if autoclick then clickLoop() end
end)

-- FLY (WASD + CAMERA)
local keys = {W=false,A=false,S=false,D=false}

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if keys[i.KeyCode.Name] ~= nil then keys[i.KeyCode.Name] = true end
end)

UIS.InputEnded:Connect(function(i)
	if keys[i.KeyCode.Name] ~= nil then keys[i.KeyCode.Name] = false end
end)

local function stopFly()
	flying = false
	if flyConn then flyConn:Disconnect() end
	if flyBV then flyBV:Destroy() end
	if flyBG then flyBG:Destroy() end
	hum.PlatformStand = false
	flyBtn.Text = "FLY: OFF"
	flyBtn.BackgroundColor3 = OFF
end

local function startFly()
	flying = true
	hum.PlatformStand = true

	flyBV = Instance.new("BodyVelocity", hrp)
	flyBV.MaxForce = Vector3.new(1e6,1e6,1e6)

	flyBG = Instance.new("BodyGyro", hrp)
	flyBG.MaxTorque = Vector3.new(1e6,1e6,1e6)
	flyBG.P = 1e6

	flyBtn.Text = "FLY: ON"
	flyBtn.BackgroundColor3 = ON

	flyConn = RunService.RenderStepped:Connect(function()
		flyBG.CFrame = cam.CFrame

		local dir = Vector3.zero
		if keys.S then dir -= cam.CFrame.LookVector end
		if keys.W then dir += cam.CFrame.LookVector end
		if keys.A then dir -= cam.CFrame.RightVector end
		if keys.D then dir += cam.CFrame.RightVector end

		flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * flySpeed or Vector3.zero
	end)
end

flyBtn.MouseButton1Click:Connect(function()
	if flying then stopFly() else startFly() end
end)

-- MINIMIZAR
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	for _,v in pairs(frame:GetChildren()) do
		if v:IsA("TextButton") and v ~= minBtn and v ~= closeBtn then
			v.Visible = not minimized
		end
	end
	frame.Size = minimized and UDim2.new(0,160,0,24) or UDim2.new(0,160,0,290)
end)

-- FECHAR
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- RESPAWN
lp.CharacterAdded:Connect(function(c)
	char = c
	hum = c:WaitForChild("Humanoid")
	hrp = c:WaitForChild("HumanoidRootPart")
	if floating then startFloat() end
	if noclip then startNoclip() end
	if speedOn then hum.WalkSpeed = 17.8 end
end)
