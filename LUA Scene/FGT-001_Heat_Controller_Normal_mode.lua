--[[    L'activation de cette scène va rechercher toutes les zones programmées ainsi que 
        toutes les vannes associées aux zones et active la programmation des zones puis
        configure les vannes FGT-001 en mode heat (normal).
        Cette scène a été édité par Julien Wetzel
        Le code source et les mises à jours se trouvent au lien suivant :
        https://github.com/st4rg33k/Fibaro-HC3 
]]

local climateZones = api.get("/panels/climate?detailed=true")

for k,zone in pairs(climateZones) do
  local devicesList = zone.properties.devices

  if zone.active == false then
    api.put("/panels/climate/"..k, {active = true})
    fibaro.debug("CLIMAT","Activation de la zone "..zone.name)
  end

  for _,id in pairs(devicesList) do
    api.put("/devices/"..api.get("/devices/"..id).parentId, {properties = {pollingInterval = -1}})
    api.put("/devices/"..id, {properties = {saveLogs = true}, enabled = true, visible = true})
    api.put("/devices/"..id, {parameters = {{id = 2, value = 513, size = 4},{id = 3, value = 1, size = 4}}, useTemplate = true})
    api.post("/devices/"..id.."/action/setProtection", {args={"2"}})
    api.post("/devices/"..id.."/action/setThermostatMode", {args = {"Heat"}})
    fibaro.debug("CLIMAT","[ID:"..id.."] "..fibaro.getName(id).." | Mode normal activé")
  end
end
