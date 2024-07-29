local M = {}

function M.startup(wezterm, workspace_name)
	local mux = wezterm.mux
	local project_dir = "~/work/ygd-be-docker-compose/"

	-- lazydocker
	local first_tab, first_pane, proj_window = mux.spawn_window({
		workspace = workspace_name,
		cwd = project_dir,
	})

	-- backend tab
	local second_tab, second_pane, _ = proj_window:spawn_tab({
		cwd = project_dir .. "backend",
	})

	-- frontend tab
	local third_tab, third_pane, _ = proj_window:spawn_tab({
		cwd = project_dir .. "frontend-SK",
	})

	-- drizzle-kit tab
	local fourth_tab, fourth_pane, _ = proj_window:spawn_tab({
		cwd = project_dir .. "drizzle-kit",
	})

	local node_pane = third_pane:split({ cwd = project_dir .. "frontend-SK", size = 5 })

	wezterm.sleep_ms(1000)
	first_pane:send_text("lazydocker\r")
	wezterm.sleep_ms(100)
	second_pane:send_text("nvim\r")
	wezterm.sleep_ms(100)
	third_pane:send_text("nvim\r")
	wezterm.sleep_ms(100)
	fourth_pane:send_text("lazysql\r")
	wezterm.sleep_ms(100)
	node_pane:send_text("nvm use 16 && npm start\r")
	wezterm.sleep_ms(100)

	first_tab:set_title(wezterm.nerdfonts.linux_docker .. " lazydocker")
	second_tab:set_title(wezterm.nerdfonts.md_language_php .. " backend")
	third_tab:set_title(wezterm.nerdfonts.md_nodejs .. " frontend-sk")
	fourth_tab:set_title(wezterm.nerdfonts.dev_mysql .. " lazysql")

	third_pane:activate()
	wezterm.sleep_ms(50)
	first_pane:activate()
	mux.set_active_workspace(workspace_name)
end

return M
