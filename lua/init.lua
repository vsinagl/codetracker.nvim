
local events = require("events")
local Database = require("db")
local db_create = require("create_db")
local config = require("config")


-- events.db = Database.new(config.dbname)

-- db_init check if database tables are created and if not then it creates them
local database = db_create.db_init(config.dbname)
if database then
  events.db = database
  events.set_events()
else
  vim.api.write("codetracker plugin: error in database")
end

-- set events for plugin


