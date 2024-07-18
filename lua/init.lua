
-- NOTE: import additonal lua files:
---- Determine the path to your Lua modules (adjust this according to your project structure)
-- Adjust package.path to include the 'deps' directory

-- Now you can require 'lua-ljsqlite3'

local dbmodule = require("db")


--local variables
local function create_values(name, start_time, end_time, duration)
	local valueset = {}
	valueset.name = name
	valueset.start_time = start_time
	valueset.end_time = end_time
	valueset.duration = duration
	return valueset
end









--[[NOTE: Working main func :)
local function main()
	print("main function is running...")
	local dbname = "codetracker.db"
	local db = dbmodule.init(dbname)
	if not db then
		return nil
	end

	local session1 = create_values("test3", "2024-07-14 15:45","2024-07-14 16:45", "01:00:00")
	local succes = dbmodule.add_session(db.con, session1)
	if not succes then
		dbmodule.close()
		return nil
	end
end
--]]


main()
