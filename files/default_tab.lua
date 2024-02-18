---@type tab
local tab = {
	title = "Empty Tab",
	update = function(lib, window, tab_idx)

	end,
	get_elems = function(lib, window, tab_idx)
		return { lib:create_text_gui_elem("No tab.", 1, "centre", "centre", true, 0, 0) }
	end
}

return tab