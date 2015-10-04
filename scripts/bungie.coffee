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

  # Returns a list of images equipped on the last character for a gamertag
  robot.respond /inventory (.*)/i, (bot) ->
    playerName = bot.match[1]

    getPlayerId(bot, playerName).then (playerId) ->
      getCharacterId(bot, playerId).then (characterId) ->
        getCharacterInventory(bot, playerId, characterId).then (response) ->
          bot.send response

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

# Gets characterId for last character played
getCharacterId = (bot, playerId) ->
  deferred = new Deferred()
  endpoint = '/1/Account/'+playerId

  makeRequest bot, endpoint, (response) ->
    data = response.data
    chars = data.characters
    recentChar = chars[0]

    characterId = recentChar.characterBase.characterId
    deferred.resolve(characterId)

  deferred.promise

# Gets Inventory of last played character
getCharacterInventory = (bot, playerId, characterId) ->
  deferred = new Deferred()
  endpoint = '/1/Account/'+playerId+'/Character/'+characterId+'/Inventory'
  params = 'definitions=true'

  callback = (response) ->
    definitions = response.definitions.items
    equippable = response.data.buckets.Equippable

    itemHashes = equippable.map (x) ->
      x.items.map (item) ->
        if item.isEquipped then item.itemHash else false
    flatHashes = [].concat itemHashes...

    equippedIcons = flatHashes.map (hash) ->
      definitions[hash].icon

    deferred.resolve(equippedIcons)

  makeRequest(bot, endpoint, callback, params)
  deferred.promise

# Gets genral information about last played character
getLastCharacter = (bot, playerId) ->
  deferred = new Deferred()
  endpoint = '/1/Account/'+playerId
  genderTypes = ['Male', 'Female', 'Unknown']
  raceTypes = ['Human', 'Awoken', 'Exo', 'Unknown']
  classTypes = ['Titan', 'Hunter', 'Warlock', 'Unknown']

  makeRequest bot, endpoint, (response) ->
    data = response.data
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
makeRequest = (bot, endpoint, callback, params) ->
  BUNGIE_API_KEY = process.env.BUNGIE_API_KEY
  baseUrl = 'https://www.bungie.net/Platform/Destiny/'
  trailing = '/'
  queryParams = if params then '?'+params else ''
  url = baseUrl+endpoint+trailing+queryParams

  console.log 'UURL URL URL URL URL URL URL URL RL '
  console.log url

  bot.http(url)
    .header('X-API-Key', BUNGIE_API_KEY)
    .get() (err, response, body) ->
      object = JSON.parse(body)
      callback(object.Response)
