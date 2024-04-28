
flight = {
  pose = lovr.math.newMat4(), -- Transformation in VR initialized to origin (0,0,0) looking down -Z
  thumbstickDeadzone = 0.4,   -- Smaller thumbstick displacements are ignored (too much noise)
  directionFrom = 'head',     -- Movement can be relative to orientation of head or left controller
  flying = true,
  -- Smooth flight parameters
  turningSpeed = 2 * math.pi * 1 / 6,
  walkingSpeed = .8,
}

function flight.smooth(dt)
  if lovr.headset.isTracked('right') then
    local x, y = lovr.headset.getAxis('right', 'thumbstick')
    -- Smooth horizontal turning
    if math.abs(x) > flight.thumbstickDeadzone then
      flight.pose:rotate(-x * flight.turningSpeed * dt, 0, 1, 0)
    end
  end
  if lovr.headset.isTracked('left') then
    local x, y = lovr.headset.getAxis('left', 'thumbstick')
    local direction = quat(lovr.headset.getOrientation(flight.directionFrom)):direction()
    if not flight.flying then
      direction.y = 0
    end
    -- Smooth strafe movement
    if math.abs(x) > flight.thumbstickDeadzone then
      local strafeVector = quat(-math.pi / 2, 0,1,0):mul(vec3(direction))
      flight.pose:translate(strafeVector * x * flight.walkingSpeed * dt)
    end
    -- Smooth Forward/backward movement
    if math.abs(y) > flight.thumbstickDeadzone then
      flight.pose:translate(direction * y * flight.walkingSpeed * dt)
    end
  end
end

function flight.update(dt)
    flight.directionFrom = 'head'
    flight.smooth(dt)
end

function flight.draw(pass)
  pass:transform(mat4(flight.pose):invert())
end

function flight.integrate()
  local stub_fn = function() end
  local existing_cb = {
    draw = lovr.draw or stub_fn,
    update = lovr.update or stub_fn,
  }
  local function wrap(callback)
    return function(...)
      m[callback](...)
      existing_cb[callback](...)
    end
  end
  --lovr.update = wrap('update')
  lovr.update = function(dt)
    flight.update(dt)
    existing_cb.update(dt)
  end
  lovr.draw = function(pass)
    flight.draw(pass)
    existing_cb.draw(pass)
  end
end

return flight