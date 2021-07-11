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

function Config:getApiKey() return self.apiKey end
function Config:getDistance() return self.distance end
function Config:getLocationId() return self.locationId end
function Config:getStoredData() return self.storedData end
function Config:setStoredData(v) self.app:setVariable('storedData', json.encode(v)) end
function Config:getTimeoutInterval() return tonumber(self.interval) * 60000 end
function Config:getDeviceTemplate() return self.deviceTemplate end
function Config:getLimit() return self.limit end

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
	if string.len(self.apiKey) < 4 and string.len(storedApiKey) > 3 then
		self.app:setVariable("apiKey", storedApiKey)
		self.apiKey = storedApiKey
	elseif (storedApiKey == nil and self.apiKey) or storedApiKey ~= self.apiKey then
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
