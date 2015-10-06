DataHelper =
  parseItemAttachment: (item) ->
    fields =
      short: true
      title: 'Primary Stat'
      value: item.primaryStat

    data =
      fallback: item.itemDescription
      title: item.itemName
      title_link: item.itemLink
      color: item.color
      text: item.itemDescription
      thumb_url: item.iconLink
      fields: [fields]

# STAT HASHES {{{
  statHashes:
    155624089:
      statHash: 155624089
      statName: 'Stability'
      statDescription: 'Decreases weapon recoil when fired continuously.'
    368428387:
      statHash: 368428387
      statName: 'Attack'
      statDescription: 'Higher Attack allows your weapons to damage higher-level opponents.'
    943549884:
      statHash: 943549884
      statName: 'Equip Speed'
      statDescription: 'The speed with which the weapon can be readied and aimed.'
    1345609583:
      statHash: 1345609583
      statName: 'Aim assistance'
      statDescription: 'The weapon\'s ability to augment your aim.'
    1931675084:
      statHash: 1931675084
      statName: 'Inventory Size'
      statDescription: 'How much space the weapon occupies in the inventory.'
    2391494160:
      statHash: 2391494160
      statName: 'Light'
      statDescription: 'Light increases your level increasing the damage your abilities deal against higher-level enemies.'
    2523465841:
      statHash: 2523465841
      statName: 'Velocity'
      statDescription: 'Increases the speed of projectiles fired by this weapon.'
    2715839340:
      statHash: 2715839340
      statName: 'Recoil direction'
      statDescription: 'The weapon\'s tendency to move while firing.'
    3555269338:
      statHash: 3555269338
      statName: 'Optics'
      statDescription: 'Optical Zoom Multiplier'
    3614673599:
      statHash: 3614673599
      statName: 'Blast Radius'
      statDescription: 'Increases the explosion radius of this weapon.'
    3871231066:
      statHash: 3871231066
      statName: 'Magazine'
      statDescription: 'The number of shots which can be fired before reloading.'
    4188031367:
      statHash: 4188031367
      statName: 'Reload'
      statDescription: 'Decreases the time it takes to reload this weapon.'
    4284893193:
      statHash: 4284893193
      statName: 'Rate of Fire'
      statDescription: 'The number of shots per minute this weapon can fire.'
# }}}

module.exports = DataHelper



