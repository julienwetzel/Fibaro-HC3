{
  conditions = { {
      id = 100,
      isTrigger = true,
      operator = "anyValue",
      property = "windowOpened",
      type = "device"
    }, {
      id = 113,
      isTrigger = true,
      operator = "anyValue",
      property = "windowOpened",
      type = "device"
    }, {
      id = 117,
      isTrigger = true,
      operator = "anyValue",
      property = "windowOpened",
      type = "device"
    }, {
      id = 175,
      isTrigger = true,
      operator = "anyValue",
      property = "windowOpened",
      type = "device"
    }, {
      id = 179,
      isTrigger = true,
      operator = "anyValue",
      property = "windowOpened",
      type = "device"
    }, {
      id = 186,
      isTrigger = true,
      operator = "anyValue",
      property = "windowOpened",
      type = "device"
    }, {
      id = 190,
      isTrigger = true,
      operator = "anyValue",
      property = "windowOpened",
      type = "device"
    }, {
      id = 194,
      isTrigger = true,
      operator = "anyValue",
      property = "windowOpened",
      type = "device"
    } },
  operator = "any"
}

--[[    L'activation de cette scène va rechercher dans quels vannes thermostatique FGT-001
        une fenêtre est détectée ouverte et va fermer toutes les vannes qui se trouvent dans
        la zone définie dans le panneau climat.

        Il est recommandé de désactiver cette scène lorsque votre profil "été" est activé.
        En effet, en été, les vannes sont configurés au max (ManufacturerSpecific) lorsque
        la chauffage a été arrêté.

        Cette scène a été édité par Julien Wetzel
        Le code source et les mises à jours se trouvent au lien suivant :
        https://github.com/st4rg33k/Fibaro-HC3 
]]

api.post("/globalVariables", {name = "climatZoneWindowOpen", isEnum = false, readOnly = true, value = "[]"})

local CZWO_last = json.decode(fibaro.getGlobalVariable("climatZoneWindowOpen"))
local CZWO_new = {}

local climateZones = api.get("/panels/climate?detailed=true")

for k,zone in pairs(climateZones) do
  local devicesList = zone.properties.devices
  local zoneWindowOpened = false
  CZWO_new[k] = false

  for _,id in pairs(devicesList) do

    if fibaro.getValue(id, "windowOpened") == true then
      zoneWindowOpened = true
      CZWO_new[k] = true
    end
  end

  if zoneWindowOpened == false and CZWO_new[k] ~= CZWO_last[k] then
    fibaro.debug("CLIMAT","Fenêtre ouverte dans la zone "..zone.name)       

    for _,id in pairs(devicesList) do
      fibaro.debug("CLIMAT","[ID:"..id.."] "..fibaro.getName(id))
      api.post("/devices/"..id.."/action/setThermostatMode", {args = {"Off"}})
      fibaro.debug("CLIMAT","[ID:"..id.."] "..fibaro.getName(id).." | Mode fermé(Off)")
    end

  elseif zoneWindowOpened == false and CZWO_new[k] ~= CZWO_last[k] then
    fibaro.debug("CLIMAT","Fenêtre fermée dans la zone "..zone.name)

    for _,id in pairs(devicesList) do
      fibaro.debug("CLIMAT","[ID:"..id.."] "..fibaro.getName(id))
      api.post("/devices/"..id.."/action/setThermostatMode", {args = {"Heat"}})
      api.post("/devices/"..id.."/action/setHeatingThermostatSetpoint", {args = {zone.properties.currentTemperatureHeating}})
      api.post("/devices/"..id.."/action/retryScheduleSynchronization", {args = {"1"}, delay = 0})
      fibaro.debug("CLIMAT","[ID:"..id.."] "..fibaro.getName(id).." | Mode normal | Température programmée: "..tostring(zone.properties.currentTemperatureHeating).."°C")
    end
  end
  fibaro.setGlobalVariable("climatZoneWindowOpen", json.encode(CZWO_new))
end
