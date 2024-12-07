local wezterm = require "wezterm"

local debug = true

return {
  localhost_browser = "Google Chrome",
  prompt_character = "$",
  window_initial = { x = 632, y = 244 },
  default_tab_name = "~",
  bg = {
    opacity = 0.8,
    -- colour = "#181818",
    -- colour = "#1a1b26",
    colour = "#151515",
    image = nil,
    -- image = "wallhaven-01rmkg.jpg",
    image_opacity = 0.7,
    image_config = {
      hsb = {
				hue = 1.0,
				saturation = 1.02,
				brightness = 0.5,
			},
    }
  },
  cfg_misc = {
    automatically_reload_config = debug,
    -- debug_key_events = debug,
    -- color_scheme = "tokyonight_night",
    -- color_scheme = "catppuccin-mocha",
    color_scheme = "Chalk (dark) (terminal.sexy)",
    font = wezterm.font_with_fallback {
      "MesloLGS NF",
      "Fira Code",
    },
    font_size = 14,
    macos_window_background_blur = 42,
  }
}