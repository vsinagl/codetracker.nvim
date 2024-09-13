local config = require("config")
local Database = require("db")

local M = {}
M.inactivity_timer = nil
M.db = "nil"
--M.session_cols =  {"buffer_id", "filepath", "filetype", "start_time", "end_time", "is_repo", "remote_url", "branch"}
M.session_cols =  {"buffer_id", "filepath", "filetype_id", "repo_id", "start_time", "end_time"}
M.session_vals = {}


local function clear_timer()
	if not M.inactivity_timer then
		return
	end
	M.inactivity_timer:stop()
	M.inactivity_timer:close()
	M.inactivity_timer = nil
end
--]]

-- function that loads repo informations, it returs three variables:
--	- is_git_repo: boolean
--	- remote_url: string
--	- branch_name: string
local function get_repo_info()
	 -- check if we're in a git repository
	local current_dir = vim.fn.expand('%:p:h')
	local original_dir = vim.fn.getcwd()
	-- HACK: changes the local working directory of the current window to current_dir.
	vim.cmd('lcd ' .. vim.fn.fnameescape(current_dir))
	local is_git_repo = vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match('^true')

	-- if not git repo, return "nil" strings
	if not is_git_repo then
		-- HACK: Change back to the original directory
		vim.cmd('lcd ' .. vim.fn.fnameescape(original_dir))
		return "nil", "nil", "nil"
	end

	local remote_url = vim.fn.system('git config --get remote.origin.url'):gsub('\n', '')
	local branch = vim.fn.system('git branch --show-current'):gsub('\n', '')
	-- If remote_url or branch are empty, set them to "nil"
	if remote_url == "" then remote_url = "nil" end
	if branch == "" then branch = "nil" end
	-- HACK: Change back to the original directory
	vim.cmd('lcd ' .. vim.fn.fnameescape(original_dir))

	return is_git_repo, remote_url, branch
end


