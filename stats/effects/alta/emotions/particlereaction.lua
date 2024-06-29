function init()
  for _,particleEmitter in ipairs(config.getParameter("particleEmitters")) do
    animator.setParticleEmitterActive(particleEmitter, true)
  end
  script.setUpdateDelta(0)
end

function update(dt)
end

function uninit()
end
