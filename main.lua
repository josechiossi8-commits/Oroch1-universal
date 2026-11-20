local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local antigo = playerGui:FindFirstChild("Oroch1Universal")
if antigo then antigo:Destroy() end

local velocidade = nil
local pulo = nil
local gui = Instance.new("ScreenGui")
gui.Name = "Oroch1Universal"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local alternar = Instance.new("TextButton")
alternar.Size = UDim2.fromOffset(150, 40)
alternar.Position = UDim2.new(0, 10, 0.5, -20)
alternar.BackgroundColor3 = Color3.fromRGB(75, 75, 110)
alternar.TextColor3 = Color3.new(1, 1, 1)
alternar.Text = "Fechar menu"
alternar.TextSize = 16
alternar.Parent = gui
Instance.new("UICorner", alternar)

local menu = Instance.new("ScrollingFrame")
menu.Size = UDim2.fromOffset(220, 290)
menu.Position = UDim2.new(0.5, -110, 0.5, -145)
menu.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
menu.BorderSizePixel = 0
menu.CanvasSize = UDim2.fromOffset(0, 425)
menu.ScrollBarThickness = 4
menu.Parent = gui
Instance.new("UICorner", menu)

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 35)
titulo.BackgroundTransparency = 1
titulo.Text = "Oroch1 universal"
titulo.TextColor3 = Color3.new(1, 1, 1)
titulo.TextSize = 18
titulo.Parent = menu

local campo = Instance.new("TextBox")
campo.Size = UDim2.new(1, -20, 0, 35)
campo.Position = UDim2.fromOffset(10, 40)
campo.PlaceholderText = "Digite a velocidade"
campo.Text = "32"
campo.TextSize = 16
campo.ClearTextOnFocus = false
campo.Parent = menu
Instance.new("UICorner", campo)

local function criarBotao(texto, y)
 local botao = Instance.new("TextButton")
 botao.Size = UDim2.new(1, -20, 0, 35)
 botao.Position = UDim2.fromOffset(10, y)
 botao.BackgroundColor3 = Color3.fromRGB(75, 75, 110)
 botao.TextColor3 = Color3.new(1, 1, 1)
 botao.Text = texto
 botao.TextSize = 16
 botao.Parent = menu
 Instance.new("UICorner", botao)
 return botao
end

local aplicar = criarBotao("Aplicar velocidade", 140)
local resetar = criarBotao("Velocidade 16", 185)

local slider = Instance.new("TextButton")
slider.Name = "ControleVelocidade"
slider.Size = UDim2.new(1, -20, 0, 40)
slider.Position = UDim2.fromOffset(10, 88)
slider.BackgroundTransparency = 1
slider.Text = ""
slider.Parent = menu

local trilho = Instance.new("Frame")
trilho.Name = "Trilho"
trilho.Size = UDim2.new(1, -20, 0, 6)
trilho.Position = UDim2.new(0, 10, 0.5, -3)
trilho.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
trilho.BorderSizePixel = 0
trilho.Parent = slider
Instance.new("UICorner", trilho)

local preenchimento = Instance.new("Frame")
preenchimento.Name = "Preenchimento"
preenchimento.Size = UDim2.new(0, 0, 1, 0)
preenchimento.BackgroundColor3 = Color3.fromRGB(150, 150, 225)
preenchimento.BorderSizePixel = 0
preenchimento.Parent = trilho
Instance.new("UICorner", preenchimento)

local indicador = Instance.new("Frame")
indicador.Name = "Indicador"
indicador.AnchorPoint = Vector2.new(0.5, 0.5)
indicador.Size = UDim2.fromOffset(20, 20)
indicador.Position = UDim2.new(0, 0, 0.5, 0)
indicador.BackgroundColor3 = Color3.fromRGB(190, 190, 255)
indicador.BorderSizePixel = 0
indicador.Parent = trilho
Instance.new("UICorner", indicador).CornerRadius = UDim.new(1, 0)

local function atualizarSlider(valor)
 local proporcao = math.clamp((valor - 1) / 499, 0, 1)
 preenchimento.Size = UDim2.new(proporcao, 0, 1, 0)
 indicador.Position = UDim2.new(proporcao, 0, 0.5, 0)
end

local function mudarVelocidade()
 local personagem = player.Character
 local humanoid = personagem and personagem:FindFirstChildOfClass("Humanoid")
 if humanoid and velocidade then
  humanoid.WalkSpeed = velocidade
 end
end

local function definirVelocidade(valor)
 velocidade = valor
 campo.Text = tostring(valor)
 atualizarSlider(valor)
 mudarVelocidade()
end

local function ajustarPelaPosicao(x)
 local largura = trilho.AbsoluteSize.X
 if largura <= 0 then return end
 local proporcao = math.clamp((x - trilho.AbsolutePosition.X) / largura, 0, 1)
 definirVelocidade(math.floor(1 + proporcao * 499 + 0.5))
end

local arrastando = false
local toqueAtivo = nil
slider.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 then
  arrastando = true
  toqueAtivo = nil
  ajustarPelaPosicao(input.Position.X)
 elseif input.UserInputType == Enum.UserInputType.Touch and not arrastando then
  arrastando = true
  toqueAtivo = input
  ajustarPelaPosicao(input.Position.X)
 end
