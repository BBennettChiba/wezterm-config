local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_domain = "WSL:Ubuntu"

require("ui").apply_to_config(config)
require("keys").apply_to_config(config)
-- disabled because it doesnt work inside nvim
-- require("background").apply_to_config(config)

local wsl_domains = wezterm.default_wsl_domains()

for _, dom in ipairs(wsl_domains) do
	if dom.name == "WSL:Ubuntu" then
		dom.default_prog = { "bash" }
	end
end

config.wsl_domains = wsl_domains

print(config.wsl_domains)

return config

--@TODO save session
--if leader key is touched change something somewhere
--change name of tab when moving between panes, I think I can run a bash script that does that
--chnage bash script to not run if not in wezterm
