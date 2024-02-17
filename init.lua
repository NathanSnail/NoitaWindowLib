---@type window_lib
local lib = dofile_once("mods/windows/files/src.lua")

function OnWorldPreUpdate()
	lib.update()
end