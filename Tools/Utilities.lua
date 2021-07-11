function QuickApp:printTable( t )
	local printTable_cache = {}
	local function sub_printTable( t, indent )

		if ( printTable_cache[tostring(t)] ) then
			print( indent .. "*" .. tostring(t) )
		else
			printTable_cache[tostring(t)] = true
			if ( type( t ) == "table" ) then
				for pos,val in pairs( t ) do
					if ( type(val) == "table" ) then
						print( indent .. "[" .. pos .. "] => " .. tostring( t ).. " {" )
						sub_printTable( val, indent .. string.rep( " ", string.len(pos)+8 ) )
						print( indent .. string.rep( " ", string.len(pos)+6 ) .. "}" )
					elseif ( type(val) == "string" ) then
						print( indent .. "[" .. pos .. '] => "' .. val .. '"' )
					else
						print( indent .. "[" .. pos .. "] => " .. tostring(val) )
					end
				end
			else
				print( indent..tostring(t) )
			end
		end
	end

	if ( type(t) == "table" ) then
		print( tostring(t) .. " {" )
		sub_printTable( t, "  " )
		print( "}" )
	else
		sub_printTable( t, "  " )
	end
end

--[[
A simple function for printing a json string in a readble format
The function takes a json string as input and returns a formatted HTML string which can be printed using fibaro:dbug()

By Per Jarnehamamr, 2019

--]]

function QuickApp:jdump(jstr, indent) 
	if not indent then indent = 2 end

	local str = "<pre><font color=yellowgreen><br>";
	local curr_ind = 0;
	local space = "&nbsp";
	local quotes = false; 

	for i = 1, string.len(jstr)  do
		char = string.sub(jstr,i,i);

		if  char == '"' then quotes = not quotes end

		if (char == "{") or (char == "[") then 
			curr_ind = curr_ind + indent;
			str = str..char.."<br>"..string.rep(space,curr_ind);

		elseif (char == "}") or (char == "]") then
			curr_ind = curr_ind - indent;
			str = str.."<br>"..string.rep(space,curr_ind)..char;

		elseif char == "," then
			str = str..char.."<br>"..string.rep(space,curr_ind);

		elseif char == ":" then
			if quotes then 
				str = str..char;
			else
				str = str..space..char..space;
			end

		else
			str = str..char;
		end
	end

	return str.."</font></pre>";
end

function QuickApp:has_value (tab, val) --Fonction qui retourne true si la valeur est trouvée dans la table 
	for _,v in ipairs(tab) do
		for _,k in pairs(v) do
			if k == val then
				return true
			end
		end
		if v == val then
			return true
		end
	end
	return false
end
