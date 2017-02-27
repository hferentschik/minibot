# Description:
#   Listens for event notifications from the ci-webhook listeners and handles Travis CI notifications

url           = require('url')
querystring   = require('querystring')

debug = false

module.exports = (robot) ->

  robot.router.post "/hubot/travis-ci", (req, res) ->
    try
      if (debug)
        robot.logger.info("Webhook received: ", req)

      data =
        payload     : req.body.payload
        query       : querystring.parse(url.parse(req.url).query)

      if (debug)
        robot.logger.info("Payload: ", data.payload)
      robot.emit "travis-ci-event", data
    catch error
      robot.logger.error "Webhook listener error: #{error.stack}. Request: #{req.body}"

    res.end ""

  robot.on "travis-ci-event", (event) ->
    data = JSON.parse event.payload

    # Only care about master notifications
    if (data.branch != "master")
      return

    if (data.type == "push")
      message = ""
      switch data.status_message
        when "Passed"
          message = "Travis CI reports another successful master build.
          Commit message: #{data.message}. Build URL: #{data.build_url}"
        when "Fixed"
          message = "Relax, Travis CI reports, master build is working again.
          Commit message: #{data.message}. Build URL: #{data.build_url}"
        when "Broken", "Failing", "Still Failing"
          message = "All hands on deck, Travis CI reports a broken master build.
          Commit message: #{data.message}. Build URL: #{data.build_url}"
        else message = "Unhandled build status message: #{data.status_message}"

      robot.messageRoom process.env.HUBOT_IRC_ROOMS, message
      return

    if (data.type == "pull_request")
      message = ""
      switch data.status_message
        when "Passed", "Fixed"
          message = "Travis CI reports, pull request ##{data.pull_request_number} completed successully.
          Commit message: #{data.message}. Build URL: #{data.build_url}"
        when "Broken", "Failing", "Still Failing"
          message = "Travis CI reports, pull request ##{data.pull_request_number} is broken.
          Commit message: #{data.message}. Build URL: #{data.build_url}"
        else message = "Unhandled build status message: #{data.status_message}"

      robot.messageRoom process.env.HUBOT_IRC_ROOMS, message
      return
