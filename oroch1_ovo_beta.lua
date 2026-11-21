-- Oroch1 Ovo beta: teste em Roube um Ovo. Criado independentemente.
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local antigo = playerGui:FindFirstChild("Oroch1OvoBeta")
if antigo then antigo:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "Oroch1OvoBeta"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local painel = Instance.new("Frame")
painel.Size = UDim2.fromOffset(255, 245)
painel.Position = UDim2.new(0.5, -127, 0.5, -122)
painel.BackgroundColor3 = Color3.fromRGB(22, 25, 25)
painel.BorderSizePixel = 0
painel.Active = true
painel.Draggable = true
painel.Parent = gui
Instance.new("UICorner", painel)

local function texto(t, y, h, size)
 local l = Instance.new("TextLabel")
 l.Size = UDim2.new(1, -20, 0, h)
 l.Position = UDim2.fromOffset(10, y)
 l.BackgroundTransparency = 1
 l.TextColor3 = Color3.fromRGB(235, 239, 233)
 l.Text = t
 l.TextSize = size
 l.TextWrapped = true
 l.Font = Enum.Font.Gotham
 l.Parent = painel
 return l
end
local titulo = texto("OROCH1 OVO  •  BETA", 5, 32, 15)
titulo.Font = Enum.Font.GothamBold
local melhor = texto("Procurando ovos...", 40, 55, 14)
local estado = texto("Aguardando dados do jogo", 198, 36, 11)
estado.TextColor3 = Color3.fromRGB(190, 195, 190)
local function botao(t, y)
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(1, -20, 0, 38)
 b.Position = UDim2.fromOffset(10, y)
 b.BackgroundColor3 = Color3.fromRGB(53, 91, 61)
 b.TextColor3 = Color3.new(1, 1, 1)
 b.Text = t
 b.TextSize = 14
 b.Font = Enum.Font.GothamMedium
 b.Parent = painel
 Instance.new("UICorner", b)
 return b
end
local tp = botao("Ir para o melhor ovo", 100)
local auto = botao("Auto roubo: DESLIGADO", 145)
local abrir = Instance.new("TextButton")
abrir.Size = UDim2.fromOffset(95, 34)
abrir.Position = UDim2.new(0, 10, 0.4, 0)
abrir.Text = "Oroch1 Ovo"
abrir.BackgroundColor3 = Color3.fromRGB(53, 91, 61)
abrir.TextColor3 = Color3.new(1, 1, 1)
abrir.Font = Enum.Font.GothamMedium
abrir.TextSize = 12
abrir.Parent = gui
Instance.new("UICorner", abrir)
abrir.Activated:Connect(function() painel.Visible = not painel.Visible end)

local alvo = nil
local repetindo = false
local geracaoAuto = 0
local ativo = true
local function posicao(obj)
 if obj:IsA("Model") then return obj:GetPivot().Position end
 if obj:IsA("BasePart") then return obj.Position end
 return nil
end
local function procurar()
 local pasta = workspace:FindFirstChild("AreaEggSlotsClient")
 if not pasta then
  alvo = nil
  melhor.Text = "Ovos não encontrados"
  estado.Text = "Pasta de ovos não encontrada"
  return
 end
 local escolha, maior, vistos = nil, nil, 0
 for _, obj in ipairs(pasta:GetChildren()) do
  if obj:IsA("Model") or obj:IsA("BasePart") then
   vistos = vistos + 1
   local valor = tonumber(obj:GetAttribute("Income") or obj:GetAttribute("EarningRate"))
   if valor and valor >= 0 and (not maior or valor > maior) then
    maior, escolha = valor, obj
   end
  end
 end
 alvo = escolha
 if escolha then
  local raridade = escolha:GetAttribute("Rarity") or escolha:GetAttribute("RarityTier") or "?"
  melhor.Text = "MELHOR OVO\n" .. tostring(escolha.Name) .. "  |  " .. tostring(raridade) .. "\nValor: " .. tostring(maior)
  estado.Text = tostring(vistos) .. " ovos detectados"
 else
  melhor.Text = vistos > 0 and "Nenhum ovo com valor legível" or "Nenhum ovo encontrado"
  estado.Text = vistos > 0 and "O jogo não mostrou o valor dos ovos" or "Aguardando ovos aparecerem"
 end
end
local function irAoAlvo(interagir)
 if not alvo or not alvo.Parent then estado.Text = "Sem alvo disponível" return end
 local personagem = player.Character
 local raiz = personagem and personagem:FindFirstChild("HumanoidRootPart")
 local destino = posicao(alvo)
 if not raiz or not destino then estado.Text = "Personagem ou ovo indisponível" return end
 raiz.CFrame = CFrame.new(destino + Vector3.new(0, 3, 0))
 if interagir then
  local prompt = alvo:FindFirstChildWhichIsA("ProximityPrompt", true)
  if prompt and type(fireproximityprompt) == "function" then
   local ok = pcall(fireproximityprompt, prompt)
   estado.Text = ok and "Tentativa enviada; confira no jogo" or "Não foi possível interagir"
  else
   estado.Text = "Interação automática indisponível"
  end
 else
  estado.Text = "Tentando chegar no ovo"
 end
end
tp.Activated:Connect(function() irAoAlvo(false) end)
auto.Activated:Connect(function()
 repetindo = not repetindo
 geracaoAuto = geracaoAuto + 1
 local minhaGeracao = geracaoAuto
 auto.Text = repetindo and "Auto roubo: LIGADO" or "Auto roubo: DESLIGADO"
 if repetindo then
  task.spawn(function()
   while ativo and repetindo and minhaGeracao == geracaoAuto do
    procurar()
    if alvo then irAoAlvo(true) end
    task.wait(5)
   end
  end)
 end
end)
gui.Destroying:Connect(function() ativo = false repetindo = false end)
task.spawn(function()
 while ativo do
  procurar()
  task.wait(3)
 end
end)
