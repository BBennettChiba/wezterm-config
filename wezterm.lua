local wezterm = require("wezterm")
local config = wezterm.config_builder()

require("keys").apply_to_config(config)
require("ui").apply_to_config(config)

config.default_domain = "WSL:Ubuntu"

return config
