
local sqlite3 = require("sqlite3")

--NOTE: db init
local M = {}

local function table_exists(db, table_name)
	local result = pcall(function()
		--for row in db:rows("SELECT * FROM sqlite_master") do
		for row in db:rows(".tables") do
		for _, v in pairs(row) do
			print(v)
			if (v == table_name) then
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

--[[NOTE: repo cols:
		  is_repo BOOLEAN,
		  remote_url TEXT,
		  branch TEXT,
-]]

local function create_sessions(db)
	local query = [[
		CREATE TABLE sessions (
		  id INTEGER PRIMARY KEY AUTOINCREMENT,
		  buffer_id INTEGER NOT NULL,
		  filepath TEXT ,
		  filetype_id INT,
		  repo_id INT,
		  start_time INTEGER NOT NULL, -- UNIX timestamp
		  end_time INTEGER,
		  FOREIGN KEY(filetype_id) REFERENCES filetypes(id)
		  FOREIGN KEY(repo_id) REFERENCES repos(id)
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
		 description TEXT 
);
	]]
	local succes, err_msq = db:exec(query)
	if succes == nil then
		error("error in creating session table: " .. err_msq)
	end
end

local function create_repos(db)
	local query = [[
		CREATE TABLE repos (
		 id INTEGER PRIMARY KEY AUTOINCREMENT,
		 is_repo BOOLEAN,
		 remote_url TEXT,
		 branch TEXT
);
	]]
	local succes, err_msq = db:exec(query)
	if succes == nil then
		error("error in creating repos table: " .. err_msq)
	end
end

local function create_filetypes(db)
	local query = [[
		CREATE TABLE filetypes(
		  id INTEGER PRIMARY KEY AUTOINCREMENT,
		  filetype TEXT,
		  is_lang BOOLEAN,
		  lang_type TEXT
);
	]]
	local succes, err_msq = db:exec(query)
	if succes == nil then
		error("error in creating filetypes table: " .. err_msq)
	end
	succes = db:insert_into(
		"filetypes",
		{"filetype", "is_lang", "lang_type"},
		{"Lua", true,  "lightweight, high-level, multi-paradigm"}
	)
end

function M.db_init(dbname)
	print("DBNAME: " .. dbname)
	local db, err_msg = sqlite3.open(dbname)
	if not db then
		error("error in creating or opening database, error: " .. err_msg)
	end
	if table_exists(db, "sessions") == false then
		create_sessions(db)
	end
	if table_exists(db, "repos") == false then
		create_repos(db)
	end
	if table_exists(db, "filetypes") == false then
		create_filetypes(db)
	end
	if table_exists(db, "projects") == false then
		create_projects(db)
	end
	db.close(db)
end

return M
