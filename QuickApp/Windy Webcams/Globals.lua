--[[
Global variables handler
@author ikubicki

MIT License

Copyright (c) 2020 Irek Kubicki

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]

class 'Globals'

function Globals:get(name, alternative)
    local response = api.get('/globalVariables/' .. name)
    if response then
        local char = string.sub(response.value, 1, 1)
        if char == '{' or char == '"' then
            return json.decode(response.value)
        end
        return response.value
    end
    return alternative
end

function Globals:set(name, value)
    local response = api.put('/globalVariables/' .. name, {
        name = name,
        value = json.encode(value)
    })
    if not response then
        response = api.post('/globalVariables', {
            name = name,
            value = json.encode(value)
        })
        
    end
    if response ~= nil then
        if response.type == 'ERROR' then
            QuickApp:error('GLOBALS ERROR[' .. response.reason .. ']:', response.message)
        end
    end
end
