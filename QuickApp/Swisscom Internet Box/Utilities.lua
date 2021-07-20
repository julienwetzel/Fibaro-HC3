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