local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("keys").apply_to_config(config)
require("ui").apply_to_config(config)

config.default_domain = "WSL:Ubuntu"

return config

--@TODO save session
--give icons if it's active show whole title but if inactive show only icon
--if leader key is touched change something somewhere
--change name of tab when moving between panes, I think I can run a bash script that does that
--setup tmuxifier for local, basch script is getting difficult. I might create a menu that opens on Leader + w that lets you choose between pre-configured scripts that open what I want
