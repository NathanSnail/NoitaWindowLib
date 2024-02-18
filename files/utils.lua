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
	for k, v in ipairs({ ... }) do
		if self.near(var, dist, v) then
			return k
		end
	end
end

---@generic T
---@param original T
---@return T copy
function utils:copy(original)
	if type(original) ~= "table" then return original end
	local copy = {}
	local seen = {}
	seen[original] = copy
	for k, v in pairs(original) do
		local cloned = seen[v]
		if cloned then
			copy[k] = cloned
		else
			local clone = self:copy(v)
			copy[k] = clone
			seen[v] = clone
		end
	end
	return copy
end

return utils
