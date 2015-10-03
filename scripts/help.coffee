module.exports = (robot) ->
  # Returns a list of custom bungie api commands
  robot.respond /bungie help/i, (bot) ->
    armory = 'dinklebot armory <gamertag> - Returns the players Grimoire Score'
    played = 'dinklebot played <gamertag> - Returns general info about the last character played'

    phrase = 
      armory+'\n'+
      played+'\n'+
      '\n'

    bot.send phrase
