
local data =
{
    page =
    {
        all = 1,
        current = 0,
    },
}

loadstring(exports.dgs:dgsImportFunction())()

-- // Window - main
local window_main = dgsCreateWindow(0.3, 0.3, 0.4, 0.4, "CRUD", true)
dgsWindowSetCloseButtonEnabled(window_main, false)
dgsWindowSetSizable(window_main, false)
dgsWindowSetMovable(window_main, true)
dgsSetVisible(window_main, false)

local button_main_add = dgsCreateButton(0.025, 0.025, 0.275, 0.075, "Добавить", true, window_main)
local edit_main_search = dgsCreateEdit(0.460, 0.025, 0.510, 0.075, "", true, window_main)
local button_main_search = dgsCreateButton(0.325, 0.025, 0.125, 0.075, "Поиск", true, window_main)

local gridlist_main = dgsCreateGridList(0.025, 0.115, 0.95, 0.700, true, window_main)
dgsGridListAddColumn(gridlist_main, "ID", 0.100)
dgsGridListAddColumn(gridlist_main, "Имя", 0.200)
dgsGridListAddColumn(gridlist_main, "Фамилия", 0.200)
dgsGridListAddColumn(gridlist_main, "Адрес проживаня", 0.450)

local button_main_edit = dgsCreateButton(0.025, 0.850, 0.275, 0.075, "Редактировать", true, window_main)
local button_main_delete = dgsCreateButton(0.310, 0.850, 0.275, 0.075, "Удалить", true, window_main)
dgsSetEnabled(button_main_edit, false)
dgsSetEnabled(button_main_delete, false)

local button_main_go = dgsCreateButton(0.610, 0.850, 0.175, 0.075, "Перейти", true, window_main)
local edit_main_page = dgsCreateEdit(0.800, 0.850, 0.080, 0.075, "0", true, window_main)
local label_main_page = dgsCreateLabel(0.900, 0.870, 0.080, 0.075, "0/1", true, window_main)
dgsEditSetTextFilter(edit_main_page, "[^0-9]")

-- // Window - add
local window_add = dgsCreateWindow(0.35, 0.35, 0.3, 0.3, "Добавить", true)
dgsWindowSetCloseButtonEnabled(window_add, false)
dgsWindowSetSizable(window_add, false)
dgsWindowSetMovable(window_add, true)
dgsSetVisible(window_add, false)

local label_add_name = dgsCreateLabel(0.025, 0.050, 0.950, 0.075, "Имя", true, window_add)
local edit_add_name = dgsCreateEdit(0.025, 0.100, 0.950, 0.100, "", true, window_add)
local label_add_surname = dgsCreateLabel(0.025, 0.250, 0.950, 0.075, "Фамилия", true, window_add)
local edit_add_surname = dgsCreateEdit(0.025, 0.300, 0.950, 0.100, "", true, window_add)
local label_add_residence = dgsCreateLabel(0.025, 0.450, 0.950, 0.075, "Адрес проживаня", true, window_add)
local edit_add_residence = dgsCreateEdit(0.025, 0.500, 0.950, 0.100, "", true, window_add)

local button_add_ok = dgsCreateButton(0.025, 0.800, 0.450, 0.100, "Добавить", true, window_add)
local button_add_close = dgsCreateButton(0.525, 0.800, 0.450, 0.100, "Закрыть", true, window_add)

-- // Window - delete
local window_delete = dgsCreateWindow(0.4, 0.45, 0.2, 0.1, "Подтверждение", true)
dgsWindowSetCloseButtonEnabled(window_delete, false)
dgsWindowSetSizable(window_delete, false)
dgsWindowSetMovable(window_delete, true)
dgsSetVisible(window_delete, false)

local button_delete_ok = dgsCreateButton(0.025, 0.225, 0.450, 0.350, "Удалить", true, window_delete)
local button_delete_close = dgsCreateButton(0.525, 0.225, 0.450, 0.350, "Закрыть", true, window_delete)

