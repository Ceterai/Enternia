require "/scripts/util.lua"

function ageItem(baseItem, aging)
  local itemConfig = root.itemConfig(baseItem.name)
  local rot_config = getParam(baseItem, itemConfig, "rotConfig", "/items/generic/food/ct_ionic_rotting.config")
  if baseItem.parameters.timeToRot then
    -- sb.logInfo("\n\nname: %s\nrot: %s\nmax: %s", baseItem.name, baseItem.parameters.timeToRot, getParam(baseItem, itemConfig, "timeToRotMax", 0))
    if baseItem.parameters.timeToRot == getParam(baseItem, itemConfig, "timeToRotMax", 0) then
      -- sb.logInfo("\n\nname: %s\nrot: %s\nmax: %s", baseItem.name, baseItem.parameters.timeToRot, getParam(baseItem, itemConfig, "timeToRotMax", 0))
      -- sb.logInfo("\n\nvariants: %s", itemConfig.config.variants)
      if itemConfig.config.variants and not baseItem.parameters.variant then
        local variant = getVariant(itemConfig.config.variants, itemConfig.config.presets)
        if #variant > 0 then
          baseItem.parameters = sb.jsonMerge(baseItem.parameters, variant)
          baseItem.parameters.variant = true
          -- baseItem.parameters.description = "^cyan;Perfect cooking!^reset; "..(baseItem.parameters.description or "")
        end
      end
    end
    baseItem.parameters.timeToRot = baseItem.parameters.timeToRot - aging

    baseItem.parameters.tooltipFields = baseItem.parameters.tooltipFields or {}
    baseItem.parameters.tooltipFields.rotTimeLabel = getRotTimeDescription(baseItem.parameters.timeToRot, rot_config)

    if baseItem.parameters.timeToRot <= 0 then
      return {
        name = getParam(baseItem, itemConfig, "rottedItem", root.assetJson(rot_config .. ":rottedItem")),
        count = baseItem.count,
        parameters = {}
      }
    end
  end
  return baseItem
end

function getParam(baseItem, itemConfig, keyName, defaultValue)
  if baseItem.parameters[keyName] ~= nil then return baseItem.parameters[keyName]
  elseif itemConfig.config[keyName] ~= nil then return itemConfig.config[keyName]
  else return defaultValue end
end

function getVariant(variants, presets)
  local total = 0.0
  local roll = util.randomInRange({total, 1.0})
  -- sb.logInfo("\n- roll: %s", roll)
  for i, variant in ipairs(variants) do
    total = total + (presets[variant].chance or 0.1)
    -- sb.logInfo("\n- total: %s", total)
    if roll <= total then return presets[variant] end
  end
  return { }
end

function getRotTimeDescription(rotTime, rotConfig)
  local descList = root.assetJson(rotConfig .. ":rotTimeDescriptions")
  for i, desc in ipairs(descList) do
    if rotTime <= desc[1] then return desc[2] end
  end
  return descList[#descList]
end
