require "/items/buildscripts/ct_utils.lua"


function init()
  local tips = getTextConfig()
end

function openScanner(widgetName)
  player.interact('ScriptPane', '/items/active/alta/scanner/gui.config')
  pane.dismiss()
end

function openStation(widgetName)
  local interactData = {
    config = '/objects/alta/crafting/crafting_station/tier5.config'
  }
  player.interact('OpenCraftingInterface', interactData, player.id())
end
