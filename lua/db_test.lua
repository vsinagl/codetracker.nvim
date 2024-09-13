-- Mocking neovim functions
local mock_vim = {
    api = {
        nvim_err_writeln = function(msg)
            print("Neovim Error: " .. msg)
        end
    }
}

-- Set the global vim
_G.vim = mock_vim

local Database = require("db")
local db_create = require("create_db")
--local sqllite3 = require("sqlite3")
local dbname = "DBTEST"


local function print_test(test_name, succes, message)
	if not succes  then
		print("\nTEST: " .. test_name)
		print("_____________________")
		print("❌ error: in insert into query:")
		print(print(message))
		print("_____________________")
	else
		print("\nTEST: " .. test_name)
		print("_____________________")
		print(" [OK]	✅")
		print("_____________________")
	end
end


local function create_test()
	local db, err
	db, err = pcall(db_create.db_init, dbname)
	print_test("db_create", db, err)
end




local function insert_test()
	--create_test(dbname)
	local db1 = Database.new(dbname)

	local succes = db1:insert_into(
		"filetypes",
		{"filetype", "is_lang", "lang_type"},
		{"Lua", true,  "lightweight, high-level, multi-paradigm"}
	)
	print_test("db_insert: filetypes", succes, "<no message>")

	succes = db1:insert_into(
		"repos",
		{"is_repo", "remote_url", "branch"},
		{true, "remote-url", "main"}
	)
	print_test("db_insert: succes", succes, "<no message>")

	succes = db1:insert_into(
		"projects",
		{"project_name", "project_name", "description"},
		{"codetracker.nvim", "codetracker.nvim", "plugin for tracking coding sessions in neovim"}
	)
	print_test("db_insert: projects", succes, "<no message>")

	local columns = {"buffer_id", "filepath", "filetype_id", "start_time", "end_time"}
	local values = {
		{13, "~/Code/test/test2.lua", 1, 10123, 10128},
		{14, "~/Code/test/test2.lua", 1, 10123, 10128},
		{15, "~/Code/test/test2.lua", 1, 10123, 10128},
	}
	succes = db1:insert_into("sessions", columns, values)
	print_test("db_insert: sessions", succes, "<no message>")
end


--NOTE: MAIN

--create_test()
insert_test()
