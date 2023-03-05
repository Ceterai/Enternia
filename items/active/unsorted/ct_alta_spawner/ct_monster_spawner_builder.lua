require "/scripts/util.lua"

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
  if not config.inventoryIcon then
    config.inventoryIcon = config.pet .. '.png'
  end
  if not config.animation then
    config.animation = 'default.animation'
  end
  if not config.animationParts then
    config.animationParts = {item = config.inventoryIcon}
  end
  if not parameters.shortdescription then
    parameters.shortdescription = pet_params.shortdescription
  end
  if not parameters.description then
    parameters.description = pet_params.description
  end
  if not config.scripts then
    config.scripts = { "monster_spawn.lua" }
  end
  if not config.ammoUsage then
    config.ammoUsage = 1
  end

  return config, parameters
end
