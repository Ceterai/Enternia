require "/items/buildscripts/ct_utils.lua"


function init()
  local tips = getTextConfig()
  -- pane.setTitle(tips.scan.title, tips.scan.subtitle)
  widget.setText("itemSlotLabel", tips.scan.item)
  widget.setText("emptyLabel", tips.scan.empty)
  widget.setVisible("itemScrollArea", false)
  self.large = false
end

function swapItem(widgetName)
  local itemDescriptor = player.swapSlotItem()

  if itemDescriptor then
    itemDescriptor.count = 1
    widget.setItemSlotItem(widgetName, itemDescriptor)
    local item = root.itemConfig(itemDescriptor)
    local dir = item.directory
    local config = item.config
    local parameters = item.parameters
    local tips = getTextConfig()
    local itemInfo = getTextConfig('/items/active/alta/scanner/items.config:database')
    parameters = sb.jsonMerge(parameters, itemInfo[config.itemName or config.objectName] or {})
    local configParameter = function(key, default) return getValue(key, default, config, parameters) end
    local uid = configParameter("itemName")
    local tags = getTags(configParameter("itemTags"), configParameter("race"), configParameter("rarity", "common"), configParameter("elementalType"))
    local tags2 = getTags(configParameter("colonyTags"), configParameter("race"), configParameter("rarity", "common"), configParameter("elementalType"))
    widget.setText("rarityLabel", configParameter('rarity'))
    widget.setVisible("emptyLabel", false)

    local elementalType = configParameter("elementalType", "physical")
    local stars = {}
    for n in string.gmatch(configParameter("shortdescription", ""), '%') do table.insert(stars, n) end
    widget.setText("levelLabel", configParameter("level", 1)..table.concat(stars, ''))
    widget.setText("levelTitleLabel", tips.level)
    widget.setText("speciesLabel", getTitle(configParameter('race', '^gray;-^reset;')))
    widget.setText("speciesTitleLabel", tips.scan.species)
    widget.setText("alkeyLabel", getTitle(configParameter('alkey', '^gray;-^reset;')))
    widget.setText("alkeyTitleLabel", tips.scan.alkey)
    widget.setText("authorLabel", configParameter('author', configParameter('license', '^gray;-^reset;')))
    widget.setText("authorTitleLabel", tips.scan.author)
    if configParameter('twoHanded') then widget.setText("handednessLabel", tips.scan.hand2)
    else widget.setText("handednessLabel", tips.scan.hand1) end
    if elementalType ~= "physical" then widget.setImage("damageKindImage", "/interface/elements/"..elementalType..".png") else widget.setImage("damageKindImage", "") end

    function getAbil(old, abilType, tooltips)
      local abil = abilType..'Ability'
      local params = configParameter(abil)
      if params ~= nil then
        local name = (params.name or config[abil].name or tooltips.none)
        local desc = (params.description or config[abil].description or '')
        local long = (params.longdescription or config[abil].longdescription or '')
        if abilType == 'passive' then abil = 'altAbility' end
        if name and name ~= '' then
          old = appendText(old, getColored(name, 'cyan')..' '..tooltips[abilType].full, '\n\n    ')
        end
        if desc and desc ~= '' then
          old = appendText(old, desc, '\n')
        end
        if long and long ~= '' then
          old = appendText(old, long, '\n')
        end
      end
      return old
    end

    local tmp_tags = tags
    if configParameter("colonyTags") then tmp_tags = tags2 end
    local lore = '    '..configParameter("shortdescription", "")  -- Full description constructor in form of a string variable.
    lore = getLore(lore, configParameter("description"), configParameter("longdescription"), tmp_tags, configParameter('category'), configParameter('race'), tips)
    if configParameter("preset") and not string.find(uid, "mimic") then
      lore = appendText(lore, string.format(tips.derivative, root.itemConfig(uid).config.shortdescription), '\n\n')
    end
    if configParameter("altaDescription") then
      lore = appendText(lore, string.format(tips.scan.lore, 'alta'), '\n\n    ')
      lore = appendText(lore, configParameter("altaDescription"), '\n')
    end
    if configParameter("floranDescription") and configParameter('race') == 'floran' then
      lore = appendText(lore, string.format(tips.scan.lore, ("floranDescription"):gsub('Description', '')), '\n\n    ')
      lore = appendText(lore, configParameter("floranDescription"), '\n')
    end
    if not configParameter("longdescription") and not configParameter("altaDescription") and configParameter('race') ~= 'alta' then
      lore = appendText(lore, tips.scan.alien, '\n')
    end
    lore = getAbil(lore, 'primary', tips)  -- Primary Ability
    lore = getAbil(lore, 'alt', tips)      -- Special Ability
    lore = getAbil(lore, 'passive', tips)  -- Passive Ability (currently replaces special in some tootips)

    -- Upgrade
    if config.upgradeParameters and config.upgradeParameters.shortdescription and config.upgradeParameters.shortdescription:len() > 0 then
      local name = config.upgradeParameters.shortdescription
      if name and name ~= configParameter("shortdescription", "") then
        config.tooltipFields.upgradeLabel = name
        config.tooltipFields.upgradeTitleLabel = tips.upgrade
        lore = appendText(lore, tips.upgfull..name, '\n\n    ')
      end
    end

    lore = appendText(lore, '', '\n')
    if config.category == "eppAugment" then lore = appendText(lore, tips.augment, '\n') end
    if config.category == "petCollar" then lore = appendText(lore, tips.collar, '\n') end
    if configParameter("smashOnBreak", false) or configParameter("smashable", false) then lore = appendText(lore, tips.breaks, '\n') end
    if configParameter("foundIn") then lore = appendText(lore, tips.found .. table.concat(configParameter("foundIn"), "^gray;,^reset; "), '\n') end
    if tags2 and #tags2 > 0 and #tags2 >= #tags then lore = appendText(lore, tips.tags..' '..getColored(table.concat(tags2, ", ")), '\n')
    elseif tags and #tags > 0 then lore = appendText(lore, tips.tags..' '..getColored(table.concat(tags, ", ")), '\n') end
    widget.setText("itemScrollArea.loreLabel", lore)
    widget.setVisible("itemScrollArea", true)
  else
    cleanBody(widgetName)
  end
