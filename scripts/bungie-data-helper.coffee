DataHelper =
  parseItemAttachment: (item) ->
    fields =
      short: true
      text: 'Primary Stat'
      value: item.primaryStat

    data =
      fallback: item.itemDescription
      title: item.itemName
      title_link: item.itemLink
      color: item.color
      text: item.itemDescription
      thumb_url: item.iconLink
      fields: [fields]

    data

module.exports = DataHelper
