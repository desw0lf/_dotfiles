-- https://github.com/bew/dotfiles/blob/main/gui/wezterm/lib/mystdlib.lua
local function merger(...)
  local result = {}
  for _, t in ipairs({...}) do
      for k, v in pairs(t) do
          if type(v) == "table" and type(result[k]) == "table" then
              -- If both are tables, recursively merge them
              result[k] = merger(result[k], v)
          else
              -- Otherwise, simply override/set the value
              result[k] = v
          end
      end
  end
  return result
end

return merger