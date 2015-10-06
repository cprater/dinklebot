DataHelper =
  parseItemAttachment: (item) ->
    data =
      fallback: item.itemDescription
      title: item.itemName
      title_link: item.itemLink
      color: item.color
      text: item.itemDescription
      thumb_url: item.iconLink
      short: true

    data

module.exports = DataHelper
