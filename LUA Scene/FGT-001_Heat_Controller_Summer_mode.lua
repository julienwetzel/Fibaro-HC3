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

  for i,id in pairs(devicesList) do

    if fibaro.getValue(id, "thermostatMode") ~= "ManufacturerSpecific" then
      api.post("/devices/"..id.."/action/setThermostatMode", {args = {"ManufacturerSpecific"}})
      fibaro.debug("CLIMAT","Mode été pour la vanne id: "..id)
    end
  end
end
