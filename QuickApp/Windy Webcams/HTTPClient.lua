--[[
HTTPClient wrapper
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
    
class 'HTTPClient'

function HTTPClient:new(options)
    if not options then
        options = {}
    end
    self.options = options
    return self
end

function HTTPClient:get(url, success, error, headers)
    local client = net.HTTPClient({timeout = 10000})
    if not headers then
        headers = {}
    end
    client:request(self:url(url), self:requestOptions(success, error, 'GET', nil, headers)) 
end

function HTTPClient:post(url, data, success, error, headers)
    local client = net.HTTPClient({timeout = 10000})
    if not headers then
        headers = {}
    end
    client:request(self:url(url), self:requestOptions(success, error, 'POST', data, headers)) 
end

function HTTPClient:postForm(url, data, success, error, headers)
    local client = net.HTTPClient({timeout = 10000})
    if not headers then
        headers = {}
    end
    headers["Content-Type"] = 'application/x-www-form-urlencoded;charset=UTF-8'
    client:request(self:url(url), self:requestOptions(success, error, 'POST', data, headers, true)) 
end

function HTTPClient:put(url, data, success, error, headers)
    local client = net.HTTPClient({timeout = 10000})
    client:request(self:url(url), self:requestOptions(success, error, 'PUT', data, headers)) 
end

function HTTPClient:delete(url, success, error, headers)
    local client = net.HTTPClient({timeout = 10000})
    if not headers then
        headers = {}
    end
    client:request(self:url(url), self:requestOptions(success, error, 'DELETE', nil, headers)) 
end

function HTTPClient:url(url)
    if (string.sub(url, 0, 4) == 'http') then
        return url
    end
    if not self.options.baseUrl then
        self.options.baseUrl = 'http://localhost'
    end
    return self.options.baseUrl .. tostring(url)
end

function HTTPClient:requestOptions(success, error, method, data, headers, isFormData)
    if error == nil then
        error = function (error)
            QuickApp:error(json.encode(error))
        end
    end
    if method == nil then
        method = 'GET'
    end
    local options = {
        checkCertificate = false,
        method = method,
        headers = headers,
    }
    if data ~= nil then
        if isFormData then
            options.data = ''
            for key, value in pairs(data) do
                if string.len(options.data) > 0 then 
                    options.data = options.data .. '&'
                end
                options.data = options.data .. key .. '=' .. value
            end
        else
            options.data = json.encode(data)
        end
    end
    return {
        options = options,
        success = success,
        error = error
    }
end
