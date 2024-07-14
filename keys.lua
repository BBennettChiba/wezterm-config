local wezterm = require("wezterm")
local features = require("features")
local act = wezterm.action

local M = {}

M.mod = "LEADER"

-- if you are *NOT* lazy-loading smart-splits.nvim (recommended)
local function is_vim(pane)
	-- this is set by the plugin, and unset on ExitPre in Neovim
	return pane:get_user_vars().IS_NVIM == "true"
end

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

M.smart_split = wezterm.action_callback(function(window, pane)
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

function M.setup(config)
	-- config.disable_default_key_bindings = true
	config.keys = {
		{ mods = M.mod, key = "t", action = act.SpawnTab("CurrentPaneDomain") },
		{ mods = M.mod, key = "Enter", action = M.smart_split },
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
					-- line will be `nil` if they hit escape without entering anything
					-- An empty string if they just hit enter
					-- Or the actual line of text they wrote
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	}

	for i = 1, 9 do
		table.insert(config.keys, {
			key = tostring(i),
			mods = "LEADER",
			action = act.ActivateTab(i - 1),
		})
	end
end

return M

--@TODO save session
--only set title to current dir
--give icons if it's active show whole title but if inactive show only icon
--if leader key is touched change something somewhere
--update tab name when switching pane
--add cpu and ram usage to status bar
--fix resizing in nvim
