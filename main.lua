pretty = require 'pl.pretty' 
solids = require('solids')
function lovr.load()
    shader = lovr.graphics.newShader('vertex.glsl', 'frag.glsl')
    model = lovr.graphics.newModel('model.obj')
    sphere_model = solids.fromModel(model)
    m = {2, 3, 1, 4, 8, 7, 1, 1}
    max_radius = 0
    randomized_surface = sphere_model:map(
        function(x, y, z)
            local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
            local theta = math.acos(z / r)
            local phi = math.atan2(y, x)
            r = 0

            r = r + math.pow(math.sin(m[8] * theta), m[1])
            r = r + math.pow(math.cos(m[2] * theta), m[3])
            r = r + math.pow(math.sin(m[4] * phi), m[5])
            r = r + math.pow(math.cos(m[6] * phi), m[7])
            if r > max_radius then
                max_radius = r
            end
            x = r * math.sin(theta) * math.cos(phi)
            y = r * math.sin(theta) * math.sin(phi)
            z = r * math.cos(theta)
            return x, y, z
        end
    )
    print('radius: ', max_radius)
    randomized_surface = randomized_surface:map(
        function(x, y, z)
            local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
            local theta = math.acos(z / r)
            local phi = math.atan2(y, x)

            r = r / max_radius
            x = r * math.sin(theta) * math.cos(phi)
            y = r * math.sin(theta) * math.sin(phi)
            z = r * math.cos(theta)
            return x, y, z
        end
    )

    harmonic22 = sphere_model:map(
        function(x, y, z)
            local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
            local theta = math.acos(z / r)
            local phi = math.atan2(y, x)
            r = return_SH(2, 2, theta, phi)
            x = r * math.sin(theta) * math.cos(phi)
            y = r * math.sin(theta) * math.sin(phi)
            z = r * math.cos(theta)
            return x, y, z
        end
    )
    n_vertices = #harmonic22.vlist
    print(n_vertices)
    -- we consider to have 100 segments horizontala dn vertical
    solid_angle = 4 * math.pi / (100 * 100)
    maxl = 2
    parameters={}
    for l = 0, maxl do
        parameters[l] = {}
        for m = -l, l do 
            parameters[l][m] = 0
        end 
    end
    print(pretty.write(parameters, '  ', true))

    for index, vertex in ipairs(harmonic22.vlist) do 
        local x, y, z = vertex[1], vertex[2], vertex[3]
        local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
        local theta = math.acos(z / r)
        local phi = math.atan2(y, x)
        if theta ~= theta then
            theta = 0
        end
        for l = 0, maxl do
            for m = -l, l do 
                if (r * math.sin(theta) * math.cos(phi) * solid_angle * return_SH(l, m, theta, phi)) ~= (r * math.sin(theta) * math.cos(phi) * solid_angle * return_SH(l, m, theta, phi)) then
                    print("ERRRO")
                    print('inrex: ', index)
                    print('l: ', l, ' m: ', m)
                    print(parameters[l][m])
                    print(r * math.sin(theta) * math.cos(phi) * solid_angle * return_SH(l, m, theta, phi))
                    print(math.sin(theta),  math.cos(phi),  return_SH(l, m, theta, phi))
                    print(theta, phi, r)
                    print(x, y, z)
                    io.read(1)
                end
        
                parameters[l][m] = parameters[l][m] + (r * math.sin(theta) * math.cos(phi) * solid_angle * return_SH(l, m, theta, phi))
            end
        end
    end
    print(pretty.write(parameters, '  ', true))
    -- idk the results might be ok but i expected it to be a lot more precise and it's all over the place.....
end
  
function lovr.draw(pass)
    draw_axes(pass)
    pass:setShader(shader)
    local start_point = vec3(1, 1, 1)
    for l = 0, 2, 1 do
        for m = -l, l, 1 do
            pass:send('l', l)
            pass:send('m', m)            
            local sphere_position = start_point + vec3(0, l, m)
            pass:sphere(sphere_position)
        end
    end
    --pass:cube(1, 1, 1)
    pass:send('time', lovr.timer.getTime())
    --pass:cylinder(1, 0, 3)
    pass:setShader('normal')

    randomized_surface:draw(pass, vec3(-1, 1, -1))
    harmonic22:draw(pass, vec3(2, 2, 2))
    pass:setShader()
    --pass:text("Spherical Hamoncs examples", start_point - vec3(0, .1, 0), .1)
    
end

function return_SH(l, m, theta, phi)
    if l == 0 then
      --Y(0,0)
      return 0.5 * math.sqrt(1/math.pi)
      
    elseif l == 1 then
        if m == -1 then
            -- Y(1, -1)
            return 0.5 * math.sqrt(1.5/math.pi) * math.sin(theta) * math.cos( -phi)
        elseif m == 0 then
            -- Y(1, 0)
            return 0.5 * math.sqrt(3/math.pi) * math.cos(theta)
        elseif m == 1 then
            -- Y(1, 1)
            return -0.5 * math.sqrt(1.5 / math.pi) * math.sin(theta) * math.cos(phi)
        end
        
    elseif l == 2 then

      if m == -2 then
          -- Y(2, -2)
          return 0.25 * math.sqrt(7.5/math.pi) * math.pow(math.sin(theta), 2) * math.cos(-2* phi)

        elseif m == -1 then
          -- Y(2, -1)
          return .5 * math.sqrt(7.5/math.pi) * math.sin(theta) * math.cos(theta) * math.cos(phi)
          
        elseif m == 0 then
          -- Y(2, 0)
          return .25 * math.sqrt(5/math.pi) * (3 * math.pow(math.cos(theta), 2) - 1)
          
        elseif m == 1 then
          --f Y(2, 1)
          return -.5 * math.sqrt(7.5/math.pi) * math.sin(theta) * math.cos(theta) * math.cos(phi)
          
        elseif m == 2 then
          --Y(2, 2)
          return 0.25 * math.sqrt(7.5 / math.pi) * math.cos(2 * phi) * math.pow(math.sin(theta), 2)
          
        end 
    end
end

---Draw system axes
---@param pass lovr.Pass draw pass
function draw_axes(pass)
    pass:setColor(1, 0, 0)
    pass:line(0, 0, 0, 1, 0, 0)
    pass:setColor(0, 1, 0)
    pass:line(0, 0, 0, 0, 1, 0)
    pass:setColor(0, 0, 1)
    pass:line(0, 0, 0, 0, 0, 1)
    pass:setColor(1, 1, 1)
end
