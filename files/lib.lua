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
---@field private gui_stack gui_stackframe[]
---@field private gui_z number
---@field grab_size int
local lib = {}
lib.windows = {}
lib.gui = GuiCreate()
lib.gui_id = 2
lib.grab_size = 15
lib.gui_z = -1000

function lib:update()
	self:check_clicks()
	self:render()
end

---@private
function lib:render()
	self.gui_id = 2
	self.gui_stack = {}
	GuiStartFrame(self.gui)
	GuiOptionsAdd(self.gui, defs.gui_option.NoPositionTween)
	for window_idx, window in ipairs(self.windows) do
		self:render_window(window, window_idx)
	end
end

---@param tabs tab[]? {}
---@param x number? 0
---@param y number? 0
---@param width number? 100
---@param height number? 100
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
---@return int id
function lib:new_id()
	self.gui_id = self.gui_id + 1
	return self.gui_id
end

---@private
---@param window window
function lib:render_window(window, window_idx)
	table.insert(self.gui_stack, {})
	GuiText(self.gui, window.x / 2, window.y / 2, tostring(window_idx))
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
	for k, tab in ipairs(window.tabs) do
		if k == 1 then --TODO: some sort of tab management system where windows can have tabs selected, ideally > 1 in a tiling system, or perhaps thats a special type of window
			---@type gui_stackframe
			local stackframe = {
				gui_elements = tab.get_elems(lib, window, k),
				window = window,
				x = window.x,
				y = window.y,
				width = window.width,
				height = window.height
			}
			table.insert(self.gui_stack, stackframe)
		end
	end
end

---@private
function lib:render_stack()
	for _, stackframe in ipairs(self.gui_stack) do
		table.sort(stackframe, function(a, b) return a.virtual_z_index > b.virtual_z_index end)
		for _, elem in ipairs(stackframe) do
			lib:render_elem(elem, stackframe)
		end
	end
end

---@param gui gui
---@param elem gui_element
---@param z number
---@param x number
---@param y number
local function render_text(gui, elem, z, x, y)
	local text_elem = elem.data
	---@cast text_elem text
	GuiZSetForNextWidget(gui, z)
	if text_elem.description then
		GuiTooltip(gui, "Hello", text_elem.description)
	end
	print(x,y,text_elem.text)
	GuiText(gui, x, y, text_elem.text)
end

---@param text string
---@param z number
---@param anchor_x anchor_pos
---@param anchor_y anchor_pos
---@param centred bool
---@param offset_x number
---@param offset_y number
---@param colour colour?
---@param description string?
---@return gui_element
function lib:create_text_gui_elem(text, z, anchor_x, anchor_y, centred, offset_x, offset_y, colour, description)
	---@type text
	local text = { text = text, description = description, render = render_text }
	---@type gui_element
	local elem = {
		virtual_z_index = z,
		anchor_x = anchor_x,
		anchor_y = anchor_y,
		centred = centred,
		offset_x = offset_x,
		offset_y = offset_y,
		data = text,
		colour = colour
	}
	return elem
end

---@private
---@param elem gui_element
---@param stackframe gui_stackframe
function lib:render_elem(elem, stackframe)
	local colour = elem.colour
	if colour then
		GuiColorSetForNextWidget(self.gui, colour.red, colour.green, colour.blue, colour.alpha)
	end
	local x_mult = elem.anchor_x == "high" and -1 or 1
	local y_mult = elem.anchor_y == "high" and -1 or 1
	local x_coeff = ({ low = 0, centre = 0.5, high = 1 })[elem.anchor_x]
	local y_coeff = ({ low = 0, centre = 0.5, high = 1 })[elem.anchor_y]
	local x1, y1 = stackframe.x, stackframe.y
	local x2, y2 = x1 + stackframe.width, y1 + stackframe.height
	local x = x2 * x_coeff + x1 * (1 - x_coeff) + x_mult * elem.offset_x
	local y = y2 * y_coeff + y1 * (1 - y_coeff) + y_mult * elem.offset_x
	print("rendering")
	elem.data.render(self.gui, elem, self.gui_z, x, y)
	self.gui_z = self.gui_z - 1
end

---@private
function lib:check_clicks()
	local click = InputIsMouseButtonDown(defs.mouse.left)
	local cursor_x, cursor_y = InputGetMousePosOnScreen()
	lib:handle_held(cursor_x, cursor_y)
	if not click then
		self.drag = nil
		self.resize = nil
		return
	end
	if not InputIsMouseButtonJustDown(defs.mouse.left) then return end
	for window_idx, window in ipairs(self.windows) do
		if lib:window_collision_check(window, cursor_x, cursor_y) then
			table.remove(self.windows, window_idx)
			table.insert(self.windows, 1, window)
			return
		end
	end
end

---@private
---@param cursor_x number
---@param cursor_y number
function lib:handle_held(cursor_x, cursor_y)
	if self.drag then
		--TODO: this will break if a window is deleted while dragging, the window_delete fn will need to account for this
		self.drag.window.x = cursor_x - self.drag.start_cursor_x + self.drag.start_window_x
		self.drag.window.y = cursor_y - self.drag.start_cursor_y + self.drag.start_window_y
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
end

---@private
---@param window window
---@param cursor_x number
---@param cursor_y number
---@return boolean
function lib:window_collision_check(window, cursor_x, cursor_y)
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
			return true
		end
		self.drag = {
			window = window,
			start_window_x = window.x,
			start_window_y = window.y,
			start_cursor_x = cursor_x,
			start_cursor_y = cursor_y
		}
		return true
	end
	return false
end

return lib
