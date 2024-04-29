pretty = require 'pl.pretty' 
solids = require('solids')

function lovr.load()
    shader = lovr.graphics.newShader('vertex.glsl', 'frag.glsl')
    sphere_model = solids.sphere(4)

    m = {2, 3, 1, 4, 8, 7, 1, 1}
    randomized_surface = generate_random_surface(m)
    randomized_surface = normalize_surface(randomized_surface)

    random_harmonic = sphere_model:map(
        function(x, y, z)
            local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
            local theta = safe_theta(z, r)
            local phi = math.atan2(y, x)
            r = .5 + (.5* return_SH(2, 2, theta, phi))
            x = r * math.sin(theta) * math.cos(phi)
            y = r * math.sin(theta) * math.sin(phi)
            z = r * math.cos(theta)
            return x, y, z
        end
    )
    random_harmonic = normalize_surface(random_harmonic)
    maxl = 2
    harmonics = {}
    for l = 0, maxl do
        harmonics[l] = {}
        for m = -l, l do
            harmonics[l][m] = normalize_surface(sphere_model:map(
                function(x, y, z)
                    local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
                    local theta = safe_theta(z, r)
                    local phi = math.atan2(y, x)
                    r = return_SH(l, m, theta, phi)
                    x = r * math.sin(theta) * math.cos(phi)
                    y = r * math.sin(theta) * math.sin(phi)
                    z = r * math.cos(theta)
                    return x, y, z
                end
            ))
        end
    end

    random_harm_params = analyze_SH(random_harmonic)
    reconstructed_random_harms = reconstruct_from_parameters(random_harm_params)

    random_params = analyze_SH(randomized_surface)
    reconstructed_random = reconstruct_from_parameters(random_params)

end

function lovr.update()
    local pressed = lovr.system.wasKeyPressed('space') or lovr.headset.wasPressed("hand/right", "trigger")
    if pressed then
        m = {   lovr.math.random(0, 10),
                lovr.math.random(0, 10),
                lovr.math.random(0, 10),
                lovr.math.random(0, 10),
                lovr.math.random(0, 10),
                lovr.math.random(0, 10),
                lovr.math.random(0, 10),
                lovr.math.random(0, 10),
        }

        randomized_surface = generate_random_surface(m)
        randomized_surface = normalize_surface(randomized_surface)

        coeffs = {
            math.random(0, maxl),
            math.random() * .4,
            math.random(0, maxl),
            math.random() * .4,
            math.random(0, maxl),
            math.random() * .4,
            math.random(0, maxl),
            math.random() * .4,
            math.random() * .5
        }
        
        random_harmonic = sphere_model:map(
            function(x, y, z)
                local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
                local theta = safe_theta(z, r)
                local phi = math.atan2(y, x)
                r = coeffs[9]
                for i = 0, 3 do
                    print(coeffs[(i * 2) + 1])
                    print(coeffs[(i * 2) + 2])
                    print(return_SH(coeffs[(i * 2) + 1], coeffs[(i * 2) + 1], theta, phi))
                    r = r + (coeffs[(i * 2) + 2] * return_SH(coeffs[(i * 2) + 1], coeffs[(i * 2) + 1], theta, phi))
                end
                x = r * math.sin(theta) * math.cos(phi)
                y = r * math.sin(theta) * math.sin(phi)
                z = r * math.cos(theta)
                return x, y, z
            end
        )
        random_harmonic = normalize_surface(random_harmonic)

        random_params = analyze_SH(randomized_surface)
        reconstructed_random = reconstruct_from_parameters(random_params)

        random_harm_params = analyze_SH(random_harmonic)
        reconstructed_random_harms = reconstruct_from_parameters(random_harm_params)
    end
end
  
function lovr.draw(pass)
    pass:setColor(1, 1, 1)
    
    
    local location = mat4(vec3(-2, 2, 1), vec3(.2),  quat(math.pi/2, 0, 1, 0))
    pass:text("Fundamental Spherical Harmonics", location)
    pass:text("Harmonic surface reconstruction", vec3(1, 2, 1), .15, quat(-math.pi/2, 0, 1, 0))
    pass:text("Randomized surface reconstruction", vec3(1, 2, 3.4), .15, quat(-math.pi / 2, 0, 1, 0))
    
    pass:setColor(.1, .1, .12)
    pass:plane(0, -0.01, 0, 25, 25, -math.pi / 2, 1, 0, 0)
    pass:setColor(.2, .2, .2)
    pass:plane(0, -0.01, 0, 25, 25, -math.pi / 2, 1, 0, 0, 'line', 50, 50)

    draw_axes(pass)

    pass:setWireframe(true)
    pass:setShader('normal')

    start_point = vec3(-2, .3, 1)
    for l = 0, 2, 1 do
        for m = -l, l, 1 do
            harmonics[l][m]:draw(pass, start_point + vec3(0, l/2, m/2))
        end
    end
    

    random_harmonic:draw(pass, vec3(1, 1, .5))
    reconstructed_random_harms:draw(pass, vec3(1, 1, 1.2))
    
    randomized_surface:draw(pass, vec3(1, 1, 3))
    reconstructed_random:draw(pass, vec3(1, 1, 3.7))

    --pass:setShader()
    --pass:text("Spherical Hamoncs examples", start_point - vec3(0, .1, 0), .1)
    
end

