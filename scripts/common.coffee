
module.exports.logWebHooks = () ->
 return process.env.MINIBOT_LOG_WEBHOOKS or false

module.exports.notifyOnSuccess = () ->
 return process.env.MINIBOT_NOTIFY_CI_SUCCESS or false

String::startsWith ?= (s) -> @slice(0, s.length) == s
String::endsWith ?= (s) -> s == '' or @slice(-s.length) == s
