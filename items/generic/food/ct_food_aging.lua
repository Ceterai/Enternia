require "/items/buildscripts/alta/consumable.lua"

-- # My Enternia Item Aging
-- A hook used by consumable items to age them (if this file is specified in the `agingScripts` list of that item).
---@param item { name: string, count: number, parameters: table } The current item instance, including amount & custom params.
---@param aging number A `dt` value passed by the game to indicate how much time has passed since the last update.
function ageItem(item, aging)
  local base = root.itemConfig(item.name) ---@type {config:{timeToRot: number,variants:table,presets:table}} Item's base config.
  local get = function(key, default) return getValue(key, default, base.config, item.parameters) end

  if item.parameters.timeToRot == base.config.timeToRot and base.config.variants and not item.parameters.variant then
    item.parameters = sb.jsonMerge(item.parameters, chooseVariant(base.config.variants, base.config.presets) or {})
  end
  item.parameters.timeToRot = item.parameters.timeToRot - aging
  if item.parameters.timeToRot <= 0 then return {name=get("agedItem", "rottenfood"), count=item.count, parameters={}} end
  item.parameters.tooltipFields = item.parameters.tooltipFields or {}
  item.parameters.tooltipFields.rotTimeLabel = getRotTimeTooltip(item.parameters.timeToRot, get("rotConfig"), true)
  return item
end

---@param variants [string] A list of presets that can be applied in case of **Perfect Cooking**.
---@param presets table A set of presets (objects) to be used when returning a variant.
---@return table|nil
function chooseVariant(variants, presets)
  local total = 0.0
  local roll = util.randomInRange({total, 1.0})
  for i, variant in ipairs(variants) do if presets[variant] then
    total = total + (presets[variant].chance or 0.1)
    if roll <= total then return sb.jsonMerge(presets[variant], {variant = true}) end
  end end
end
