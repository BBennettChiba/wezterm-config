local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

M.globals_dir = wezterm.config_dir .. "/globals.json"

M.getLuaFromJSON = function()
	local file = assert(io.open(M.globals_dir, "r"))
	local json = file:read("a")
	file:close()
	return wezterm.serde.json_decode(json)
end

M.writeLuaToJSON = function(lua)
	local json = wezterm.serde.json_encode_pretty(lua)
	local file = assert(io.open(M.globals_dir, "w"))
	file:write(json)
	file:close()
end

M.switcher = function(window, pane, title, data, action)
	local choices = {}

	for key, _ in pairs(data) do
		table.insert(choices, {
			label = tostring(key),
		})
	end

	table.sort(choices, function(c1, c2)
		return c1.label < c2.label
	end)

	window:perform_action(
		act.InputSelector({
			title = title,
			choices = choices,
			fuzzy = true,
			action = action,
		}),
		pane
	)
end

-- M.font_switcher = function(window, pane)
--     local fonts = M.getLuaFromJSON().fonts
--     local action = wezterm.action_callback(function(_, _, _, label)
--         if label then
--             local lua = M.getLuaFromJSON()
--             lua.font = fonts[label]
--             M.writeLuaToJSON(lua)
--         end
--     end)

--     M.switcher(window, pane, "🎨 Pick a Font!", fonts, action)
-- end

M.theme_switcher = function(window, pane)
	local schemes = wezterm.get_builtin_color_schemes()
	local action = wezterm.action_callback(function(_, _, _, label)
		if label then
			local lua = M.getLuaFromJSON()
			lua.colorscheme = label
			M.writeLuaToJSON(lua)
		end
	end)

	M.switcher(window, pane, "🎨 Pick a Theme!", schemes, action)
end

return M
