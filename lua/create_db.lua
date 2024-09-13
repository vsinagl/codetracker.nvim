
-- local sqlite3 = require("lsqlite3")
local Database = require("db")

--NOTE: db init
local M = {}

local languages = {
    {".lua", "Lua", true},
    {".py", "Python", true},
    {".js", "JavaScript", true},
    {".java", "Java", true},
    {".cs", "C#", true},
    {".cpp", "C++", true},
    {".rb", "Ruby", true},
    {".go", "Go", true},
    {".swift", "Swift", true},
    {".kt", "Kotlin", true},
    {".php", "PHP", true},
    {".ts", "TypeScript", true},
    {".rs", "Rust", true},
    {".m", "Objective-C", true},
    {".scala", "Scala", true},
    {".pl", "Perl", true},
    {".r", "R", true},
    {".dart", "Dart", true},
    {".hs", "Haskell", true},
    {".ex", "Elixir", true},
    {".clj", "Clojure", true},
    {".m", "MATLAB", true},
    {".vba", "VBA", true},
    {".groovy", "Groovy", true},
    {".sh", "Shell", true}
}

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
      extension TEXT NOT NULL,
		  filetype TEXT,
		  is_lang BOOLEAN,
		  lang_type TEXT
);
	]]
	local succes, err_msq = db:exec(query)
	if succes == nil then
		error("error in creating filetypes table: " .. err_msq)
	end
end

local function insert_languages(database)
  local succes = database:insert_into(
    "filetypes",
    {"extension", "filetype", "lang_type"},
    languages
  )
  if succes == nil then
    vim.err_writeln("error in inserting languages")
  end
end


function M.db_init(dbname)
  -- local db, err_msg = sqlite3.open(dbname)
  database = Database.new(dbname)
  local db = database.con
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
    insert_languages(database)
	end
	if table_exists(db, "projects") == false then
		create_projects(db)
	end
  return database
end

return M
