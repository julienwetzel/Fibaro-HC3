--[[
Configuration handler
@author jwetzel
]]
class 'Config'

function Config:new(app)
	self.app = app
	self:init()
	return self
end

function Config:getApiKey()
	return self.apiKey
end

function Config:getDistance()
	local n = tonumber(self.distance )
	if n == 0 then return nil, 300
	elseif n == nil then return nil, 303
	else return n, 200
	end
end

function Config:getLocationId()
	local n = tonumber(self.locationId)
	local _,c = api.get("/panels/location/" .. n)
	if n == 0 then return nil, 300
	elseif n == nil then return nil, 303
	elseif c == 200 then return n, 200
	else return nil, 404
	end
end

function Config:getLimit() 
	local n = tonumber(self.limit)
	if n == 0 then return nil, 300 
	elseif n == nil then return nil, 303
	elseif n < 0 or n > 50 then return nil, 303
	else return n, 200
	end
end

function Config:getTimeoutInterval()
	local n = tonumber(self.interval)
	if n  == 0 then return nil, 300
	elseif n == nil then return nil, 303
	else return n * 60000, 200 
	end
end

function Config:getStoredData() return self.storedData end
function Config:setStoredData(v) self.app:setVariable('storedData', json.encode(v)) end
function Config:getDeviceTemplate() return self.deviceTemplate end

function Config:init()
	self.locationId = self.app:getVariable('locationId')
	self.storedData = json.decode(self.app:getVariable('storedData'))
	self.apiKey     = self.app:getVariable('apiKey') 
	self.distance   = self.app:getVariable('distance')
	self.interval   = self.app:getVariable('refreshInterval')
	self.limit      = self.app:getVariable('maxWebcam')
	self.deviceTemplate = {
		name = "string",
		type = "com.fibaro.ipCamera",
		baseType = "com.fibaro.camera",
		enabled = true,
		visible = true,
		properties = {
			httpsEnabled = true,
			ip = "images-webcams.windy.com",
			jpgPath = "path",
			refreshTime = 3600
		}}

	local storedApiKey = Globals:get('windy_webcams_apikey')
	local storedInterval = Globals:get('windy_webcams_interval')

	-- handling apiKey
	if QuickApp:isEmpty(self:getApiKey(self.apiKey)) and not(QuickApp:isEmpty(self:getApiKey(storedApiKey))) then
		self.app:setVariable("apiKey", storedApiKey)
		self.apiKey = storedApiKey
	elseif not(QuickApp:isEmpty(self:getApiKey(self.apiKey))) then
		Globals:set('windy_webcams_apikey', self.apiKey) 
	end

	-- handling interval
	if not self.interval or self.interval == "" then
		if storedInterval and storedInterval ~= "" then
			self.app:setVariable("Refresh Interval", storedInterval)
			self.interval = storedInterval
		else self.interval = "5" end
	end
	if (storedInterval == "" and self.interval ~= "") then
		Globals:set('windy_webcams_interval', self.interval) end
	end
