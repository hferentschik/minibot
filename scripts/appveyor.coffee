# Description:
#   Listens for event notifications from the ci-webhook listeners and handles Travis CI notifications

url           = require('url')
querystring   = require('querystring')
starwars      = require('starwars')

debug = false

module.exports = (robot) ->

  robot.router.post "/hubot/appveyor", (req, res) ->
    try
      if (debug)
        robot.logger.info("Webhook received: ", req)

      robot.emit "appveyor-event", req.body
    catch error
      robot.logger.error "Webhook listener error: #{error.stack}. Request: #{req.body}"

    res.end ""

  robot.on "appveyor-event", (notification) ->
    if (notification.eventData.failed is true)
      if (notification.eventData.isPullRequest is true)
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Appveyor reports a failed build for pull request https://github.com/#{notification.eventData.repositoryName}/pulls/#{notification.eventData.pullRequestId}"
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Build URL: #{notification.eventData.buildUrl}."
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Commit message: #{notification.eventData.commitMessage}"
      else
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Red alert, Appveyor reports a failed master build: #{notification.eventData.buildUrl}"
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Commit message: #{notification.eventData.commitMessage}"
    else
      if (notification.eventData.isPullRequest is true)
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Appveyor reports a successful build for pull request https://github.com/#{notification.eventData.repositoryName}/pulls/#{notification.eventData.pullRequestId}"
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Build URL: #{notification.eventData.buildUrl}"
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Commit message: #{notification.eventData.commitMessage}"
      else
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Yeah, Appveyor reports another successful master build: #{notification.eventData.buildUrl}"
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Commit message: #{notification.eventData.commitMessage}"

      robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Build artifacts:"
      for artifact, index in notification.eventData.jobs[0].artifacts
        robot.messageRoom process.env.HUBOT_IRC_ROOMS, "#{artifact.url}"

    robot.messageRoom process.env.HUBOT_IRC_ROOMS, starwars()
