-- Oroch1 Hub | Roube um Ovo | versao experimental
-- A coleta depende das regras do servidor e dos prompts que o jogo mostra.
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("Oroch1HubOvo")
if previous then previous:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "Oroch1HubOvo"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui
local blue = Color3.fromRGB(22, 73, 176)
local dark = Color3.fromRGB(11, 32, 83)
local medium = Color3.fromRGB(18, 52, 126)
local white = Color3.fromRGB(242, 248, 255)
local function corner(obj, r)
 local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 6); c.Parent = obj
end
local function outline(obj, color)
 local s = Instance.new("UIStroke"); s.Color = color or Color3.fromRGB(74, 151, 255); s.Thickness = 1; s.Parent = obj
end
local function label(parent, text, size, pos, fontSize)
 local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1; l.Size = size; l.Position = pos
 l.Text = text; l.TextColor3 = white; l.Font = Enum.Font.Gotham; l.TextSize = fontSize or 12
 l.TextXAlignment = Enum.TextXAlignment.Left; l.TextTruncate = Enum.TextTruncate.AtEnd; l.Parent = parent; return l
end
local function button(parent, text, size, pos, bg, fontSize)
 local b = Instance.new("TextButton"); b.Size = size; b.Position = pos; b.BackgroundColor3 = bg or medium
 b.Text = text; b.TextColor3 = white; b.Font = Enum.Font.GothamBold; b.TextSize = fontSize or 11
 b.AutoButtonColor = true; b.Parent = parent; corner(b, 5); return b
end
local open = button(gui, "OROCH1", UDim2.fromOffset(78, 28), UDim2.new(1, -88, 0.5, -14), blue, 11)
open.Visible = false
local frame = Instance.new("Frame")
frame.Name = "Painel"; frame.AnchorPoint = Vector2.new(1, 0.5); frame.Size = UDim2.fromOffset(235, 320)
frame.Position = UDim2.new(1, -10, 0.5, 0); frame.BackgroundColor3 = dark; frame.BorderSizePixel = 0; frame.Parent = gui
corner(frame, 9); outline(frame)
local scale = Instance.new("UIScale"); scale.Parent = frame
local function resize()
 local camera = Workspace.CurrentCamera
 if camera then scale.Scale = math.min(1, math.max(0.55, (camera.ViewportSize.Y - 12) / 320), math.max(0.55, (camera.ViewportSize.X - 16) / 235)) end
end
resize()
local cameraConnection
if Workspace.CurrentCamera then cameraConnection = Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(resize) end
local title = label(frame, "OROCH1 HUB", UDim2.new(1, -82, 0, 30), UDim2.fromOffset(10, 2), 12)
title.Font = Enum.Font.GothamBold
local collapse = button(frame, "−", UDim2.fromOffset(30, 23), UDim2.new(1, -35, 0, 5), medium, 16)
collapse.Activated:Connect(function() frame.Visible = false; open.Visible = true end)
open.Activated:Connect(function() frame.Visible = true; open.Visible = false end)
local close = button(frame, "X", UDim2.fromOffset(25, 23), UDim2.new(1, -64, 0, 5), medium, 11)
close.Activated:Connect(function() gui:Destroy() end)
local refresh = button(frame, "ATUALIZAR", UDim2.new(1, -20, 0, 23), UDim2.fromOffset(10, 34), blue, 10)
local hint = label(frame, "OVOS DETECTADOS • MAIS PERTO PRIMEIRO", UDim2.new(1, -20, 0, 18), UDim2.fromOffset(10, 60), 9)
hint.TextColor3 = Color3.fromRGB(173, 207, 255)
local list = Instance.new("ScrollingFrame"); list.BackgroundTransparency = 1; list.Size = UDim2.new(1, -20, 0, 146)
list.Position = UDim2.fromOffset(10, 79); list.BorderSizePixel = 0; list.ScrollBarThickness = 4
list.ScrollBarImageColor3 = Color3.fromRGB(116, 190, 255); list.CanvasSize = UDim2.new(); list.Parent = frame
local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 4); layout.SortOrder = Enum.SortOrder.LayoutOrder; layout.Parent = list
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
 list.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y)