-- // Window - edit
local window_edit = dgsCreateWindow(0.35, 0.35, 0.3, 0.3, "Редактировать", true)
dgsWindowSetCloseButtonEnabled(window_edit, false)
dgsWindowSetSizable(window_edit, false)
dgsWindowSetMovable(window_edit, true)
dgsSetVisible(window_edit, false)

local label_edit_name = dgsCreateLabel(0.025, 0.050, 0.950, 0.075, "Имя", true, window_edit)
local edit_edit_name = dgsCreateEdit(0.025, 0.100, 0.950, 0.100, "", true, window_edit)
local label_edit_surname = dgsCreateLabel(0.025, 0.250, 0.950, 0.075, "Фамилия", true, window_edit)
local edit_edit_surname = dgsCreateEdit(0.025, 0.300, 0.950, 0.100, "", true, window_edit)
local label_edit_residence = dgsCreateLabel(0.025, 0.450, 0.950, 0.075, "Адрес проживаня", true, window_edit)
local edit_edit_residence = dgsCreateEdit(0.025, 0.500, 0.950, 0.100, "", true, window_edit)

local button_edit_ok = dgsCreateButton(0.025, 0.800, 0.450, 0.100, "Применить", true, window_edit)
local button_edit_close = dgsCreateButton(0.525, 0.800, 0.450, 0.100, "Закрыть", true, window_edit)

-- // Подгрузка количество страниц
addEvent("crud_player_info_page", true)
function func_player_info_page(current, all)
    data.page.all = all
    data.page.current = current
    dgsSetText(edit_main_page, current)
    dgsSetText(label_main_page, current.."/"..all)
end
addEventHandler("crud_player_info_page", localPlayer, func_player_info_page)

-- // Данные при поиске
addEvent("crud_player_result_page", true)
function func_player_result_page(result)
    dgsGridListClear(gridlist_main)
    dgsSetEnabled(button_main_edit, false)
    dgsSetEnabled(button_main_delete, false)
    dgsGridListSetSelectedItem(gridlist_main, -1)
    for _, value in pairs(result) do
        local row = dgsGridListAddRow(gridlist_main)
        dgsGridListSetItemText(gridlist_main, row, 1, value.id, false, false)
        dgsGridListSetItemText(gridlist_main, row, 2, value.name, false, false)
        dgsGridListSetItemText(gridlist_main, row, 3, value.surname, false, false)
        dgsGridListSetItemText(gridlist_main, row, 4, value.residence, false, false)
    end
end
addEventHandler("crud_player_result_page", localPlayer, func_player_result_page)

-- // Обновление данных
function func_load_page_current()
    triggerServerEvent("crud_set_page_data", localPlayer, localPlayer, data.page.current)
end

-- // Управление видимостью основного окна
function func_toggle_main_window(state)
    if state ~= nil then
        if state then
            func_load_page_current()
            dgsSetVisible(window_main, true)
            showCursor(true)
        else
            dgsSetVisible(window_main, false)
            dgsSetVisible(window_edit, false)
            dgsSetVisible(window_add, false)
            showCursor(false)
        end
    else
        local state = not dgsGetVisible(window_main)
        if state then
            func_load_page_current()
            dgsSetVisible(window_main, true)
            showCursor(true)
        else
            dgsSetVisible(window_main, false)
            dgsSetVisible(window_edit, false)
            dgsSetVisible(window_add, false)
            showCursor(false)
        end
    end
end

bindKey("L", "down", function()
    func_toggle_main_window()
end)

-- // Поиск
addEventHandler("onDgsMouseClick", button_main_search, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    if source ~= button_main_search then return end
    local search = dgsGetText(edit_main_search)
    if search ~= "" then
        triggerServerEvent("crud_get_search_data", localPlayer, localPlayer, search)
    else
        triggerServerEvent("crud_set_page_data", localPlayer, localPlayer, data.page.current)
    end
end)

