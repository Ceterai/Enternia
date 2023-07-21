function init() initAnimation() end
function update(dt) end
function uninit() end

-- Initializes all **animation things** configured via the optional `animation` effect parameter.
function initAnimation(animation)
  self.ct_anim = animation or config.getParameter("animation", {})
  initParticles()
  initDirectives()
  initLights()
  initStates()
end

-- Initializes all **particle emitters** configured via the optional `animation.particles` effect parameter.
function initParticles()
  for _,particleEmitter in ipairs(self.ct_anim.particles or {}) do initParticle(particleEmitter) end
end

-- Initializes all **color directives** configured via the optional `animation.directives` effect parameter.
function initDirectives()
  if self.ct_anim.directives then effect.setParentDirectives(self.ct_anim.directives or "fade=7733AA=0.25") end
end

-- Initializes all **lights** configured via the optional `animation.lights` effect parameter.
function initLights()
  for _,light in ipairs(self.ct_anim.lights or {}) do initLight(light) end
end

-- Initializes all **states** configured via the optional `animation.states` effect parameter.
function initStates()
  for _,state in ipairs(self.ct_anim.states or {}) do initState(state) end
end

-- Disables all **animation things** configured via the optional `animation` effect parameter.
function uninitAnimation(animation)
  self.ct_anim = animation or config.getParameter("animation", {})
  uninitParticles()
  uninitDirectives()
  uninitLights()
  uninitStates()
end

-- Disables all **particle emitters** configured via the optional `animation.particles` effect parameter.
function uninitParticles()
  for _,particleEmitter in ipairs(self.ct_anim.particles or {}) do uninitParticle(particleEmitter) end
end

-- Disables all **color directives** configured via the optional `animation.directives` effect parameter.
function uninitDirectives()
  if self.ct_anim.directives then effect.setParentDirectives("") end
end

-- Disables all **lights** configured via the optional `animation.lights` effect parameter.
function uninitLights()
  for _,light in ipairs(self.ct_anim.lights or {}) do uninitLight(light) end
end

-- Disables all **states** configured via the optional `animation.states` effect parameter.
function uninitStates()
  for _,state in ipairs(self.ct_anim.states or {}) do uninitState(state) end
end

function initParticle(emitter)
  animator.setParticleEmitterOffsetRegion(emitter, mcontroller.boundBox())
  animator.setParticleEmitterActive(emitter, true)
end

function initLight(light) animator.setLightActive(light, true) end

function initState(state) animator.setAnimationState(state, "on") end

function uninitParticle(emitter) animator.setParticleEmitterActive(emitter, false) end

function uninitLight(light) animator.setLightActive(light, false) end

function uninitState(state) animator.setAnimationState(state, "off") end
