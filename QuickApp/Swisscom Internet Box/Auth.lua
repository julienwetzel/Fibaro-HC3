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

class 'Auth'

function Auth:new(app)
    self.config = app.config
    self.model = app.model
    self.http = HTTPClient:new({
        baseUrl = 'http://192.168.1.1'
    })
    self.RTV1905VW = RTV1905VW:new(app)
	self:init()  
	return self
end

function Auth:login(info)
    cmd("Auth:login()")
	local url = '/ws'
	local callback = function(r)
        --print(jdump(json.encode(r)))
        local data = json.decode(r.data)
        local contextID = data.data.contextID
        local cookie = r.headers["Set-Cookie"]
		if r.status == 200 then 
            self:setCookie(cookie)
            self:setContextID(contextID)
            if info.method == "refresh" then 
                self[self.model]:getInfo()
            else
                self[self.model].command = info.command
                self[self.model][info.method](self[self.model])
            end
        else badNew("Auth:login", r.status)
		end
	end

	self.http:post(url, self[self.model]["getLoginBody"](), callback, error, self:getHeaders({}))
	return {}
end

function Auth:getHeaders(headers)
	headers = {
        ["Content-Type"] = "application/x-sah-ws-4-call+json",
        ["Accept"] = "*/*",
        ["Authorization"] = "X-Sah-Login",
    }
	return headers
end

function Auth:getContextID() return self.contextID end
function Auth:setContextID(v) self.contextID = v end
function Auth:getCookie() return self.cookie end
function Auth:setCookie(v) self.cookie = v end
function Auth:resetAuth() self.contextID, self.cookie = "", "" end

function Auth:init()
    self.contextID = ""
    self.cookie = ""
    self.info = ""
    self.model = Config:getModel()
end
