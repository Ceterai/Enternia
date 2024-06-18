local CSAILoldInit = init
local CSAILoldOnInteraction = onInteraction

-- # My Enternia S.A.I.L. Script
-- This builder was created mainly to provide in-built support for a mod called Scripted Artificial Intelligence Lattice (Customisable A.I.!)  
-- Link: https://steamcommunity.com/workshop/filedetails/?id=947429656
function init()
  if isCSAILinstalled() then
    object.setConfigParameter("interactAction", "ScriptPane")
    object.setConfigParameter("interactData", "/interface/ai/aicustom.config")
    object.setConfigParameter("fallbackInteractAction", "OpenAiInterface")
    object.setConfigParameter("fallbackInteractData", "")
    object.setConfigParameter("screwdriverInteractAction", "ScriptPane")
    object.setConfigParameter("screwdriverInteractData", "/interface/ai/backpanel.config")
    object.setConfigParameter("animationScripts", { "/objects/scripts/changeObjectSprite.lua", })
  else
    object.setConfigParameter("interactAction", "OpenAiInterface")
    object.setConfigParameter("interactData", nil)
    object.setConfigParameter("fallbackInteractAction", nil)
    object.setConfigParameter("fallbackInteractData", nil)
    object.setConfigParameter("screwdriverInteractAction", nil)
    object.setConfigParameter("screwdriverInteractData", nil)
    object.setConfigParameter("animationScripts", nil)
  end
	if CSAILoldInit then CSAILoldInit() end
  if isCSAILinstalled() then
    object.setConfigParameter("retainScriptStorageInItem", true)
    self.fallback = false
    storage.data = storage.data or {}
    storage.imageconfig = storage.imageconfig or nil
    object.setAnimationParameter("imageConfig", storage.imageconfig)

    --there are too many similar handlers, but I'm too tired to rewrite now, and later I'll be too lazy because it'd work anyway, rip this
    message.setHandler("setFallback", function(_,_, value) self.fallback = value end)
    message.setHandler("storeData", function(_,_, widget, data) storage.data[widget] = data end)
    message.setHandler("returnData", function() return storage.data end)
    message.setHandler("screwdriverInteraction", function() return {config.getParameter("screwdriverInteractAction"), config.getParameter("screwdriverInteractData")} end) --also this is probably a super shitty way to handle this but maybe I'll use that screwdriver for other things later
    message.setHandler("setImage", function(_,_, imageconfig)
      storage.imageconfig = imageconfig
      object.setAnimationParameter("imageConfig", imageconfig) 
    end)
    message.setHandler("setInterfaceObj", function(_,_, itemDesc) storage.interfaceObjIDesc = itemDesc end)
    message.setHandler("gibInterfaceObj", function() return storage.interfaceObjIDesc end)
  end
end

function onInteraction()
  if CSAILoldOnInteraction then
    if isCSAILinstalled() then
      if self.dialogTimer then
        sayNext()
        return nil
      else
        if not self.fallback then
          return {config.getParameter("interactAction"), config.getParameter("interactData")}
        else
          return {config.getParameter("fallbackInteractAction"), config.getParameter("fallbackInteractData")}
        end
      end
    else
      return CSAILoldOnInteraction()
    end
  end
end

function isCSAILinstalled()
  return root.assetJson("/objects/ship/hylotltechstation/hylotltechstation.object").screwdriverInteractAction
end
