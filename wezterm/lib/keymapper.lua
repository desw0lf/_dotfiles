local wezterm = require "wezterm"

local function determine_os(target_triple)
  if string.find(target_triple:lower(), "windows") then
    return "windows"
  end
  return "other"
end

local os = determine_os(wezterm.target_triple) -- "x86_64-pc-windows-msvc"

local maps = {
  windows = {
    CMD = "CTRL",
    OPT = "ALT",
  }
}

local function keymapper(keys)
  local map = maps[os]
  local result = {}

  for _, key in ipairs(keys) do
      if map and map[key] then
          table.insert(result, map[key])
      else
          table.insert(result, key)
      end
  end

  return table.concat(result, "|")
end

return keymapper