---Analyze surface to extract Spherical Harmonic Parameters
---@param surface table Surface must be from solids.lua
---@return table
function analyze_SH(surface)
  
    n_vertices = #surface.vlist
    print("N Vertices on surface: ", n_vertices)
    -- we consider to have 100 segments horizontala dn vertical
    solid_angle = 4 * math.pi / (n_vertices)
    maxl = 2

    parameters={}
    for l = 0, maxl do
        parameters[l] = {}
        for m = -l, l do 
            parameters[l][m] = 0
        end 
    end

    for index, vertex in ipairs(surface.vlist) do
        local x, y, z = vertex[1], vertex[2], vertex[3]
        local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
        local theta = safe_theta(z, r)
        local phi = math.atan2(y, x)
        for l = 0, maxl do
            for m = -l, l do
                parameters[l][m] = parameters[l][m] +
                    (r * return_SH(l, m, theta, -phi) * solid_angle)  -- * math.cos(m * phi) -- not needed for our version
            end
        end
    end
    print('Resulting Harmoncis parameters: ')
    print(pretty.write(parameters, '  ', true))
    return parameters
end

---Given a Yable fo Harmonics parameters, reconstruct the solid
---@param parameters table
---@return table 
function reconstruct_from_parameters(parameters)
    reconstructed_surface = sphere_model:map(
        function(x, y, z)
            local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
            local theta = safe_theta(z, r)
            local phi = math.atan2(y, x)

            r = 0
            for l = 0, maxl do
                for m = -l, l do
                    r = r + (parameters[l][m] * return_SH(l, m, theta, phi))
                end
            end
            x = r * math.sin(theta) * math.cos(phi)
            y = r * math.sin(theta) * math.sin(phi)
            z = r * math.cos(theta)
            return x, y, z
        end
    )
    return reconstructed_surface
end

---Return desired SH at required angles
---@param l number 
---@param m number 
---@param theta number 
---@param phi number
---@return number
function return_SH(l, m, theta, phi)
    if l == 0 then
      --Y(0,0)
      return 0.5 * math.sqrt(1/math.pi)
      
    elseif l == 1 then
        if m == -1 then
            -- Y(1, -1)
            return math.sqrt(3/( 4 * math.pi)) * math.sin(theta) * math.sin(phi)
        elseif m == 0 then
            -- Y(1, 0)
            return math.sqrt(3/( 4 * math.pi)) * math.cos(theta)
        elseif m == 1 then
            -- Y(1, 1)
            return math.sqrt(3/( 4 * math.pi)) * math.sin(theta) * math.cos(phi)
        end
        
    elseif l == 2 then

      if m == -2 then
          -- Y(2, -2)
          return 0.25 * math.sqrt(15/math.pi) * math.pow(math.sin(theta), 2) * math.sin(2 * phi)

        elseif m == -1 then
          -- Y(2, -1)
          return 0.25 * math.sqrt(15/math.pi) * math.sin(2 * theta) * math.sin(phi)
          
        elseif m == 0 then
          -- Y(2, 0)
          return .25 * math.sqrt(5/math.pi) * (3 * math.pow(math.cos(theta), 2) - 1)
          
        elseif m == 1 then
          -- Y(2, 1)
          return 0.25 * math.sqrt(15/math.pi) * math.sin(2 * theta) * math.cos(phi)
          
        elseif m == 2 then
          -- Y(2, 2)
          return 0.25 * math.sqrt(15/math.pi) * math.pow(math.sin(theta), 2) * math.cos(2 * phi)
          
        end 
    end
end

---Simple check if R = 0
---@param z number Z coordinate
---@param r number Radius
---@return integer 
function safe_theta(z, r) 
    if r == 0 then
        return 0
    end
    return math.acos(z/r)
end

---Normalize surface to have diameter <= 1
---@param surface table
---@param coeff number
---@return table
function normalize_surface(surface, coeff)
    local coeff = coeff or 2
    local max_radius = 1

    surface:map(
        function(x, y, z)
            local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
            if r > max_radius then
                max_radius = r
            end
            return x, y, z
        end
    )

    print('radius: ', max_radius)
    surface = surface:map(
        function(x, y, z)
            local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
            local theta = safe_theta(z, r)
            local phi = math.atan2(y, x)

            r = r / (max_radius * coeff)
            x = r * math.sin(theta) * math.cos(phi)
            y = r * math.sin(theta) * math.sin(phi)
            z = r * math.cos(theta)
            return x, y, z
        end
    )
    return surface
    
end

function generate_random_surface(m)

    randomized_surface = sphere_model:map(
        function(x, y, z)
            local r = math.sqrt(math.pow(x, 2) + math.pow(y, 2) + math.pow(z, 2))
            local theta = safe_theta(z, r)
            local phi = math.atan2(y, x)
            r = 0

            r = r + m[8] * math.pow(math.sin(m[8] * theta), m[1])
            r = r + m[2] * math.pow(math.cos(m[2] * theta), m[3])
            r = r + m[4] * math.pow(math.sin(m[4] * phi), m[5])
            r = r + m[6] * math.pow(math.cos(m[6] * phi), m[7])


            x = r * math.sin(theta) * math.cos(phi)
            y = r * math.sin(theta) * math.sin(phi)
            z = r * math.cos(theta)
            return x, y, z
        end
    )

    return randomized_surface
    
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

require('flight').integrate()