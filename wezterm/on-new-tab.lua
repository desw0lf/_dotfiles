local wezterm = require "wezterm"
local vars = require "vars"
local home_dir = wezterm.home_dir

local function replace_home_dir(path)
	return string.gsub(path, "^" .. home_dir, vars.default_tab_name)
end

-- function truncate_start(str, max_length)
-- 	if #str <= max_length then
-- 			return str
-- 	else
-- 			return "..." .. string.sub(str, -max_length + 3)
-- 	end
-- end

local function truncate_path(path, max_dirs)
	local parts = {}
	for part in string.gmatch(path, "[^/]+") do
			table.insert(parts, part)
	end

	if #parts <= max_dirs then
			return path
	else
			local truncated = table.concat(parts, "/", #parts - max_dirs + 1)
			return ".../" .. truncated
	end
end

local function tab_title(tab)
	local title = tab.tab_title
	
	-- if title == "" then
	-- 	return vars.default_tab_name
	-- end
	
	if #title > 0 then
		return replace_home_dir(title)
	end

	return replace_home_dir(tab.active_pane.title)
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	if #tabs == 1 then
		return {}
	end
	return { { Text = " " .. truncate_path(tab_title(tab), 2) .. " " } }
end)
