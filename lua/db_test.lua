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
local dbname = "DBTEST2"


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




local function insert_test(db1)
	--create_test(dbname)

	local succes = db1:insert_into(
		"filetypes",
		{"extension", "filetype", "is_lang", "lang_type"},
		{".lua", "Lua", true,  "lightweight, high-level, multi-paradigm"}
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


--filetype == extension
local function get_or_insert_filetype(database, extension)
    local result = database:select_from("filetypes", {"id"}, {extension = extension})
    if #result > 0 then
        return result[1].id
    else
        database:insert_into("filetypes", {"extension", "is_lang"}, {extension, true})
        vim.api.nvim_err_writeln("last insert id: ", database.con:last_insert_rowid())
        return database.con:last_insert_rowid()
    end
end

local function select_test(database)
  local result = database:select_from("sessions",{"*"}, {filepath = "~/Code/test/test2.lua"})
  print_test("db_select: sessions", result, "<no message>")
  print("result: ")
  for i, v in ipairs(result) do
    print(i, v)
  end
  print("-----------------")

  local result2 = get_or_insert_filetype(database, ".bobr")
  print_test("db_select: filetypes_1", result2, "<no message>")
  print("result: ",result2)

  local result3 = get_or_insert_filetype(database, ".r")
  if result3 == nil or result3 == 0 then
    print_test("db_select: filetypes_2", nil, "<no message>")
  else
    print_test("db_select: filetypes_2", result3, "<no message>")
    print("result: ",result3, " should be 17")
  end
end

  

--NOTE: MAIN

local db = Database.new(dbname)

--create_test()
--insert_test(db)
select_test(db)
