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

  regex = /(?:^|\s)#(\d+)\b/i

  robot.hear regex, (res) ->
    id = res.match[1]


    github.get "repos/minishift/minishift/issues/" + id, (issue) ->
      out = ""
      if /pull/.test(issue.html_url)
      	out = out + "PR - "
      out = out + issue.title + ' (' + issue.state  + ') - ' + issue.html_url
      res.send out
