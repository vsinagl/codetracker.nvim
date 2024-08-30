local sqlite3 = require("sqlite3")

local  Database = {}
Database.__index = Database

local function db_connect(dbname)
	local db, err =  sqlite3.open(dbname)
	if not db then
		vim.api.nvim_err_writeln("error in opening db: " .. err)
		return nil
	end
	return db
end

function Database.new(dbname)
	local db_instance = setmetatable({}, Database)
    	db_instance.dbname = dbname
    	db_instance.con = db_connect(dbname)
    	if not db_instance.con then
		return nil
    	end
    	return db_instance
end

--closing connection
function Database:close()
	if self.con then
		self.con:close()
		self.con = nil
	end
end

function Database:prepare_entry()
	local sql_query = "INSERT INTO sessions (name, start_time, end_time, duration) VALUES (?, ?, ?, ?);"
	local stmt, err = self.con:prepare(sql_query)
	if not stmt then
		vim.api.nvim_err_writeln("Error in preparing insert statement: " .. err)
		return nil
	end
	local success, bind_err = stmt:bind_values('Coding lua', '10:45', '10:51', '6')
	if not success then
		vim.api.nvim_err_writeln("Error in binding values: " .. bind_err)
		return nil  -- Return nil to indicate failure
	end
	return stmt
end

-- creating sql query as a string
-- WARNING: argument ares:
--	table_name: name of the table,
--	columns: table with name of the columns to which will be inserted,
--	values: values that will be inserted
--
--	for sessions table:
--	entry = { buffer_id (integer),
--		filepath(string),
--		filetype (string),
--		start_time(UNIX format - integer),
--		end_time (UNIX format - integer),
--		duration (int)
--		is_repo (boolean)
--		remote_url (string),
--		branch (string),

local function quote(value)
	return "\'" .. value .. "\'"
end

--[[
--
local function format_values(value)
	local formated_value = {}
	--for _,value in ipairs(values) do
	if type(value) == "number" then
		table.insert(formated_values, tostring(value))
	elseif type(value) == "string" then
		table.insert(formated_values, quote(value))
	elseif type(value) == "boolean" then
		if value == true then
			table.insert(formated_values, tostring(1))
		else
			table.insert(formated_values, tostring(0))
		end
	elseif type(value) == "nil" then
		table.insert(formated_values, "NULL")
	else
		vim.api.nvim_err_writeln("Unsupported data type: " .. type(value))
	end
	--end
	return table.concat(formated_values, ", ")
end
--]]

local function format_values(values)
	local formated_values = {}
	for _,value in ipairs(values) do
		if type(value) == "number" then
			table.insert(formated_values, tostring(value))
		elseif type(value) == "string" then
			if value == "nil" then
				table.insert(formated_values, "NULL")
			else
				table.insert(formated_values, quote(value))
			end
		elseif type(value) == "boolean" then
			if value == true then
				table.insert(formated_values, tostring(1))
			else
				table.insert(formated_values, tostring(0))
			end
		elseif type(value) == "nil" then
			table.insert(formated_values, "NULL")
		else
			vim.api.nvim_err_writeln("Unsupported data type: " .. type(value))
		end
	end
	return table.concat(formated_values, ", ")
end

function Database:insert_into(table_name, columns, values)
	local succes, result = pcall(function()
		local sql_query = string.format(
			"INSERT INTO %s (%s) VALUES (%s);",
			table_name,
			table.concat(columns, ", "),
			format_values(values)
        )
		local succes, err = self.con:exec(sql_query)	
		if not succes then
			vim.api.nvim_err_writeln("Session insert error: " .. err)
			return nil
		end
		return succes
	end)
	if not succes then
		vim.api.nvim_err_writeln("Database.insert_into() error")
		return nil
	end
	return result
end

return Database
