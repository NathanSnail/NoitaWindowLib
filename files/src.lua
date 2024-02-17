--dofile("mods/windows/files/types.lua")

---@class (exact) window_lib
---@field windows window[]
---@field gui gui
---@field update fun()
---@field render fun()
local lib = {}
lib.windows = {}
lib.gui = GuiCreate()
lib.update = function()
	lib.render()
end
lib.render = function()
	for _, window in ipairs(lib.windows) do
		window.render(lib, window)
	end
end

return lib