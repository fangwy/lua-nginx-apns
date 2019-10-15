local Log = function (...)
	ngx.log(ngx.ERR,string.format(...))
end

return Log