---@meta

---@alias int integer
---@alias render_fn fun(lib: window_lib, window: window, tab_idx: int): nil

---@class (exact) tab
---@field title string
---@field render render_fn
---@field update fun(lib: window_lib, window: window, tab_idx: int)

---@class (exact) window
---@field x int
---@field y int
---@field width int
---@field height int
---@field tabs tab[]
