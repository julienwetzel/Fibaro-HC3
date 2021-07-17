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


code 200    : Ok
code 300    : Null value (To configure)
code 303    : Bad value
other code  : No working

]]

class 'Installation'

function Installation:new()
	return self
end

function font(v,o) if o == nil then o = "" end return "<font " .. o .. ">" .. v .. "</font>"end
function table(v,o) if o == nil then o = "" end return "<table " .. o .. ">" .. v .. "</table>" end
function tr(v,o) if o == nil then o = "" end return "<tr " .. o .. ">" .. v .. "</tr>" end
function td(v,o) if o == nil then o = "" end return "<td " .. o .. ">" .. v .. "</td>" end
function u(v) return "<u>" .. v .. "</u>" end
function mark(v) return "<mark>" .. v .. "</mark>" end

function Installation:run(varInfo,nextFunction)
	--printTable(v)
	local l, txt = "", ""

	function stxt(v) txt = txt .. v end

	function code200(c) 
		for _,v in pairs(c) do if v.code ~= 200 then return false end end
		return true
	end

	if not(code200(varInfo)) then

		function tableVar(var,status,unit,ex)
			local col = td(font(var,"face='Courier New'"))
			col = col .. td(font(status,"face='Courier New'"),"align=center")
			col = col .. td(font(unit,"face='Courier New'"),"align=center")
			col = col .. td(font(ex,"face='Courier New'"),"align=left")
			return  tr(col)
		end

		-- Variables Infos
		l = tableVar("Variable","Status","Unit","Example")
		for k,v in pairs(varInfo) do l = l .. (tableVar(k,self:varStatus(v.code),v.unit,v.example)) end
		stxt(table(l,"cellpadding='2px' bgcolor=DarkSlateGray border='1' width=480px"))
	else
		nextFunction()
		return
	end

	-- Text content
	for k,v in pairs(varInfo) do 
		if v.code ~= 200 then 
			l = tr(td(font(k,"color=Gainsboro face='Trebuchet MS' size=+1"),"colspan='2'"))
			l = l .. tr(td("","width='20px'") .. td(font(v.txt,"color=Gainsboro face='Trebuchet MS'")))
			stxt("<br>" .. table(l, "border=0 cellpadding=2"))
		end 
	end

	QuickApp:trace(table(tr(td(txt .. "<br>")),"border=1 bgcolor=#121f1f width=480px"))
end

function Installation:varStatus(v)
	if v == 300 then return font("to configure","color=OrangeRed")
	elseif v == 303 then return font("bad value","color=Red")
	elseif v == 200 then return font("Configured","color=LawnGreen")
	else return font("No working","color=red")
	end
end
