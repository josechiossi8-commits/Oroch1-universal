local base = "https://raw.githubusercontent.com/josechiossi8-commits/Oroch1-universal/6fae1b34c7d7cf5f79bd594d9cc261d1e1600372/oroch1-partes/"
local nomes = {"parte1.txt", "parte2.txt", "parte3_corrigida.txt", "parte4.txt"}
local partes = {}
for i, nome in ipairs(nomes) do
 partes[i] = game:HttpGet(base .. nome)
end
local executar, erro = loadstring(table.concat(partes))
if not executar then error("Oroch1: " .. tostring(erro)) end
executar()
