--dofile("mods/windows/files/types.lua")
dofile_once("data/scripts/debug/keycodes.lua")

---@class (exact) window_lib
---@field private windows window[]
---@field private gui gui
---@field private gui_id int
---@field private drag drag?
local lib = {}
lib.windows = {}
lib.gui = GuiCreate()
lib.gui_id = 2

function lib:update()
	self:check_drag()
	self:render()
end

---@private
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

---@private
---@return integer id
function lib:new_id()
	self.gui_id = self.gui_id + 1
	return self.gui_id
end

---@private
---@param window window
function lib:render_window(window)
	GuiImage(
		self.gui,
		self:new_id(),
		window.x / 2,
		window.y / 2,
		"mods/windows/files/window_bg.png",
		1,
		window.width / 2,
		window.height / 2
	)
end

---@private
function lib:check_drag()
	local click = InputIsMouseButtonDown(Mouse_left)
	local cx, cy = InputGetMousePosOnScreen()
	print(cx, cy)
	if self.drag then
		--TODO: this will break if a window is deleted while dragging, the window_delete fn will need to account for this
		self.drag.window.x = cx - self.drag.cx + self.drag.wx
		self.drag.window.y = cy - self.drag.cy + self.drag.wy
	end
	if not click then
		self.drag = nil
		return
	end
	if not InputIsMouseButtonJustDown(Mouse_left) then return end
	for _, window in ipairs(self.windows) do
		local x1, y1 = window.x, window.y
		local x2, y2 = x1 + window.width, y1 + window.height
		if x1 < cx and cx < x2 and y1 < cy and cy < y2 then
			self.drag = { window = window, wx = window.x, wy = window.y, cx = cx, cy = cy }
		end
	end
end

return lib
