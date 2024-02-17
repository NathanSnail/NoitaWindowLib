--dofile("mods/windows/files/types.lua")

---@class (exact) window_lib
---@field private windows window[]
---@field gui gui
---@field gui_id int
local lib = {}
lib.windows = {}
lib.gui = GuiCreate()
lib.gui_id = 2

function lib:update()
	self:render()
end

function lib:render()
	self.gui_id = 2
	for _, window in ipairs(self.windows) do
		self:render_window(window)
	end
end

---@param tabs tab[]?
---@param x integer?
---@param y integer?
---@param width integer?
---@param height integer?
---@return window new_window
function lib:make_window(tabs, x, y, width, height)
	---@type window
	local window = {
		tabs = tabs or {},
		x = x or 0,
		y = y or 0,
		width = width or 100,
		height = height or 100,
	}
	table.insert(self.windows, window)
	return window
end

---@return integer id
function lib:new_id()
	self.gui_id = self.gui_id + 1
	return self.gui_id
end

function lib:render_window(window)
	GuiImage(
		self.gui,
		self:new_id(),
		window.x,
		window.y,
		"mods/windows/files/window_bg.png",
		1,
		window.width,
		window.height
	)
end

return lib
