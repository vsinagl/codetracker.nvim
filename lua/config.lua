--defualt cofing for plugin
local M = {
	inactivity_period = 100, -- inactivity period in miliseconds, after this period event for saving session will be triggered
	min_activity = 2, -- minimal duration of session that will be stored into database
	-- min activity time is for quick moving from one buffer to another --> no data storing in this case
	database_name = "codetrackerdb"

}

-- NOTE: path to database
--	- local database is stored in plugin folder inside lua/
local plugin_path = debug.getinfo(1, "S").source:sub(2)
local plugin_dir = vim.fn.fnamemodify(plugin_path, ":h")
M.dbname = plugin_dir  .."/".. M.database_name

return M
