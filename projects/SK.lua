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

	wezterm.sleep_ms(700)
	first_pane:send_text("lazydocker\r")
	second_pane:send_text("nvim\r")
	third_pane:send_text("nvim\r")
	local node_pane = third_pane:split({ cwd = project_dir .. "frontend-SK" })
	wezterm.sleep_ms(900)
	node_pane:send_text("nvm use 16\n")
	node_pane:send_text("npm start\n")
	third_pane:activate()
	fourth_pane:send_text("npx drizzle-kit studio\r")

	wezterm.sleep_ms(400)
	first_tab:set_title(wezterm.nerdfonts.linux_docker .. " lazydocker")
	second_tab:set_title(wezterm.nerdfonts.md_language_php .. " backend")
	third_tab:set_title(wezterm.nerdfonts.md_nodejs .. " frontend-sk")
	fourth_tab:set_title(wezterm.nerdfonts.dev_mysql .. " drizzle")

	first_pane:activate()
	mux.set_active_workspace(workspace_name)
end

return M