end)

local movimento = UserInputService.InputChanged:Connect(function(input)
 if not arrastando then return end
 if (toqueAtivo and input == toqueAtivo) or
  (not toqueAtivo and input.UserInputType == Enum.UserInputType.MouseMovement) then
  ajustarPelaPosicao(input.Position.X)
 end
end)

local fimEntrada = UserInputService.InputEnded:Connect(function(input)
 if (toqueAtivo and input == toqueAtivo) or
  (not toqueAtivo and input.UserInputType == Enum.UserInputType.MouseButton1) then
  arrastando = false
  toqueAtivo = nil
 end
end)

local campoPulo = campo:Clone()
campoPulo.Position = UDim2.fromOffset(10, 235)
campoPulo.PlaceholderText = "Digite a forca do pulo"
campoPulo.Text = "50"
campoPulo.Parent = menu

local sliderPulo = slider:Clone()
sliderPulo.Name = "ControlePulo"
sliderPulo.Position = UDim2.fromOffset(10, 280)
sliderPulo.Parent = menu
local trilhoPulo = sliderPulo:WaitForChild("Trilho")
local preenchimentoPulo = trilhoPulo:WaitForChild("Preenchimento")
local indicadorPulo = trilhoPulo:WaitForChild("Indicador")

local aplicarPulo = criarBotao("Aplicar pulo", 330)
local resetarPulo = criarBotao("Pulo 50", 375)

local function atualizarSliderPulo(valor)
 local proporcao = math.clamp(valor / 500, 0, 1)
 preenchimentoPulo.Size = UDim2.new(proporcao, 0, 1, 0)
 indicadorPulo.Position = UDim2.new(proporcao, 0, 0.5, 0)
end

local function aplicarPuloAoPersonagem(humanoid)
 if humanoid and pulo ~= nil then
  humanoid.UseJumpPower = true
  humanoid.JumpPower = pulo
 end
end

local function definirPulo(valor)
 pulo = valor
 campoPulo.Text = tostring(valor)
 atualizarSliderPulo(valor)
 local personagem = player.Character
 aplicarPuloAoPersonagem(personagem and personagem:FindFirstChildOfClass("Humanoid"))
end

local function ajustarPuloPelaPosicao(x)
 local largura = trilhoPulo.AbsoluteSize.X
 if largura <= 0 then return end
 local proporcao = math.clamp((x - trilhoPulo.AbsolutePosition.X) / largura, 0, 1)
 definirPulo(math.floor(proporcao * 500 + 0.5))
end

local arrastandoPulo = false
local toquePulo = nil
sliderPulo.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 then
  arrastandoPulo = true
  toquePulo = nil
  ajustarPuloPelaPosicao(input.Position.X)
 elseif input.UserInputType == Enum.UserInputType.Touch and not arrastandoPulo then
  arrastandoPulo = true
  toquePulo = input
  ajustarPuloPelaPosicao(input.Position.X)
 end
end)

local movimentoPulo = UserInputService.InputChanged:Connect(function(input)
 if not arrastandoPulo then return end
 if (toquePulo and input == toquePulo) or
  (not toquePulo and input.UserInputType == Enum.UserInputType.MouseMovement) then
  ajustarPuloPelaPosicao(input.Position.X)
 end
end)

local fimEntradaPulo = UserInputService.InputEnded:Connect(function(input)
 if (toquePulo and input == toquePulo) or
  (not toquePulo and input.UserInputType == Enum.UserInputType.MouseButton1) then
  arrastandoPulo = false
  toquePulo = nil
 end
end)

aplicarPulo.Activated:Connect(function()
 local valor = tonumber(campoPulo.Text)
 if valor and valor >= 0 and valor <= 500 then
  definirPulo(valor)
 else
  campoPulo.Text = ""
  campoPulo.PlaceholderText = "Digite de 0 a 500"
 end
end)

resetarPulo.Activated:Connect(function()
 definirPulo(50)
end)

atualizarSliderPulo(50)

alternar.Activated:Connect(function()
 menu.Visible = not menu.Visible
 alternar.Text = menu.Visible and "Fechar menu" or "Abrir menu"
end)

aplicar.Activated:Connect(function()
 local valor = tonumber(campo.Text)
 if valor and valor >= 1 and valor <= 500 then
  definirVelocidade(valor)
 else
  campo.Text = ""
  campo.PlaceholderText = "Digite de 1 a 500"
 end
end)

resetar.Activated:Connect(function()
 definirVelocidade(16)
end)

atualizarSlider(32)

local conexao = player.CharacterAdded:Connect(function(personagem)
 local humanoid = personagem:WaitForChild("Humanoid", 10)
 if humanoid and gui.Parent then
  if velocidade then humanoid.WalkSpeed = velocidade end
  aplicarPuloAoPersonagem(humanoid)
 end
end)

gui.Destroying:Connect(function()
 conexao:Disconnect()
 movimento:Disconnect()
 fimEntrada:Disconnect()
 movimentoPulo:Disconnect()
 fimEntradaPulo:Disconnect()
end)
