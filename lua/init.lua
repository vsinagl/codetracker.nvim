
local config = require("config")
local events = require("events")
local db_create = require("create_db")
local Database = require("db")


local function file_exists(filepath)
    local file = io.open(filepath, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end


print(config.dbname)

local database = nil
--[[
local boolean = file_exists(config.dbname)
if boolean == true then
  print("boolean = true")
else
  print("boolean = false")
end
--]]

--check if database exists, run creation subroutine
if file_exists(config.dbname) == false then
  print("creating database")
  database = db_create.db_init(config.dbname)
else
  print("database already created !")
  database = Database.new(config.dbname)
end

--set events for plugin
if database then
  events.set_events(database)
else
  vim.api.write("codetracker plugin: error in database")
end



