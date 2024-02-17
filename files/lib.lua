--dofile("mods/windows/files/types.lua")
---@type button_bundle
local buttons = dofile_once("mods/windows/files/input_codes.lua")
---@type gui_enums
local gui_enums = dofile_once("mods/windows/files/gui_enums.lua")
---@type utils
local utils = dofile_once("mods/windows/files/utils.lua")

---@class (exact) defs
---@field mouse mouse_buttons
---@field keyboard keyboard_buttons
---@field controller controller_buttons
---@field gui_option gui_option
---@field rec_animation_playback rect_animation_playback
---@field texture_filtering texture_filtering
---@field texture_wrapping texture_wrapping

local defs = {}
defs.mouse = buttons.mouse
defs.keyboard = buttons.keyboard
defs.controller = buttons.controller
defs.gui_option = gui_enums.gui_option
defs.rect_animation_playback = gui_enums.rect_animation_playback
defs.texture_filtering = gui_enums.texture_filtering
defs.texture_wrapping = gui_enums.texture_wrapping

---@class (exact) window_lib
---@field private windows window[]
---@field private gui gui
---@field private gui_id int
---@field private drag drag? exists if a window is currently being dragged
---@field private resize resize?
---@field private grab_size int
local lib = {}
lib.windows = {}
lib.gui = GuiCreate()
lib.gui_id = 2
lib.grab_size = 5

function lib:update()
	self:check_drag()
	self:render()
end

---@private
function lib:render()
	self.gui_id = 2
	GuiStartFrame(self.gui)
	GuiOptionsAdd(lib.gui, defs.gui_option.NoPositionTween)
	for _, window in ipairs(self.windows) do
		self:render_window(window)
	end
end

---@param tabs tab[]? {}
---@param x integer? 0
---@param y integer? 0
---@param width integer? 100
---@param height integer? 100
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
	local click = InputIsMouseButtonDown(defs.mouse.left)
	local cursor_x, cursor_y = InputGetMousePosOnScreen()
	if self.drag then
		--TODO: this will break if a window is deleted while dragging, the window_delete fn will need to account for this
		self.drag.window.x = cursor_x - self.drag.cx + self.drag.wx
		self.drag.window.y = cursor_y - self.drag.cy + self.drag.wy
	end
	if self.resize then
		local x = self.resize.anchor_x
		local y = self.resize.anchor_y
		local cursor_x_glued = cursor_x + self.resize.glue_x
		local cursor_y_glued = cursor_y + self.resize.glue_y
		if x == 1 then
			local target_width = (self.resize.window.width + self.resize.window.x) - cursor_x_glued
			local target_x = cursor_x_glued
			if target_width < self.grab_size * 2 then
				target_width = self.grab_size * 2
				target_x = (self.resize.window.width + self.resize.window.x) - self.grab_size * 2
			end
			self.resize.window.width = target_width
			self.resize.window.x = target_x
		elseif x == 2 then
			self.resize.window.width = math.max(cursor_x_glued - self.resize.window.x, self.grab_size * 2)
		end
		if y == 1 then
			local target_height = (self.resize.window.height + self.resize.window.y) - cursor_y_glued
			local target_y = cursor_y_glued
			if target_height < self.grab_size * 2 then
				target_height = self.grab_size * 2
				target_y = (self.resize.window.height + self.resize.window.y) - self.grab_size * 2
			end
			self.resize.window.height = target_height
			self.resize.window.y = target_y
		elseif y == 2 then
			self.resize.window.height = math.max(cursor_y_glued - self.resize.window.y, self.grab_size * 2)
		end
	end
	if not click then
		self.drag = nil
		self.resize = nil
		return
	end
	if not InputIsMouseButtonJustDown(defs.mouse.left) then return end
	for _, window in ipairs(self.windows) do
		local x1, y1 = window.x, window.y
		local x2, y2 = x1 + window.width, y1 + window.height
		if x1 < cursor_x and cursor_x < x2 and y1 < cursor_y and cursor_y < y2 then
			local res_x = utils:near_many(cursor_x, self.grab_size, x1, x2)
			local res_y = utils:near_many(cursor_y, self.grab_size, y1, y2)
			if res_x or res_y then
				local edge_x = cursor_x
				if res_x then
					edge_x = ({ x1, x2 })[res_x]
				end
				local edge_y = cursor_y
				if res_y then
					edge_y = ({ y1, y2 })[res_y]
				end
				self.resize = {
					window = window,
					anchor_x = res_x,
					anchor_y = res_y,
					glue_x = edge_x - cursor_x,
					glue_y = edge_y - cursor_y
				}
				return
			end
			self.drag = { window = window, wx = window.x, wy = window.y, cx = cursor_x, cy = cursor_y }
			return
		end
	end
end

return lib
