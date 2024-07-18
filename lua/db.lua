-- Construct the new package.path value

local sqlite3 = require("sqlite3")

--NOTE: Lua module for dbinit containing all functions and entities
local M = {}

-- creating prepare statement for inserting into sessions
local function prepare_entry(self)
	local sql_query = "INSERT INTO sessions (name, start_time, end_time, duration) VALUES (?, ?, ?, ?);"
	local stmt, err = self.con:prepare(sql_query)
	if not stmt then
		print("Error in preparing insert statement: " .. err)
		return nil
	end
	local success, bind_err = stmt:bind_values('Coding lua', '10:45', '10:51', '6')
	if not success then
		print("Error in binding values: " .. bind_err)
		return nil  -- Return nil to indicate failure
	end
	return stmt
end

function M.add_session(db, value)
	local values = "\'" .. value.name .. "\',\'" .. value.start_time .. "\',\'" .. value.end_time .. "\',\'" .. value.duration .. "\'"
	local sql_query = "INSERT INTO sessions (name, start_time, end_time, duration) VALUES (" .. values .. ");"
	print(sql_query)
	local succes, err = db:exec(sql_query)	
	if not succes then
		print("Session insert error: " .. err)
		return nil
	end
	return succes
end


--initializing the db --> if db not exists, creating db and tables
function M.init(dbname)
	local db, err =  sqlite3.open(dbname)
	if not db then
		print("error in opening db: " .. err)
		return nil
	end

	local success, err_msg = db:exec([[
        CREATE TABLE IF NOT EXISTS sessions (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		name	TEXT,
		start_time TEXT,
            	end_time TEXT,
            	duration INTEGER
        )
    ]])
	if not success then
		db:close()
		print("Error creating table: " .. err_msg)
		return nil
	end
	M.con = db

	--[[ WARN: this is not working, dont know why
	--
	local stmt_sessions = prepare_entry(M)
	if not stmt_sessions then
		db.close()
		return nil
	end
	M.session_add = stmt_sessions
	--]]
	return M
end

--closing connection
function M.close()
	if M.connection then
		M.connection:close()
		M.connection = nil
	end
end


return M




