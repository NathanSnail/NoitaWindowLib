---@class utils
local utils = {}

---@param var number
---@param dist number
---@param val number
---@return boolean
function utils.near(var, dist, val)
	return math.abs(var - val) < dist
end

---@param var number
---@param dist number
---@param ... number
---@return int?
function utils:near_many(var, dist, ...)
	for k, v in ipairs({...}) do
		if self.near(var, dist, v) then
			return k
		end
	end
end

return utils
