print("----------------------------------------------------")
local climateZones = api.get("/panels/climate?detailed=true")

for k,zone in pairs(climateZones) do
  local devicesList = zone.properties.devices

  if zone.active == true then
    api.put("/panels/climate/"..k, {active = {"false"}})
    print("Désactivation de la zone "..zone.name)
  end

  for i,id in pairs(devicesList) do

    if fibaro.getValue(id, "thermostatMode") ~= "ManufacturerSpecific" then
      api.post("/devices/"..id.."/action/setThermostatMode", {args = {"ManufacturerSpecific"}})
      print("Mode été pour la vanne id: "..id)
    end
  end
end
