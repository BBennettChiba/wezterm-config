local wezterm = require("wezterm")
local act = wezterm.action
local features = require("features")
local projects = require("projects")

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local mod = "LEADER"

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

-- -- if I run this function the terminal doesn't launch in Ubuntu
local function update_choices()
	local workspaces = wezterm.mux.get_workspace_names()
	local choices = {}
	for i, workspace in ipairs(workspaces) do
		table.insert(choices, #choices + 1, {
			label = workspace,
			id = tostring(i),
		})
	end
end

local smart_split = wezterm.action_callback(function(window, pane)
	local dim = pane:get_dimensions()
	if dim.pixel_height > dim.pixel_width then
		window:perform_action(act.SplitVertical({ domain = "CurrentPaneDomain" }), pane)
	else
		window:perform_action(act.SplitHorizontal({ domain = "CurrentPaneDomain" }), pane)
	end
end)

local function split_nav(resize_or_move, key)
	return {
		key = key,
		mods = resize_or_move == "resize" and "META" or "CTRL",
		action = wezterm.action_callback(function(win, pane)
			if is_vim(pane) then
				-- pass the keys through to vim/nvim
				win:perform_action({
					SendKey = { key = key, mods = resize_or_move == "resize" and "META" or "CTRL" },
				}, pane)
			else
				if resize_or_move == "resize" then
					win:perform_action({ AdjustPaneSize = { direction_keys[key], 3 } }, pane)
				else
					win:perform_action({ ActivatePaneDirection = direction_keys[key] }, pane)
				end
			end
		end),
	}
end

local keys = {
	apply_to_config = function(config)
		-- config.disable_default_key_bindings = true
		config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }
		config.keys = {
			{ mods = mod, key = "Enter", action = smart_split },
			{ mods = "LEADER|SHIFT", key = "%", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
			{ mods = "LEADER|SHIFT", key = '"', action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
			{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
			{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
			{ mods = "CTRL|SHIFT", key = "V", action = act.PasteFrom("Clipboard") },
			{
				key = "k",
				mods = "CTRL|ALT",
				action = wezterm.action_callback(function(window, pane)
					features.theme_switcher(window, pane)
				end),
			},
			{
				mods = "LEADER",
				key = "Space",
				action = wezterm.action.RotatePanes("Clockwise"),
			},
			{
				mods = "LEADER",
				key = "0",
				action = wezterm.action.PaneSelect({
					mode = "SwapWithActive",
				}),
			},
			{
				key = "[",
				mods = "LEADER",
				action = "ActivateCopyMode",
			},
			{
				key = "c",
				mods = "LEADER",
				action = act.SpawnTab("CurrentPaneDomain"),
			},
			split_nav("move", "h"),
			split_nav("move", "j"),
			split_nav("move", "k"),
			split_nav("move", "l"),
			-- resize panes
			split_nav("resize", "h"),
			split_nav("resize", "j"),
			split_nav("resize", "k"),
			split_nav("resize", "l"),
			{
				key = "R",
				mods = "LEADER|SHIFT",
				action = act.PromptInputLine({
					description = "Enter new name for tab",
					action = wezterm.action_callback(function(window, pane, line)
						if line then
							window:active_tab():set_title(line)
						end
					end),
				}),
			},
			{
				key = "H",
				mods = "CTRL|SHIFT",
				action = act.ActivateTabRelative(-1),
			},
			{
				key = "L",
				mods = "CTRL|SHIFT",
				action = act.ActivateTabRelative(1),
			},
			{
				key = "O",
				mods = "LEADER|SHIFT",
				action = wezterm.action_callback(function(win, _)
					local tab = win:active_tab()
					local activeTabId = tab:tab_id()
					local muxWin = win:mux_window()
					local tabs = muxWin:tabs()
					for _, t in ipairs(tabs) do
						if t:tab_id() ~= activeTabId then
							t:activate()
							for _, p in ipairs(t:panes()) do
								win:perform_action(wezterm.action.CloseCurrentTab({ confirm = false }), p)
							end
						end
					end
				end),
			},
			{
				key = ":",
				mods = "CTRL|SHIFT",
				action = act.ShowDebugOverlay,
			},
			{
				key = "E",
				mods = "LEADER|SHIFT",
				action = act.InputSelector(projects.get_input_selector()),
			},
			-- {
			-- 	key = "W",
			-- 	mods = "LEADER|SHIFT",
			-- 	action = act.InputSelector({
			-- 		title = "Workspace selector",
			-- 		action = wezterm.action_callback(function(_, _, _, label)
			-- 			-- If the project workspace already exists, don't create it again. Just switch
			-- 			for _, ws in pairs(wezterm.mux.get_workspace_names()) do
			-- 				if ws == label then
			-- 					wezterm.mux.set_active_workspace(label)
			-- 					return
			-- 				end
			-- 			end
			-- 			print("something went wrong")
			-- 		end),
			-- 		choices = (function()
			-- 			update_choices()
			-- 			return choices
			-- 		end)(),
			-- 	}),
			-- },
		}

		for i = 1, 9 do
			table.insert(config.keys, {
				key = tostring(i),
				mods = "LEADER",
				action = act.ActivateTab(i - 1),
			})
		end
	end,
}

return keys
