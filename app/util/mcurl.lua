local ffi = require 'ffi'
local Log = require 'util.log'

ffi.cdef[[
    void *curl_easy_init();
    int curl_easy_setopt(void *curl, int option, ...);
    int curl_easy_perform(void *curl);
    void curl_easy_cleanup(void *curl);
    char *curl_easy_strerror(int code);
	int curl_easy_getinfo(void *curl, int info, ...);
	typedef unsigned int (*WRITEFUNC)(void *ptr, unsigned int size, unsigned int nmemb, void *userdata);
	struct curl_slist *curl_slist_append(struct curl_slist *,
                                                 const char *);
	void curl_slist_free_all(struct curl_slist *);
]]

local libcurl = ffi.load('app/libs/libcurl.so')
local curl_easy_init = libcurl.curl_easy_init
local curl_easy_setopt = libcurl.curl_easy_setopt
local curl_easy_perform = libcurl.curl_easy_perform
local curl_easy_strerror = libcurl.curl_easy_strerror
local curl_easy_cleanup = libcurl.curl_easy_cleanup
local curl_easy_getinfo = libcurl.curl_easy_getinfo
local curl_slist_append = libcurl.curl_slist_append
local curl_slist_free_all = libcurl.curl_slist_free_all

local CURLOPT_URL = 10002
local CURLOPT_POSTFIELDS = 10015
local CURLOPT_SSL_VERIFYPEER = 00064
local CURLOPT_HTTP_VERSION = 00084
local CURLOPT_TIMEOUT_MS = 00155
local CURLOPT_WRITEFUNCTION = 20011
local CURLOPT_SSLCERTTYPE = 10086
local CURLOPT_SSLKEY = 10087
local CURLOPT_SSLKEYTYPE = 10088

local CURLOPT_HTTPHEADER = 10023
local CURLOPT_SSLCERT = 10025
local CURLE_OK = 0


local CURL_HTTP_VERSION_2_0 = 3
local CURL_HTTP_VERSION_2TLS = 4

local mcurl = {}

function mcurl:http2Push(url, cert, headers, post_fields)		
	local curl = curl_easy_init()
	if curl then
		curl_easy_setopt(curl, CURLOPT_URL, url)
		curl_easy_setopt(curl, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_2TLS)
		curl_easy_setopt(curl, CURLOPT_TIMEOUT_MS, 6);
		curl_easy_setopt(curl, CURLOPT_POSTFIELDS, post_fields)
	
		-- local data
		-- local writeFunc = ffi.cast("WRITEFUNC", function(ptr,size,nmemb,userdata)
		-- 	data=ffi.string(ptr)
		-- 	return size*nmemb
		-- end)
		-- curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, writeFunc)
		
		curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER,true);
		curl_easy_setopt(curl, CURLOPT_SSLCERT, cert)
		
		local __headers = ffi.new("void *")
		for k,v in pairs(headers) do 
			curl_slist_append(__headers, v)
		end
		curl_easy_setopt(curl, CURLOPT_HTTPHEADER, __headers)
		local res = curl_easy_perform(curl)
		if res ~= CURLE_OK then
			Log(" res->"..ffi.string(curl_easy_strerror(res)))
		end
		curl_easy_cleanup(curl)
		-- writeFunc:free()
		curl_slist_free_all(__headers)
	end
end

return mcurl
