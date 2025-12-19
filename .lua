-- Menu Mini Ajustado sem Click TP - Botões Centralizados
-- PC + Celular

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- COORDENADAS DO FLING HUG
local HUG_TP_CFRAME = CFrame.new(-928327.25, 9555376.00, 280584.09)

-- CONFIG
local DISTANCIA_MAX = 6
local VIDA_MINIMA = 10

-- ESTADOS
local infiniteJump = false
local infiniteFling = false
local autoTPReset = false
local randomTpDebounce = false
local debounceTPReset = false

-- CHARACTER
local humanoid
local function updateCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end
updateCharacter(character)
player.CharacterAdded:Connect(updateCharacter)

-- DETECTA ABRAÇO
local function estaAbracando(meuChar, alvoChar)
	for _, obj in ipairs(meuChar:GetDescendants()) do
		if obj:IsA("Weld") or obj:IsA("WeldConstraint") or obj:IsA("Motor6D") then
			if obj.Part0 and obj.Part1 then
				if obj.Part0:IsDescendantOf(alvoChar) or obj.Part1:IsDescendantOf(alvoChar) then
					return true
				end
			end
		end
	end
	return false
end

-- GUI
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

-- Aba
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 140, 0, 35)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(255,140,170)
frame.BorderSizePixel = 0
frame.Active = true

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,1,0)
title.Text = "Menu bibi <3"
title.TextSize = 14
title.Font = Enum.Font.SourceSansBold
title.TextColor3 = Color3.new(0,0,0)
title.BackgroundTransparency = 1

-- Menu
local menu = Instance.new("Frame", gui)
menu.Size = UDim2.new(0,140,0,170)
menu.Position = frame.Position + UDim2.new(0,0,0,35)
menu.BackgroundColor3 = Color3.fromRGB(255,170,190)
menu.BorderSizePixel = 0
menu.Visible = false

local function makeButton(text, y, color)
	local b = Instance.new("TextButton", menu)
	b.Size = UDim2.new(1,-10,0,22)
	b.Position = UDim2.new(0,5,0,y)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 12
	return b
end

-- BOTÕES
local buttonNames = {
	{"Inf Jump", Color3.fromRGB(255,110,150)},
	{"Fling", Color3.fromRGB(255,110,150)},
	{"Fling Hug", Color3.fromRGB(255, 70, 120)},
	{"Teleport", Color3.fromRGB(230,90,130)},
	{"AutoReset", Color3.fromRGB(180,60,60)},
	{"Rejoin", Color3.fromRGB(200,80,120)}
}

local buttons = {}
local buttonHeight = 22
local spacing = 5
local totalHeight = #buttonNames * buttonHeight + (#buttonNames-1) * spacing
local startY = (menu.Size.Y.Offset - totalHeight)/2

for i, info in ipairs(buttonNames) do
	local yPos = startY + (i-1)*(buttonHeight + spacing)
	table.insert(buttons, makeButton(info[1], yPos, info[2]))
end

-- Abrir menu
frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		menu.Visible = not menu.Visible
	end
end)

-- INF JUMP
UserInputService.JumpRequest:Connect(function()
	if infiniteJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

buttons[1].MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump
	buttons[1].BackgroundColor3 = infiniteJump and Color3.fromRGB(60,180,80) or Color3.fromRGB(255,110,150)
end)

-- FLING NORMAL
buttons[2].MouseButton1Click:Connect(function()
	infiniteFling = not infiniteFling
	buttons[2].BackgroundColor3 = infiniteFling and Color3.fromRGB(60,180,80) or Color3.fromRGB(255,110,150)
end)

-- 🔥 FLING HUG (CLICK → TP)
buttons[3].MouseButton1Click:Connect(function()
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = HUG_TP_CFRAME
end)

-- TELEPORT ALEATÓRIO
buttons[4].MouseButton1Click:Connect(function()
	if randomTpDebounce then return end
	randomTpDebounce = true
	task.delay(0.8,function() randomTpDebounce = false end)

	local list = Players:GetPlayers()
	if #list <= 1 then return end
	local target
	repeat target = list[math.random(#list)] until target ~= player

	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
	end
end)

-- AUTO RESET
local SAFE_POS = Vector3.new(-87.28,859.34,110.26)
buttons[5].MouseButton1Click:Connect(function()
	autoTPReset = not autoTPReset
	buttons[5].BackgroundColor3 = autoTPReset and Color3.fromRGB(60,180,80) or Color3.fromRGB(180,60,60)
end)

-- REJOIN
buttons[6].MouseButton1Click:Connect(function()
	TeleportService:Teleport(game.PlaceId, player)
end)