end)
local status = label(frame, "Carregando...", UDim2.new(1, -20, 0, 29), UDim2.fromOffset(10, 226), 10)
status.TextWrapped = true; status.TextTruncate = Enum.TextTruncate.None
local go = button(frame, "▶  GO", UDim2.new(0.5, -12, 0, 25), UDim2.new(0, 10, 1, -61), blue, 11)
local stop = button(frame, "PARAR", UDim2.new(0.5, -12, 0, 25), UDim2.new(0.5, 2, 1, -61), medium, 11)
local markBase = button(frame, "MARCAR BASE", UDim2.new(0.5, -12, 0, 25), UDim2.new(0, 10, 1, -31), medium, 10)
local tpBase = button(frame, "TP BASE", UDim2.new(0.5, -12, 0, 25), UDim2.new(0.5, 2, 1, -31), blue, 10)
outline(go); outline(stop); outline(markBase); outline(tpBase)
local selected, generation, busy = nil, 0, false
local savedBase = nil
local function basePart(prompt)
 local p = prompt.Parent
 if p and p:IsA("Attachment") then p = p.Parent end
 if p and p:IsA("BasePart") then return p end
 local model = prompt:FindFirstAncestorOfClass("Model")
 return model and (model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true)) or nil
end
local function rootPart()
 local c = player.Character
 return c and c:FindFirstChild("HumanoidRootPart")
end
local function isEggPrompt(p)
 if not p:IsA("ProximityPrompt") or not p.Enabled then return false end
 local name = string.lower(p.Name)
 if name == "carryareaegg" then return true end
 local context = string.lower(p.Name .. " " .. p.ActionText .. " " .. p.ObjectText)
 local parent = p.Parent
 if parent then context = context .. " " .. string.lower(parent.Name) end
 local egg = context:find("egg", 1, true) or context:find("ovo", 1, true)
 local action = context:find("carry", 1, true) or context:find("steal", 1, true) or context:find("pegar", 1, true) or context:find("roubar", 1, true)
 return egg ~= nil and action ~= nil
end
local function possibleName(s)
 if type(s) ~= "string" then return nil end
 s = s:gsub("<[^>]->", ""):match("^%s*(.-)%s*$")
 if #s == 0 or #s > 40 or s:find("[\r\n$%%]") or s:match("^%d") then return nil end
 local low = s:lower()
 local generic = {egg=true, ovo=true, eggs=true, carry=true, steal=true, pegar=true, roubar=true, model=true, part=true, attachment=true, common=true, rare=true, epic=true, legendary=true, mythic=true, godly=true}
 if generic[low] or low:find("/s", 1, true) or low:find(" kg", 1, true) then return nil end
 return s
end
local function describe(p)
 local nodes = {p}; local ancestor = p.Parent
 for _ = 1, 3 do
  if not ancestor or ancestor == Workspace then break end
  table.insert(nodes, ancestor); ancestor = ancestor.Parent
 end
 for _, obj in ipairs(nodes) do
  for _, key in ipairs({"EggName", "PetName", "CreatureName", "DisplayName"}) do
   local name = possibleName(obj:GetAttribute(key)); if name then return name end
   local value = obj:FindFirstChild(key)
   if value and value:IsA("StringValue") then name = possibleName(value.Value); if name then return name end end
  end
 end
 local object = possibleName(p.ObjectText); if object then return object end
 for _, obj in ipairs(nodes) do
  for _, v in ipairs(obj:GetDescendants()) do
   if (v:IsA("TextLabel") or v:IsA("TextButton")) and v:FindFirstAncestorWhichIsA("BillboardGui") then
    local field = v.Name:lower()
    if field == "name" or field == "eggname" or field == "petname" or field == "creaturename" or field == "title" then
     local name = possibleName(v.Text); if name then return name end
    end
   end
  end
 end
 return "Ovo (nome não disponível)"
end
local function scan()
 local root = rootPart(); local found = {}
 for _, p in ipairs(Workspace:GetDescendants()) do
  if isEggPrompt(p) then
   local part = basePart(p)
   if part then
    local distance = root and (root.Position - part.Position).Magnitude or math.huge
    table.insert(found, {prompt = p, part = part, distance = distance})
   end
  end
 end
 table.sort(found, function(a, b) return a.distance < b.distance end)
 return found
