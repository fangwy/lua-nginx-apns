local ffi = require 'ffi'

local _M = {}

local function string_split(str, delimiter)
	str = tostring(str)
	delimiter = tostring(delimiter)
	if (delimiter=='') then return false end
	local pos,arr = 0, {}
	-- for each divider found
	for st,sp in function() return string.find(str, delimiter, pos, true) end do
	table.insert(arr, string.sub(str, pos, st - 1))
	pos = sp + 1
	end
	table.insert(arr, string.sub(str, pos))
	return arr
end

-- 去除扩展名  
local function stripextension(filename)  
	local idx = filename:match(".+()%.%w+$")  
	if(idx) then  
	return filename:sub(1, idx-1)  
	else  
	return filename  
	end  
end

local function tryLoad(filename)  
	local o = nil
	local status, err = pcall(function (  )
		o = ffi.load(filename)
	end)
	return o, status, err	
end

function _M.load( so, showmsg )
	local ar = string_split(package.path, ';')
	local o = nil
	local errs = {}
	table.foreach(ar, function(k,v)
	if o ~= nil then
		return
	end
	local try_path, count = v:gsub('?', so)
	if count == 1 then
		local status, err
		o, status, err = tryLoad(try_path)
		if not o then
			table.insert(errs, err)
			try_path = stripextension(try_path)..'.so' 
			o, status, err = tryLoad(try_path)
			if not o then
				table.insert(errs, err)
				try_path = stripextension(try_path)..'.dll' 
				o, status, err = tryLoad(try_path)
				if not o then
				  table.insert(errs, err)
				end
			end
		 end
	  end
	end)
	if not o then
		print(table.concat(errs, "\r\n"))
	end
	return o
end

return _M


