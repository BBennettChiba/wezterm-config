local wezterm = require("wezterm")
local M = {}
M.get_ram_usage = function()
	local meminfo = {}

	local success, stdout, stderr = wezterm.run_child_process({ "wsl", "bash", "-c", "cat /proc/meminfo" })

	for line in stdout:gmatch("[^\r\n]+") do
		local key, value = line:match("^(%S+):%s+(%d+)")
		if key and value then
			meminfo[key] = tonumber(value)
		end
	end

	local total_ram = meminfo["MemTotal"] / 1024 / 1000
	local free_ram = meminfo["MemFree"] / 1024 / 1000
	local available_ram = meminfo["MemAvailable"] / 1024 / 1000
	local used_ram = total_ram - available_ram

	-- print(string.format("Total RAM: %.2f GB", total_ram))
	-- print(string.format("Free RAM: %.2f GB", free_ram))
	-- print(string.format("Available RAM: %.2f GB", available_ram))
	-- print(string.format("Used RAM: %.2f GB", used_ram))
	return string.format("%.2f", (used_ram / total_ram) * 100) .. "%"
end

return M
