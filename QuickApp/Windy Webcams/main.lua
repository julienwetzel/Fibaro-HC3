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

-- Initialisation
function QuickApp:onInit()
	self.config  = Config:new(self)
	self.auth    = Auth:new(self.config)
	self.http    = HTTPClient:new()
	self.install = Installation:new()
	self:trace('')
	self:trace('Windy Webcams')
	self:run()
end

-- run interval
function QuickApp:run()
	self:installation(function() self:pullWindyData() end)
	local interval = self.config:getTimeoutInterval()
	if self:isEmpty(interval) then fibaro.setTimeout(1000*60*1, function() self:run() end)
	else fibaro.setTimeout(interval, function() self:run() end)
	end
end

-- Main function
function QuickApp:pullWindyData()
	local location = self:getHCLocation(self.config:getLocationId())
	local url = string.format("https://api.windy.com/api/webcams/v2/list/orderby=popularity/nearby=%s,%s,%s/limit=%s?show=webcams:location,image", location.lat, location.lon, self.config:getDistance(), self.config:getLimit())
	self:trace("Connecting:", url)

	-- callback function
	local callback = function(response)
		local data = json.decode(response.data)
		local res = data.result

		-- If data are OK
		if data.status == "OK" then
			self:trace("Webcam found : " .. tostring(res.total))
			self:trace("Webcam safe limitation : " .. tostring(res.limit)) 
			local storedData = self.config:getStoredData()

			-- Initialize storedData if empty
			if self:isEmpty(storedData.webcams) then 
				self:setVariable("storedData",{})
				storedData["webcams"] = {} 
			end

			local webcam = {}
			local webcamConfig = self.config:getDeviceTemplate()
			local webcamExist = true
			local n,r,c,camInfo

			-- Webcam device creation
			for _,v in pairs(res.webcams) do
				webcam = storedData.webcams[v.id]

				-- If webcam not exist
				if webcam == nil then webcam = {status = "", city = "", img = "", deviceId = "", inList = true} end

				-- True or false if device is in the HC3
				webcamExist, camInfo = self:ifDeviceExist( webcam.deviceId )

				-- Webcam inList on the request Windy server
				webcam.inList = true

				-- Webcam status process
				if self:isEmpty(v.status) == false then webcam.status = v.status
				else 
					return self:error("Not received Webcam status on Windy server") 
				end

				-- Webcam city process
				if self:isEmpty(v.location.city) == false then 
					webcam.city   = v.location.city
				else 
					return self:error("Not received Webcam city on Windy server") 
				end

				-- Webcam name process
				if (webcam.name == "" or self:isEmpty(webcam.name)) then webcam.name = "wy " .. webcam.city
					if string.len(webcam.name) > 20 then webcam.name = string.sub(webcam.name,1,20) end
					webcamConfig.name = webcam.name
				end

				-- Link img process
				if self:isEmpty(v.image.current.preview) == false then
					_,n = string.find(v.image.current.preview,".com")
					webcam.img = string.sub(v.image.current.preview,n+1)
				else 
					return self:error("Not received link image on Windy server")
				end

				-- Datas verification
				for o,p in pairs(webcam) do
					if self:isEmpty(p) and o ~= "deviceId" then
						return self:error("storedData new webcam, var \"" .. o .. "\" are not defined")
					end
				end

				webcamConfig.properties.jpgPath = webcam.img

				-- Webcam visible and enabled
				if webcam.status ~= "active" then 
					webcamConfig.enabled = false
					webcamConfig.visible = false
				else 
					webcamConfig.enabled = true
					webcamConfig.visible = true 
				end

				-- Add or update camera device 
				if not(webcamExist) then
					r,c = api.post("/devices", webcamConfig)
					if c ~= 200 then self:error("Camera \"" .. webcam.name .. "\" not created, error: " .. c .. " " .. r.message)
					else webcam.deviceId = r.id 
						self:trace("Webcam[id:" .. r.id .. "] \"" .. webcam.name .. "\" added") 
					end
				else 
					r,c = api.put("/devices/" .. webcam.deviceId, webcamConfig)
					if c ~= 200 then self:error("Camera \"" .. camInfo.name .. "\" not updated, error: " .. c .. " " .. r.message) 
					else self:trace("Webcam[id:" .. r.id .. "] \"" .. camInfo.name .. "\" updated") end
				end

				-- Var deviceId verification
				if self:isEmpty(webcam.deviceId) then
					return self:error("storedData, deviceId are not defined")
				end

				webcam.inList = true
				storedData.webcams[v.id] = webcam
			end

			-- Delete camera device
			if storedData.webcams ~= nil then
				for a,j in pairs(storedData.webcams) do 
					if j.inList == false then 
						r,c = api.delete("/devices/" .. j.deviceId)
						if c ~= 200 then self:trace("Camera \"" .. j.name .. "\" not deleted, error: " .. tostring(c))
						else self:trace("Webcam[id:" .. j.deviceId .. "] \"" .. j.name .. "\" removed ") 
						end
						storedData.webcams[a] = nil 
					else storedData.webcams[a].inList = false 
					end
				end
			end

			self.config:setStoredData(storedData) 
		else 
			return self:error("Webcam acquisition error")
		end
	end

	self.http:get(url, callback, nil, self.auth:getHeaders({}))
	return {}
