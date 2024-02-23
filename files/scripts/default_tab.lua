---@type tab
local tab = {
	title = "Empty Tab",
	update = function(lib, window, tab_idx)

	end,
	get_elems = function(lib, window, tab_idx)
		return { lib:create_text_gui_elem("", 1, "centre", "centre", true, 0, 0), lib:create_text_gui_elem("Yes Hello.",2, "low", "low", false, 0, 0) }
	end
}

return tab