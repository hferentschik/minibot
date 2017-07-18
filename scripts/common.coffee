
module.exports.logWebHooks = () ->
 return process.env.MINIBOT_LOG_WEBHOOKS or false

String::startsWith ?= (s) -> @slice(0, s.length) == s
String::endsWith ?= (s) -> s == '' or @slice(-s.length) == s
