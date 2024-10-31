-- A collection of methods commonly used by item builder scripts.
require '/scripts/util.lua'


function replaceRegexInData(data, replacevalue)
  if type(data) == 'table' then
    for k, v in pairs(data) do
      if (type(v) == 'string' and v:len() > 4 and (v:find('%.png') or v:find('%.animation') or (k ~= 'builder' and v:find('%.lua'))) and v:sub(1, 1) ~= '/') then
        data[k] = replacevalue..v  -- sb.logInfo("\nReplacing value %s of key %s with value %s\n", v, k, data[k])
      else replaceRegexInData(v, replacevalue) end
    end
  end
end

function getValue(keyName, defaultValue, config, parameters)
  if parameters[keyName] ~= nil then return parameters[keyName]
  elseif config[keyName] ~= nil then return config[keyName]
  else return defaultValue end
end

function inif(q, t, f) if q then return t else return f end end  -- Inline if-else: if q, then t, else f. Warning: args are pre-calculated.
function rand(v) if type(v) == "table" then return util.randomChoice(v) else return v end end  -- Better `util.randomChoice` that handles non-tables.
function nullify(data, keys) for _, key in ipairs(keys) do if data[key] then data[key] = nil end end end
function getTextConfig(path) return root.assetJson(path or '/items/buildscripts/ct_texts.config') end
function getTitle(text) return string.gsub(' '..text, '%W%l', string.upper):sub(2) end
function getColored(text, color) return '^' .. (color or 'gray') .. ';' .. text .. '^reset;' end
function appendText(old, new, delimiter) if old then return old .. delimiter .. new else return new end end
function appendList(l1, l2) for _,v in ipairs(l2 or {}) do l1[#l1+1] = v end; return l1 end

function getSortedUnique(list)
  local hash = {}
  local res = {}
  for _,v in ipairs(list or {}) do if (not hash[v]) and v and v ~= '' then res[#res+1] = v; hash[v] = true end end
  table.sort(res)
  return res
end

function getTags(tagList, race, rarity, element) return getSortedUnique(appendList(tagList or jarray(), {race or '', (rarity or ''):lower(), element or ''})) end

function getPickupMsgs(msgList, tagList)
  for _,v in ipairs(tagList) do
    if v == 'gsr' then table.insert(msgList, 'ct_gsr_msg') end
    if v == 'set' then table.insert(msgList, 'ct_set_msg') end
    if v == 'loot' then table.insert(msgList, 'ct_loot_crate_msg') end
    if v == 'datamass' then table.insert(msgList, 'ct_datamass_msg') end
    if v == 'ebook' then table.insert(msgList, 'ct_ebook_msg') end
    if v == 'faradea' then table.insert(msgList, 'ct_faradea_msg') end
    if v == 'haven' then table.insert(msgList, 'ct_haven_msg') end
    if v == 'warped' then table.insert(msgList, 'ct_warped_msg') end
    if v == 'eds' then table.insert(msgList, 'ct_eds_msg') end
    if v == 'shield' then table.insert(msgList, 'ct_alta_shield_msg') end
    if v == 'weapon' then table.insert(msgList, 'ct_alta_weapon_msg') end
    if v == 'energy_shielder' then table.insert(msgList, 'ct_energy_shielder_msg') end
    if v == 'drone' or v == 'droid' then table.insert(msgList, 'ct_robot_spawner_msg') end
  end
  if #msgList > 0 then return getSortedUnique(msgList) end
end

function getDirectivesString(dirT, dirs)
  for _, v in ipairs(dirT) do dirs = string.format("%s%s", dirs, v) end
  return dirs
end

function getDirectivesList(palette, option)
  local dirs = {}
  for k, v in pairs(palette[option + 1] or {}) do table.insert(dirs, string.format("?replace=%s=%s", k:gsub('#', ''), v:gsub('#', ''))) end
  return dirs
end

function getCleanImage(img, swaps)
  for _, swap in ipairs(swaps) do img = img:gsub(swap, '') end
  return img
end

function getColoredImage(icon, dirs, oldSwaps)
  if type(icon) == "string" then icon = getCleanImage(icon, oldSwaps)..dirs
  elseif icon then
    for i, drawable in ipairs(icon) do
      if drawable.image then
        drawable.image = getCleanImage(drawable.image, oldSwaps)..dirs
      end
    end
  end
  return icon
end

function getPalette(palette, swaps, directory)
  swaps = copy(swaps or {})
  if type(palette) == "string" then palette = root.assetJson(util.absolutePath(directory, palette)) end
  if palette and swaps then for i, _ in ipairs(palette) do for key, swap in pairs(swaps) do palette[i][key:gsub('#', '')] = swap:gsub('#', '') end end end
  return palette
end

-- Deprecated, left for compatability

function getColorDirectives(dirT, dirs)
  for _, v in ipairs(dirT) do dirs = string.format("%s%s", dirs, v) end
  return dirs
end

function getDirectivesTable(dir, palette, option, swaps, dirs)
  swaps = copy(swaps or {})
  if palette then for k, v in pairs(root.assetJson(util.absolutePath(dir, palette))[(option or 0) + 1]) do swaps[k] = v end end
  for k, v in pairs(swaps) do table.insert(dirs, string.format("?replace=%s=%s", k:gsub('#', ''), v:gsub('#', ''))) end
  return dirs
end

function getColorsIcon(icon, dirs, oldSwaps)
  if type(icon) == "string" then icon = getCleanImage(icon, oldSwaps)..dirs
  elseif icon then for i, drawable in ipairs(icon) do if drawable.image then drawable.image = getCleanImage(drawable.image, oldSwaps)..dirs end end end
  return icon
end

function getColorsArmor(options, swaps)
  if options and swaps then for i, _ in ipairs(options) do for key, swap in pairs(swaps) do options[i][key:gsub('#', '')] = swap:gsub('#', '') end end end
  return options
end
