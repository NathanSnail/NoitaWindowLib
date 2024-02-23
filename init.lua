---@type window_lib
local lib = dofile_once("mods/windows/files/lib.lua")
for i = 1, 1 do
	local tablist = lib:default_tab_list()
	if i == 1 then
		---@type tab
		local tab = {
			title = "whatever",
			update = function(lib, window, tab_idx)

			end,
			get_elems = function(lib, window, tab_idx)
				return { lib:create_text_gui_elem("hamis", 1, "centre", "centre", true, 0, 0, nil,
					"wowie\nDoes\nThe\nTitle\nEven\nMatter?") }
			end
		}
		table.insert(tablist, tab)
	end
	lib:make_window(tablist, i * 100)
end

function OnWorldPreUpdate()
	for i = 1, 1 do
		-- update takes ~ 11us / window for a default window
		lib:update()
	end
end