end

function QuickApp:installation(nextFunction)
	local v = self:getVarInfo()
	local code = 0
	local ak = self.config:getApiKey()
	if ak  == "0" then code = 300
	else
		local url = "https://api.windy.com/api/webcams/v2/list/limit=1?show=webcams:location"
		local callback = function(response)
			if response.status == 200 then 
				Globals:set('windy_webcams_apikey', ak) 
			end
			v.apiKey.code = response.status
			self.install:run(v,function() nextFunction() end)
		end

		self.http:get(url, callback, nil, self.auth:getHeaders({}))
		return {}
	end

	v.apiKey.code = code
	self.install:run(v,function() nextFunction() end)
end

function QuickApp:getVarInfo()
	local varInfo = {
		distance = {code = nil, unit = "km", example = "5", txt = ""}, 
		apiKey = {code = nil, unit = "", example = "MNgwCHC87gplxaH2z4VBeCUyvChDyXyS", txt = ""},
		locationId = {code = nil, unit = "", example = "219", txt = ""},
		refreshInterval = {code = nil, unit = "min", example = "5", txt = ""},
		maxWebcam = {code = nil, unit = "", example = "50", txt = ""},
	}
	local c,r = 0
	r,c = self.config:getDistance()
	varInfo.distance.code = c
	r,c = self.config:getLocationId()
	varInfo.locationId.code = c
	r,c = self.config:getTimeoutInterval()
	varInfo.refreshInterval.code = c
	r,c = self.config:getLimit()
	varInfo.maxWebcam.code = c

	varInfo.distance.txt = "This is the search radius from the location."

	varInfo.apiKey.txt = "[Step 1] Create a login to <a target='_blank' href='https://community.windy.com/login'>https://community.windy.com/login</a>"
	varInfo.apiKey.txt = varInfo.apiKey.txt .. "<br>[Step 2] Go to <a target='_blank' href='https://api.windy.com/keys'>https://api.windy.com/keys</a>"
	varInfo.apiKey.txt = varInfo.apiKey.txt .. "<br>[Step 3] Click on button \"Create a new API Key\""
	varInfo.apiKey.txt = varInfo.apiKey.txt .. "<br>[Step 4] Fill the <b>Project identification</b> field (Example : \"Fibaro\")"
	varInfo.apiKey.txt = varInfo.apiKey.txt .. "<br>[Step 5] Choose <b>Webcams API</b> option in API Service and click Create"
	varInfo.apiKey.txt = varInfo.apiKey.txt .. "<br>[Step 6] Copy/past your ApiKey in the apiKey variable"

	varInfo.locationId.txt = "Choose your ID location and set the variable \"locationId\"<br>" .. self:tableLocation()

	varInfo.refreshInterval.txt = "This is the refresh rate in minutes."
	varInfo.refreshInterval.txt = varInfo.refreshInterval.txt .. "<br>- Please note that webcams are generally updated every 15 minutes."

	varInfo.maxWebcam.txt = "This is the limit of the maximum number of webcams that are retrieved."
	varInfo.maxWebcam.txt = varInfo.maxWebcam.txt .. "<br>It is possible to install the program several times to obtain webcams from several locations."
	varInfo.maxWebcam.txt = varInfo.maxWebcam.txt .. "<br>- Please note that it is not possible to get more than 50 webcams."

	return varInfo
end

-- Get HC3 longitude and latitude
function QuickApp:getHCLocation(val)
	local location,c = api.get("/panels/location/" .. val)
	if c == 200 then 
		self:trace("Configured name location:", location.name)
		location = {lat = location.latitude, lon = location.longitude}
		return location
	else return self:error("Error to get Location")
	end
end

function QuickApp:isEmpty(s) return s == nil or s == "" end

-- Return true or false if device exist
function QuickApp:ifDeviceExist(id)
	if self:isEmpty(id) then 
		return false
	else 
		local r,c = api.get("/devices/" .. id)
		if c == 200 then return true, r
		else 
			return false, nil
		end
	end
end

-- Return list of location in HC3 in format web table
function QuickApp:tableLocation()
	local list,_ = api.get("/panels/location")
	local t = "<tr><td>Location name</td><td>ID</td></tr>"
	for _,v in pairs(list) do t = t .. "<tr><td>" .. v.name .. "</td><td>" .. v.id .. "</td></tr>" end
	return table(t,"bgcolor='#203737' border='1' width=150px")
end
