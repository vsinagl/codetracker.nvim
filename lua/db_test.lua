local Database = require("db")
local db_create = require("create_db")
--local sqllite3 = require("sqlite3")
local dbname = "testing_db"

local function create_test(dbname)
	local db, err = db_create.db_init(dbname)
	print("\nTEST 1: create database")
	if db == nil then
		print("_____________________")
		print("db: ", db)
		error("❌ error in insert into query: ", err)
		print("_____________________")
	else
	print("_____________________")
	print(" [OK]	✅")
	print("_____________________")
	end
end

local function insert_test()
	--create_test(dbname)
	local db1 = Database.new(dbname)
	local columns = {"buffer_id", "filepath", "filetype", "start_time", "end_time", "duration", "is_repo"}
	local values = {
		"1", "~/Code/test/test2.lua", "lua", 10123, 10128, 5, false
	}
	succes = db1:insert_into("sessions", columns, values)
	if not succes  then
		print("\nTEST 2: inser_test()")
		print("_____________________")
		error("❌ error in insert into query,\n")
		print("_____________________")
	else
		print("\nTEST 2: inser_test()")
		print("_____________________")
		print(" [OK]	✅")
		print("_____________________")
	end
end

insert_test()
