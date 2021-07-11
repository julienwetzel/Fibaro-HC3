--[[
Windy authentication class
@author jwetzel
]]
class 'Auth'

function Auth:new(config)
    self.config = config
    self:init()
    return self
end

function Auth:getHeaders(headers)
    local apiKey = self.config:getApiKey()
    if string.len(apiKey) > 0 then headers["x-windy-key"] = apiKey end
    return headers
end
 
function Auth:init()

end
