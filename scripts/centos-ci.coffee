# Description:
#   Integration with CentOS CI
#
# Dependencies:
#   None
#
# Configuration:
#
# Commands:
#   none
#
# Notes:
#   None
#
getHrefs = require('get-hrefs')

module.exports = (robot) ->

  robot.respond /artifacts for pr ([0-9]+) *$/i, (msg) ->
    pr_id = msg.match[1]
    robot.http('http://artifacts.ci.centos.org/minishift/minishift/pr/')
      .get() (err, httpRes, body) ->
        try
          hrefs = getHrefs(body)
          for href, index in hrefs
            if href.startsWith(pr_id)
              msg.send "Artifacts for pull request ##{pr_id} can be found at http://artifacts.ci.centos.org/minishift/minishift/pr/#{href}"
              return
          msg.send "No artifacts for pull request ##{pr_id}. Is the id correct and has the build completed successfully?"
        catch error
          msg.send "Error retrieving pull request artifacts: #{data.errorMessages[0]}"
