---@meta

---@alias int integer
---@alias bool boolean
---@alias tab_fn fun(lib: window_lib, window: window, tab_idx: int): nil

---@class (exact) tab
---@field title string
---@field render tab_fn
---@field update tab_fn

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

---@class (exact) image
---@field size_x number
---@field size_y number
---@field alpha number
---@field centred bool
---@field file string

---@class (exact) gui_element
---@field anchor_x anchor_pos
---@field anchor_y anchor_pos
---@field offset_x number
---@field offset_y number
---@field data image
--TODO: this class needs more data variants
