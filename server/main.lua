
local data =
{
    result =
    {
    },
    value =
    {
        all = 0,
        item = 100,
        all_page = 0,
    },
}

-- // Создать таблицы
function func_db_create_table()
    local value =
    {
        {name = "id", type = "int", options = "NOT NULL PRIMARY KEY AUTO_INCREMENT"},
        {name = "name", type = "varchar", size = 25, options = "NOT NULL"},
        {name = "surname", type = "varchar", size = 25, options = "NOT NULL"},
        {name = "residence", type = "varchar", size = 25, options = "NOT NULL"},
    }
    db_create_table("user", value)
end

-- // Запись данных
function func_get_all_data()
    db_select_table("user", {}, {}, function(result)
        if not result then return end
        if #result == 0 then return end
        for index, value in pairs(result) do
            data.result[index] =
            {
                id = value.id,
                name = value.name,
                surname = value.surname,
                residence = value.residence,
            }
        end
        data.value.all_page = math.floor(#result / data.value.item)
        data.value.all = #result
    end)
end

-- // Поиск данных
addEvent("crud_get_search_data", true)
function func_get_search_data(player, search)
    local search_table = {}
    local search = string.lower(search)
    for index, value in pairs(data.result) do
        for _, value in pairs(value) do
            local value = string.lower(value)
            if value:find(search) then
                table.insert(search_table, data.result[index])
                break
            end
        end
    end
    triggerClientEvent(player, "crud_player_result_page", player, search_table)
end
addEventHandler("crud_get_search_data", root, func_get_search_data)

-- // Загрузка страницы
addEvent("crud_set_page_data", true)
function func_get_page_data(player, page)
    local page_table = {}
    data.value.all_page = math.floor(#data.result / data.value.item)
    if page > data.value.all_page then
        page = data.value.all_page
    end
    for i = 1, data.value.item do
        local item = page * data.value.item + (i - 1)
        if data.result[item] then
            table.insert(page_table, data.result[item])
        end
    end
    triggerClientEvent(player, "crud_player_result_page", player, page_table)
    triggerClientEvent(player, "crud_player_info_page", player, page, data.value.all_page)
end
addEventHandler("crud_set_page_data", root, func_get_page_data)

-- // Удаление строки
addEvent("crud_delete_row_data", true)
function func_delete_row_data(player, page, id)
    db_delete_value("user", {id = id}, function(result, player, page, id)
        for index, value in pairs(data.result) do
            if value.id == id then
                table.remove(data.result, index)
                break
            end
        end
        func_get_page_data(player, page)
    end, {player, page, id})
end
addEventHandler("crud_delete_row_data", root, func_delete_row_data)

-- // Редактировать строки
addEvent("crud_edit_row_data", true)
function func_edit_row_data(player, page, id, row)
    db_update_table("user", row, {id = id}, function(result, player, page, id, row)
        for index, value in pairs(data.result) do
            if value.id == id then
                row.id = id
                data.result[index] = row
                break
            end
        end
        func_get_page_data(player, page)
    end, {player, page, id, row})
end
addEventHandler("crud_edit_row_data", root, func_edit_row_data)

-- // Добавить строки
addEvent("crud_add_row_data", true)
function func_add_row_data(player, page, id, row)
    db_insert_value("user", row, function(result, player, page, id, row)
        row.id = data.result[#data.result].id + 1
        data.result[#data.result + 1] = row
        func_get_page_data(player, page)
    end, {player, page, id, row})
end
addEventHandler("crud_add_row_data", root, func_add_row_data)

-- // Подключение к базе данных
addEventHandler("onResourceStart", getResourceRootElement(), function()
    setTimer(function()
        if db_get_connect() then
            killTimer(sourceTimer)
            func_db_create_table()
            func_get_all_data()
        end
    end, 100, 0)
end)

-- function func_create_row_data()
--     for index = 1, 10000 do
--         local data =
--         {
--             name = index,
--             surname = index,
--             residence = index,
--         }
--         db_insert_value("user", data, function() end)
--     end
-- end

