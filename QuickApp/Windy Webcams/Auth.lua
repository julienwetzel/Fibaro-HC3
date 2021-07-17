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
