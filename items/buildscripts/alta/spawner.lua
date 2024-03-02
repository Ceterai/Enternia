require "/scripts/util.lua"
require "/items/buildscripts/alta/item.lua"

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
  -- 1. Load monster parameters
  config.pet = config.itemName
  if config.pets then config.pet = config.pets[math.random(#config.pets)] end
  local pet_params = root.assetJson(config.asset)
  -- 2. Get basic parameters if not set
  if pet_params.shortdescription then config.shortdescription = pet_params.shortdescription end
  if not config.description then config.description = pet_params.description end
  if not config.inventoryIcon then config.inventoryIcon = config.pet .. '.png' end
  if not config.animation then config.animation = 'default.animation' end
  if not config.animationParts then config.animationParts = {item = config.inventoryIcon} end
  if not config.scripts then config.scripts = { "monster_spawn.lua" } end
  if not config.ammoUsage then config.ammoUsage = 1 end
  -- 3. Merge with monster base parameters
  config = sb.jsonMerge(config, pet_params)
  -- 4. Run through regular builder
  config, parameters = ct_alta_item_builder(directory, config, parameters, level, seed)
  -- 5. Construct monster preview
  local img = root.monsterPortrait(config.pet, parameters.baseParameters)
  local tooltip = config.subtitle or tips.egg
  local frame = config.iconTooltipFrame
  if config.titleTooltip then tooltip = tips[config.titleTooltip] end
  if img then
    for i, v in ipairs(img) do
      if parameters.baseParameters and parameters.baseParameters.customBody then
        v.image = parameters.baseParameters.customBody..string.gsub(v.image, '^.*:', ':')
      end
      if frame then
        v.image = string.gsub(v.image, ':.*$', ':')..frame
      end
      parameters.tooltipFields = {
        subtitle = tooltip,
        objectImage = v.image
      }
    end
  end
  -- 6. Get tooltips
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
