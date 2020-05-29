local Polygon = pkgImport(..., "polygon")
local Poly = class("Poly")

local _ratio = 1 -- IPAD_SCALE

local function _genDefaultVetices(w, h, scale)
    -- local wh = whInfo or Image:getImageInfo(filePath)
    scale = scale or 1
    local halfW = w * 0.5
    local halfH = h * 0.5
    return {
        (0 - halfW) * scale,
        (0 - halfH) * scale,
        (w - halfW) * scale,
        (0 - halfH) * scale,
        (w - halfW) * scale,
        (h - halfH) * scale,
        (0 - halfW) * scale,
        (h - halfH) * scale
    }
end

function Poly.static.createByImage(filePath, coarseness, displayObject, scale)
    local vertices, wh = _genImageOutline(filePath, coarseness, scale)
    return Poly:new(vertices, displayObject)
end

function Poly.static.createByBox(filePath, displayObject, scale)
    local wh = Image:getImageInfo(filePath)
    local vertices
    if wh == nil then
        local info = Image:getSheetInfo(filePath)
        vertices = _genDefaultVetices(info.frame.width, info.frame.height, scale)
    else
        vertices = _genDefaultVetices(wh[1], wh[2], scale)
    end
    return Poly:new(vertices, displayObject, wh, filePath)
end

function Poly.static.createByWH(width, height, displayObject, scale)
    local vertices = _genDefaultVetices(width, height, scale)
    return Poly:new(vertices, displayObject, {width, height})
end

function Poly.static.genOutlineByImage(filePath, coarseness, scale)
    return _genImageOutline(filePath, coarseness, scale)
end

function Poly.static.genOutlineBySprite(filePath, coarseness)
    return _genSpriteOutline(filePath, coarseness)
end

function Poly.static.genOutlineByPSD(dataFilePath, scale)
    return _pathDecode(dataFilePath, scale)
end

function Poly:initialize(vertices, displayObject, wh, filePath)
    -- local vertices = _genImageOutline(filePath, coarseness)
    if type(vertices[1]) == "table" and vertices[1].x and vertices[1].y then
        self.polygon = Polygon(vertices)
    else
        self.polygon = Polygon(unpack(vertices))
    end
    self.vertices = vertices
    self.target = displayObject
    self.filePath = filePath
    self.wh = wh
end

function Poly.static.debugDrawVertices(polygon, coordinate, color)
    coordinate = coordinate or display.currentStage
    color = color or {1, 0, 0, 0.2}
    local vertices = polygon.vertices
    for i=1, #vertices do
        -- local x, y = vertices[i], vertices[i + 1]
        local p = vertices[i]
        local wx, wy = coordinate:localToContent(p.x, p.y)
        local dot = display.newCircle(wx, wy, 10)
        dot:setFillColor(unpack(color))
    endetFillColor(unpack(color))
    end
end

function Poly:attachTo(target)
    self.target = target
end

function Poly:getCenter()
    return self.polygon.centroid
end

function Poly:getPolygonVertices()
    return self.polygon.vertices
end

function Poly:getBounds()
    local vertices = self.polygon.vertices
    local xMin, xMax = math.huge, -math.huge
    local yMin, yMax = math.huge, -math.huge
    local min = math.min
    local max = math.max
    for i=1, #vertices do
        local v = vertices[i]
        xMin = min(xMin, v.x)
        xMax = max(xMax, v.x)
        yMin = min(yMin, v.y)
        yMax = max(yMax, v.y)
    end
    return {
        xMin = xMin, xMax = xMax,
        yMin = yMin, yMax = yMax
    }
end

function Poly:contains(x, y)
    local lx, ly = self.target:contentToLocal(x, y)
    return self.polygon:contains(lx, ly)
end

function Poly:containsPolygon(otherPolygon, scale)
    scale = scale or 1
    local vertices = otherPolygon:getPolygonVertices()
    local coordinate = otherPolygon.target
    for i=1, #vertices do
        local x, y = coordinate:localToContent(vertices[i].x * scale, vertices[i].y * scale)
        if not self:contains(x, y) then
            return false
        end
    end
    return true
