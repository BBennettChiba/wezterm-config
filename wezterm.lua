local wezterm = require("wezterm")
local features = require("features")
local config = wezterm.config_builder()
local G = features.getLuaFromJSON()
local ram = require("ram")
local cpu = require("cpu")

local scheme = wezterm.color.get_builtin_schemes()[G.colorscheme]

require("keys").setup(config)

local function hex2rgb(hex)
	hex = hex:gsub("#", "")
	return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 10
config.color_scheme = "CustomTheme"
config.color_schemes = {
	["CustomTheme"] = scheme,
}

config.window_background_opacity = 0.8
config.window_padding = {
	bottom = 0,
	top = 0,
	left = 0,
	right = 0,
}
config.default_domain = "WSL:Ubuntu"
config.initial_cols = 188
config.initial_rows = 45
config.window_decorations = "RESIZE"
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.tab_max_width = 60

-- window_background_image = "C:/Users/ブライソンベネット/Pictures/term background/snow.gif",
-- File = "C:/Users/ブライソンベネット/Pictures/term background/forest.gif"
config.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 1000 }

local r, g, b = hex2rgb(scheme.background)
local rgbPlusA = "rgba(" .. r .. "," .. g .. "," .. b .. ",0.8)"

config.colors = {
	compose_cursor = "orange",
	tab_bar = {
		background = rgbPlusA,
	},
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- The filled in variant of the > symbol
	--
	local RIGHT_ARROW = utf8.char(0xe0b1)
	local SOLID_RIGHT_ARROW = wezterm.nerdfonts.pl_left_hard_divider
	local title = tab.active_pane.title
	if tab.tab_title and #tab.tab_title > 0 then
		title = tab.tab_title
	end

	local is_first = tab.tab_index == 0
	local is_last = tab.tab_index == #tabs - 1

	local active = "#1EA896"
	local inactive = "#AFCBFF"
	local previous_tab = tabs[tab.tab_index]
	local is_last_active = previous_tab and previous_tab.is_active
	local both_are_inactive = not (is_last_active or tab.is_active)

	local tabTable = {}
	if not is_first then
		table.insert(tabTable, { Background = { Color = tab.is_active and active or inactive } })
		if both_are_inactive then
			table.insert(tabTable, { Foreground = { Color = both_are_inactive and "#FFFFFF" or active } })
			table.insert(tabTable, { Text = both_are_inactive and RIGHT_ARROW or SOLID_RIGHT_ARROW })
		end
		if previous_tab.is_active then
			table.insert(tabTable, { Foreground = { Color = active } })
			table.insert(tabTable, { Text = SOLID_RIGHT_ARROW })
		end
		if tab.is_active then
			table.insert(tabTable, { Foreground = { Color = inactive } })
			table.insert(tabTable, { Text = SOLID_RIGHT_ARROW })
		end
	end
	table.insert(tabTable, { Background = { Color = tab.is_active and active or inactive } })
	table.insert(tabTable, { Foreground = { Color = "#FFFFFF" } })
	table.insert(
		tabTable,
		{ Text = " " .. (tab.is_active and title .. " " or "") .. tostring((tab.tab_index + 1)) .. " " }
	)
	if is_last then
		table.insert(tabTable, { Background = { Color = rgbPlusA } })
		table.insert(tabTable, { Foreground = { Color = tab.is_active and active or inactive } })
		table.insert(tabTable, { Text = SOLID_RIGHT_ARROW })
	end
	return tabTable
end)

config.window_frame = {
	font_size = 11.0,
	active_titlebar_bg = "#333333",
}
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.3,
}

--@TODO cpu and ram usage
wezterm.on("update-right-status", function(window, pane)
	-- Each element holds the text for a cell in a "powerline" style << fade
	local cells = {}

	table.insert(cells, "ram: " .. ram.get_ram_usage())
	table.insert(cells, "cpu: " .. cpu.get_cpu_usage())

	-- Figure out the cwd and host of the current pane.
	-- This will pick up the hostname for the remote host if your
	-- shell is using OSC 7 on the remote host.
	local cwd_uri = pane:get_current_working_dir()
	if cwd_uri then
		local cwd = ""
		local hostname = ""

		if type(cwd_uri) == "userdata" then
			-- Running on a newer version of wezterm and we have
			-- a URL object here, making this simple!

			cwd = cwd_uri.file_path
			hostname = cwd_uri.host or wezterm.hostname()
		else
			-- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
			-- which doesn't have the Url object
			cwd_uri = cwd_uri:sub(8)
			local slash = cwd_uri:find("/")
			if slash then
				hostname = cwd_uri:sub(1, slash - 1)
				-- and extract the cwd from the uri, decoding %-encoding
				cwd = cwd_uri:sub(slash):gsub("%%(%x%x)", function(hex)
					return string.char(tonumber(hex, 16))
				end)
			end
		end

		-- Remove the domain name portion of the hostname
		local dot = hostname:find("[.]")
		if dot then
			hostname = hostname:sub(1, dot - 1)
		end
		if hostname == "" then
			hostname = wezterm.hostname()
		end

		table.insert(cells, cwd)
		table.insert(cells, hostname)
	end

	-- I like my date/time in this style: "Wed Mar 3 08:14"
	local date = wezterm.strftime("%a %b %-d %H:%M")
	table.insert(cells, date)

	-- An entry for each battery (typically 0 or 1 battery)
	for _, b in ipairs(wezterm.battery_info()) do
		table.insert(cells, string.format("%.0f%%", b.state_of_charge * 100))
	end

	-- The filled in variant of the < symbol
	local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

	-- Color palette for the backgrounds of each cell
	local colors = {
		"#113415",
		"#3c1361",
		"#52307c",
		"#663a82",
		"#7c5295",
		"#b491c8",
	}

	-- Foreground color for the text across the fade
	local text_fg = "#c0c0c0"

	-- The elements to be formatted
	local elements = {}
	-- How many cells have been formatted
	local num_cells = 0

	-- Translate a cell into elements
	local function push(text, is_last, is_first)
		local cell_no = num_cells + 1
		if is_first then
			table.insert(elements, { Foreground = { Color = colors[1] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })
		end

		table.insert(elements, { Foreground = { Color = text_fg } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Text = " " .. text .. " " })
		if not is_last then
			table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = SOLID_LEFT_ARROW })
		end
		num_cells = num_cells + 1
	end

	local howManyCells = #cells
	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0, #cells == howManyCells - 1)
	end

	window:set_right_status(wezterm.format(elements))
end)

return config
