# Description:
#   Automatically post jira links when issue numbers are seen
#
# Dependencies:
#   None
#
# Commands:
#   none
#
# Notes:
#   None

module.exports = (robot) ->

  regex = /cdk-\d+/ig
  robot.hear regex, (res) ->

    for issue in res.match
      url = 'https://issues.jboss.org/rest/api/2/search?jql=project=CDK%20AND%20key=' + issue
      res.http(url)
        .header('Accept', 'application/json')
        .get() (err, httpRes, body) ->
          data = JSON.parse body
          try
            res.send "CDK - #{data.issues[0].fields.summary} (#{data.issues[0].fields.status.name}) -  https://issues.jboss.org/browse/#{issue}"
          catch error
            res.send "Unknown CDK issue #{issue}"

