-- Menu de Testes (refatorado + Tema Verde)
-- PC + Celular
-- Infinite Jump, Fling (AO ABRAÇAR), TP Aleatório, Auto TP+Reset, Rejoin, Fling Hug

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local task = task

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- ====================== CONFIG FLING ======================
local TARGET_CFRAME = CFrame.new(-928327.25, 9555375.88, 280584.09)
local DISTANCIA_MAX = 6
local VIDA_MINIMA = 10

-- ====================== ESTADOS ======================
local infiniteJump = false
local infiniteFling = false
local autoTPReset = false
local randomTpDebounce = false
local jaExecutou = false
local debounceTPReset = false

-- ====================== ATUALIZA CHARACTER ======================
local humanoid

local function updateCharacter(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
end

updateCharacter(character)
player.CharacterAdded:Connect(updateCharacter)

-- ====================== FUNÇÃO: DETECTA ABRAÇO ======================
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

-- ====================== FUNÇÃO PARA TOGGLE COR ======================
local function toggleButtonColor(button, estado, corPadrao)
	if estado then
		button.BackgroundColor3 = Color3.fromRGB(60,180,80) -- verde
	else
		button.BackgroundColor3 = corPadrao
	end
end

-- ====================== FUNÇÃO DE TELEPORT ======================
local function teleportTo(pos)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		hrp.CFrame = CFrame.new(pos)
	end
end

-- ====================== GUI ======================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 140, 0, 230) -- tamanho ajustado
frame.Position = UDim2.new(0.05, 0, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(255,170,190)
frame.BorderSizePixel = 0
frame.Active = true

-- ====================== TÍTULO COM IMAGEM ======================
local title = Instance.new("Frame", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(255,140,170)
title.BorderSizePixel = 0
title.Active = true

-- Imagem Hello Kitty ao lado esquerdo
local titleImage = Instance.new("ImageLabel", title)
titleImage.Size = UDim2.new(0, 30, 1, 0)
titleImage.Position = UDim2.new(0, 0, 0, 0)
titleImage.BackgroundTransparency = 1
titleImage.Image = "rbxassetid://100865817538481" -- seu decal
titleImage.ScaleType = Enum.ScaleType.Fit

-- Texto do título
local titleText = Instance.new("TextLabel", title)
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 35, 0, 0)
titleText.Text = "Menu do bibi"
titleText.BackgroundTransparency = 1
titleText.TextColor3 = Color3.new(0, 0, 0)
titleText.Font = Enum.Font.SourceSansBold
titleText.TextSize = 16
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.TextYAlignment = Enum.TextYAlignment.Center

-- Botão fechar
local closeBtn = Instance.new("TextButton", title)
closeBtn.Size = UDim2.new(0,25,1,0)
closeBtn.Position = UDim2.new(1,-20,0,0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 16
closeBtn.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- ====================== BOTÕES CENTRALIZADOS ======================
local function makeButton(text, color)
	local b = Instance.new("TextButton", frame)
	b.Size = UDim2.new(0.9, 0, 0, 30)
	b.Text = text
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 14
	return b
end

local btnColor = Color3.fromRGB(255,110,150)
local pinkDark = Color3.fromRGB(200,90,120)

local buttons = {
	makeButton("Infinite Jump", btnColor),
	makeButton("Fling Players", btnColor),
	makeButton("Fling Hug", btnColor),
	makeButton("TP Aleatório", Color3.fromRGB(230,90,130)),
	makeButton("Auto TP+Reset", Color3.fromRGB(180,60,60)),
	makeButton("Rejoin", Color3.fromRGB(200,80,120))
}

-- ====================== POSICIONAMENTO DOS BOTÕES ======================
local startY = 35
local spacing = 32
for i, b in ipairs(buttons) do
	b.Position = UDim2.new(0.05, 0, 0, startY + (i-1)*spacing)
end

-- ====================== INFINITE JUMP ======================
UserInputService.JumpRequest:Connect(function()
	if infiniteJump and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

buttons[1].MouseButton1Click:Connect(function()
	infiniteJump = not infiniteJump
	buttons[1].Text = infiniteJump and "Desativar Jump" or "Infinite Jump"
	toggleButtonColor(buttons[1], infiniteJump, btnColor)
end)

-- ====================== FLING AO ABRAÇAR ======================
RunService.Heartbeat:Connect(function()
	if not infiniteFling then return end
	local myHrp = character:FindFirstChild("HumanoidRootPart")
	if not myHrp then return end
	local alvoHrp
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - myHrp.Position).Magnitude <= DISTANCIA_MAX then
				alvoHrp = hrp
				break
			end
		end
	end
	if not alvoHrp or not estaAbracando(character, alvoHrp.Parent) then
		jaExecutou = false
		return
	end
	if jaExecutou then return end
	jaExecutou = true
	myHrp.CFrame = alvoHrp.CFrame * CFrame.new(0,0,-0.5)
	task.wait(0.05)
	myHrp.CFrame = TARGET_CFRAME
	myHrp.AssemblyLinearVelocity = Vector3.zero
end)

buttons[2].MouseButton1Click:Connect(function()
	infiniteFling = not infiniteFling
	buttons[2].Text = infiniteFling and "Desativar Fling" or "Fling Players"
	toggleButtonColor(buttons[2], infiniteFling, btnColor)
end)

-- ====================== BOTÃO FLING HUG ======================
buttons[3].MouseButton1Click:Connect(function()
	local hugPosition = Vector3.new(-928327.25,9554865.0,280584.09375)
	teleportTo(hugPosition)
end)

-- ====================== TP ALEATÓRIO ======================
buttons[4].MouseButton1Click:Connect(function()
	if randomTpDebounce then return end
	randomTpDebounce = true
	task.delay(0.8, function() randomTpDebounce = false end)
	local list = Players:GetPlayers()
	if #list <= 1 then return end
	local target
	repeat target = list[math.random(#list)] until target ~= player
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
		hrp.AssemblyLinearVelocity = Vector3.zero
		hrp.Anchored = true
		task.wait(0.15)
		hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,-3)
		task.wait(0.1)
		hrp.Anchored = false
	end
end)

-- ====================== AUTO TP+RESET ======================
local SAFE_POSITION = Vector3.new(-87.28, 859.34, 110.26)
buttons[5].MouseButton1Click:Connect(function()
	autoTPReset = not autoTPReset
	buttons[5].Text = autoTPReset and "Auto TP+Reset (ON)" or "Auto TP+Reset"
	toggleButtonColor(buttons[5], autoTPReset, Color3.fromRGB(180,60,60))
end)

RunService.Heartbeat:Connect(function()
	if not autoTPReset then return end
	if not humanoid or humanoid.Health <= 0 then return end
	if debounceTPReset then return end
	if humanoid.Health <= VIDA_MINIMA then
		debounceTPReset = true
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if hrp then
			hrp.CFrame = CFrame.new(SAFE_POSITION)
			hrp.AssemblyLinearVelocity = Vector3.zero
		end
		task.delay(0.9, function()
			if humanoid and humanoid.Health > 0 then
				humanoid.Health = 0
			end
			debounceTPReset = false
		end)
	end
end)

-- ====================== REJOIN ======================
buttons[6].MouseButton1Click:Connect(function()
	TeleportService:Teleport(game.PlaceId, player)
end)

-- ====================== ARRASTAR + MINIMIZAR PELO TITULO ======================
local dragging = false
local dragStartPos = Vector2.new(0,0)
local frameStartPos = frame.Position
local minimized = false
local activeInput = nil

title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		if activeInput then return end
		activeInput = input

		if not dragging then
			minimized = not minimized
			for _, b in pairs(buttons) do
				b.Visible = not minimized
			end
			frame.Size = minimized and UDim2.new(0,140,0,30) or UDim2.new(0,140,0,230)
		end

		dragging = true
		dragStartPos = input.Position
		frameStartPos = frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
				activeInput = nil
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == activeInput and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - dragStartPos
		frame.Position = UDim2.new(
			frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
			frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
		)
	end
end)
