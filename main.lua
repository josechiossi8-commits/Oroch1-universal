local partes = {}
local base = "https://raw.githubusercontent.com/josechiossi8-commits/Oroch1-universal/main/oroch1-partes/parte"
for i = 1, 4 do
 partes[i] = game:HttpGet(base .. i .. ".txt")
end
local executar, erro = loadstring(table.concat(partes))
if not executar then error("Oroch1: " .. tostring(erro)) end
executar()