end
local function refreshList()
 if not gui.Parent then return end
 for _, child in ipairs(list:GetChildren()) do if child:IsA("GuiObject") then child:Destroy() end end
 local ok, results = pcall(scan)
 if not ok then status.Text = "Erro ao procurar ovos."; return end
 if selected and (not selected.Parent or not isEggPrompt(selected)) then selected = nil end
 if not selected and results[1] then selected = results[1].prompt end
 local selectedStillListed = false
 for i = 1, #results do
  local entry = results[i]
  if entry.prompt == selected then selectedStillListed = true end
 end
 if not selectedStillListed and results[1] then selected = results[1].prompt end
 for i = 1, #results do
  local entry = results[i]; local name = describe(entry.prompt)
  local item = button(list, "", UDim2.new(1, -4, 0, 33), UDim2.new(), entry.prompt == selected and blue or medium, 10)
  item.LayoutOrder = i
  outline(item, entry.prompt == selected and Color3.fromRGB(116, 190, 255) or Color3.fromRGB(41, 92, 175))
  local main = label(item, name, UDim2.new(1, -12, 0, 15), UDim2.fromOffset(6, 2), 10); main.Font = Enum.Font.GothamBold
  local details = entry.distance == math.huge and "Distância indisponível" or string.format("%.0f studs • toque para selecionar", entry.distance)
  local sub = label(item, details, UDim2.new(1, -12, 0, 12), UDim2.fromOffset(6, 18), 9); sub.TextColor3 = Color3.fromRGB(179, 205, 244)
  item.Activated:Connect(function() selected = entry.prompt; refreshList() end)
 end
 if not busy then
  if #results == 0 then status.Text = "Nenhum prompt de ovo visível. Chegue perto e atualize."
  else status.Text = string.format("%d prompt(s) visível(is). Selecione um e toque GO.", #results) end
 end
end
refresh.Activated:Connect(refreshList)
markBase.Activated:Connect(function()
 local root = rootPart()
 if not root then status.Text = "Personagem indisponível."; return end
 savedBase = root.CFrame
 status.Text = "Base marcada neste local!"
end)
tpBase.Activated:Connect(function()
 if not savedBase then status.Text = "Na sua base, toque MARCAR BASE primeiro."; return end
 local root = rootPart()
 if not root then status.Text = "Personagem indisponível."; return end
 generation = generation + 1; busy = false
 local ok = pcall(function() root.CFrame = savedBase end)
 if ok then status.Text = "TP solicitado. Confira se chegou na base."
 else status.Text = "Não foi possível ir até a base." end
end)
stop.Activated:Connect(function() generation = generation + 1; busy = false; status.Text = "Tentativa interrompida." end)
go.Activated:Connect(function()
 if busy then return end
 local p = selected; local root = rootPart()
 if not p or not p.Parent or not isEggPrompt(p) then status.Text = "Selecione um ovo disponível."; return end
 local part = basePart(p)
 if not root or not part then status.Text = "Personagem ou ovo indisponível."; return end
 if type(fireproximityprompt) ~= "function" then status.Text = "Executor sem suporte a interação automática."; return end
 busy = true; generation = generation + 1; local token = generation
 status.Text = "Indo até o ovo..."
 task.spawn(function()
  local ok = pcall(function() root.CFrame = part.CFrame * CFrame.new(0, 0, 3) end)
  if not ok then if token == generation then busy = false; status.Text = "Não foi possível ir até o ovo." end; return end
  task.wait(0.5)
  if token ~= generation or not gui.Parent then return end
  if not p.Parent or not p.Enabled then busy = false; status.Text = "Ovo indisponível. Atualize."; return end
  local oldDuration = p.HoldDuration
  local fired, err = pcall(function() p.HoldDuration = 0; fireproximityprompt(p) end)
  pcall(function() if p.Parent then p.HoldDuration = oldDuration end end)
  if token ~= generation or not gui.Parent then return end
  busy = false
  if fired then status.Text = "Interação enviada. Confira se pegou o ovo."
  else status.Text = "Interação falhou. Tente pegar manualmente."; warn("Oroch1 Hub: " .. tostring(err)) end
 end)
end)
gui.Destroying:Connect(function() generation = generation + 1; if cameraConnection then cameraConnection:Disconnect() end end)
refreshList()
