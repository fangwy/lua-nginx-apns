local apns =  require("util.apns")
-- bundle identifier
local apns_topic = "com.xim.xcsj"
local msg = '{"aps":{"alert":"Hello apns","sound":"msg_high.m4a","badgeNum":1}}'
local device_token = "3ae0bdf9d8b0fce24597508eb528050c04bd47f5a915c5" 
local cert = "./cert/apns_dev.pem"
	
apns:push_dev(apns_topic, msg, device_token, cert)	

ngx.say("hello!")
ngx.exit(200)


