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
    local tips = getTextConfig()
    local itemInfo = getTextConfig('/items/active/alta/scanner/items.config:database')
    local parameters = sb.jsonMerge(itemInfo[config.itemName or config.objectName] or {}, item.parameters)
    local get = function(key, default) return getValue(key, default, config, parameters) end
    local uid = get("itemName")
    local tags = getTags(get("colonyTags") or get("itemTags"), get("race"), get("rarity", "common"), get("elementalType"))
    widget.setVisible("emptyLabel", false)
    widget.setText("speciesLabel", getTitle(get('race', '^gray;-^reset;')))
    widget.setText("speciesTitleLabel", tips.scan.species)
    widget.setText("alkeyLabel", getTitle(get('alkey', '^gray;-^reset;')))
    widget.setText("alkeyTitleLabel", tips.scan.alkey)
    widget.setText("authorLabel", table.concat(get('authors', {}), ', ') or get('license', get('author', '^gray;-^reset;')))
    widget.setText("authorTitleLabel", tips.scan.author)
    widget.setText("handednessLabel", get('twoHanded') and tips.scan.hand2 or tips.scan.hand1)
    widget.setImage("damageKindImage", string.gsub(get("elementalType", ""), "physical", ""):gsub("^(%a+)$", "/interface/elements/%1.png"))

    function getAbil(old, abilType, tooltips)
      local abil = abilType..'Ability'
      local params = get(abil)
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

    local lore = '    '..get("shortdescription", "")  -- Full description constructor in form of a string variable.
    local level = tips.level..' '..get("level", 0)..string.gsub(get("shortdescription", ""), '[^%]', "")
    lore = appendText(lore, get('rarity')..' '..level..' item.', '\n')
    lore = getLore(lore, get("description"), get("longdescription"), tags, get('category'), get('race'), tips)
    if get("preset") and not string.find(uid, "mimic") then
      lore = appendText(lore, string.format(tips.derivative, root.itemConfig(uid).config.shortdescription), '\n\n')
    end
    if get("altaDescription") then
      lore = appendText(lore, string.format(tips.scan.lore, 'alta'), '\n\n    ')
      lore = appendText(lore, get("altaDescription"), '\n')
    end
    if get("floranDescription") and get('race') == 'floran' then
      lore = appendText(lore, string.format(tips.scan.lore, ("floranDescription"):gsub('Description', '')), '\n\n    ')
      lore = appendText(lore, get("floranDescription"), '\n')
    end
    if not get("longdescription") and not get("altaDescription") and get('race') ~= 'alta' then
      lore = appendText(lore, tips.scan.alien, '\n')
    end
    lore = getAbil(lore, 'primary', tips)  -- Primary Ability
    lore = getAbil(lore, 'alt', tips)      -- Special Ability
    lore = getAbil(lore, 'passive', tips)  -- Passive Ability (currently replaces special in some tootips)

    -- Upgrade
    if config.upgradeParameters and config.upgradeParameters.shortdescription and config.upgradeParameters.shortdescription:len() > 0 then
      local name = config.upgradeParameters.shortdescription
      if name and name ~= get("shortdescription", "") then
        config.tooltipFields.upgradeLabel = name
        config.tooltipFields.upgradeTitleLabel = tips.upgrade
        lore = appendText(lore, tips.upgfull..name, '\n\n    ')
      end
    end

    lore = appendText(lore, '', '\n')
    if config.category == "eppAugment" then lore = appendText(lore, tips.augment, '\n') end
    if config.category == "petCollar" then lore = appendText(lore, tips.collar, '\n') end
    if get("smashOnBreak", false) or get("smashable", false) then lore = appendText(lore, tips.breaks, '\n') end
    if get("foundIn") then lore = appendText(lore, tips.found .. table.concat(get("foundIn"), "^gray;,^reset; "), '\n') end
    if tags and #tags > 0 then lore = appendText(lore, tips.tags..' '..getColored(table.concat(tags, ", ")), '\n') end
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