local function extract_filetype(text)
	local result = vim.split(text, ".", {plain = true})
	if #result == 0 then
		return "NULL"
	end
	return (result[#result])
end


-- set start_time and informations about buffer
local function set_values()
	M.session_vals[4] = os.time() --start time
	M.session_vals[1] = vim.api.nvim_get_current_buf() -- buff_id
	M.session_vals[2] = vim.api.nvim_buf_get_name(M.session_vals[1]) --filepath
	M.session_vals[3] = extract_filetype(M.session_vals[2]) --filetype
	M.session_vals[6], M.session_vals[7], M.session_vals[8] = get_repo_info() --is repo, remote_url, branch
end

-- function that returns filetype id from filetabes table or create a new filetype if there is no such filetype
local function get_or_insert_filetype(extension)
  local success, result = pcall(function()
      local extension_mod = "." .. extension
      local result = M.db:select_from("filetypes", {"id"}, {extension = extension_mod})
      if #result > 0 then
          return result[1].id
      else
          M.db:insert_into("filetypes", {"extension", "is_lang"}, {extension_mod, true})
  
          vim.api.nvim_err_writeln("last insert id: " .. tostring(M.db.con:last_insert_rowid()))
          return M.db.con:last_insert_rowid()
      end
  end)
  if not success then
    return nil
  end
  return result
end

-- fuction that returns repo id from repos table or create a new repo if there is no such repo
local function get_or_insert_repo(is_repo, remote_url, branch)
  local succes, result = pcall(function()
      local result = M.db:select_from("repos",
          {"id"},
          {is_repo = is_repo, remote_url = remote_url, branch = branch})
      if #result > 0 then
          return result[1].id
      else
          M.db:insert_into("repos",
              {"is_repo", "remote_url", "branch"},
              {is_repo, remote_url, branch})
          return M.db.con:last_insert_rowid()
      end
  end)
  if succes == false then
    return nil
  end
  return result
end


local function create_session_record()
	clear_timer()
	M.session_vals[5] = os.time() --end time
	-- NOTE: values with null filetypes are not allowed (neovim buffers)
	if not M.session_vals[1] or M.session_vals[2] == "" then
		return
	end

  local filetype_id = get_or_insert_filetype(M.session_vals[3])
  if filetype_id == nil then
    vim.api.nvim_err_writeln("Error: filetype id == nil")
    return
  end

  if M.session_vals[6] ~= "nil" then
    local repo_id = get_or_insert_repo(M.session_vals[6], M.session_vals[7], M.session_vals[8])
    if not repo_id then
      vim.api.nvim_err_writeln("Error: repo id == nil")
      return
    end
    M.db:insert_into("sessions",
           M.session_cols,
          { M.session_vals[1], M.session_vals[2], filetype_id, repo_id,
        M.session_vals[4], M.session_vals[5]})
  else
    M.db:insert_into("sessions",
           M.session_cols,
          { M.session_vals[1], M.session_vals[2], filetype_id, "nil", M.session_vals[4], M.session_vals[5]})
  end
end


local function create_session_record_inactivity()
	clear_timer()
	M.session_vals[5] = os.time() - config.inactivity_period --end time
	print("difference: ", M.session_vals[5] - M.session_vals[4])
	if M.session_vals[5] - M.session_vals[4] < config.min_activity then
--		vim.api.nvim_err_writeln("session duration < minimal activity, duration: " .. tostring(M.session_vals[5] - M.session_vals[4]))
		return
	end
	-- nvim internal buffers (telescope for example) don't have filetypes
	-- NOTE: values with null filetypes are not allowed
	if not M.session_vals[1] or M.session_vals[2] == "" then
		return
	end

  local filetype_id = get_or_insert_filetype(M.session_vals[3])
  if filetype_id == nil then
    vim.api.nvim_err_writeln("Error: filetype id == nil")
    return
  end

  if M.session_vals[6] ~= "nil" then
    local repo_id = get_or_insert_repo(M.session_vals[6], M.session_vals[7], M.session_vals[8])
    if not repo_id then
      vim.api.nvim_err_writeln("Error: repo id == nil")
      return
    end
    M.db:insert_into("sessions",
           M.session_cols,
          { M.session_vals[1], M.session_vals[2], filetype_id, repo_id, M.session_vals[4], M.session_vals[5]})
  else
    M.db:insert_into("sessions",
           M.session_cols,
          { M.session_vals[1], M.session_vals[2], filetype_id, "nil", M.session_vals[4], M.session_vals[5]})
  end
end


-- This function triggers on user activity, e.g starting vim and moving the cursor
local function reset_timer()
	if not M.inactivity_timer then
		set_values()
		M.inactivity_timer = vim.loop.new_timer()
	end
	M.inactivity_timer:stop()
	M.inactivity_timer:start(
		config.inactivity_period * 1000,
		0,
		vim.schedule_wrap(create_session_record_inactivity)
	)
end


local function buffer_change()
	--i switch to buffer when i have already inactivy --> no timer set
	if not M.inactivity_timer then
		return
	end
	--minimal inactivity -> if not reached, session will not be saved
	if (os.time() - M.session_vals[4] ) <= config.min_activity then
		clear_timer()
		return
	end
	create_session_record()
end


local function on_cursor_move()
	M.inactivity_timer = nil
	vim.api.nvim_create_autocmd({
		"CursorMoved", "CursorMovedI",
      "VimEnter","ModeChanged",
    	"TextChanged", "TextChangedI", "TextChangedP",
    	"BufEnter", "BufWritePost"
		},
		{
		callback = reset_timer,
		pattern = "*",
		desc = "reseting timer after cursor move",
		}
	)
end


-- NOTE: function that runs when the buffer changes
-- if time spent in the buffer is longer than the min activity time, it saves the session to the db
-- sometimes I switch buffers quickly for no real reason, so I don't want 1-second records in the db
local function on_buffer_change()
	vim.api.nvim_create_autocmd({"BufEnter", "VimLeavePre"}, {
		callback = buffer_change,
		desc = "creating database record",
	}
	)
end


function M.set_events(db)
  M.db = db
	on_buffer_change()
	on_cursor_move()
end

return M
