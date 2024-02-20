--dofile("mods/windows/files/types.lua")
---@type button_bundle
local buttons = dofile_once("mods/windows/files/input_codes.lua")
---@type gui_enums
local gui_enums = dofile_once("mods/windows/files/gui_enums.lua")
---@type utils
local utils = dofile_once("mods/windows/files/utils.lua")
---@type tab
local default_tab = dofile_once("mods/windows/files/default_tab.lua")

---@class defs
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
---@field default_tab tab
---@field grab_size int
local lib = {}
lib.windows = {}
lib.gui = GuiCreate()
lib.grab_size = 15
lib.gui_z = -1000
lib.default_tab = default_tab

function lib:update()
	self:check_clicks()
	self:render()
end

---@private
function lib:render()
	self.gui_id = 2
	self.gui_stack = {}
	self.gui_z = -1000
	GuiStartFrame(self.gui)
	for window_idx = #self.windows, 1, -1 do
		local window = self.windows[window_idx]
		self:render_window(window, window_idx)
	end
	self:render_stack()
end

---@nodiscard
---@param tabs tab[]? {}
---@param x number? 0
---@param y number? 0
---@param width number? 100
---@param height number? 100
---@return window new_window
function lib:make_window(tabs, x, y, width, height)
	---@type window
	local window = {
		tabs = tabs or { utils:copy(default_tab) },
		x = x or 0,
		y = y or 0,
		width = width or 100,
		height = height or 100,
		selected_tab = 1,
	}
	table.insert(self.windows, window)
	return window
end

---@private
---@nodiscard
---@return int id
function lib:new_id()
	self.gui_id = self.gui_id + 1
	return self.gui_id
end

---@nodiscard
---@return tab[]
function lib:default_tab_list()
	return { utils:copy(self.default_tab) }
end

---@private
---@param window window
function lib:render_window(window, window_idx)
	for k, tab in ipairs(window.tabs) do
		if k == window.selected_tab then --TODO: some sort of tab management system where windows can have tabs selected, ideally > 1 in a tiling system, or perhaps thats a special type of window
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
---@nodiscard
---@return int
function lib:new_z()
	self.gui_z = self.gui_z - 1
	return self.gui_z
end

---@private
---@param stackframe gui_stackframe
---@param inner fun()
---@param outer fun()
function lib:gui_cutout(stackframe, inner, outer)
	-- credits to aarvlo for this method
	outer()
	local cutout_id = self:new_id()
	GuiAnimateBegin(self.gui)
	GuiAnimateAlphaFadeIn(self.gui, cutout_id, 0, 0, true)
	GuiBeginAutoBox(self.gui)
	GuiBeginScrollContainer(self.gui, cutout_id, stackframe.x / 2, stackframe.y / 2, stackframe.width / 2,
		stackframe.height / 2, false, 0, 0)
	GuiEndAutoBoxNinePiece(self.gui)
	GuiAnimateEnd(self.gui)
	--your content here
	inner()
	GuiOptionsClear(self.gui)
	GuiEndScrollContainer(self.gui)
	--TODO: make windows manage their own bg as an inner() element
end

---@private
---@param func fun(id: int)
function lib:enclose_elem(func)
	GuiZSetForNextWidget(self.gui, self:new_z())
	func(self:new_id())
end

---@private
function lib:render_stack()
	for _, stackframe in ipairs(self.gui_stack) do
		GuiOptionsClear(self.gui)
		table.sort(stackframe.gui_elements, function(a, b) return a.virtual_z_index > b.virtual_z_index end)
		self:gui_cutout(stackframe, function()
			GuiOptionsAdd(self.gui, defs.gui_option.NoPositionTween)
			GuiOptionsAdd(self.gui, defs.gui_option.NonInteractive)
			for _, elem in ipairs(stackframe.gui_elements) do
				self:render_elem(elem, stackframe)
			end
			GuiOptionsClear(self.gui)
		end, function()
			self:enclose_elem(function(id)
				GuiImageNinePiece(self.gui, id, stackframe.x / 2 + 2, stackframe.y / 2 + 2,
					stackframe.width / 2 - 4,
					stackframe.height / 2 - 4)
			end)
			self:enclose_elem(function(id)
				-- TODO: make the sounds go away
				GuiOptionsAdd(self.gui, defs.gui_option.ForceFocusable)
				GuiOptionsAdd(self.gui, defs.gui_option.NoPositionTween)
				GuiImageNinePiece(self.gui, id, stackframe.x / 2, stackframe.y / 2, stackframe.width / 2,
					stackframe.height / 2, 0, "mods/windows/files/invisible_9.png")
			end)

			GuiOptionsClear(self.gui)
		end)
		--GuiImageNinePiece(self.gui, self:newGuiAnimateBegin(gui)
		--(stackframe.x, stackframe.y, stackframe.width, stackframe.height, 0)
		-- GuiBeginScrollContainer(self.gui, -1, stackframe.x, stackframe.y, stackframe.width, stackframe.height,
		-- 	false, 0, 0)
	end
end

---@type render_fn
local function render_text(gui, elem, z, x, y)
	local text_elem = elem.data
	---@cast text_elem text
	GuiZSetForNextWidget(gui, z)
	if elem.centred then
		local width, height = GuiGetTextDimensions(gui, text_elem.text)
		x, y = x - width, y - height
	end
	GuiText(gui, x / 2, y / 2, text_elem.text)
	if text_elem.description then
		GuiTooltip(gui, text_elem.description, "")
	end
end

---@nodiscard
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
	local data = { text = text, description = description, render = render_text }
	---@type gui_element
	local elem = {
		virtual_z_index = z,
		anchor_x = anchor_x,
		anchor_y = anchor_y,
		centred = centred,
		offset_x = offset_x,
		offset_y = offset_y,
		data = data,
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
	elem.data.render(self.gui, elem, self:new_z(), x - stackframe.x, y - stackframe.y) -- the element doesn't know about the library and so can't be enclosed
end

---@private
function lib:check_clicks()
	local click = InputIsMouseButtonDown(defs.mouse.left)
	local cursor_x, cursor_y = InputGetMousePosOnScreen()
	self:handle_held(cursor_x, cursor_y)
	if not click then
		self.drag = nil
		self.resize = nil
		return
	end
	if not InputIsMouseButtonJustDown(defs.mouse.left) then return end
	for window_idx, window in ipairs(self.windows) do
		if self:window_collision_check(window, cursor_x, cursor_y) then
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
			if target_width < self.grab_size * 3 then
				target_width = self.grab_size * 3
				target_x = (self.resize.window.width + self.resize.window.x) - self.grab_size * 3
			end
			self.resize.window.width = target_width
			self.resize.window.x = target_x
		elseif x == 2 then
			self.resize.window.width = math.max(cursor_x_glued - self.resize.window.x, self.grab_size * 3)
		end
		if y == 1 then
			local target_height = (self.resize.window.height + self.resize.window.y) - cursor_y_glued
			local target_y = cursor_y_glued
			if target_height < self.grab_size * 3 then
				target_height = self.grab_size * 3
				target_y = (self.resize.window.height + self.resize.window.y) - self.grab_size * 3
			end
			self.resize.window.height = target_height
			self.resize.window.y = target_y
		elseif y == 2 then
			self.resize.window.height = math.max(cursor_y_glued - self.resize.window.y, self.grab_size * 3)
		end
	end
end

---@private
---@nodiscard
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
