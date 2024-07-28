local config = require("config")
local Database = require("db")

--NOTE: main module with record
local M = {}
M.inactivity_timer = nil
M.db = Database.new(config.dbname)
M.session_cols =  {"buffer_id", "filepath", "filetype", "start_time", "end_time", "duration", "is_repo", "remote_url", "branch"}
M.session_vals = {}

-- event variables
-- local inactivity_timer = nil
-- local last_activity = nil -- time in UNIX format

local function stop_timer()
	if not M.inactivity_timer then
		return
	end
	M.inactivity_timer:stop()
	M.inactivity_timer:close()
	M.inactivity_timer = nil
end

local function get_repo_info()
    local result = vim.fn.systemlist("git rev-parse --is-inside-work-tree")[1]
	local remote_url = "nil"
	local branch = "nil"
    if result == true then
		remote_url =  vim.fn.systemlist("git config --get remote.origin.url")[1]
	end
	return result, remote_url, branch
end

local function extract_filetype(text)
	local result = vim.split(text, ".", {plain = true})
	if #result == 0 then
		return "NULL"
	end
	return (result[#result])
end


local function set_values()
	M.session_vals[4] = os.time() --start time
	M.session_vals[1] = vim.api.nvim_get_current_buf() -- buff_id
	M.session_vals[2] = vim.api.nvim_buf_get_name(M.session_vals[1]) --filepath
	M.session_vals[3] = extract_filetype(M.session_vals[2]) --filetype
	M.session_vals[7], M.session_vals[8], M.session_vals[9] = get_repo_info() --is repo

end

local function create_session_record()
	stop_timer()
	M.session_vals[5] = os.time() --end time
	M.session_vals[6] = M.session_vals[5] - M.session_vals[4] --duration
	M.db:insert_into("sessions", M.session_cols, M.session_vals)
	--print("suck it, jing jang\n")
end

local function reset_timer()
	if M.inactivity_timer then
		stop_timer()
	else
		set_values()
	end
	M.inactivity_timer = vim.loop.new_timer()
	M.inactivity_timer:start(5000, 0, vim.schedule_wrap(create_session_record))
end

local function buffer_change()
	--i switch to buffer when i have already inactivy --> no timer set
	if not M.inactivity_timer then
		return
	end
	--minimal inactivity
	if (os.time() - M.session_vals[4] ) < config.min_activity then
		print("fcking time: ", (os.time()-M.session_vals[4]) < config.min_activity)
		stop_timer()
		return
	end
	create_session_record()
end

--NOTE: setup function that create nvim.api autocommand that trigger reset_timer every time that cursor is moved
local function set_inactivity_tracker()
	M.inactivity_timer = nil
	vim.api.nvim_create_autocmd({"CursorMoved", "CursorMovedI"}, {
		callback = reset_timer,
		pattern = "*",
		desc = "reseting timer after cursor move",
		}
	)
end

local function set_buffer_tracker()
	vim.api.nvim_create_autocmd({"BufEnter", "VimLeavePre"}, {
		callback = buffer_change,
		desc = "creating database record",
	}
	)
end

function M.set_events()
	print(#M.session_vals)
	reset_timer()
	set_buffer_tracker()
	set_inactivity_tracker()
end

return M
