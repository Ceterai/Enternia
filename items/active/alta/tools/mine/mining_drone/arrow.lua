require "/scripts/vec2.lua"

function init()
end

function update()
  localAnimator.clearDrawables()

  local fireOffset = animationConfig.animationParameter("fireOffset")
  if fireOffset then
    local startLine = vec2.add(activeItemAnimation.ownerPosition(), activeItemAnimation.handPosition(fireOffset))
    local endLine = activeItemAnimation.ownerAimPosition()
    local dir = vec2.norm(world.distance(endLine, startLine))
    local angle = vec2.angle(dir)

    local segments = 14
    local segmentSize = 1.0
    for i = 0, segments do
      local image = "/items/active/unsorted/miningdrone/arrow.png"
      if i == 0 then
        image = "/items/active/unsorted/miningdrone/arrowstart.png"
      end
      if i == segments then
        image = "/items/active/unsorted/miningdrone/arrowend.png"
      end
      
      localAnimator.addDrawable({
        image = image,
        position = vec2.add(startLine, vec2.mul(dir, i * segmentSize)),
        rotation = angle,
        fullbright = true
      }, "ForegroundTile+10")
    end
  end
end