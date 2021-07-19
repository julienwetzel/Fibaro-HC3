--[[
   Copyright [2021] [Julien Wetzel]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
]]

function QuickApp:onInit()   
    self.app = self
	self.config = Config:new(self)
	self.auth = Auth:new(self.config)
    self.swisscom = Swisscom:new(self.util)
	self:run()
end

function QuickApp:run()

end

function QuickApp:startWifi()
    cmd("QuickApp:startWifi()")
	self.swisscom:setWifi(true)
end

function QuickApp:stopWifi()
    cmd("QuickApp:stopWifi()")
	self.swisscom:setWifi(false) 
end

function QuickApp:refresh()
    cmd("QuickApp:refresh()")
	self.swisscom:updateInfo()
end

function QuickApp:startWifiGuest()
    cmd("QuickApp:startWifiGuest()")
	self.swisscom:setGuestWifi(true)
end

function QuickApp:stopWifiGuest()
    cmd("QuickApp:stopWifiGuest()")
	self.swisscom:setGuestWifi(false)
end

function QuickApp:startCentralStorage()
    cmd("QuickApp:startCentralStorage()")
	self.swisscom:setCentralStorage(true)
end

function QuickApp:stopCentralStorage()
    cmd("QuickApp:stopCentralStorage()")
	self.swisscom:setCentralStorage(false)
end

function QuickApp:startHomeApp()
    cmd("QuickApp:startHomeApp()")
	self.swisscom:setHomeApp(true)
end

function QuickApp:stopHomeApp()
    cmd("QuickApp:stopHomeApp()")
	self.swisscom:setHomeApp(false)
end

function QuickApp:startDynDNS()
    cmd("QuickApp:startDynDNS()")
	self.swisscom:setDynDNS(true)
end

function QuickApp:stopDynDNS()
    cmd("QuickApp:stopDynDNS()")
	self.swisscom:setDynDNS(false)
end
--[[function QuickApp:actionButtonPressed(param)
  local command = param.elementName 
  command = string.gsub(command, "Button", "") --cut part of buttonID which is a command to mower
  local TimeCommand = tonumber( command, 10) 
  self:setVariable("commandAction", command)

  if command == "Park" or command == "Start" then
    self:setVariable( "commandDuration", self.duration )
    self:login()
  elseif TimeCommand ~= nil then    
    self.duration = TimeCommand * 60
    self:updateView( "durationSlider", "value", tostring( math.floor(( TimeCommand * 60 ) * ( 100 / 1440 ))))
    self:updateView( "durationLabel", "text", "Commandes horaires (durée): [hh:mm] " ..TimeCommand.."h")
  else
    self:setVariable( "commandDuration", 0 ) 
    self:login()
  end
end]]

function QuickApp:displayInfo()
	cmd("displayInfo()")
    print("1")
	local data = self.swisscom:getBoxInfo()
    print("2")
    --QuickApp:updateView("label1", "text", "WLAN: " .. tostring(data.wifi.data.Enable)) 
    --self:updateView("label1", "text", "WLAN: test")   
    --QuickApp:updateProperty("txtWifi", "Wifi On")
    
	--print(jdump(json.encode(data)))
    --print(data.wifi.data.Enable)
    --[[if data.wifi.data.Enable == true then self:updateView("wifi", "text", "WLAN On") 
    else self:updateView("wifi", "text", "WLAN off")
    end]]
end
