local mcurl =  require("util.mcurl")

local dev_url = "https://api.development.push.apple.com/3/device/"
local apns = {}

function apns:push_dev(apns_topic, msg, device_token, cert)
	local headers = {"apns-topic:"..apns_topic}
	mcurl:http2Push(dev_url..device_token, cert, headers, msg)
end

return apns
