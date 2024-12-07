local wezterm = require "wezterm"
local vars = require "vars"

local function find_first_match(uri, patterns)
  for _, pattern in ipairs(patterns) do
      local start_pos, end_pos = uri:find(pattern)
      if start_pos then
          return start_pos, end_pos, pattern
      end
  end
  return nil
end

local patterns = {
  "localhost:[0-9]+",    -- localhost with port
  "192%.168%.",       -- matches 192.168.x.x
  "127%.0%.0%.",      -- matches 127.0.0.x
  "0%.0%.0%.",        -- matches 0.0.0.0
}

wezterm.on("open-uri", function(window, pane, uri)
  if (#vars.localhost_browser < 1) then
    return true
  end
  -- local start, match_end = uri:find "localhost:"
  local start = find_first_match(uri, patterns)
  if start == 8 or start == 9 then
    wezterm.open_with(uri, vars.localhost_browser)
    -- prevent the default action from opening in a browser
    return false
  end
end)