end

function cleanBody(widgetName)
  widget.setItemSlotItem(widgetName, nil)
  widget.setVisible("emptyLabel", true)
  widget.setVisible("itemScrollArea", false)
  widget.setText("rarityLabel", '')
  widget.setText("levelLabel", '')
  widget.setText("levelTitleLabel", '')
  widget.setText("speciesLabel", '')
  widget.setText("speciesTitleLabel", '')
  widget.setText("alkeyLabel", '')
  widget.setText("alkeyTitleLabel", '')
  widget.setText("authorLabel", '')
  widget.setText("authorTitleLabel", '')
  widget.setText("handednessLabel", '')
  widget.setImage("damageKindImage", '')
  widget.setText("itemScrollArea.loreLabel", '')
end

function getLore(full, desc, lore, tags, cat, species, tips)
  if desc then full = appendText(full, desc, '\n') end
  if lore then full = appendText(full, lore, '\n') end
  for _, tag in ipairs(tags) do
    if tips.lore.alta[tag] and species == 'alta' then full = appendText(full, tips.lore.alta[tag], '\n\n') end
  end
  for _, tag in ipairs(tags) do
    if tips.lore.tags[tag] then full = appendText(full, tips.lore.tags[tag], '\n\n') end
  end
  for _, tag in ipairs(tags) do
    if tips.lore.factions[tag] then full = appendText(full, tips.lore.factions[tag], '\n\n') end
  end
  if cat and tips.lore.categories[cat] then full = appendText(full, tips.lore.categories[cat], '\n\n') end
  if species and tips.lore.species[species] then full = appendText(full, tips.lore.species[species], '\n\n') end
  return full
end
