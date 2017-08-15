# Description:
#   Integration with CentOS CI
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   minibot latest master artifacts - Prints the URL to download latest master artifacts
#   minibot artifacts for pr <pr-id> - Prints the URL to download artifacts build from this pull request
#
# Notes:
#   None
#
getHrefs = require('get-hrefs')
common = require("./common.coffee")

module.exports = (robot) ->

  robot.router.post "/hubot/centosci", (req, res) ->
    try
      if (common.logWebHooks())
        robot.emit "centos-ci-release", req.body.payload

    catch error
      robot.logger.error "Webhook listener error: #{error.stack}. Request: #{req.body}"

    res.end ""

  robot.on "centos-ci-release", (payload) ->
    robot.messageRoom process.env.HUBOT_IRC_ROOMS, "#{payload.message}"
    robot.messageRoom process.env.HUBOT_IRC_ROOMS, "Release URL: #{payload.url}"

  robot.respond /artifacts for pr ([0-9]+) *$/i, (msg) ->
    pr_id = msg.match[1]
    pullRequestArtifactsUrl = 'http://artifacts.ci.centos.org/minishift/minishift/pr/'
    robot.http(pullRequestArtifactsUrl)
      .get() (err, httpRes, body) ->
        try
          hrefs = getHrefs(body)
          for href, index in hrefs
            if href.startsWith(pr_id)
              msg.send "Artifacts for pull request ##{pr_id} can be found at #{pullRequestArtifactsUrl}#{href}"
              return
          msg.send "No artifacts for pull request ##{pr_id}. Is the id correct and has the build completed successfully?"
        catch error
          msg.send "Error retrieving pull request artifacts: #{error}"

  robot.respond /latest master artifacts *$/i, (msg) ->
    masterArtifactsUrl = 'http://artifacts.ci.centos.org/minishift/minishift/master/'
    robot.http(masterArtifactsUrl)
      .get() (err, httpRes, body) ->
        try
          latest_build_nr = 0
          hrefs = getHrefs(body)
          for href, index in hrefs
            if /[0-9]+\//.test(href)
              build_nr = +href.replace /\//, ""
              if build_nr > latest_build_nr && build_nr != 877 # need to exlude 877, which should actually be removed form the server
                latest_build_nr = build_nr
          msg.send "Artifacts for latest master build (https://ci.centos.org/job/minishift/#{latest_build_nr}/) can be found at #{masterArtifactsUrl}#{latest_build_nr}"
        catch error
          msg.send "Error determining master artifacts URL: #{error}"
