require "/stats/effects/ct_velocity_jump/ct_longfall.lua"
ct_longfall_init = init
require "/stats/effects/ct_velocity_jump/ct_velocity_boost.lua"
ct_velocity_boost_init = init
ct_velocity_boost_update = update


function init()
  ct_longfall_init()
  ct_velocity_boost_init()
end

function update(dt)
  ct_velocity_boost_update(dt)
end

function uninit()
end