end

function Poly:containsByPolygons(polygons, scale)
    scale = scale or 1
    local coordinate = self.target
    local vertices = self:getPolygonVertices()
    local num = #vertices
    local count = 0
    for i=1, num do
        local x, y = coordinate:localToContent(vertices[i].x * scale, vertices[i].y * scale)
        for j=1, #polygons do
            local shape = polygons[j]
            if shape:contains(x, y) then
                count = count + 1
                break
            end
        end
    end
    if count / num > 0.9 then
        return true
    else
        return false
    end
end

function Poly:toTriangles(coordinate, physicsProperties)
    local triangles = self.polygon:triangulate()
    local res = {}
    for i=1, #triangles do
        local tri = triangles[i]:totable_reverse()
        for j=1, #tri, 2 do
            local wx, wy = self.target:localToContent(tri[j], tri[j+1])
            local lx, ly = coordinate:contentToLocal(wx, wy)
            tri[j], tri[j+1] = lx, ly
        end
        if physicsProperties then
            local shape = _.clone(physicsProperties)
            shape.shape = tri
            res[i] = shape
        else
            res[i] = tri
        end
    end
    return res
end

function Poly:toTriangles2(coordinate, physicsProperties)
    local triangles = self.polygon:triangulate()
    local res = {}
    local ox, oy = self.target.x - coordinate.x, self.target.y - coordinate.y
    for i=1, #triangles do
        local tri = triangles[i]:totable_reverse()
        for j=1, #tri, 2 do
            -- local wx, wy = self.target:localToContent(tri[j], tri[j+1])
            -- local lx, ly = coordinate:contentToLocal(wx, wy)
            tri[j], tri[j+1] = tri[j] + ox, tri[j+1] + oy
        end
        if physicsProperties then
            local shape = _.clone(physicsProperties)
            shape.shape = tri
            res[i] = shape
        else
            res[i] = tri
        end
    end
    return res
end

function Poly:convertToMesh(uvs)
    local indices, vertices = self.polygon:triangulateToIndices()
    if type(uvs) == "table" then
        for i=1, #vertices, 2 do
            uvs[#uvs + 1] = (vertices[i] - _L) / _RW
            uvs[#uvs + 1] = (vertices[i + 1] - _T) / _RH
        end
    end
    return vertices, indices, uvs
end

function Poly:debugDrawMesh(color)
    color = color or {1, 0, 0, 0.3}
    local indices, vertices = self.polygon:triangulateToIndices()
    print(#vertices)
    local mesh = display.newMesh{
        x = 0, y = 0,
        mode = "indexed",
        vertices = vertices,
        indices = indices
    }
    mesh:setFillColor(unpack(color))
    mesh:translate(self.target:localToContent(mesh.path:getVertexOffset()))
    -- mesh:translate(self.target:localToContent(0, 0))
    mesh:rotate(display.getWorldRotation(self.target))
    mesh:scale(display.getWorldScale(self.target))

    timer.performWithDelay(5000, function()
        mesh:removeSelf()
    end)
end

function Poly:debugDraw(color)
    color = color or {1, 0, 0, 0.2}
    local vertices = self.vertices
    for i=1, #vertices, 2 do
        timer.performWithDelay(50 * i, function()
            local x, y = vertices[i], vertices[i + 1]
            local wx, wy = self.target:localToContent(x, y)
            local dot = display.newCircle(wx, wy, 5)
            dot:setFillColor(unpack(color))
        end)
    end
end

function Poly:debugDraw2(color)
    color = color or {1, 0, 0, 0.2}
    local vertices = self.polygon.vertices
    for i=1, #vertices do
        -- local x, y = vertices[i], vertices[i + 1]
        timer.performWithDelay(50 * i, function()
            local p = vertices[i]
            local wx, wy = self.target:localToContent(p.x, p.y)
            local dot = display.newCircle(wx, wy, 5)
            dot:setFillColor(unpack(color))
        end)
    end
end

return Poly
