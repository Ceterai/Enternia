require "/scripts/util.lua"
require "/items/buildscripts/ct_alta_item_builder.lua"

local ct_alta_item_builder = build

function build(directory, config, parameters, level, seed)
  local configParameter = function(keyName, defaultValue)
    if parameters[keyName] ~= nil then return parameters[keyName]
    elseif config[keyName] ~= nil then return config[keyName]
    else return defaultValue end
  end

  -- Item stats
  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)
  config.colonyTags = getTags(configParameter("colonyTags", {}), configParameter("race"), configParameter("rarity", "common"), configParameter("elementalType"))
  config.radioMessagesOnPickup = getPickupMsgs(configParameter("radioMessagesOnPickup", {}), config.colonyTags)

  -- Basic stats (Health, Tags, Slots, Drop Warning)
  if configParameter("smashOnBreak", false) or configParameter("smashable", false) then
    config.tooltipFields.smashLabel = "^red;Doesn't drop itself if broken/smashed!^reset;"
  end
  if configParameter("slotCount") ~= nil and configParameter("slotCount") > 0 then
    config.tooltipFields.slotCountLabel = "Holds " .. configParameter("slotCount") .. " Items"
  end
  local light = configParameter("lightColor")
  if light ~= nil then
    for i = 1, #light do light[i] = string.format("%02s", string.format("%x", light[i])) end
    config.tooltipFields.lightTitleLabel = "Light color:"
    config.tooltipFields.lightLabel = "^#" .. table.concat(light) .. ";^reset;"
  end
  config.tooltipFields.tagsTitleLabel = "Tags:"
  config.tooltipFields.tagsLabel = "^gray;" .. table.concat(config.colonyTags, ", ") .. "^reset;"
  config.tooltipFields.healthTitleLabel = "Health:"
  config.tooltipFields.healthLabel = configParameter("health", 1) * 10

  -- Damage (Traps, Turrets, Mines, Hazards)
  local abil = sb.jsonMerge(config.touchDamage or {}, parameters.touchDamage or {})
  local dmg = abil.damage or abil.baseDamage or abil.power or configParameter("baseDamage") or configParameter("damage") or configParameter("power")
  local rate = (abil.fireTime or configParameter("fireTime"))
  local eps = (abil.energyUsage or configParameter("energyUsage"))
  local kb = (abil.knockback or configParameter("knockback"))
  if dmg ~= nil and dmg > 0 then
    dmg = dmg * (config.damageLevelMultiplier or 1)
    config.tooltipFields.damagePerShotTitleLabel = "^blue;DMG^reset;/Shot:"
    config.tooltipFields.damagePerShotLabel = util.round(dmg, 1)
    if rate ~= nil then
      local dps = dmg / rate
      config.tooltipFields.dpsTitleLabel = "^blue;DPS^reset;:"
      config.tooltipFields.dpsLabel = util.round(dps, 1)
      config.tooltipFields.fireRateTitleLabel = "FireRate:"
      config.tooltipFields.fireRateLabel = util.round(1 / rate, 1)
      if eps ~= nil then
        config.tooltipFields.energyPerShotTitleLabel = "^cyan;ERG^reset;/Shot:"
        config.tooltipFields.energyPerShotLabel = util.round(eps * (rate or 1.0), 1)
        config.tooltipFields.damagePerEnergyTitleLabel = "^blue;DMG^reset;/^cyan;ERG^reset;:"
        config.tooltipFields.damagePerEnergyLabel = util.round(dps / eps, 1)
      end
    end
    if eps ~= nil then
      config.tooltipFields.energyTitleLabel = "^cyan;EPS^reset;:"
      config.tooltipFields.energyLabel = util.round(eps, 1)
    end
    if kb ~= nil then
      config.tooltipFields.knockbackTitleLabel = "Knockback:"
      config.tooltipFields.knockbackLabel = kb
    end
  end
  return config, parameters
end
