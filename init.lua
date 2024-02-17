---@type window_lib
local lib = dofile_once("mods/windows/files/src.lua")
lib:make_window()

function OnWorldPreUpdate()
	lib:update()
end