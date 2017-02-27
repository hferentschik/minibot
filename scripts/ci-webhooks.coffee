url           = require('url')
querystring   = require('querystring')

debug = false

module.exports = (robot) ->

  robot.router.post "/hubot/ci", (req, res) ->
    try
      if (debug)
        robot.logger.info("Webhook received: ", req)
      data =
        payload     : req.body.payload
        query       : querystring.parse(url.parse(req.url).query)

      robot.logger.info("Payload: ", data.payload)
      robot.emit "ci-event", data
    catch error
      robot.logger.error "Webhook listener error: #{error.stack}. Request: #{req.body}"

    res.end ""
