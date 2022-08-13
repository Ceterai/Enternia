require "/scripts/util.lua"

function build(directory, config, parameters, level, seed)
  if not parameters.stemName then
    parameters.stemName = "ct_ayaka_garden_stem"
    parameters.foliageName = parameters.foliageName or "ct_ayaka_garden_leaves"
  end

  config.inventoryIcon = jarray()

  table.insert(config.inventoryIcon, {
      image = string.format("%s?hueshift=%s", util.absolutePath(root.treeStemDirectory(parameters.stemName), "icon.png"), parameters.stemHueShift or 0)
    })

  if parameters.foliageName then
    table.insert(config.inventoryIcon, {
        image = string.format("%s?hueshift=%s", util.absolutePath(root.treeFoliageDirectory(parameters.foliageName), "icon.png"), parameters.foliageHueShift or 0)
      })
  end

  return config, parameters
end
