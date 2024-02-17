---@meta

---@alias int integer
---@alias bool boolean
---@alias tab_update_fn fun(lib: window_lib, window: window, tab_idx: int)
---@alias tab_render_fn fun(lib: window_lib, window: window, tab_idx: int): gui_element[]
---@alias render_fn fun(gui: gui, elem: gui_element, z: number, x: number, y:number)

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

---@class (exact) image
---@field size_x number
---@field size_y number
---@field file string
---@field render render_fn

---@class (exact) text
---@field text string
---@field description string?
---@field render render_fn

---@class (exact) gui_element
---@field virtual_z_index number
---@field anchor_x anchor_pos
---@field anchor_y anchor_pos
---@field offset_x number
---@field offset_y number
---@field centred bool
---@field colour colour?
---@field data image | text
--TODO: this class needs more data variants

---@class (exact) gui_stackframe
---@field gui_elements gui_element[]
---@field x number
---@field y number
---@field width number
---@field height number
