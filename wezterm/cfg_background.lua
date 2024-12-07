local wezterm = require "wezterm"
local vars = require "vars"
local merger = require("lib/merger")

local cfg = {}

cfg.background = {}

if vars.bg.image and vars.bg.image_opacity ~= 0 then
  table.insert(
    cfg.background,
    merger(
      {
        source = {
            File = wezterm.config_dir .. "/assets/" .. vars.bg.image,
        },
        opacity = vars.bg.image_opacity
      },
      vars.bg.image_config or {}
    )
  )
end

-- Conditionally add the color configuration
if vars.bg.opacity ~= 0 then
  table.insert(
    cfg.background,
    {
      source = {
        Color = vars.bg.colour,
      },
      width = "100%",
      height = "100%",
      opacity = vars.bg.opacity
    }
  )
end

return cfg