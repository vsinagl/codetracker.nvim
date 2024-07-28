
local function format_values(value)
        print("formattion function started\n")
	local formated_value
	if type(value) == "number" then
		formated_value = tostring(value)
	elseif type(value) == "string" then
		formated_value = quote(value)
	elseif type(value) == "boolean" then
		if value == true then
			formated_value = tostring(1)
		else
			formated_value = tostring(0)
		end
	elseif type(value) == "nil" then
		formated_value = "NULL"
	else
		error("Unsupported data type: " .. type(value))
	end
	--end
	print(formated_value)
	return formated_value
end


function test(table_name, record)
	local succes, result = pcall(function()
		--[[WARNING: putting this do pici
		if #columns ~= #values then
			local err_msg = string.format("len of columns (%i) is not equal to len of values (%i)-> could't construct the sql query.\n", #columns, #values)
			vim.api.nvim_err_writeln(err_msg);
			return nil
		end
			--]]
		local columns = {}
		local values = {}
                print("I'am here\n")
		for k,v in pairs(record) do
                    print(k)
                    print(v)
			columns.insert(k)
			values.insert(format_values(v))
			print(table.concat(values, " "))
		end
		print(table.concat(columns, ", "))
		local sql_query = string.format(
			"INSERT INTO %s (%s) VALUES (%s);",
			table_name,
			table.concat(columns, ", "),
			table.concat(values, ", ")
        )
		print(sql_query)
		return sql_query
	end)
	if not succes then
            print("nechapu")
	end
	return result
end

local session_vals = {
	buffer_id = 2,
	filepath = "hello",
	filetype = ".c",
	start_time = 12312312,
	end_time = 12312318,
	duration = 6,
	is_repo = nil,
	remote_url = nil,
	branch = nil,
}

test("neco", session_vals)


