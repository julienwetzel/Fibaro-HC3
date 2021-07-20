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

class 'Config'

function Config:new(app)
    self.app = app
    self:init()
    return self
end

function Config:getUsername()
    return self.username
end

function Config:getPassword()
    return self.password
end

function Config:getUrl()
    return self.url
end

function Config:getModel()
    return self.model
end

function Config:init()
    self.username = self.app:getVariable('Username')
    self.password = self.app:getVariable('Password')
    self.url = self.app:getVariable('Url')
    self.model = self.app:getVariable('Model')
end