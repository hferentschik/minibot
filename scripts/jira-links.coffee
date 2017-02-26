# Description:
#   Automatically post jira links when issue numbers are seen
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_JIRA_DOMAIN - domain when your jira instance lives (e.g. "example.atlassian.com")
#   HUBOT_JIRA_PROJECTS - comma separated list of project prefixes (e.g. "AB,CD,EF")
#
# Commands:
#   none
#
# Notes:
#   None

module.exports = (robot) ->

  if process.env.HUBOT_JIRA_PROJECTS
    regex = ///
      (?:^|\s) # start of line or space
      (#{process.env.HUBOT_JIRA_PROJECTS.split(',').join('|')}) # list of jira project prefixes
      - # a hyphen
      (\d+) # one or more digits
      \b # word boundary
      ///i # case insensitive
  else
    regex = ///
      (?:^|\s) # start of line or space
      ([a-z]+) # one or more letters
      -
      (\d+) # one or more digits
      \b # word boundary
      ///i

  robot.hear regex, (res) ->
    project = res.match[1].toUpperCase()
    id = res.match[2]
    issue = project + '-' + id
    url = 'https://' + process.env.HUBOT_JIRA_DOMAIN + '/rest/api/2/search?jql=project=' + project + '%20AND%20key=' + issue
    res.http(url)
      .header('Accept', 'application/json')
      .get() (err, httpRes, body) ->
        data = JSON.parse body
        try
          res.send "#{data.issues[0].fields.summary} (#{data.issues[0].fields.status.name}) -  https://#{process.env.HUBOT_JIRA_DOMAIN}/browse/#{issue}"
        catch error
          res.send "Unknown CDK issue #{issue}"

