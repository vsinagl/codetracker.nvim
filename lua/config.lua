--defualt cofing for plugin
local M = {
	inactivity_period = 5000, --inactivity perion in miliseconds
	min_activity = 3,
	database_name = "testing_db"
}
local pwd = vim.fn.systemlist("pwd")[1]
M.dbname =  vim.split(pwd, "codetracker.nvim", {plain = true})[1] .. "codetracker.nvim/lua/" .. M.database_name
return M
