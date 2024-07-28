
local config = require("config")
local sqlite3 = require("sqlite3")
local Database = require("db")

--NOTE: db init
local M = {}

local function table_exists(db, table_name)
	local success, result = pcall(function()
		for row in db:rows("SELECT * FROM sqlite_master") do
		for _, v in pairs(row) do
			if (v == table_name) then
				print("table find!")
				return true
			end
        	    end
        	end
        	print("No rows found in sqlite_master")
        	return false
    end)
	--[[NOTE: for debuging
	print("sqlite_master query success:", success)
	print("sqlite_master query result:", result)
	--]]
	return result
end

local function create_sessions(db)
	local query = [[
		CREATE TABLE sessions (
		  id INTEGER PRIMARY KEY AUTOINCREMENT,
		  buffer_id INTEGER NOT NULL,
		  filepath TEXT NOT NULL,
		  filetype TEXT,
		  start_time INTEGER NOT NULL, -- UNIX timestamp
		  end_time INTEGER,
		  duration INTEGER,
		  is_repo BOOLEAN,
		  remote_url TEXT,
		  branch TEXT,
		  FOREIGN KEY(filetype) REFERENCES supported_filetypes(id)
		);
	]]
	local succes, err_msq = db:exec(query)
	if succes == nil then
		error("error in creating session table: " .. err_msq)
	end
end

local function create_projects(db)
	local query = [[
		CREATE TABLE projects (
		 id INTEGER PRIMARY KEY AUTOINCREMENT,
		 project_name TEXT NOT NULL,
		 remote_url TEXT 
);
	]]
	local succes, err_msq = db:exec(query)
	if succes == nil then
		error("error in creating session table: " .. err_msq)
	end
end

local function create_filetypes(db)
	local query = [[
		CREATE TABLE supported_filetypes(
		  id TEXT PRIMARY KEY,
		  file_name TEXT,
		  is_lang BOOLEAN,
		  lang_type TEXT
);
	]]
	local succes, err_msq = db:exec(query)
	if succes == nil then
		error("error in creating session table: " .. err_msq)
	end
end

function M.db_init(dbname)
	local db, err_msg = sqlite3.open(dbname)
	if not db then
		error("error in creating or opening database, error: " .. err_msg)
	end
	if table_exists(db, "sessions") == false then
		create_sessions(db)
	end
	if table_exists(db, "projects") == false then
		create_projects(db)
	end
	if table_exists(db, "supported_filetypes") == false then
		--NOTE: populating the database with values
		create_filetypes(db)
	end
	db.close(db)
end

return M
