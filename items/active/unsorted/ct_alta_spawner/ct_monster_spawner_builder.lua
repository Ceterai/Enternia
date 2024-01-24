require "/scripts/util.lua"
require "/items/buildscripts/ct_alta_item_builder.lua"

local ct_alta_item_builder = build


-- # My Enternia Monster Spawner Builder
-- This enhanced monster spawner builder is based on the enhanced item builder, and is able to provide an extended amount of functions.
-- Its main usage is for monster spawner items, items that spawn a monster when used/consumed.
-- More info: https://github.com/Ceterai/Enternia/wiki/Modding-Items#monster-spawners
-- ## Monster Config
-- Can load and merge with a monster config, if a path to it is provided:
-- - `asset` (`str`) - the path to `.monstertype` file with the monster's parameters.
-- ## Tooltips
-- A big variety of supported tooltip fields, including:
-- - everything from the item builder
-- - health info
-- - resistance info
-- > Note that all tooltip text is located in a separate config file.
function build(directory, config, parameters, level, seed)
  local tips = getTextConfig()
  config.pet = config.itemName
  if config.pets then config.pet = config.pets[math.random(#config.pets)] end
  local pet_params = root.assetJson(config.asset)
  local img = root.monsterPortrait(config.pet)
  if img then
    for i, v in ipairs(img) do
      parameters.tooltipFields = {
        subtitle = config.subtitle or tips.egg,
        objectImage = v.image
      }
    end
  end
  parameters = sb.jsonMerge(parameters, pet_params)
  if not config.inventoryIcon then config.inventoryIcon = config.pet .. '.png' end
  if not config.animation then config.animation = 'default.animation' end
  if not config.animationParts then config.animationParts = {item = config.inventoryIcon} end
  if pet_params.shortdescription then parameters.shortdescription = pet_params.shortdescription end
  if pet_params.shortdescription then config.shortdescription = pet_params.shortdescription end
  if not parameters.description then parameters.description = pet_params.description end
  if not config.scripts then config.scripts = { "monster_spawn.lua" } end
  if not config.ammoUsage then config.ammoUsage = 1 end

  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)
  local params = sb.jsonMerge(config.baseParameters or {}, parameters.baseParameters or {})
  local settings = params.statusSettings or {}
  local stats = settings.stats or {}
  stats.maxHealth.baseValue = stats.maxHealth.baseValue * root.evalFunction("monsterLevelHealthMultiplier", (parameters.level or config.level or 1))
  if stats then
    config.tooltipFields.healthTitleLabel = tips.HP
    config.tooltipFields.healthLabel = util.round(stats.maxHealth.baseValue, 0)
    config.tooltipFields.armorTitleLabel = tips.AP
    config.tooltipFields.armorLabel = util.round(stats.protection.baseValue, 1)
    config.tooltipFields.healthRegenTitleLabel = tips.HPR
    config.tooltipFields.healthRegenLabel = util.round(stats.healthRegen.baseValue, 2)

    function getBlock(value)
      if value > 0 then return "block" else return "" end end
    config.tooltipFields.resTitleLabel = tips.resist.title
    config.tooltipFields.physicalResTitleLabel = tips.resist.physical
    config.tooltipFields.physicalResLabel = util.round(stats.physicalResistance.baseValue * 100, 0)
    config.tooltipFields.physicalResImage = "/interface/tooltips/armor.png"
    config.tooltipFields.fireResTitleLabel = tips.resist.fire
    config.tooltipFields.fireResLabel = util.round(stats.fireResistance.baseValue * 100, 0)
    config.tooltipFields.fireResImage = "/interface/statuses/fire" .. getBlock(stats.fireStatusImmunity.baseValue) .. ".png"
    config.tooltipFields.iceResTitleLabel = tips.resist.ice
    config.tooltipFields.iceResLabel = util.round(stats.iceResistance.baseValue * 100, 0)
    config.tooltipFields.iceResImage = "/interface/statuses/ice" .. getBlock(stats.iceStatusImmunity.baseValue) .. ".png"
    config.tooltipFields.electricResTitleLabel = tips.resist.electric
    config.tooltipFields.electricResLabel = util.round(stats.electricResistance.baseValue * 100, 0)
    config.tooltipFields.electricResImage = "/interface/statuses/electric" .. getBlock(stats.electricStatusImmunity.baseValue) .. ".png"
    config.tooltipFields.poisonResTitleLabel = tips.resist.poison
    config.tooltipFields.poisonResLabel = util.round(stats.poisonResistance.baseValue * 100, 0)
    config.tooltipFields.poisonResImage = "/interface/statuses/poison" .. getBlock(stats.poisonStatusImmunity.baseValue) .. ".png"
  end

  return config, parameters
end
