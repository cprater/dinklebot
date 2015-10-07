request = require('request')

class DataHelper
  fetchDefs: ->
    @fetchStatDefs (error, response, body) =>
      @statDefs = JSON.parse body

  parseItemAttachment: (item) ->
    statFields = @buildStats(item.stats) || []

    fallback: item.itemDescription
    title: item.itemName
    title_link: item.itemLink
    color: item.color
    text: item.itemDescription
    thumb_url: item.iconLink
    fields: statFields

  buildStats: (statsData) ->
    defs = @statDefs

    foundStats = statsData.map (stat) ->
      found = defs[stat.statHash]
      return if not found

      title: found.statName
      value: stat.value
      short: true

    foundStats.filter (x) -> x

  fetchStatDefs: (callback) ->
    options =
      method: 'GET'
      url: 'http://destiny.plumbing/raw/mobileWorldContent/en/DestinyStatDefinition.json'
      gzip: true

    request options, callback

module.exports = DataHelper



