require "/scripts/util.lua"

function build(directory, config, parameters, level, seed)
  if not parameters.stemName and not parameters.foliageName then
    parameters.stemName = "ct_ayaka_garden_stem"
    parameters.foliageName = "ct_ayaka_garden_leaves"
    parameters.scriptStorage = {}
    local icon = config.inventoryIcon
    config.inventoryIcon = jarray()
    table.insert(config.inventoryIcon, {
        image = string.format("%s?hueshift=%s", util.absolutePath(directory, icon), 0)
      })
  else
    if not parameters.stemName then
      parameters.stemName = "ct_ayaka_garden_stem"
      parameters.foliageName = parameters.foliageName or "ct_ayaka_garden_leaves"
    end
  
    config.inventoryIcon = jarray()
  
    table.insert(config.inventoryIcon, {
        image = string.format("%s?hueshift=%s", util.absolutePath(root.treeStemDirectory(parameters.stemName), "icon.png"), parameters.stemHueShift or 0)
      })
  
    table.insert(config.inventoryIcon, {
        image = string.format("%s?hueshift=%s", util.absolutePath(root.treeStemDirectory(parameters.stemName), parameters.stemName .. "_icon.png"), parameters.stemHueShift or 0)
      })
  
    if parameters.foliageName then
      table.insert(config.inventoryIcon, {
          image = string.format("%s?hueshift=%s", util.absolutePath(root.treeFoliageDirectory(parameters.foliageName), "icon.png"), parameters.foliageHueShift or 0)
        })
    end
  end

  return config, parameters
end
