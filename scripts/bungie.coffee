require('dotenv').load()
Deferred = require('promise.coffee').Deferred

module.exports = (robot) ->
  # Returns a grimoire score for a gamertag
  robot.respond /armory (.*)/i, (bot) ->
    playerName = bot.match[1]

    getPlayerId(bot, playerName).then (playerId) ->
      getGrimoireScore(bot, playerId).then (grimoireScore) ->
        bot.send playerName+'\'s Grimoire Score is: '+grimoireScore

  # Returns an inventory object of last played character for a gamertag
  robot.respond /played (.*)/i, (bot) ->
    playerName = bot.match[1]

    getPlayerId(bot, playerName).then (playerId) ->
      getLastCharacter(bot, playerId).then (response) ->
        bot.send 'Guardian '+playerName+' last played on their '+response

# Gets general player information from a players gamertag
getPlayerId = (bot, name) ->
  deferred = new Deferred()
  endpoint = 'SearchDestinyPlayer/1/'+name

  makeRequest bot, endpoint, (response) ->
    foundData = response[0]

    if !foundData
      bot.send 'Guardian '+name+' not found :('
      deferred.reject()
      return

    playerId = foundData.membershipId
    deferred.resolve(playerId)

  deferred.promise

# Gets genral information about last played character
getLastCharacter = (bot, playerId) ->
  deferred = new Deferred()
  endpoint = '/1/Account/'+playerId
  genderTypes = ['Male', 'Female', 'Unknown']
  raceTypes = ['Human', 'Awoken', 'Exo', 'Unknown']
  classTypes = ['Titan', 'Hunter', 'Warlock', 'Unknown']

  makeRequest bot, endpoint, (response) ->
    data = response.data || {}
    chars = data.characters
    recentChar = chars[0]
    charData = recentChar.characterBase
    levelData = recentChar.levelProgression

    level = levelData.level
    lightLevel = charData.powerLevel
    gender = genderTypes[charData.genderType]
    charClass = classTypes[charData.classType]

    phrase = 'level '+level+' '+gender+' '+charClass+', with a light level of: '+lightLevel
    deferred.resolve(phrase)

  deferred.promise

# Gets a players Grimoire Score from their membershipId
getGrimoireScore = (bot, memberId) ->
  deferred = new Deferred()
  endpoint = '/Vanguard/Grimoire/1/'+memberId

  makeRequest bot, endpoint, (response) ->
    score = response.data.score
    deferred.resolve(score)

  deferred.promise

# Sends GET request from an endpoint, needs a success callback
makeRequest = (bot, endpoint, callback) ->
  BUNGIE_API_KEY = process.env.BUNGIE_API_KEY
  baseUrl = 'https://www.bungie.net/Platform/Destiny/'
  trailing = '/'
  url = baseUrl+endpoint+trailing

  bot.http(url)
    .header('X-API-Key', BUNGIE_API_KEY)
    .get() (err, response, body) ->
      object = JSON.parse(body)
      callback(object.Response)
