# Description:
#   Defines webhooks and commands for integrating with Minishift team sprints.
#
# Dependencies:
#   None
#
# Commands:
#   minibot print sprint <sprint number> - Prints the issues for the specified sprint
#   minibot mark issue <issue-id> of sprint <sprint-id> completed - Marks the issue as completed for this sprint
#   minibot list known sprints - lists the sprints known to Minibot
#
# Notes:
#   To post sprint data, export data from planning sreadsheet and use the /hubot/sprint hook
#   to post it to Minibot. You can use curl:
#
#   $ curl -X POST http://<IP>:9009/hubot/sprint -d sprint=134 -d data="$(cat sprint-134.csv)"

parse = require('csv-parse/lib/sync')
pad   = require('pad')

module.exports = (robot) ->

  robot.error (err, res) ->
    robot.logger.error "Error in sprint module: #{err}"

    if res?
      res.reply "42"

  robot.router.post "/hubot/sprint", (req, res) ->
    body = req.body
    sprint_id = body.sprint
    data = body.data

    records = parse(data)
    robot.brain.data.sprint or= {}
    robot.brain.data.sprint[sprint_id] = records
    robot.brain.save()

    res.writeHead 200, {'Content-Type': 'text/plain'}
    res.end "Sprint data for sprint #{sprint_id} received. Thanks!\n"

  robot.respond /print sprint ([0-9]+) *$/i, (msg) ->
    sprint_id = msg.match[1]

    if robot.brain.data.sprint?[sprint_id]
      for issue, index in robot.brain.data.sprint[sprint_id]
        # only print issues "accpeted" into the sprint
        if issue[1] is "no"
          continue

        # some column mappings due to changes in the number of columns
        title_column_index = 9
        key_column_index = 15
        if parseInt( sprint_id, 10 ) > 135
          title_column_index = 11
          key_column_index = 17

        msg.send("P(#{pad(2,index)}) E(#{pad(2, issue[2])}) C(#{pad(issue[0], 1, strip: true)}) - #{pad(issue[key_column_index], 8)} - #{issue[title_column_index]}")
    else
      msg.send("No sprint with id #{sprint_id} defined.")

  robot.respond /mark issue ([0-9]+) of sprint ([0-9]+) completed *$/i, (msg) ->
    issue_id = msg.match[1]
    sprint_id = msg.match[2]

    if robot.brain.data.sprint?[sprint_id]
      if robot.brain.data.sprint[sprint_id][issue_id]
        # mark issue as completed
        robot.brain.data.sprint[sprint_id][issue_id][0] = "yes"
        msg.send("Issue '#{robot.brain.data.sprint[sprint_id][issue_id][9]}' marked completed.")
      else
        msg.send("#{issue_id} is not valid issue index for sprint #{sprint_id}.")
    else
      msg.send("No sprint with id #{sprint_id} defined.")

  robot.respond /list known sprints *$/i, (msg) ->
    if robot.brain.data.sprint
      sprints = ""
      for key, value of robot.brain.data.sprint
        sprints = sprints + "#{key} "
      msg.send("I know about the sprint(s) #{sprints}")
    else
      msg.send("No sprints defined.")

