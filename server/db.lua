
local data =
{
    result =
    {

    },
    connection = nil
}

-- // Подключение к базе данных
local function db_connect()
    local login, password = "root", ""
    local host = "dbname=database;host=localhost;charset=utf8"
    data.connection = dbConnect("mysql", host, login, password, "share=1")
    return data.connection
end

-- // Отключение от базы данных
local function db_disconnect()
    if not data.connection then return end
    for key, value in pairs(data.result) do
        dbFree(data.connection, value.r)
    end
    destroyElement(data.connection)
    data.connection = nil
end

-- // Вернуть состояние
function db_get_connect()
    return isElement(data.connection)
end

-- // Подключение к базе данных
addEventHandler("onResourceStart", getResourceRootElement(), function()
    if not db_connect() then
        print("[crud][mysql][failed] - [connect]")
        cancelEvent()
    else
        print("[crud][mysql][success] - [connect]")
    end
end)

-- // Отключение от базы данных
addEventHandler("onResourceStop", getResourceRootElement(), function()
    print("[crud][mysql][success] - [disconnect]")
    db_disconnect()
end)

-- // Создать таблицу в базе данных
function db_create_table(name, column_table, options)
    if type(options) == "string" then
        options = ", "..options
    else
        options = ""
    end
    local column_queries = {}
    for _, column in ipairs(column_table) do
        local column_query = dbPrepareString(data.connection, "`??` ??", column.name, column.type)
        if column.size and tonumber(column.size) then
            local prepare = dbPrepareString(data.connection, "(??)", column.size)
            column_query = column_query..prepare
        end
        if not column.options or type(column.options) ~= "string" then
            column.options = ""
        end
        if string.len(column.options) > 0 then
            column_query = column_query.." "..column.options
        end
        table.insert(column_queries, column_query)
    end
    local query_string = dbPrepareString(data.connection, "CREATE TABLE IF NOT EXISTS `??` ("..table.concat(column_queries, ", ").." "..options..");", name)
    return dbExec(data.connection, query_string)
end

-- // Обновить таблицу
function db_update_table(name, set_field, where_field, func, ...)
    local set_queries = {}
    for column, value in pairs(set_field) do
        if value == "NULL" then
            table.insert(set_queries, dbPrepareString(data.connection, "`??`=NULL", column))
        else
            table.insert(set_queries, dbPrepareString(data.connection, "`??`=?", column, value))
        end
    end
    local where_queries = {}
    if not where_field then
        where_field = {}
    end
    for column, value in pairs(where_field) do
        table.insert(where_queries, dbPrepareString(data.connection, "`??`=?", column, value))
    end
    local query_string = dbPrepareString(data.connection, "UPDATE `??` SET "..table.concat(set_queries, ", "), name)
    if #where_queries > 0 then
        query_string = query_string..dbPrepareString(data.connection, " WHERE "..table.concat(where_queries, " AND "))
    end
    query_string = query_string..";"
    return db_retrieve_query_result(query_string, func, ...)
end

-- // Вставить в таблицу
function db_insert_value(name, insert, func, ...)
    local value_count = 0
    local value_queries = {}
    local column_queries = {}
    for column, value in pairs(insert) do
        table.insert(column_queries, dbPrepareString(data.connection, "`??`", column))
        table.insert(value_queries, dbPrepareString(data.connection, "?", value))
        value_count = value_count + 1
    end
    if value_count == 0 then
        return db_retrieve_query_result(dbPrepareString(data.connection, "INSERT INTO `??`;", name), func, ...)
    end
    local column_query = dbPrepareString(data.connection, "("..table.concat(column_queries, ",")..")")
    local value_query = dbPrepareString(data.connection, "("..table.concat(value_queries, ",")..")")
    local query_string = dbPrepareString(data.connection, "INSERT INTO `??` "..column_query.." VALUES "..value_query..";", name)
    return db_retrieve_query_result(query_string, func, ...)
end

-- // Выдать значения из таблицы
function db_select_table(name, columns, field, func, ...)
    local where_queries = {}
    if not field then field = {} end
    for column, value in pairs(field) do
        table.insert(where_queries, dbPrepareString(data.connection, "`??`=?", column, value))
    end
    local wherequery_string = ""
    if #where_queries > 0 then
        wherequery_string = " WHERE "..table.concat(where_queries, " AND ")
    end
    if not columns or type(columns) ~= "table" or #columns == 0 then
        return db_retrieve_query_result(dbPrepareString(data.connection, "SELECT * FROM `??` "..wherequery_string..";", name), func, ...)
    end
    local select_columns = {}
    for i, name in ipairs(columns) do
        table.insert(select_columns, dbPrepareString(data.connection, "`??`", name))
    end
    local query_string = dbPrepareString(data.connection, "SELECT "..table.concat(select_columns, ",").." FROM `??` "..wherequery_string..";", name)
    return db_retrieve_query_result(query_string, func, ...)
end

-- // Удалить значение
function db_delete_value(name, field, func, ...)
    local where_queries = {}
    if not field then field = {} end
    for column, value in pairs(field) do
        table.insert(where_queries, dbPrepareString(data.connection, "`??`=?", column, value))
    end
    local wherequery_string = ""
    if #where_queries > 0 then
        wherequery_string = " WHERE "..table.concat(where_queries, " AND ")
    end
    local query_string = dbPrepareString(data.connection, "DELETE FROM `??` "..wherequery_string..";", name)
    return db_retrieve_query_result(query_string, func, ...)
end

-- // Максимальный ID
function db_max_table_id(name, func, ...)
    local query_string = dbPrepareString(data.connection, "SELECT id FROM `??` ORDER BY id DESC LIMIT 0,1;", name)
    return db_retrieve_query_result(query_string, func, ...)
end

-- // Получение результатов запроса
-- // В первом случае - асинхронно
function db_retrieve_query_result(query, func, ...)
    if type(func) == "function" then
        return not not dbQuery(function(query, args)
            local result = dbPoll(query, 0)
            if type(args) ~= "table" then args = {} end
            db_execute_callback(func, result, unpack(args))
        end, {...}, data.connection, query)
    else
        local handle = dbQuery(data.connection, query)
        return dbPoll(handle, -1)
    end
end

-- // Выполнить обратный вызов
function db_execute_callback(func, ...)
    if type(func) ~= "function" then return false end
    local success, fail = pcall(func, ...)
    if not success then
        local fail = tostring(fail)
        print("[crud][func][failed] - ["..fail.."]")
        return false
    end
    return true
end
