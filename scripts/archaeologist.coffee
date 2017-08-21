# Description:
#   Handle archaeologist role selection
#
# Commands:
#   minibot archaeologist? - show help archaeologist help
#   minibot who are archaeologists - show users with archaeologist role
#   minibot who is archaeologist - displays the user who is currently archaeologist
#   minibot archaeologist next - advances the current archaeologist
#
# Author:
#   @hferentschik

module.exports = (robot) ->
  robot.brain.on 'standupLog', (group, room, response, logs) ->
    archaeologist(robot)

  robot.respond /who are archaeologists *$/i, (msg) ->
    archaeologists = allArchaeologists(robot)
    if archaeologists.length > 0
      who = archaeologists.map((user) -> user.name).join(', ')
      msg.send "#{who} have the archaeologist role"

  robot.respond /who is archaeologist *$/i, (msg) ->
    whoIsArchaeologist(robot)

  robot.respond /archaeologist next *$/i, (msg) ->
    current = currentNecromancer(robot)
    archaeologists = allArchaeologists(robot)
    newIndex =  (current.index + 1) %% archaeologists.length

    robot.brain.data.archaeologist = {
      user: archaeologists[newIndex],
      start: new Date().getTime(),
      index: newIndex
    }

    msg.send "Archaeologist role passes from #{current.user.name} to #{robot.brain.data.archaeologist.user.name}"

  robot.respond /archaeologist\?? *$/i, (msg) ->
    msg.send """
             who are archaeologists - show users with archaeologist role
             who is archaeologist - displays the user who is currently archaeologist
             archaeologist next - advances the current archaeologist
             """

whoIsArchaeologist = (robot) ->
  archaeologist = currentNecromancer(robot)
  daysLeft = archaeologistRotation() - numberOfDays(archaeologist.start)
  robot.messageRoom process.env.HUBOT_IRC_ROOMS, "#{archaeologist.user.name} is archaeologist for #{daysLeft} more days"

allArchaeologists = (robot) ->
  archaeologists = []
  for own key, user of robot.brain.data.users
    roles = user.roles or [ ]
    if 'archaeologist' in roles or "a archaeologist member" in roles or "an archaeologist member" in roles or "a member of archaeologist" in roles
      archaeologists.push user
  return archaeologists

currentNecromancer = (robot) ->
  if not robot.brain.data.archaeologist
    archaeologists = allArchaeologists(robot)
    if archaeologists.length = 0
      robot.messageRoom process.env.HUBOT_IRC_ROOMS, "No user with archaeologist role found"
      return
    robot.brain.data.archaeologist = {
      user: allArchaeologists(robot)[0],
      start: new Date().getTime(),
      index: 0
    }
  return robot.brain.data.archaeologist

numberOfDays = (start) ->
 DAY = 1000 * 60 * 60  * 24

 now = new Date().getTime()
 Math.round((now - start) / DAY)

archaeologistRotation = () ->
 +process.env.MINIBOT_ARCHAEOLOGIST_DAYS or 7
