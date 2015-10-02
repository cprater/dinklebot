module.exports = (robot) ->
  require('dotenv').load()

  robot.respond /test bungie/i, (bot) ->
    makeRequest bot, (response) ->
      bot.send "The response: " + response

makeRequest = (bot) ->
  BUNGIE_API_KEY = process.env.BUNGIE_API_KEY

  bot.http('http://www.bungie.net/Platform/Destiny/Stats/Definition/')
    .header('X-API-Key', BUNGIE_API_KEY)
    .get() (err, res, body) ->
      bot.send body
