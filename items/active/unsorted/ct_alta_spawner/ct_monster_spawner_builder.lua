require "/scripts/util.lua"
require "/items/buildscripts/ct_alta_item_builder.lua"

local ct_alta_item_builder = build

function build(directory, config, parameters, level, seed)
  config.pet = config.itemName
  if config.pets then config.pet = config.pets[math.random(#config.pets)] end
  local pet_params = root.assetJson(config.asset)
  local img = root.monsterPortrait(config.pet)
  if img then
    for i, v in ipairs(img) do
      parameters.tooltipFields = {
        subtitle = config.subtitle or 'Monster Egg',
        objectImage = v.image
      }
    end
  end
  parameters = sb.jsonMerge(parameters, pet_params)
  if not config.inventoryIcon then config.inventoryIcon = config.pet .. '.png' end
  if not config.animation then config.animation = 'default.animation' end
  if not config.animationParts then config.animationParts = {item = config.inventoryIcon} end
  if not parameters.shortdescription then parameters.shortdescription = pet_params.shortdescription end
  if not parameters.description then parameters.description = pet_params.description end
  if not config.scripts then config.scripts = { "monster_spawn.lua" } end
  if not config.ammoUsage then config.ammoUsage = 1 end

  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)
  local params = sb.jsonMerge(config.baseParameters or {}, parameters.baseParameters or {})
  -- sb.logInfo("\n\nprs: %s", params)
  local settings = params.statusSettings or {}
  -- sb.logInfo("\n\nsettings: %s", settings)
  local stats = settings.stats or {}
  -- sb.logInfo("\n\nstats: %s", stats)
  stats.maxHealth.baseValue = stats.maxHealth.baseValue * root.evalFunction("monsterLevelHealthMultiplier", (parameters.level or config.level or 1))
  if stats then
    config.tooltipFields.healthTitleLabel = "^green;HP^reset;:"
    config.tooltipFields.healthLabel = util.round(stats.maxHealth.baseValue, 0)
    config.tooltipFields.armorTitleLabel = "^yellow;Armor^reset;:"
    config.tooltipFields.armorLabel = util.round(stats.protection.baseValue, 1)
    config.tooltipFields.healthRegenTitleLabel = "^green;HP^reset; Regen:"
    config.tooltipFields.healthRegenLabel = util.round(stats.healthRegen.baseValue, 2)

    function getBlock(value)
      if value > 0 then return "block" else return "" end end
    config.tooltipFields.resTitleLabel = "Resistances, %:"
    config.tooltipFields.physicalResTitleLabel = "Phys. Res.:"
    config.tooltipFields.physicalResLabel = util.round(stats.physicalResistance.baseValue * 100, 0)
    config.tooltipFields.physicalResImage = "/interface/tooltips/armor.png"
    config.tooltipFields.fireResTitleLabel = "^red;Fire^reset; Res.:"
    config.tooltipFields.fireResLabel = util.round(stats.fireResistance.baseValue * 100, 0)
    config.tooltipFields.fireResImage = "/interface/statuses/fire" .. getBlock(stats.fireStatusImmunity.baseValue) .. ".png"
    config.tooltipFields.iceResTitleLabel = "^cyan;Ice^reset; Res.:"
    config.tooltipFields.iceResLabel = util.round(stats.iceResistance.baseValue * 100, 0)
    config.tooltipFields.iceResImage = "/interface/statuses/ice" .. getBlock(stats.iceStatusImmunity.baseValue) .. ".png"
    config.tooltipFields.electricResTitleLabel = "^purple;Electric^reset; Res.:"
    config.tooltipFields.electricResLabel = util.round(stats.electricResistance.baseValue * 100, 0)
    config.tooltipFields.electricResImage = "/interface/statuses/electric" .. getBlock(stats.electricStatusImmunity.baseValue) .. ".png"
    config.tooltipFields.poisonResTitleLabel = "^green;Poison^reset; Res.:"
    config.tooltipFields.poisonResLabel = util.round(stats.poisonResistance.baseValue * 100, 0)
    config.tooltipFields.poisonResImage = "/interface/statuses/poison" .. getBlock(stats.poisonStatusImmunity.baseValue) .. ".png"
  end

  return config, parameters
end
