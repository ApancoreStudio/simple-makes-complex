---@class Polyhedron
---@field vertices vector[]
---@field faces integer[][]
---@field boundingBox {min: vector, max: vector}
local Polyhedron = {}

local mathMin, mathMax, mathHuge, mathSqrt, mathAbs
    = math.min, math.max, math.huge, math.sqrt, math.abs

---Creates a new Polyhedron instance
---@param vertices vector[] Array of 3D vertices that define the polyhedron
---@param faces integer[][] Array of faces, where each face is an array of vertex indices
---@return Polyhedron
function Polyhedron:new(vertices, faces)
    local instance = setmetatable({
        vertices = vertices,
        faces = faces,
        boundingBox = self:calculateBoundingBox(vertices)
    }, {__index = self})
    return instance
end

---Calculates the axis-aligned bounding box for the polyhedron
---@param vertices vector[] Array of vertices to compute bounds for
---@return {min: vector, max: vector} Bounding box with min and max corners
function Polyhedron:calculateBoundingBox(vertices)
    local min = vector.new(mathHuge, mathHuge, mathHuge)
    local max = vector.new(-mathHuge, -mathHuge, -mathHuge)
    
    for _, vertex in ipairs(vertices) do
        min.x = mathMin(min.x, vertex.x)
        min.y = mathMin(min.y, vertex.y)
        min.z = mathMin(min.z, vertex.z)
        max.x = mathMax(max.x, vertex.x)
        max.y = mathMax(max.y, vertex.y)
        max.z = mathMax(max.z, vertex.z)
    end
    
    return {min = min, max = max}
end

