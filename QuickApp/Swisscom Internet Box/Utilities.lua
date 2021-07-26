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

function isEmpty(s) return s == nil or s == "" end
function cmd(t) QuickApp:trace("CMDEvent: " ..t) end

function badNew(origin,code)
	local txt = ""
	if code == 401 then txt = "Permission Denied" 
	elseif code == 404 then txt = "Not Found"
	elseif code == 504 then txt = "Gateway Timeout"
	elseif code == 800 then txt = "Missing value"
	else txt = "Error unknown"
	end
	QuickApp:error(origin .. " # Code:" .. code .. " " .. txt)
end

function TableConcat(t1,t2)
    for k,v in pairs(t2) do t1[k] = v end
    --[[for i=1, #t2 do
        t1[#t1+1] = t2[i]
    end]]
    return t1
end
function toboolean(b)
    if b == "true" then return true
    elseif b == "false" then return false
    elseif b == true or b == false then return b
    else QuickApp:error("toboolean not work with " .. b) return
    end
end
