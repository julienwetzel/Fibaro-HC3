--[[    L'activation de cette scène va rechercher toutes les zones programmées ainsi que 
        toutes les vannes associées aux zones et désactive la programmation des zones puis
        configure les vannes FGT-001 au max (ManufacturerSpecific).
        Il est nécessaire de désactiver toutes les autres scènes suceptibles de modifier
        l'état des vannes.
        Cette scène a été édité par Julien Wetzel
        Le code source et les mises à jours se trouvent au lien suivant :
        https://github.com/st4rg33k/Fibaro-HC3 
]]

local climateZones = api.get("/panels/climate?detailed=true")

for k,zone in pairs(climateZones) do
  local devicesList = zone.properties.devices

  if zone.active == true then
    api.put("/panels/climate/"..k, {active = {"false"}})
    fibaro.debug("CLIMAT","Désactivation de la zone "..zone.name)
  end

  for _,id in pairs(devicesList) do
    api.post("/devices/"..id.."/action/setThermostatMode", {args = {"ManufacturerSpecific"}})
    api.put("/devices/"..id, {parameters = {{id = 2, value = 0, size = 4},{id = 3, value = 1, size = 4}}, useTemplate = true})
    api.post("/devices/"..id.."/action/setProtection", {args={"2"}})
    api.put("/devices/"..api.get("/devices/"..id).parentId, {properties = {pollingInterval = -1}})
    api.put("/devices/"..id, {properties = {saveLogs = false}, enabled = false, visible = false})
    fibaro.debug("CLIMAT","[ID:"..id.."] "..fibaro.getName(id).." | Mode été activé")
  end
end
