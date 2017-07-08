# Description:
#   Listens for event notifications from the ci-webhook listeners and handles Travis CI notifications

url           = require('url')
querystring   = require('querystring')
Entities      = require('html-entities').XmlEntities;
entities      = new Entities();

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
      switch data.status_message
        when "Passed"
          robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Travis CI reports another successful master build"
        when "Fixed"
          robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Relax, Travis CI reports, master build is working again"
        when "Broken", "Failing", "Still Failing"
          robot.messageRoom process.env.HUBOT_IRC_ROOMS, "All hands on deck, Travis CI reports a broken master build"
        else robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Unhandled build status message: #{data.status_message}"
      robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Commit message: #{data.message}"
      robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Build URL: #{data.build_url}"
      askChuck robot
      return

    if (data.type == "pull_request")
      switch data.status_message
        when "Passed", "Fixed"
          robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Travis CI reports, pull request ##{data.pull_request_number} completed successully"
        when "Broken", "Failing", "Still Failing"
          robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Travis CI reports, pull request ##{data.pull_request_number} is broken"
        else message = "Unhandled build status message: #{data.status_message}"
      robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Commit message: #{data.message}"
      robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Build URL: #{data.build_url}"
      askChuck robot
      return

  askChuck = (robot) ->
    robot.http("http://api.icndb.com/jokes/random")
      .get() (err, res, body) ->
        if err
          robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Chuck Norris says: #{err}"
        else
          message_from_chuck = JSON.parse(body)
          if message_from_chuck.length == 0
            robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Achievement unlocked: Chuck Norris is quiet!"
          else
            robot.messageRoom process.env.HUBOT_IRC_ROOMS, entities.decode(message_from_chuck.value.joke.replace /\s\s/g, " ")
