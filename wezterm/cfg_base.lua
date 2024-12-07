local wezterm = require "wezterm"
local vars = require "vars"
local merger = require("lib/merger")

local cfg = wezterm.config_builder()
-- local cfg = {}

-- wezterm.on("gui-startup", function(cmd)
--   local tab, pane, window = mux.spawn_window(cmd or
--     {position={x=0,y=460}}
--   )
-- end)

cfg = {
	window_close_confirmation = "NeverPrompt",
	exit_behavior = "Close",
	-- quit_when_all_windows_are_closed = true,
	window_decorations = "RESIZE|MACOS_FORCE_DISABLE_SHADOW",
	use_dead_keys = false,
	-- treat_left_ctrlalt_as_altgr = false,
	-- use_ime = false,
	-- send_composed_key_when_right_alt_is_pressed = false,
	window_padding = {
		left = 32,
		right = 24,
		top = 32,
		bottom = 12,
	},
	-- window_frame = {
	-- 	border_top_height = 20,
	-- },
	initial_rows = 36,
	initial_cols = 138,
	adjust_window_size_when_changing_font_size = false,
	-- window_background_opacity = 0,
	-- ### Cursor:
	force_reverse_video_cursor = true,
	default_cursor_style = "BlinkingBar",
	cursor_thickness = 3,
	cursor_blink_ease_in = "Constant",
	cursor_blink_ease_out = "Constant",
	cursor_blink_rate = 540,
	-- animation_fps = 60,
	-- ### Tab bar:
	show_tab_index_in_tab_bar = false,
	tab_bar_at_bottom = true,
	use_fancy_tab_bar = false,
	tab_max_width = 32,
	hide_tab_bar_if_only_one_tab = false,
	-- tab_and_split_indices_are_zero_based = true,
}

return cfg