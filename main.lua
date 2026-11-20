local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local antigo = playerGui:FindFirstChild("Oroch1Universal")
if antigo then antigo:Destroy() end

local velocidade = nil
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

local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(220, 180)
menu.Position = UDim2.new(0.5, -110, 0.5, -90)
menu.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
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

local aplicar = criarBotao("Aplicar velocidade", 85)
local resetar = criarBotao("Velocidade 16", 130)

local function mudarVelocidade()
    local personagem = player.Character
    local humanoid = personagem and personagem:FindFirstChildOfClass("Humanoid")
    if humanoid and velocidade then
        humanoid.WalkSpeed = velocidade
    end
end

alternar.Activated:Connect(function()
    menu.Visible = not menu.Visible
    alternar.Text = menu.Visible and "Fechar menu" or "Abrir menu"
end)

aplicar.Activated:Connect(function()
    local valor = tonumber(campo.Text)
    if valor and valor >= 1 and valor <= 500 then
        velocidade = valor
        mudarVelocidade()
    else
        campo.Text = ""
        campo.PlaceholderText = "Digite de 1 a 500"
    end
end)

resetar.Activated:Connect(function()
    velocidade = 16
    campo.Text = "16"
    mudarVelocidade()
end)

local conexao = player.CharacterAdded:Connect(function(personagem)
    local humanoid = personagem:WaitForChild("Humanoid", 10)
    if humanoid and velocidade and gui.Parent then
        humanoid.WalkSpeed = velocidade
    end
end)

gui.Destroying:Connect(function()
    conexao:Disconnect()
end)