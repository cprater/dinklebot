require('dotenv').load()
Deferred = require('promise.coffee').Deferred

module.exports = (robot) ->
  robot.respond /basic/i, (msg) =>
   #Test custom attachments
    fields = []
    fields.push
      title: "Field 1: Title"
      value: "Field 1: Value"
      short: true

    fields.push
      title: "Field 2: Title"
      value: "Field 2: Value"
      short: true

    payload =
      message: msg.message
      content:
        text: "Attachement Demo Text"
        fallback: "Fallback Text"
        pretext: "This is Pretext"
        color: "#FF0000"
        fields: fields

    robot.emit 'slack-attachment', payload

  robot.respond /test (.*)/i, (bot) =>
    playerName = bot.match[1]

    getPlayerId(bot, playerName).then (playerId) ->
      getCharacterId(bot, playerId).then (characterId) ->
        getCharacterInventory(bot, playerId, characterId).then (response) ->
          attachments = response.map (item) ->
            parseItemAttachment(item)

          payload = attachments[0]
          console.log 'attachment', payload
          robot.emit 'slack-attachment', payload

  # Returns a grimoire score for a gamertag
  robot.respond /armory (.*)/i, (bot) =>
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
          for url in response
            bot.send url

parseItemAttachment = (item) ->
  fields =
    content:
      title: item.itemName
      title_link: item.itemLink
      color: item.color
      fallback: item.itemDescription
      thumb_url: item.iconLink
      text: item.itemDescription

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
  endpoint = '1/Account/'+playerId

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
  endpoint = '1/Account/'+playerId+'/Character/'+characterId+'/Inventory'
  params = 'definitions=true'
  rarityColor =
    Uncommon: '#f5f5f5'
    Common: '#2f6b3c'
    Rare: '#557f9e'
    Legendary: '#4e3263'
    Exotic: '#ceae32'
  #rarityColor =
  #  Uncommon: 'rgba(245,245,245,0.9)'
  #  Common: 'rgba(47, 107, 60, 0.9)'
  #  Rare: 'rgba(85,127,158,0.9)'
  #  Legendary: 'rgba(78,50,99,0.9)'
  #  Exotic: 'rgba(206,174,50,0.9)'

  callback = (response) ->
    definitions = response.definitions.items
    equippable = response.data.buckets.Equippable

    itemHashes = equippable.map (x) ->
      x.items.map (item) ->
        if item.isEquipped then item.itemHash else false
    flatHashes = [].concat itemHashes...

    items = flatHashes.map (hash) ->
      defData = definitions[hash]

      prefix = 'http://www.bungie.net'
      iconSuffix = definitions[hash].icon
      itemSuffix = '/en/Armory/Detail?item='+hash

      data =
        itemName: defData.itemName
        itemDescription: defData.itemDescription
        rarity: defData.tierTypeName
        color: rarityColor[defData.tierTypeName]
        iconLink: prefix + iconSuffix
        itemLink: prefix + itemSuffix

      data

    deferred.resolve(items)

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

  bot.http(url)
    .header('X-API-Key', BUNGIE_API_KEY)
    .get() (err, response, body) ->
      object = JSON.parse(body)
      callback(object.Response)