---Computes the normal vector for a face using Newell's method
---@param face integer[] Array of vertex indices forming the face
---@return vector Normalized normal vector for the face
function Polyhedron:computeFaceNormal(face)
    if #face < 3 then
        error("Face must have at least 3 vertices")
    end
    
    -- Use Newell's method for more robust normal calculation with non-convex polygons
    local normal = vector.new(0, 0, 0)
    
    for i = 1, #face do
        local j = (i % #face) + 1
        local current = self.vertices[face[i]]
        local next = self.vertices[face[j]]
        
        normal.x = normal.x + (current.y - next.y) * (current.z + next.z)
        normal.y = normal.y + (current.z - next.z) * (current.x + next.x)
        normal.z = normal.z + (current.x - next.x) * (current.y + next.y)
    end
    
    return normal:normalize()
end

---Computes the plane equation for a face
---@param face integer[] Array of vertex indices forming the face
---@return {normal: vector, point: vector, d: number} Plane equation in form: normal·x + d = 0
function Polyhedron:computePlane(face)
    local normal = self:computeFaceNormal(face)
    local point = self.vertices[face[1]]
    local d = -normal:dot(point)
    return {normal = normal, point = point, d = d}
end

---Finds the intersection point between a ray and a plane
---@param rayOrigin vector Starting point of the ray
---@param rayDir vector Direction vector of the ray (should be normalized)
---@param plane {normal: vector, point: vector, d: number} Plane equation
---@return vector|nil Intersection point, or nil if no intersection
function Polyhedron:rayPlaneIntersection(rayOrigin, rayDir, plane)
    local denom = plane.normal:dot(rayDir)
    
    -- Ray is parallel to plane
    if mathAbs(denom) < 1e-6 then
        return nil
    end
    
    local t = (-plane.normal:dot(rayOrigin) - plane.d) / denom
    
    -- Intersection is behind ray origin
    if t < 0 then
        return nil
    end
    
    return rayOrigin + rayDir * t
end

---Checks if a 3D point lies within a face (convex or non-convex)
---@param point vector The point to test
---@param face integer[] Array of vertex indices forming the face
---@return boolean True if point is inside the face, false otherwise
function Polyhedron:pointInFace(point, face)
    if #face < 3 then
        return false
    end
    
    -- Project the face and point to 2D using the face's plane
    local plane = self:computePlane(face)
    
    -- Create a 2D coordinate system on the plane
    local uAxis, vAxis = self:createPlaneBasis(plane.normal)
    
    -- Project all vertices to 2D
    local vertices2D = {}
    for _, vertexIndex in ipairs(face) do
        local vertex = self.vertices[vertexIndex]
        local vecToVertex = vertex - plane.point
        local u = vecToVertex:dot(uAxis)
        local v = vecToVertex:dot(vAxis)
        table.insert(vertices2D, {u, v})
    end
    
    -- Project the point to 2D
    local vecToPoint = point - plane.point
    local pointU = vecToPoint:dot(uAxis)
    local pointV = vecToPoint:dot(vAxis)
    local point2D = {pointU, pointV}
    
    -- Use winding number algorithm for point-in-polygon test (works with non-convex polygons)
    return self:pointInPolygon2D(point2D, vertices2D)
end

---Creates an orthonormal basis for a plane defined by its normal
---@param normal vector Normal vector of the plane
---@return vector uAxis First basis vector
---@return vector vAxis Second basis vector
function Polyhedron:createPlaneBasis(normal)
    -- Choose an arbitrary vector not parallel to normal
    local temp
    if mathAbs(normal.x) > mathAbs(normal.y) then
        temp = vector.new(0, 1, 0)
    else
        temp = vector.new(1, 0, 0)
    end
    
    local uAxis = normal:cross(temp):normalize()
    local vAxis = normal:cross(uAxis):normalize()
    
    return uAxis, vAxis
end

---Winding number algorithm for 2D point-in-polygon test
---@param point number[] 2D point as {u, v} coordinates
---@param polygon number[][] Array of 2D polygon vertices as {{u,v}, ...}
---@return boolean True if point is inside polygon, false otherwise
function Polyhedron:pointInPolygon2D(point, polygon)
    local wn = 0 -- Winding number counter
    
    for i = 1, #polygon do
        local j = (i % #polygon) + 1
        local vi = polygon[i]
        local vj = polygon[j]
        
        if vi[2] <= point[2] then
            if vj[2] > point[2] then
                -- Upward crossing
                if self:isLeft(vi, vj, point) > 0 then
                    wn = wn + 1
                end
            end
        else
            if vj[2] <= point[2] then
                -- Downward crossing
                if self:isLeft(vi, vj, point) < 0 then
                    wn = wn - 1
                end
            end
        end
    end
    
    return wn ~= 0 -- Non-zero means inside
end

---Helper function for winding number algorithm - determines if point is left of edge
---@param a number[] First vertex of edge {u, v}
---@param b number[] Second vertex of edge {u, v}
---@param p number[] Point to test {u, v}
---@return number Positive if left, negative if right, zero if collinear
function Polyhedron:isLeft(a, b, p)
    return (b[1] - a[1]) * (p[2] - a[2]) - (p[1] - a[1]) * (b[2] - a[2])
end

---Checks if a ray intersects with a face
---@param rayOrigin vector Starting point of the ray
---@param rayDir vector Direction vector of the ray
---@param face integer[] Array of vertex indices forming the face
---@return boolean True if ray intersects the face, false otherwise
function Polyhedron:rayIntersectsFace(rayOrigin, rayDir, face)
    local plane = self:computePlane(face)
    local intersection = self:rayPlaneIntersection(rayOrigin, rayDir, plane)
    
    if not intersection then
        return false
    end
    
    return self:pointInFace(intersection, face)
end

---Calculates the minimum distance from a point to a face
---@param point vector The point to measure distance from
---@param face integer[] Array of vertex indices forming the face
---@return number Minimum distance to the face (0 if point is on the face)
function Polyhedron:distanceToFace(point, face)
    local plane = self:computePlane(face)
    
    -- First check if projection is inside the face
    local projection = point - plane.normal * (plane.normal:dot(point) + plane.d)
    
    if self:pointInFace(projection, face) then
        -- Point projects inside face, return distance to plane
        return mathAbs(plane.normal:dot(point) + plane.d)
    end
    
    -- Point projects outside face, find minimum distance to edges or vertices
    local minDistance = mathHuge
    
    -- Check distance to each edge
    for i = 1, #face do
        local j = (i % #face) + 1
        local v1 = self.vertices[face[i]]
        local v2 = self.vertices[face[j]]
        
        local edgeDistance = self:pointToLineSegmentDistance(point, v1, v2)
        minDistance = mathMin(minDistance, edgeDistance)
    end
    
    -- Also check distance to vertices (in case the closest point is a vertex)
    for _, vertexIndex in ipairs(face) do
        local vertex = self.vertices[vertexIndex]
        local vertexDistance = (point - vertex):length()
        minDistance = mathMin(minDistance, vertexDistance)
    end
    
    return minDistance
end

---Calculates the distance from a point to a line segment
---@param point vector The point to measure distance from
---@param lineStart vector Start point of the line segment
---@param lineEnd vector End point of the line segment
---@return number Minimum distance from point to the line segment
function Polyhedron:pointToLineSegmentDistance(point, lineStart, lineEnd)
    local lineVec = lineEnd - lineStart
    local lineLengthSq = lineVec:dot(lineVec)
    
    if lineLengthSq == 0 then
        return (point - lineStart):length()
    end
    
    local t = (point - lineStart):dot(lineVec) / lineLengthSq
    t = mathMax(0, mathMin(1, t))
    
    local projection = lineStart + lineVec * t
    return (point - projection):length()
end

---Checks if this polyhedron's bounding box intersects with another's
---@param otherPolyhedron Polyhedron The other polyhedron to test against
---@return boolean True if bounding boxes intersect, false otherwise
function Polyhedron:boundingBoxIntersects(otherPolyhedron)
    local box1 = self.boundingBox
    local box2 = otherPolyhedron.boundingBox
    
    return box1.min.x <= box2.max.x and box1.max.x >= box2.min.x and
           box1.min.y <= box2.max.y and box1.max.y >= box2.min.y and
           box1.min.z <= box2.max.z and box1.max.z >= box2.min.z
end

---Checks if any edge of this polyhedron intersects with any face of another polyhedron
---@param otherPolyhedron Polyhedron The other polyhedron to test against
---@return boolean True if any edge intersects any face, false otherwise
function Polyhedron:edgesIntersect(otherPolyhedron)
    -- Check each edge of this polyhedron against each face of the other
    for _, face in ipairs(self.faces) do
        for i = 1, #face do
            local j = (i % #face) + 1
            local edgeStart = self.vertices[face[i]]
            local edgeEnd = self.vertices[face[j]]
            
            if self:edgeIntersectsPolyhedron(edgeStart, edgeEnd, otherPolyhedron) then
                return true
            end
        end
    end
    
    -- Check each edge of the other polyhedron against each face of this
    for _, face in ipairs(otherPolyhedron.faces) do
        for i = 1, #face do
            local j = (i % #face) + 1
            local edgeStart = otherPolyhedron.vertices[face[i]]
            local edgeEnd = otherPolyhedron.vertices[face[j]]
            
            if self:edgeIntersectsPolyhedron(edgeStart, edgeEnd, otherPolyhedron) then
                return true
            end
        end
    end
    
    return false
end

---Checks if an edge intersects with any face of a polyhedron
---@param edgeStart vector Start point of the edge
---@param edgeEnd vector End point of the edge
---@param polyhedron Polyhedron The polyhedron to test against
---@return boolean True if edge intersects the polyhedron, false otherwise
function Polyhedron:edgeIntersectsPolyhedron(edgeStart, edgeEnd, polyhedron)
    local edgeDir = (edgeEnd - edgeStart):normalize()
    local edgeLength = (edgeEnd - edgeStart):length()
    
    for _, face in ipairs(polyhedron.faces) do
        local plane = polyhedron:computePlane(face)
        local intersection = self:rayPlaneIntersection(edgeStart, edgeDir, plane)
        
        if intersection then
            local t = (intersection - edgeStart):length()
            
            -- Check if intersection is within edge bounds and inside face
            if t >= 0 and t <= edgeLength and polyhedron:pointInFace(intersection, face) then
                return true
            end
        end
    end
    
    return false
end

---Determines if a point is inside the polyhedron using ray-casting
---@param point vector The point to test
---@return boolean True if point is inside the polyhedron, false otherwise
function Polyhedron:containsPoint(point)
    -- Ray-casting algorithm for point-in-polyhedron test
    local rayDir = vector.new(1, 0, 0) -- Simple X-direction ray
    local intersections = 0
    
    for _, face in ipairs(self.faces) do
        if self:rayIntersectsFace(point, rayDir, face) then
            intersections = intersections + 1
        end
    end
    
    return intersections % 2 == 1 -- Odd number of intersections = inside
end

---Calculates the minimum distance from a point to the surface of the polyhedron
---@param point vector The point to measure distance from
---@return number Minimum distance to the polyhedron surface
function Polyhedron:distanceToSurface(point)
    local minDistance = mathHuge
    
    for _, face in ipairs(self.faces) do
        local distance = self:distanceToFace(point, face)
        minDistance = mathMin(minDistance, distance)
    end
    
    return minDistance
end

---Checks if this polyhedron intersects with another polyhedron
---@param otherPolyhedron Polyhedron The other polyhedron to test against
---@return boolean True if polyhedrons intersect, false otherwise
function Polyhedron:intersects(otherPolyhedron)
    -- Check if bounding boxes intersect first (optimization)
    if not self:boundingBoxIntersects(otherPolyhedron) then
        return false
    end
    
    -- Check if any vertex of one is inside the other
    for _, vertex in ipairs(self.vertices) do
        if otherPolyhedron:containsPoint(vertex) then return true end
    end
    
    for _, vertex in ipairs(otherPolyhedron.vertices) do
        if self:containsPoint(vertex) then return true end
    end
    
    -- Check for edge-face intersections
    return self:edgesIntersect(otherPolyhedron)
end

return Polyhedron