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

class 'Swisscom' 

function Swisscom:new()
    self.rtv = RTV1905VW:new()
    self:init()
    return self
end

function Swisscom:setDynDNS(boolean)
    cmd("Swisscom:setHomeApp()")
    if self.model == "RTV1905VW" then Auth:login(function() RTV1905VW:setDynDNS(boolean) end) end
end

function Swisscom:setHomeApp(boolean)
    cmd("Swisscom:setHomeApp()")
    if self.model == "RTV1905VW" then Auth:login(function() RTV1905VW:setHomeApp(boolean) end) end
end

function Swisscom:setCentralStorage(boolean)
    cmd("Swisscom:setCentralStorage()")
    if self.model == "RTV1905VW" then Auth:login(function() RTV1905VW:setCentralStorage(boolean) end) end
end

function Swisscom:setGuestWifi(boolean)
    cmd("Swisscom:setGuestWifi()")
    if self.model == "RTV1905VW" then Auth:login(function() RTV1905VW:setGuestWifi(boolean) end) end
end

function Swisscom:setWifi(boolean)
    cmd("Swisscom:setWifi")
    if self.model == "RTV1905VW" then Auth:login(function() RTV1905VW:setWifi(boolean) end) end
end

function Swisscom:getLoginBody()
    cmd("Swisscom:getLoginBody()")
    if self.model == "RTV1905VW" then return RTV1905VW:getLoginBody() end
end

 function Swisscom:updateInfo()
    cmd("Swisscom:updateInfo()")
    if self.model == "RTV1905VW" then Auth:login(function() RTV1905VW:getInfo() end) end
 end

function Swisscom:getBoxInfo() cmd("Swisscom:getBoxInfo()") return self.boxInfo  end 
function Swisscom:setBoxInfo(t) cmd("Swisscom:setBoxInfo()") self.boxInfo = TableConcat(self.boxInfo,t) end

function Swisscom:init()
    self.model = Config:getModel()
    self.boxInfo = {}
end

