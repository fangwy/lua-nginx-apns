# lua-nginx-apns
lua-nginx-apns

  -- replace then bundle identifier, msg, device token and cert with your own
  local apns_topic = "com.xxx.xxx"
  local msg = '{"aps":{"alert":"Hello apns","sound":"msg_high.m4a","badgeNum":1}}'
  local device_token = "xxxxxxxxx" 
  local cert = "./cert/apns_dev.pem"

  apns:push_dev(apns_topic, msg, device_token, cert)
