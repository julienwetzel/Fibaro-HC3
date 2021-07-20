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

class 'RTV1905VW'

function RTV1905VW:new()
    return self
end
-----------------------------------------------------------------------------
function RTV1905VW:getLoginBody()
	local body = {
		service = "sah.Device.Information",
		method = "createContext",
		parameters = {
			applicationName = "webui",
			username = Config:getUsername(),
			password = Config:getPassword()
		}
	}
	return body
end
-----------------------------------------------------------------------------
function RTV1905VW:setDynDNS(boolean)
	cmd("RTV1905VW:setDynDNS(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login(function() Swisscom:setDynDNS(boolean) end)
	else
		local url = "/sysbus/NMC/Guest:set"
		local body = {
                    service = "com.swisscom.apsm/dyndns.com.swisscom.apsm.dyndns",
                    method = "Configure",
                    parameters = {
                        enable = boolean,
                        name = "1786"
                    }
                    }

		local callback = function(r)
			print(jdump(json.encode(r)))
			if r.status == 200 then Swisscom:updateInfo()
			else badNew("RTV1905VW:setDynDNS()", r.status)
			end
			Auth:resetAuth()
		end
        print(jdump(json.encode(self:getHeaders({}))))
        print(jdump(json.encode(body)))
		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setHomeApp(boolean)
	cmd("RTV1905VW:setHomeApp(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login(function() Swisscom:setHomeApp(boolean) end)
	else
		local url = "/sysbus/NMC/Guest:set"
		local body = {
                        service = "com.vestiacom.rnas/com/vestiacom/rnas.com.vestiacom.rnas",
                        method = "SetEnabled",
                        parameters = {
                            enable = boolean
                        }
                        }

		local callback = function(r)
			print(jdump(json.encode(r)))
			if r.status == 200 then Swisscom:updateInfo()
			else badNew("RTV1905VW:setHomeApp()", r.status)
			end
			Auth:resetAuth()
		end
        print(jdump(json.encode(self:getHeaders({}))))
        print(jdump(json.encode(body)))
		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setCentralStorage(boolean)
	cmd("RTV1905VW:setCentralStorage(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login(function() Swisscom:setCentralStorage(boolean) end)
	else
		local url = "/sysbus/NMC/Guest:set"
		local body = {
			service = "com.swisscom.stargate/ws/centralstorage.com.swisscom.stargate.centralstorage",
			method = "SetState",
			parameters = {
				state = boolean
			}
		}

		local callback = function(r)
			print(jdump(json.encode(r)))
			if r.status == 200 then Swisscom:updateInfo()
			else badNew("RTV1905VW:setCentralStorage()", r.status)
			end
			Auth:resetAuth()
		end
        print(jdump(json.encode(self:getHeaders({}))))
        print(jdump(json.encode(body)))
		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setGuestWifi(boolean)
	cmd("RTV1905VW:setGuestWifi(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login(function() Swisscom:setGuestWifi(boolean) end)
	else
		local url = "/sysbus/NMC/Guest:set"
		local body = {
			parameters = {
				Enable = boolean
			}
		}

		local callback = function(r)
			--print(jdump(json.encode(r)))
			if r.status == 200 then Swisscom:updateInfo()
			else badNew("RTV1905VW:setGuestWifi()", r.status)
			end
			Auth:resetAuth()
		end

		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setWifi(boolean)
	cmd("RTV1905VW:setWifi(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login(function() Swisscom:setWifi(boolean) end)
	else
		--print(Auth:getContextID()) 
		local url = "/sysbus/NMC/Wifi:set"
		local body = {
			parameters = {
				Enable = boolean,
				ConfigurationMode = true,
				Status = boolean
			}
		}

		local callback = function(r)
			--print(jdump(json.encode(r)))
			if r.status == 200 then Swisscom:updateInfo()
			else badNew("RTV1905VW:setWifi()", r.status)
			end
			Auth:resetAuth()
		end

		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:getHeaders(headers)
	cmd("RTV1905VW:getHeaders()")
	local c = Auth:getContextID()
	if isEmpty(c) then badNew("RTV1905VW:getHeaders()", 800) end
	headers = {
		["Content-Type"] = "application/json",
		["Accept"] = "application/json",
		["Cookie"] = Auth:getCookie(),
		["Authorization"] = "X-Sah " .. Auth:getContextID()
	}
	return headers
end
-----------------------------------------------------------------------------
function RTV1905VW:getInfo()
	cmd("RTV1905VW:getInfo()")
	if isEmpty(Auth:getContextID()) then
		Auth:login(function() RTV1905VW:getInfo() end)
	else
		--body = {parameters = "null"}
		--print(Auth:getContextID())  
		local urls = {}
		urls = {
			[1] = {title = "time", url = "/sysbus/Time:getTime"},
			[2] = {title = "lan", url = "/sysbus/APController/LAN:get"},
			[3] = {title = "wan", url = "/sysbus/NMC:getWANStatus"},
			[4] = {title = "controller", url = "/sysbus/APController:get"},
			[5] = {title = "wifi", url = "/sysbus/NMC/Wifi:get"},
			[6] = {title = "device", url = "/sysbus/DeviceInfo:get"},
			[7] = {title = "wifiguest", url = "/sysbus/NMC/Guest:get"}
		}
		--Lien traduction fr : http://192.168.1.1/static/translations/stargatev2/fr.json
		--lien traduction de : http://192.168.1.1/static/translations/stargatev2/de.json
		--lien traduction it : http://192.168.1.1/static/translations/stargatev2/it.json

		local data = {}
		local t = {}
		local num = 0
		for i=1, #urls do
			local callback = function(r)
				data = json.decode(r.data).result
				--print(jdump(json.encode(r))) 
				if r.status == 200 then
					t = {}
					if isEmpty(data) then t[urls[i].title] = {}
					else t[urls[i].title] = data
					end

					Swisscom:setBoxInfo(t)
					num = num + 1

					if num == #urls then displayInfo() end
				else badNew("RTV1905VW:getInfo()", r.status)
				end
				Auth:resetAuth()
			end

			url = urls[i].url
			HTTPClient:post(url, body, callback, error, self:getHeaders({})) 
		end
		return {}
	end
end
