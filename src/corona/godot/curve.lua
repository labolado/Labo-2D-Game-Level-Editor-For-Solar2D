local Vec = GodotGlobal.Vector
local class = GodotGlobal.class

local Curve = class("Curve")

local floor = math.floor
local fmod = math.fmod

local function pointOnCurve(p1, p2, p3, p4, t)
    local var1 = 1 - t
    local var2 = var1 * var1 * var1
    local var3 = t * t * t
    local x = var2*p1.x + 3*t*var1*var1*p2.x + 3*t*t*var1*p3.x + var3*p4.x
    local y = var2*p1.y + 3*t*var1*var1*p2.y + 3*t*t*var1*p3.y + var3*p4.y

	return x, y
end

local function linearInterpolate(a, b, t)
	return {
		a[1] + t * (b[1] - a[1]),
		a[2] + t * (b[2] - a[2])
	}
end

local function cubicInterpolate(p0, p1, p2, p3, t)
	local t2 = t * t
	local t3 = t2 * t

	local x = 0.5 * ((p1[1] * 2.0) +
						(-p0[1] + p2[1]) * t +
						(2.0 * p0[1] - 5.0 * p1[1] + 4 * p2[1] - p3[1]) * t2 +
						(-p0[1] + 3.0 * p1[1] - 3.0 * p2[1] + p3[1]) * t3)
	local y = 0.5 * ((p1[2] * 2.0) +
						(-p0[2] + p2[2]) * t +
						(2.0 * p0[2] - 5.0 * p1[2] + 4 * p2[2] - p3[2]) * t2 +
						(-p0[2] + 3.0 * p1[2] - 3.0 * p2[2] + p3[2]) * t3)
	return {x, y}
end

-- local function cubicInterpolate2(p1, p2, p3, p4, t)
--     local var1 = 1 - t
--     local var2 = var1 * var1 * var1
--     local var3 = t * t * t
--     local x = var2*p1[1] + 3*t*var1*var1*p2[1] + 3*t*t*var1*p3[1] + var3*p4[1]
--     local y = var2*p1[2] + 3*t*var1*var1*p2[2] + 3*t*t*var1*p3[2] + var3*p4[2]

-- 	return {x, y}
-- end

local function pointEqual(a, b)
	return a[1] == b[1] and a[2] == b[2]
end

function Curve:initialize(info)
	self.bakedMaxOfs = 0
	self.bakeInterval = info.spacing or 32
	self.points = info.curve
	self.bakedPoints = {}
end

function Curve:bake()
	local bakedPoints = self.bakedPoints
	local points = self.points
	local bakeInterval = self.bakeInterval
	local bakedMaxOfs = 0

	local size = #points
	if size == 0 then
		return
	end

	local step = 0.1
	local dist = Vec.dist
	local posX = points[1][1]
	local posY = points[1][2]

	bakedPoints[1] = {posX, posY}
	local n = 2
	if size == 1 then
		return
	end

	for i=1, size - 1 do
		local curve = points[i]
		local curve2 = points[i + 1]
		local p1 = {x = curve[1], y = curve[2]}
		local p2 = {x = p1.x + curve[5], y = p1.y + curve[6]}
		local p4 = {x = curve2[1], y = curve2[2]}
		local p3 = {x = p4.x + curve2[3], y = p4.y + curve2[4]}

		local p = 0
		while p < 1 do
			local np = p + step
			if np > 1 then
				np = 1
			end

			local nppX, nppY = pointOnCurve(p1, p2, p3, p4, np)
			local d = dist(posX, posY, nppX, nppY)
			if d > bakeInterval then
				local low = p
				local hi = np
				local mid = low + (hi - low) * 0.5
				for j=1, 10 do
					nppX, nppY = pointOnCurve(p1, p2, p3, p4, mid)
					d = dist(posX, posY, nppX, nppY)

					if (bakeInterval < d) then
						hi = mid
					else
						low = mid
					end
					mid = low + (hi - low) * 0.5
				end

				posX, posY = nppX, nppY
				p = mid
				bakedPoints[n] = {posX, posY}
				n = n + 1
			else
				p = np
			end
		end
	end

	local lastPosX, lastPosY = points[size][1], points[size][2]
	local rem = dist(posX, posY, lastPosX, lastPosY)
	bakedMaxOfs = (n - 2) * bakeInterval + rem
	bakedPoints[n] = {lastPosX, lastPosY}

	self.bakedMaxOfs = bakedMaxOfs
end

function Curve:interpolateBaked(offset, cubic)
	local bakedPoints = self.bakedPoints
	local bakedMaxOfs = self.bakedMaxOfs
	local bakeInterval = self.bakeInterval

	local size = #bakedPoints
	if size > 0 then
		if size == 1 then
			return bakedPoints[1]
		end

		if offset < 0 then
			return bakedPoints[1]
		end
		if offset >= bakedMaxOfs then
			return bakedPoints[size]
		end

		local idx = floor(offset / bakeInterval) + 1
		local frac = fmod(offset, bakeInterval)

		if idx >= size then
			return bakedPoints[size]
		elseif (idx == size - 1) then
			if frac > 0 then
				frac = frac / fmod(bakedMaxOfs, bakeInterval)
			end
		else
			frac = frac / bakeInterval
		end

		if cubic then
			local pre = idx > 1 and bakedPoints[idx - 1] or bakedPoints[idx]
			local post = (idx < size - 1) and bakedPoints[idx + 2] or bakedPoints[idx + 1]
			return cubicInterpolate(pre, bakedPoints[idx], bakedPoints[idx + 1], post, frac)
		else
			return linearInterpolate(bakedPoints[idx], bakedPoints[idx + 1], frac)
		end
	end
end

function Curve:getBakedLength()
	return self.bakedMaxOfs
end

function Curve:isClosed()
	local points = self.points
	local size = #points
	if size > 0 then
		return pointEqual(points[1], points[2])
	end
	return false
end

return Curve
