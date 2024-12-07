local wezterm = require "wezterm"
local vars = require "vars"
local km = require "lib/keymapper"
local splitter = require "lib/splitter"
local mux = wezterm.mux
local home_dir = wezterm.home_dir
local act = wezterm.action

local cfg = {}

local function delete_selection(window, pane, full_selection)
	local delim = vars.prompt_character .. " "

	local split_selection = splitter(full_selection, delim)
	local split_lines = splitter(pane:get_lines_as_text(), delim)

	local selection = split_selection[#split_selection]:gsub("%s+$", "")
	local last_line = split_lines[#split_lines]:gsub("\n", "")
	
  if string.sub(last_line, -1) == vars.prompt_character then
    return  -- no current text
  end

	if not last_line:find(selection, 1, false) then
		return -- selection not found
	end

	local count = 0
	for _ in string.gmatch(last_line, selection) do
			count = count + 1
	end
	wezterm.log_info("count: " .. count)
	-- if count == 0 then
	-- 	return -- selection not found
	-- end

	if count > 1 then
		-- multiple matches limitation of logic :(
		window:perform_action(act.QuickSelectArgs {
			label = "Many matches",
			patterns = { "(" .. selection .. ").{" .. (#selection) .. "}" }
		}, pane)
		return
	end

	local final = last_line:gsub(selection, "", 1)

  window:perform_action(act.SendKey { key = "u", mods = "CTRL" }, pane)

  if final ~= "" then
  	window:perform_action(wezterm.action{SendString=final}, pane)
	end
end

function onNewTab(window, pane)
	window:perform_action(act.SpawnCommandInNewTab{ cwd = home_dir }, pane)
end

local select_all_commands_prefix_regex = "^\\" .. vars.prompt_character .."\\s+" -- matches start of line + starting ($ )

local select_all_commands_action = act.QuickSelectArgs {
	label = "Select commands",
	patterns = { select_all_commands_prefix_regex .. "(.+)" }
} 


cfg.keys = {
	-- { key = "P", mods = km({ "CMD", "SHIFT" }), action = act.ActivateCommandPalette }
	{ key = "LeftArrow", mods = km({ "OPT" }), action = act{SendString="\x1bb"} },
	{ key = "RightArrow", mods = km({ "OPT" }), action = act{SendString="\x1bf"} },
	{ key = "LeftArrow", mods = km({ "CMD", "OPT" }), action = act.MoveTabRelative(-1) },
	{ key = "RightArrow", mods = km({ "CMD", "OPT" }), action = act.MoveTabRelative(1) },
	{ key = "d", mods = km({ "CMD" }), action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
	{ key = "d", mods = km({ "CMD", "SHIFT" }), action = act.SplitVertical { domain = "CurrentPaneDomain" } },
	{ key = "LeftArrow", mods = km({ "CMD" }), action = act{ActivatePaneDirection="Prev"} },
	{ key = "RightArrow", mods = km({ "CMD" }), action = act{ActivatePaneDirection="Next"} },
	-- { key = "w", mods = km({ "CMD" }), action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "Backspace", mods = km({ "NONE" }), action = wezterm.action_callback(function(window, pane)
			local selection = window:get_selection_text_for_pane(pane)
			window:perform_action(act.ClearSelection, pane)
			if selection == "" then 
				window:perform_action(act.SendKey { key = "Backspace", mods = km({ "NONE" }) }, pane)
				return
			end
			delete_selection(window, pane, selection)
		end)
	},
	{ key = "w", mods = km({ "CMD" }), action = wezterm.action_callback(function(window, pane)
			local current_window = wezterm.mux.get_window(window:window_id())
			local tabs = current_window:tabs()
			if #tabs == 1 then
				-- window:perform_action(act.ClearScrollback "ScrollbackAndViewport", pane)
				window:perform_action(act.Multiple { 
					act.SendKey { key = "u", mods = "CTRL" },
					act.SendKey { key = "l", mods = "CTRL" }
				}, pane)
			else
				window:perform_action(act.CloseCurrentPane({ confirm = true }), pane)
			end
		end)
	},
	{ key = "w", mods = km({ "CMD", "SHIFT" }), action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "Enter", mods = km({ "CMD" }), action = act.Nop },
	{ key = "l", mods = km({ "OPT" }), action = act.Nop },
	{ key = "m", mods = km({ "CMD" }), action = act.DisableDefaultAssignment },
	{ key = "t", mods = km({ "CMD" }), action = wezterm.action_callback(function(window, pane)
		onNewTab(window, pane)
		end)
	},
	{ key = "0", mods = km({ "CMD" }), action = wezterm.action_callback(function(window, pane) 
			window:perform_action(act.ResetFontAndWindowSize, pane)
			window:set_position(vars.window_initial.x, vars.window_initial.y)
		end)
	},
	{
		key = "c",
		mods = km({ "CMD" }),
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo "ClipboardAndPrimarySelection", pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act.SendKey { key = "c", mods = "CTRL" }, pane) -- TODO: might not work on Windows
			end
		end),
	},
	{ key = "a", mods = km({ "CMD", "SHIFT" }), action = select_all_commands_action },
  {
		key = "a",
		mods = km({ "CMD" }),
		action = wezterm.action_callback(function(window, pane)
			-- TODO 1. Fix issue when CURRENT selection is empty, so it selects the one above
			-- TODO 2. Fix issue when selection has (?) null value and quick_selection window is not closing (happens e.g. on new tab)
			local actAccept = act.SendKey { key = "a", mods = km({ "NONE" }) }
			-- local act3 = act.SendKey { key = "Escape" } -- in case nothing found
			window:perform_action(select_all_commands_action, pane)
			window:perform_action(actAccept, pane)
			-- window:perform_action(act3, pane)
			local no_text = window:get_selection_text_for_pane(pane) ~= ""
			if not no_text then 
				window:perform_action(act.ClearSelection, pane)
			end
		end)
	},
	-- { key = "x", mods = km({ "CMD" }), action = wezterm.action_callback(function(window, pane)
	-- 		local cursor = pane:get_cursor_position()
	-- 	end)
	-- },
	-- ### MacOS specific hacks
	{
		key = "3",
		mods = "OPT",
		action = act.SendString("#")
	}
}

wezterm.on("new-tab-button-click", function(window, pane, button, default_action)
  if button == "Left" then
    onNewTab(window, pane)
    return false
  end
end)

return cfg;