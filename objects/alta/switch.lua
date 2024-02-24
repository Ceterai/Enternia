-- Hooks

-- # Switch
-- General switch/light script.
-- ## Parameters
-- All parameters are oprional (unless needed for compatability, like `stateType`).
-- - `alwaysLit`, `bool` (default: `false`)
-- - `alwaysOn`, `bool` (default: `false`)
-- - `blockInteractIfConnected`, `bool` (default: `false`)
-- - `defaultState`, `bool` (default: `false`)
-- - `inputNodes`, `list` (default: `nil`)
-- - `interactive`, `bool` (default: `true`) - if `true`, will be interactive.
-- Can be set to false for objects that are only supposed to be switched by other objects.
-- - `lightColor`, `list` (default: `[0, 0, 0]`)
-- - `lightColorOff`, `list` (default: `[0, 0, 0]`)
-- - `oneWay`, `bool` (default: `false`)
-- - `persistent`, `bool` (default: `false`)
-- - `stateType`, `bool` (default: `false`)
function init()
    processWireInput(storage.state or getDefaultState(), true)
    if storage.triggered == nil and config.getParameter("oneWay", false) then
        storage.triggered = false
    end
end

function update(dt)  -- WIP logic
    if storage.triggered ~= nil and config.getParameter("oneWay", false) then
        if object.getInputNodeLevel(0) and not storage.triggered then
            storage.triggered = true
            output(not storage.state)
        elseif storage.triggered and not object.getInputNodeLevel(0) then
            storage.triggered = false
        end
    end
end

function state() if not isPersistent() then return storage.state end end
function onNpcPlay(npcId) onInteraction() end  -- Switch state on npc play.
function onNodeConnectionChange(args) processWireInput() end
function onInteraction(args) if not shouldBlockInteract() then output(not storage.state) end end
function onInputNodeChange(args) if args.level and isPersistent() then output(args.node == 0) else processWireInput() end end

-- Custom methods

function processWireInput(forceState, forceSwitch)
    if shouldBlockInteract() then setInteractive(false) else setInteractive() end
    output(getValue(forceState, getInputState()), forceSwitch)
end

function output(forceState, forceSwitch) switch(getValue(forceState, getDefaultState()), forceSwitch) end

function switch(state, forceSwitch)
    if isAlwaysOn() then state = true end
    if state ~= storage.state or forceSwitch then
        storage.state = state
        local stateName = "off"
        if state then stateName = "on" end
        local stateType = config.getParameter("stateType", "body")  -- switchState, light
        if stateType ~= "none" then animator.setAnimationState(stateType, stateName) end
        if not isAlwaysLit() then object.setLightColor(getLightColor(state)) end
        object.setSoundEffectEnabled(state)
        if animator.hasSound(stateName) then animator.playSound(stateName) end
        object.setAllOutputNodes(state)
    end
end

function getValue(val, default) if val == nil then return default else return val end end
function getDefaultState() return config.getParameter("defaultState", false) end
function getInputNodes() return config.getParameter("inputNodes") end
function getInputState(node) if getInputNodes() then return object.getInputNodeLevel(node or 0) end end
function getLightColor(state) local var = "lightColor"; if not state then var = var.."Off" end; return config.getParameter(var, {0, 0, 0}) end
function isConnected(node) return getInputNodes() and object.isInputNodeConnected(node or 0) end
function isPersistent() return config.getParameter("persistent", false) end
function isInteractive() return config.getParameter("interactive", true) end
function isAlwaysOn() return config.getParameter("alwaysOn", false) end
function isAlwaysLit() return config.getParameter("alwaysLit", false) end
function canBlockInteract() return config.getParameter("blockInteractIfConnected", false) end
function shouldBlockInteract() return canBlockInteract() and isConnected() end
function setInteractive(forceState) object.setInteractive(getValue(forceState, isInteractive())) end

function debug()
    sb.logInfo("debug \"%s\":\n"
        .."- alwaysLit:\t%s\n"
        .."- alwaysOn:\t%s\n"
        .."- oneWay:\t%s\n"
        .."- persistent:\t%s\n"
        .."- interactive:\t%s\n"
        .."- blockInter.:\t%s\n"
        .."- stateType:\t%s\n"
        .."- defaultState:\t%s\n"
        .."- inputNodes:\t%s\n",
        config.getParameter("objectName"),
        isAlwaysLit(),
        isAlwaysOn(),
        config.getParameter("oneWay", false),
        isPersistent(),
        isInteractive(),
        canBlockInteract(),
        config.getParameter("stateType", "body"),
        getDefaultState(),
        getInputNodes()
    )
end

function debugState(action)
    sb.logInfo("%s \"%s\" - state:\t%s\n",
        action or "debug",
        config.getParameter("objectName"),
        storage.state
    )
end
