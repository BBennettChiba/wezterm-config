local wezterm = require("wezterm")
local M = {}

M.get_cpu_usage = function()
	local success, cpu, err = wezterm.run_child_process({
		"wsl",
		"bash",
		"-c",
		"~/work/scripts/cpu_usage.sh",
	})

	if not success then
		print("Error: " .. err)
		return "Error"
	end

	local cpu_usage = tonumber(cpu)
	if cpu_usage then
		return string.format("%.2f", cpu_usage) .. "%"
	else
		print("Error parsing CPU usage: " .. cpu)
		return "Error"
	end
end

return M

--need line 19 pointing to a shell script. the contents of which should look like
--#!/bin/env bash

--cpu_usage=$(mpstat 1 1 | awk '/Average/ {print 100 - $12}')

--echo "$cpu_usage"

--@TODO doesn't seem to work well. try different method
