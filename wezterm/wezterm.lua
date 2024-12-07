local wezterm = require "wezterm"
require "on-new-tab"
require "on-uri-open"

-- local user = os.getenv("USER") or os.getenv("LOGNAME") or os.getenv("USERNAME")

-- function get_zone_around_cursor(pane)
--   local cursor = pane:get_cursor_position()
--   -- using x-1 here because the cursor may be one cell outside the zone
--   local zone = pane:get_semantic_zone_at(cursor.x - 1, cursor.y)
--   if zone then
--     return pane:get_text_from_semantic_zone(zone)
-- 	else
-- 		return nil
-- 	end
-- end

local merger = require("lib/merger")
local cfg_base = require("cfg_base")
local cfg_keys = require("cfg_keys")
local cfg_mouse_bindings = require("cfg_mouse")
local cfg_colors = require("cfg_colors")
local cfg_background = require("cfg_background")
local cfg_misc = require "vars".cfg_misc

return merger(cfg_base, cfg_keys, cfg_mouse_bindings, cfg_colors, cfg_background, cfg_misc)