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

function RTV1905VW:new(app)
    self.quickapp = app
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
function RTV1905VW:reboot()
	cmd("RTV1905VW:reboot()")
	if isEmpty(Auth:getContextID()) then
		Auth:login(function() self:setDynDNS(boolean) end)
	else
		local url = "/sysbus/NMC:reboot"
		local body = {parameters = {reason = "Webui reboot"}}

		local callback = function(r)
			if r.status == 200 then self:getInfo()
			else badNew("RTV1905VW:reboot()", r.status)
			end

			Auth:resetAuth()
		end

		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setVPNServer()
    boolean = toboolean(self.command)
	cmd("RTV1905VW:setVPNServer(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login(function() self:setDynDNS(boolean) end)
	else
		local url = "/sysbus/VPN:setServer"
		local body = {
                    parameters = {
                        server = "default",
                        enable = boolean}}

		local callback = function(r)
			if r.status == 200 then self:getInfo()
			else badNew("RTV1905VW:setVPNServer()", r.status)
			end
			Auth:resetAuth()
		end

		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:getNameDynDNS(start)
	cmd("RTV1905VW:getNameDynDNS()")
	if isEmpty(Auth:getContextID()) then
        local boolean = toboolean(self.command)
		Auth:login({method = "setDynDNS", command = boolean})
	else
		local url = "/ws"
		local body = {
                    service = "com.swisscom.apsm/dyndns.com.swisscom.apsm.dyndns",
                    method = "GetName",
                    parameters = { }
                    }

		local callback = function(r)
            --print(jdump(json.encode(r)))
			if r.status ~= 200 then badNew("RTV1905VW:getNameDynDNS()", r.status) end
			start(json.decode(json.decode(r.data).status).result)
		end

		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setDynDNS() 
    local start = function(n)
        local boolean = toboolean(self.command)
        cmd("RTV1905VW:setDynDNS(" .. tostring(boolean) .. ")")
        if isEmpty(Auth:getContextID()) then
            Auth:login({method = "setDynDNS", command = boolean})
        else
            local url = "/ws"
            local body = {
            service = "com.swisscom.apsm/dyndns.com.swisscom.apsm.dyndns",
            method = "Configure",
            parameters = {
                enable = boolean,
                name = n
            }
            }

            local callback = function(r)
                --print(jdump(json.encode(r)))
                if r.status == 200 then
                    self:getInfo()
                else
                    badNew("RTV1905VW:setDynDNS()", r.status)
                end
                Auth:resetAuth()
            end

            HTTPClient:post(url, body, callback, error, self:getHeaders({}))
            return {}
        end
    end
    self:getNameDynDNS(start)
    return {}
end

-----------------------------------------------------------------------------
function RTV1905VW:setInternetMobileConnect()
    local boolean = toboolean(self.command)
	cmd("RTV1905VW:setInternetMobileConnect(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login({method = "getContextID", command = boolean})
	else
		local url = "/sysbus/NMC/WWAN:set"
		local body = {parameters = {EnableTethering = boolean}}

		local callback = function(r)
			if r.status == 200 then self:getInfo()
			else badNew("RTV1905VW:setInternetMobileConnect()", r.status)
			end
			Auth:resetAuth()
		end
        
		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setHomeApp()
    local boolean = toboolean(self.command)
	cmd("RTV1905VW:setHomeApp(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login({method = "setHomeApp", command = boolean})
	else
		local url = "/ws"
		local body = {
                        service = "com.vestiacom.rnas/com/vestiacom/rnas.com.vestiacom.rnas",
                        method = "SetEnabled",
                        parameters = {
                            enable = boolean
                        }
                        }

		local callback = function(r)
			if r.status == 200 then self:getInfo()
			else badNew("RTV1905VW:setHomeApp()", r.status)
			end
			Auth:resetAuth()
		end

		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setCentralStorage()
    local boolean = toboolean(self.command)
	cmd("RTV1905VW:setCentralStorage(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login({method = "setCentralStorage", command = boolean})
	else
		local url = "/ws"
		local body = {
                        service = "com.swisscom.stargate/ws/centralstorage.com.swisscom.stargate.centralstorage",
                        method = "SetState",
                        parameters = {
                            state = boolean
                        }}

		local callback = function(r)
			--print(jdump(json.encode(r)))
			if r.status == 200 then self:getInfo()
			else badNew("RTV1905VW:setCentralStorage()", r.status)
			end
			Auth:resetAuth()
		end
        --print(jdump(json.encode(self:getHeaders({}))))
        --print(jdump(json.encode(body)))
		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setGuestWifi()
    local boolean = toboolean(self.command)
	cmd("RTV1905VW:setGuestWifi(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login({method = "setGuestWifi", command = boolean})
	else
		local url = "/sysbus/NMC/Guest:set"
		local body = {
			parameters = {
				Enable = boolean
			}
		}

		local callback = function(r)
			if r.status == 200 then self:getInfo()
			else badNew("RTV1905VW:setGuestWifi()", r.status)
			end
			Auth:resetAuth()
		end

		HTTPClient:post(url, body, callback, error, self:getHeaders({}))  
		return {}
	end
end
-----------------------------------------------------------------------------
function RTV1905VW:setWifi()
    local boolean = toboolean(self.command)
	cmd("RTV1905VW:setWifi(" .. tostring(boolean) .. ")")
	if isEmpty(Auth:getContextID()) then
		Auth:login({method = "setWifi", command = boolean})
	else
		local url = "/sysbus/NMC/Wifi:set"
		local body = {
			parameters = {
				Enable = boolean,
				ConfigurationMode = true,
				Status = boolean
			}
		}

		local callback = function(r)
			if r.status == 200 then self:getInfo()
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
	--cmd("RTV1905VW:getHeaders()")
	local contextID = Auth:getContextID()
    local cookies = Auth:getCookie()

    local _, _, deviceID, sessionID, reste = string.find(cookies, "(%w+)(.-);%s(.+)")

	if isEmpty(contextID) then badNew("RTV1905VW:getHeaders()", 800) end
	headers = {
		["Content-Type"] = "application/x-sah-ws-4-call+json",
		["Accept"] = "*/*",
        --["Cookie"] = Auth:getCookie(), 
		["Cookie"] = deviceID .. "accept-language=fr-CH,fr; test=test; " .. deviceID .. sessionID .. "; swc/deviceID=" .. deviceID .. "; " .. deviceID .. "/context=" .. contextID,
		["Authorization"] = "X-Sah " .. Auth:getContextID(),
        ["X-Context"] = contextID,
        ["X-Requested-With"] = "XMLHttpRequest",
        ["User-Agent"] = "Fibaro/HC3",
        ["Origin"] = "http://192.168.1.1",
        ["Referer"] = "http://192.168.1.1",
        ["Host"] = "192.168.1.1",
        ["Connection"] = "keep-alive",
        ["Accept-Encoding"] = "gzip, deflate",
        ["Accept-Language"] = "fr-CH,fr;q=0.9"
	}
    
    local headersContent = json.encode(headers)  
    headers["Content-Length"] = tostring(#headersContent)
	return headers
end
-----------------------------------------------------------------------------
function RTV1905VW:getInfo()
	cmd("RTV1905VW:getInfo()")
	if isEmpty(Auth:getContextID()) then
		Auth:login({method = "getInfo", command = "true"})
	else
		local urls = {}
		urls = {
			[1] = {title = "time", url = "/sysbus/Time:getTime"},
			[2] = {title = "lan", url = "/sysbus/APController/LAN:get"},
			[3] = {title = "wan", url = "/sysbus/NMC:getWANStatus"},
			[4] = {title = "controller", url = "/sysbus/APController:get"},
			[5] = {title = "wifi", url = "/sysbus/NMC/Wifi:get"},
			[6] = {title = "device", url = "/sysbus/DeviceInfo:get"},
			[7] = {title = "wifiguest", url = "/sysbus/NMC/Guest:get"},
            [8] = {title = "wwan", url = "/sysbus/NMC/WWAN:get"},
            [9] = {title = "vpn", url = "/sysbus/VPN:getServersConfig"},
            [10] = {title = "homeapp", url = "/ws", body = {
                        service = "com.vestiacom.rnas/com/vestiacom/rnas.com.vestiacom.rnas",
                        method = "GetEnabled",
                        parameters = { }}},
            [11] = {title = "dyndns", url = "/ws", body = {
                        service = "com.swisscom.apsm/dyndns.com.swisscom.apsm.dyndns",
                        method = "IsEnabled",
                        parameters = { }}},
            [12] = {title = "centralstorage", url = "/ws", body = {
                        service = "com.swisscom.stargate/ws/centralstorage.com.swisscom.stargate.centralstorage",
                        method = "GetState",
                        parameters = { }}}
		}
		--Lien traduction fr : http://192.168.1.1/static/translations/stargatev2/fr.json
		--lien traduction de : http://192.168.1.1/static/translations/stargatev2/de.json
		--lien traduction it : http://192.168.1.1/static/translations/stargatev2/it.json 

		local data = {}
		local t = {}
		local num = 0
		for i=1, #urls do
			local callback = function(r)
                --print(jdump(json.encode(r)))
				data = json.decode(r.data)
                --print(data)
				if r.status == 200 then
					t = {}
					if isEmpty(data) then t[urls[i].title] = {}
					else t[urls[i].title] = data
					end

					self.quickapp:setBoxInfo(t)
					num = num + 1

					if num == #urls then self.quickapp:displayInfo() end
				else badNew("RTV1905VW:getInfo() title: " .. urls[i].title, r.status)
				end
				Auth:resetAuth()
			end

			url = urls[i].url
            body = urls[i].body
            --print(jdump(json.encode(self:getHeaders({}))))
			HTTPClient:post(url, body, callback, error, self:getHeaders({})) 
		end
		return {}
	end
end
