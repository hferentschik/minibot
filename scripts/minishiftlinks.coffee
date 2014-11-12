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

  regex = /(?:^|\s)#(\d+)\b/i

  robot.hear regex, (res) ->
    # return if msg.subtype is 'bot_message'
    issue = res.match[1]
    url = 'https://github.com/minishift/minishift/issues/' + issue
    res.send url
