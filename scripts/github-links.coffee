# Description:
#   Automatically post minishift links when issue numbers are seen
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

module.exports = (robot) ->
  github = require('githubot')(robot)

  regex = /#\d+/ig

  robot.hear regex, (res) ->
    for id in res.match
      # drop leading '#'
      id = id.substr(1)

      # register error handler
      github.handleErrors (response) ->
        if response.statusCode = 404
          res.send "Unkown Minishift issue #{id}"

      github.get "repos/minishift/minishift/issues/" + id, (issue) ->
        out = ""
        if /pull/.test(issue.html_url)
          out = out + "Minishift PR - "
        else
          out = out + "Minishift Issue - "
        out = out + issue.title + ' (' + issue.state  + ') - ' + issue.html_url
        res.send out
