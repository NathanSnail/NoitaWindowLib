---@meta

---@alias int integer
---@alias bool boolean
---@alias tab_update_fn fun(lib: window_lib, window: window, tab_idx: int)
---@alias tab_render_fn fun(lib: window_lib, window: window, tab_idx: int): gui_element[]
---@alias render_fn fun(self: self, gui: gui, id: number, z: number, x: number, y:number)
---@alias size_fn fun(self: self, gui: gui): (width: number, height: number)

---@class (exact) tab
---@field title string
---@field get_elems tab_render_fn
---@field update tab_update_fn

---@class (exact) window
---@field x number
---@field y number
---@field width number
---@field height number
---@field tabs tab[]
---@field selected_tab int

---@class (exact) drag
---@field start_window_x number
---@field start_window_y number
---@field start_cursor_x number
---@field start_cursor_y number
---@field window window

---@class (exact) resize
---@field anchor_x number?
---@field anchor_y number?
---@field glue_x number
---@field glue_y number
---@field window window

---@alias anchor_pos "low" | "centre" | "high"

---@class (exact) colour
---@field red number
---@field green number
---@field blue number
---@field alpha number

---@class (exact) renderable
---@field render render_fn
---@field size size_fn

---@class (exact) image: renderable
---@field size_x number
---@field size_y number
---@field file string

---@class (exact) text: renderable
---@field text string
---@field description string?

---@class (exact) gui_element
---@field virtual_z_index number
---@field anchor_x anchor_pos
---@field anchor_y anchor_pos
---@field offset_x number
---@field offset_y number
---@field centred bool
---@field colour colour?
---@field data renderable

---@class (exact) gui_stackframe
---@field gui_elements gui_element[]
---@field x number
---@field y number
---@field width number
---@field height number
