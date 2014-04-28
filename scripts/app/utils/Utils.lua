--
-- Author: ejian
-- Date: 2014-04-26 22:31:33
--
local Utils = {}

--[[
矩形碰撞检测
@param a
@param b
]]
function Utils:isRectCollision(a, b)
	return not (self:getMaxX(a) < self:getMinX(b) or self:getMaxX(b) < self:getMinX(a)
				or self:getMaxY(a) < self:getMinY(b) or self:getMaxY(b) < self:getMinY(a))
end

function Utils:getMinX(node)
	local rect = node:getBoundingBox()
	return rect.origin.x
end

function Utils:getMinY(node)
	local rect = node:getBoundingBox()
	return rect.origin.y
end

function Utils:getMaxX(node)
	local rect = node:getBoundingBox()
	return rect.origin.x + rect.size.width
end

function Utils:getMaxY(node)
	local rect = node:getBoundingBox()
	return rect.origin.y + rect.size.height
end

return Utils