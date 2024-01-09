require "/scripts/util.lua"
require "/items/buildscripts/ct_alta_item_builder.lua"

local ct_alta_item_builder = build

function build(directory, config, parameters, level, seed)
  local configParameter = function(key, default) return getValue(key, default, config, parameters) end

  -- Item stats
  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)
  config.colonyTags = getTags(configParameter("colonyTags"), configParameter("race"), configParameter("rarity", "common"), configParameter("elementalType"))
  if parameters.colonyTags and parameters.colonyTags ~= config.colonyTags then parameters.colonyTags = config.colonyTags end
  config.radioMessagesOnPickup = getPickupMsgs(configParameter("radioMessagesOnPickup", {}), config.colonyTags)
  local tips = getTextConfig()

  -- Basic stats (Health, Tags, Slots, Drop Warning)
  if configParameter("smashOnBreak", false) or configParameter("smashable", false) then
    config.tooltipFields.smashLabel = tips.breaks
  end
  if configParameter("slotCount") ~= nil and configParameter("slotCount") > 0 then
    config.tooltipFields.slotCountLabel = string.format(tips.store, configParameter("slotCount"))
  end
  local light = configParameter("lightColor")
  if light ~= nil then
    for i = 1, #light do light[i] = string.format("%02s", string.format("%x", light[i])) end
    config.tooltipFields.lightTitleLabel = tips.light
    config.tooltipFields.lightLabel = "^#"..table.concat(light)..";^reset;"
  end
  config.tooltipFields.tagsTitleLabel = tips.tags
  config.tooltipFields.tagsLabel = getColored(table.concat(config.colonyTags, ", "))
  config.tooltipFields.healthTitleLabel = tips.health
  config.tooltipFields.healthLabel = configParameter("health", 1) * 10

  -- Damage (Traps, Turrets, Mines, Hazards)
  local abil = sb.jsonMerge(config.touchDamage or config.barrierDamage or {}, parameters.touchDamage or {})
  local dmg = abil.damage or abil.baseDamage or abil.power or configParameter("baseDamage") or configParameter("damage") or configParameter("power")
  local rate = (abil.fireTime or configParameter("fireTime"))
  local eps = (abil.energyUsage or configParameter("energyUsage"))
  local kb = (abil.knockback or configParameter("knockback"))
  if dmg ~= nil and dmg > 0 then
    dmg = dmg * (config.damageLevelMultiplier or 1)
    config.tooltipFields.damagePerShotTitleLabel = tips.DPC
    config.tooltipFields.damagePerShotLabel = util.round(dmg, 1)
    if rate ~= nil then
      local dps = dmg / rate
      config.tooltipFields.dpsTitleLabel = tips.DPS
      config.tooltipFields.dpsLabel = util.round(dps, 1)
      config.tooltipFields.fireRateTitleLabel = tips.FSR
      config.tooltipFields.fireRateLabel = util.round(1 / rate, 1)
      if eps ~= nil then
        config.tooltipFields.energyPerShotTitleLabel = tips.EPC
        config.tooltipFields.energyPerShotLabel = util.round(eps * (rate or 1.0), 1)
        config.tooltipFields.damagePerEnergyTitleLabel = tips.DPE
        config.tooltipFields.damagePerEnergyLabel = util.round(dps / eps, 1)
      end
    end
    if eps ~= nil then
      config.tooltipFields.energyTitleLabel = tips.EPS
      config.tooltipFields.energyLabel = util.round(eps, 1)
    end
    if kb ~= nil then
      config.tooltipFields.knockbackTitleLabel = tips.KB
      config.tooltipFields.knockbackLabel = kb
    end
  end
  return config, parameters
end
