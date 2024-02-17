---@class gui_option
local GUI_OPTION = {
	None = 0,

	IsDraggable = 1, -- you might not want to use this, because there will be various corner cases and bugs, but feel free to try anyway.
	NonInteractive = 2, -- works with GuiButton
	AlwaysClickable = 3,
	ClickCancelsDoubleClick = 4,
	IgnoreContainer = 5,
	NoPositionTween = 6,
	ForceFocusable = 7,
	HandleDoubleClickAsClick = 8,
	GamepadDefaultWidget = 9, -- it's recommended you use this to communicate the widget where gamepad input will focus when entering a new menu

	-- these work as intended (mostly)
	Layout_InsertOutsideLeft = 10,
	Layout_InsertOutsideRight = 11,
	Layout_InsertOutsideAbove = 12,
	Layout_ForceCalculate = 13,
	Layout_NextSameLine = 14,
	Layout_NoLayouting = 15,

	-- these work as intended (mostly)
	Align_HorizontalCenter = 16,
	Align_Left = 17,

	FocusSnapToRightEdge = 18,

	NoPixelSnapY = 19,

	DrawAlwaysVisible = 20,
	DrawNoHoverAnimation = 21,
	DrawWobble = 22,
	DrawFadeIn = 23,
	DrawScaleIn = 24,
	DrawWaveAnimateOpacity = 25,
	DrawSemiTransparent = 26,
	DrawActiveWidgetCursorOnBothSides = 27,
	DrawActiveWidgetCursorOff = 28,

	TextRichRendering = 29,

	NoSound = 47,
	Hack_ForceClick = 48,
	Hack_AllowDuplicateIds = 49,

	ScrollContainer_Smooth = 50,
	IsExtraDraggable = 51,

	_SnapToCenter = 62,
	Disabled = 63,
}

-- volatile: must be kept in sync with the ImGuiRectAnimationPlaybackType enum in imgui.h
---@class rect_animation_playback
local GUI_RECT_ANIMATION_PLAYBACK = {
	PlayToEndAndHide = 0,
	PlayToEndAndPause = 1,
	Loop = 2,
}


-- volatile: must be kept in sync with lua_api.cpp
-- for GameSetPostFxTextureParameter()

---@class texture_wrapping
local TEXTURE_WRAPPING_MODE = {
	CLAMP = 0,
	CLAMP_TO_EDGE = 1,
	CLAMP_TO_BORDER = 2,
	REPEAT = 3,
	MIRRORED_REPEAT = 4,
}

---@class texture_filtering
local TEXTURE_FILTERING_MODE = {
	UNDEFINED = 0, -- if "pixel art anti-aliasing" option is turned on, will be set to BILINEAR, otherwise NEAREST
	BILINEAR = 1,
	NEAREST = 2, -- nearest neighbour
}

---@class gui_enums
local bundle = {gui_option = GUI_OPTION, rect_animation_playback = GUI_RECT_ANIMATION_PLAYBACK, texture_wrapping = TEXTURE_WRAPPING_MODE, texture_filtering = TEXTURE_FILTERING_MODE}
return bundle