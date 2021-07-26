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
    self.boolean = ""
    self.boxInfo = {}
	self.config = Config:new(self)
    self.model = self.config:getModel()
	self.auth = Auth:new(self)
end

function QuickApp:actionButtonPressed(param)
    self:updateView("refresh_true", "text", "LOADING...")
    local command = param.elementName
    local btn,cmd = {},{}
    for w in command:gmatch("%w+") do table.insert(btn, w) end
    cmd.method = btn[1]
    cmd.command = btn[2]
    self.auth:login(cmd)
end

function QuickApp:displayInfo()
    cmd("displayInfo()")
    local txt = ""
    function msg(t) 
        txt = txt .. "\n" .. t 
        self:debug(t)
    end 

	local data = self.boxInfo
    --print(jdump(json.encode(data))) 
    msg(os.date("Last update : %x %X \n---------------------------------------------"))
    if isEmpty(data) then txt = "Error"
    else
        if data.wifi.data.Enable then msg("WLAN : On") 
        else msg("WLAN : Off")
        end
        if data.wifiguest.data.Enable then msg("Guest WLAN : On")
        else msg("Guest WLAN : Off")
        end
        if data.centralstorage.status then msg("Central storage : On")
        else msg("Central storage : Off")
        end
        if data.homeapp.status then msg("Home App : On")
        else msg("Home App : Off")
        end
        if data.wwan.status.EnableTethering then msg("Internet Mobile : On")
        else msg("Internet Mobile : Off")
        end
        if json.decode(data.dyndns.status).result then msg("DynDNS : On")
        else msg("DynDNS : Off")
        end
        if data.vpn.data.config.Server[1].Enable then msg("VPN : On")
        else msg("VPN : Off")
        end
        msg("---------------------------------------------\nAdvanced Info\n---------------------------------------------")
        msg("Internet Connection : " .. data.controller.status.Connection)
        msg("External IP : " .. data.wan.data.IPAddress)
        msg("Software version : " .. data.device.status.SoftwareVersion)
    end
    self:updateView("label1", "text", txt)
    self:updateView("refresh_true", "text", "Refresh")
end

function QuickApp:setBoxInfo(t) self.boxInfo = TableConcat(self.boxInfo,t) end
