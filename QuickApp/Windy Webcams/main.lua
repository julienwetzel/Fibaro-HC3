--[[ 
Windy Webcam
@author jwetzel 
]]

-- Initialisation
function QuickApp:onInit()
	self.config = Config:new(self)
	self.auth   = Auth:new(self.config)
	self.http   = HTTPClient:new()
	self:trace('')
	self:trace('Windy Webcams')
	self:run()
end

-- run interval
function QuickApp:run()
	self:pullWindyData()
	local interval = self.config:getTimeoutInterval()
	if (interval > 0) then fibaro.setTimeout(interval, function() self:run() end) end
end

-- Main function
function QuickApp:pullWindyData()
	local location = self:getHCLocation(self.config:getLocationId())
	local url = string.format("https://api.windy.com/api/webcams/v2/list/orderby=popularity/nearby=%s,%s,%s/limit=%s?show=webcams:location,image", location.lat, location.lon, self.config:getDistance(), self.config:getLimit())
	self:trace("Connecting:", url)

	-- callback function
	local callback = function(response)
		local data = json.decode(response.data)
		local res = data.result --dataTest or data.result

		--print(self:jdump(json.encode(res)))
		-- return error if return error message
		if data.error and data.error.message then 
			self:error(data.error.message)
			return false 
		end

		-- If data are OK
		if data.status == "OK" then
			self:trace("Webcam found : " .. tostring(res.total))
			self:trace("Webcam safe limitation : " .. tostring(res.limit)) 

			local storedData = self.config:getStoredData()

			-- Initialize storedData if empty
			if self:isEmpty(storedData.webcams) then storedData["webcams"] = {} end

			local webcam = {}
			local webcamConfig = self.config:getDeviceTemplate()
			local webcamExist = true
			local n,r,c

			-- Webcam device creation
			for _,v in pairs(res.webcams) do
				webcam = storedData.webcams[v.id]

				-- If webcam not exist
				if webcam == nil then webcam = {name = "", status = "", city = "", img = "", deviceId = "", inList = true} end
				--print(self:jdump(json.encode(webcam)))

				-- True or false if device is in the HC3
				webcamExist = self:ifDeviceExist( webcam.deviceId )

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
				if webcam.name == "" then webcam.name = "wy " .. webcam.city
					if string.len(webcam.name) > 20 then webcam.name = string.sub(webcam.name,1,20) end
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

				webcamConfig.name = webcam.name
				webcamConfig.properties.jpgPath = webcam.img

				-- Webcam visible and enabled
				if webcam.status ~= "active" then 
					webcamConfig.enabled = false
					webcamConfig.visible = false
				else 
					webcamConfig.enabled = true
					webcamConfig.visible = true 
				end
				--print(self:jdump(json.encode(webcamConfig)))
				--print(self:jdump(json.encode(webcam)))

				-- Add or update camera device 
				if not(webcamExist) --[[webcam.new or self:ifDeviceExist( webcam.deviceId ) == false ]]then
					r,c = api.post("/devices", webcamConfig)
					if c ~= 200 then self:error("Camera \"" .. webcam.name .. "\" not created, error: " .. c .. " " .. r.message)
					else webcam.deviceId = r.id 
						self:trace("Webcam[id:" .. r.id .. "] \"" .. webcam.name .. "\" added") 
					end
				else 
					r,c = api.put("/devices/" .. webcam.deviceId, webcamConfig)
					if c ~= 200 then self:error("Camera \"" .. webcam.name .. "\" not updated, error: " .. c .. " " .. r.message) 
					else self:trace("Webcam[id:" .. r.id .. "] \"" .. webcam.name .. "\" updated") end
				end

				-- Var deviceId verification
				if self:isEmpty(webcam.deviceId) then
					return self:error("storedData, deviceId are not defined")
				end

				webcam.inList = true
				storedData.webcams[v.id] = webcam
				--print(self:jdump(json.encode(webcam)))
			end

			--print(self:jdump(json.encode(storedData))) 
			--self.config:setStoredData(storedData) 

			-- Delete camera device
			if storedData.webcams ~= nil then
				for a,j in pairs(storedData.webcams) do 
					if j.inList == false then 
						r,c = api.delete("/devices/" .. j.deviceId)
						if c ~= 200 then 
							self:error("Camera \"" .. j.name .. "\" not deleted, error: " .. c .. " " .. r.message)
						else 
							self:trace("Webcam[id:" .. j.deviceId .. "] \"" .. j.name .. "\" removed ") 
							storedData.webcams[a] = nil 
						end
					else 
						storedData.webcams[a].inList = false 
					end
				end
			end

			--print(self:jdump(json.encode(storedData)))
			self.config:setStoredData(storedData) 
		else 
			return self:error("Webcam acquisition error")
		end
	end

	--print(self.auth:getHeaders())
	self.http:get(url, callback, nil, self.auth:getHeaders({}))
	return {}
end

-- Get HC3 longitude and latitude
function QuickApp:getHCLocation(val)
	local location,c = api.get("/panels/location/" .. val)
	if c == 200 then 
		self:trace("Configured name location:", location.name)
		location = {lat = location.latitude, lon = location.longitude}
		return location
	else 
		location,c = api.get("/settings/location")
		if c == 200 then
			self:trace("City HC3 location:", location.city)
			location = {lat = location.latitude, lon = location.longitude}
			return location
		else
			return self:error("Location with provided id (", val ,") doesn't exist")
		end
	end
end

function QuickApp:isEmpty(s) return s == nil or s == '' end

-- Return true or false if device exist
function QuickApp:ifDeviceExist(id)
	if self:isEmpty(id) then 
		return false
	else 
		local r,c = api.get("/devices/" .. id)
		if c == 200 then return true
		else 
			return false 
		end
	end
end
