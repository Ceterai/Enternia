local oldInit = init  -- original S.A.I.L. `init()`
local oldOnInteraction = onInteraction  -- original S.A.I.L. `onInteraction()`


-- ### My Enternia S.A.I.L. Init Script
-- This builder was created mainly to provide in-built support for a mod called Scripted Artificial Intelligence Lattice (Customisable A.I.!)  
-- Read more here: https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support#customizable-ai
function init()

  -- Dynamically updating object parameters to support CSAIL if it is installed, otherwise switch back
  setCSAILparameters()

  -- Run original S.A.I.L. `init()` if that script was included in `scripts`
	if oldInit then oldInit() end

  -- Run CSAIL init if CSAIL was detected
  if isCSAILinstalled() then CSAILinit() end
end


-- ### My Enternia S.A.I.L. Interaction Script
-- A custom script run on interaction with S.A.I.L. See `init()` description for more info.
function onInteraction()
  if oldOnInteraction then
    if isCSAILinstalled() then return CSAILonInteraction() else return oldOnInteraction() end
  end
end


--- Custom Functions ---


-- ### My Enternia S.A.I.L. CSAIL Detection Script
-- A simple way to determine whether CSAIL is installed is by checking whether a vanilla S.A.I.L.
-- has its patched parameters.  
-- Made it a separate function for ease of use and updating if needed.
function isCSAILinstalled()
  return root.assetJson("/objects/ship/hylotltechstation/hylotltechstation.object").screwdriverInteractAction
end


-- ### My Enternia S.A.I.L. CSAIL Parameters Setting Script
-- Here, CSAIL-required params are set if CSAIL is detected. Otherwise, vanilla ones are applied.  
-- Made it a separate function for ease of use and updating if needed.
function setCSAILparameters()
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
end


--- Customisable A.I. (CSAIL) Logic ---


-- ### My Enternia S.A.I.L. CSAIL Init Script Part
-- CSAIL logic copied from its `init()` (`/objects/scripts/customtechstation.lua`),
-- should run if CSAIL was detected.  
-- Made it a separate function for ease of use and updating if needed.
function CSAILinit()
  object.setConfigParameter("retainScriptStorageInItem", true)
  self.fallback = false
  storage.data = storage.data or {}
  storage.imageconfig = storage.imageconfig or nil
  object.setAnimationParameter("imageConfig", storage.imageconfig)

  message.setHandler("setFallback", function(_,_, value) self.fallback = value end)
  message.setHandler("storeData", function(_,_, widget, data) storage.data[widget] = data end)
  message.setHandler("returnData", function() return storage.data end)
  message.setHandler("screwdriverInteraction", function()
    return {config.getParameter("screwdriverInteractAction"), config.getParameter("screwdriverInteractData")}
  end)
  message.setHandler("setImage", function(_,_, imageconfig)
    storage.imageconfig = imageconfig
    object.setAnimationParameter("imageConfig", imageconfig)
  end)
  message.setHandler("setInterfaceObj", function(_,_, itemDesc) storage.interfaceObjIDesc = itemDesc end)
  message.setHandler("gibInterfaceObj", function() return storage.interfaceObjIDesc end)
end


-- ### My Enternia S.A.I.L. CSAIL Interaction Script Part
-- CSAIL logic copied from its `onInteraction()` (`/objects/scripts/customtechstation.lua`),
-- should be called in return statement if CSAIL was detected.  
-- Made it a separate function for ease of use and updating if needed.
function CSAILonInteraction()
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
end
