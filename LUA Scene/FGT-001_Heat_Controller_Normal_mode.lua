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
    api.put("/panels/climate/"..k, {active = {"true"}})
    fibaro.debug("CLIMAT","Activation de la zone "..zone.name)
  end

  for i,id in pairs(devicesList) do

    if fibaro.getValue(id, "thermostatMode") ~= "Heat" then
      api.post("/devices/"..id.."/action/setThermostatMode", {args = {"Heat"}})
      fibaro.debug("CLIMAT","Mode normal pour la vanne id: "..id)
    end
  end
end
