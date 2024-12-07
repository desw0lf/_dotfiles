local wezterm = require "wezterm"
-- local vars = require "vars"

local cfg = {}

local tab_colors = {
	inactive = {
		bg_color = "transparent",
		fg_color = "#808080",
	},
	hover = {
		bg_color = "rgba(0, 0, 0, 0.1)",
		fg_color = "#ababab",
		italic = false,
	},
}

cfg.colors = {
  selection_bg = "#b193ea",
  selection_fg = "black",
  -- copy_mode_active_highlight_bg = { Color = 'yellow'},
  -- copy_mode_active_highlight_fg = { AnsiColor = 'Black' },
  -- copy_mode_inactive_highlight_bg = { Color = '#52ad70' },
  -- copy_mode_inactive_highlight_fg = { AnsiColor = 'White' },

  -- quick_select_label_bg = { Color = 'peru' },
  -- quick_select_label_fg = { Color = '#ffffff' },
  -- quick_select_match_bg = { AnsiColor = 'Navy' },
  -- quick_select_match_fg = { Color = '#ffffff' },
  -- compose_cursor = 'orange',
  tab_bar = {
    background = "transparent",
    active_tab = {
      bg_color = "rgba(0, 0, 0, 0.2)",
      fg_color = "#c0c0c0",
    },
    inactive_tab = tab_colors.inactive,
    inactive_tab_hover = tab_colors.hover,
    new_tab = tab_colors.inactive,
    new_tab_hover = tab_colors.hover,
  },
}


return cfg