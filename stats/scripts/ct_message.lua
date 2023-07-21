require "/stats/scripts/ct_immune.lua"


function init() queueImmuneMessage() end
function update(dt) end
function uninit() end

-- Plays different radio messages depending on immunity.
function queueImmuneMessage()
  if immune() and config.getParameter("radioMessageImmune") ~= nil then queueMessage(config.getParameter("radioMessageImmune"))
  elseif semiImmune(true) and config.getParameter("radioMessageSemiImmune") ~= nil then queueMessage(config.getParameter("radioMessageSemiImmune"))
  elseif barelyImmune(true) and config.getParameter("radioMessageBarelyImmune") ~= nil then queueMessage(config.getParameter("radioMessageBarelyImmune"))
  elseif vulnerable() and config.getParameter("radioMessageVulnerable") ~= nil then queueMessage(config.getParameter("radioMessageVulnerable"))
  elseif config.getParameter("radioMessage") ~= nil then queueMessage(config.getParameter("radioMessage")) end
end

-- Plays radio message set as `message` for `time` seconds (5 by default).
function queueMessage(message, time)
  world.sendEntityMessage(entity.id(), "queueRadioMessage", message, time or 5)
end
