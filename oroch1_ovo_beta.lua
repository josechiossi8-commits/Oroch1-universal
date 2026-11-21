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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local registros = {}
local pedindo = false
local function atualizarRegistros()
 if pedindo then return end
 pedindo = true
 task.spawn(function()
  local encontrados = {}
  local client = ReplicatedStorage:FindFirstChild("Client")
  local modulo = client and client:FindFirstChild("EggState")
  if modulo then
   local ok, estadoOvos = pcall(require, modulo)
   if ok and type(estadoOvos) == "table" and type(estadoOvos.ReadFieldEggs) == "function" then
    local sucesso, resultado = pcall(estadoOvos.ReadFieldEggs)
    if sucesso and type(resultado) == "table" then table.insert(encontrados, resultado.Records or resultado) end
   end
  end
  local remoto = ReplicatedStorage:FindFirstChild("RF/EggWorld/AskFieldEggSnapshot", true)
   or ReplicatedStorage:FindFirstChild("AskFieldEggSnapshot", true)
   or ReplicatedStorage:FindFirstChild("Eggs: RequestAreaEggSnapshot", true)
  if remoto and remoto:IsA("RemoteFunction") then
   local ok, resultado = pcall(function() return remoto:InvokeServer() end)
   if ok and type(resultado) == "table" then table.insert(encontrados, resultado.Records or resultado) end
  end
  registros = encontrados
  pedindo = false
 end)
end
local function procurar()
 local pasta = workspace:FindFirstChild("AreaEggSlotsClient")
 local modelos = {}
 if pasta then
  for _, obj in ipairs(pasta:GetChildren()) do
   if obj:IsA("Model") or obj:IsA("BasePart") then
    modelos[tostring(obj:GetAttribute("UID") or obj:GetAttribute("Uid") or obj.Name)] = obj
   end
  end
 end
 local candidatos = {}
 local function adicionar(uid, nome, raridade, valor, modelo, localizacao)
  valor = tonumber(valor)
  if modelo and not modelo.Parent then modelo = nil end
  if valor and valor >= 0 and (modelo or localizacao) then
   table.insert(candidatos, { uid = uid, nome = nome, raridade = raridade, valor = valor, modelo = modelo, localizacao = localizacao })
  end
 end
 for _, lista in ipairs(registros) do
  if type(lista) == "table" then
   for chave, item in pairs(lista) do
    if type(item) == "table" and item.State ~= "Carried" and item.State ~= 2 then
     local uid = item.Uid or item.UID or (type(chave) == "string" and chave)
     local cf = item.BoundsCFrame or item.BottomCFrame or item.CFrame
     local ponto = typeof(cf) == "CFrame" and cf.Position or nil
     local modelo = uid and modelos[tostring(uid)] or nil
     adicionar(uid, item.AssetCategory or item.Category or uid or "Ovo", item.Rarity or item.RarityTier or "?", item.Income or item.EarningRate, modelo, ponto)
    end
   end
  end
 end
 for uid, obj in pairs(modelos) do
  adicionar(uid, obj:GetAttribute("Category") or obj.Name, obj:GetAttribute("Rarity") or obj:GetAttribute("RarityTier") or "?", obj:GetAttribute("Income") or obj:GetAttribute("EarningRate"), obj, nil)
 end
 table.sort(candidatos, function(a, b) return a.valor > b.valor end)
 alvo = candidatos[1]
 if alvo then
  melhor.Text = "MELHOR OVO\n" .. tostring(alvo.nome) .. "  |  " .. tostring(alvo.raridade) .. "\nValor: " .. tostring(alvo.valor)
  estado.Text = tostring(#candidatos) .. " registros com valor"
 else
  melhor.Text = "Nenhum ovo com valor legível"
  estado.Text = "Ainda não consegui ler os dados dos ovos"
 end
end
local function irAoAlvo(interagir)
 if not alvo then estado.Text = "Sem alvo disponível" return end
 local personagem = player.Character
 local raiz = personagem and personagem:FindFirstChild("HumanoidRootPart")
 local destino = alvo.modelo and alvo.modelo.Parent and posicao(alvo.modelo) or alvo.localizacao
 if not raiz or not destino then estado.Text = "Personagem ou ovo indisponível" return end
 raiz.CFrame = CFrame.new(destino + Vector3.new(0, 3, 0))
 if interagir then
  local prompt = alvo.modelo and alvo.modelo:FindFirstChildWhichIsA("ProximityPrompt", true)
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
  atualizarRegistros()
  task.wait(1)
  if ativo then procurar() end
  task.wait(4)
 end
end)
