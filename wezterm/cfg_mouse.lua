local wezterm = require "wezterm"
local km = require "lib/keymapper"
local act = wezterm.action

local cfg = {}

cfg.mouse_bindings = {
	{
    event = { Up = { streak = 1, button = "Left" } },
    mods = km({ "NONE "}),
    action = act.CompleteSelection "ClipboardAndPrimarySelection",
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = km({ "CMD "}),
    action = act.OpenLinkAtMouseCursor,
  },
}

return cfg;