-- // Перейти к странице
addEventHandler("onDgsMouseClick", button_main_go, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    if source ~= button_main_go then return end
    local page = tonumber(dgsGetText(edit_main_page))
    if page ~= "" and type(page) == "number" and page <= data.page.all then
        triggerServerEvent("crud_set_page_data", localPlayer, localPlayer, page)
    end
end)

-- // Основное окно - кнопки
addEventHandler("onDgsMouseClick", root, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    if source == gridlist_main then
        local select = dgsGridListGetSelectedItem(gridlist_main)
        if (not select) or (select == -1) then
            dgsSetEnabled(button_main_edit, false)
            dgsSetEnabled(button_main_delete, false)
            return
        end
        dgsSetEnabled(button_main_edit, true)
        dgsSetEnabled(button_main_delete, true)
    elseif source == button_main_add then
        if not dgsGetVisible(window_add) then
            dgsSetVisible(window_add, true)
            dgsBringToFront(window_add)
        end
    elseif source == button_main_edit then
        if not dgsGetVisible(window_edit) then
            local select = dgsGridListGetSelectedItem(gridlist_main)
            local name = dgsGridListGetItemText(gridlist_main, select, 2)
            local surname = dgsGridListGetItemText(gridlist_main, select, 3)
            local residence = dgsGridListGetItemText(gridlist_main, select, 4)
            dgsSetText(edit_edit_name, name)
            dgsSetText(edit_edit_surname, surname)
            dgsSetText(edit_edit_residence, residence)
            dgsSetVisible(window_edit, true)
            dgsBringToFront(window_edit)
        end
    elseif source == button_main_delete then
        if not dgsGetVisible(window_delete) then
            dgsSetVisible(window_delete, true)
            dgsBringToFront(window_delete)
        end
    end
end)

-- // Окно "Добавить"
addEventHandler("onDgsMouseClick", root, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    if source == button_add_ok then
        local name = dgsGetText(edit_add_name)
        local surname = dgsGetText(edit_add_surname)
        local residence = dgsGetText(edit_add_residence)
        if name ~= "" and surname ~= "" and residence ~= "" then
            local value =
            {
                name = name,
                surname = surname,
                residence = residence,
            }
            triggerServerEvent("crud_add_row_data", localPlayer, localPlayer, data.page.current, id, value)
            dgsSetVisible(window_add, false)
            dgsBringToFront(window_main)
        end
    elseif source == button_add_close then
        dgsSetVisible(window_add, false)
        dgsBringToFront(window_main)
    end
end)

-- // Окно "Редактировать"
addEventHandler("onDgsMouseClick", root, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    if source == button_edit_ok then
        local select = dgsGridListGetSelectedItem(gridlist_main)
        local id = tonumber(dgsGridListGetItemText(gridlist_main, select, 1))
        local name = dgsGetText(edit_edit_name)
        local surname = dgsGetText(edit_edit_surname)
        local residence = dgsGetText(edit_edit_residence)
        if id and name ~= "" and surname ~= "" and residence ~= "" then
            local value =
            {
                name = name,
                surname = surname,
                residence = residence,
            }
            triggerServerEvent("crud_edit_row_data", localPlayer, localPlayer, data.page.current, id, value)
            dgsSetVisible(window_edit, false)
            dgsBringToFront(window_main)
        end
    elseif source == button_edit_close then
        dgsSetVisible(window_edit, false)
        dgsBringToFront(window_main)
    end
end)

-- // Окно "Удалить"
addEventHandler("onDgsMouseClick", root, function(button, state)
    if button ~= "left" or state ~= "down" then return end
    if source == button_delete_ok then
        local select = dgsGridListGetSelectedItem(gridlist_main)
        local id = tonumber(dgsGridListGetItemText(gridlist_main, select, 1))
        triggerServerEvent("crud_delete_row_data", localPlayer, localPlayer, data.page.current, id)
        dgsSetVisible(window_delete, false)
        dgsBringToFront(window_delete)
    elseif source == button_delete_close then
        dgsSetVisible(window_delete, false)
        dgsBringToFront(window_delete)
    end
end)
