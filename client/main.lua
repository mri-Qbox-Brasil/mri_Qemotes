local ENGINE = 'rpemotes-reborn'
local KVP_FAVORITES = 'mri_qemotes:favorites'
local KVP_RECENT = 'mri_qemotes:recent'
local MAX_FAVORITES = 200
local MAX_RECENT = 24

local isOpen = false
local catalogSent = false
local currentMood

local accentColor = GetConvar('mri:color', '#00E699')
local backgroundColor = GetConvar('mri:backgroundColor', '')
local oxLibUiConfig

CreateThread(function()
    if GetResourceState('ox_lib') ~= 'started' then return end
    local ok, cfg = pcall(lib.callback.await, 'ox_lib:getUiConfig', false)
    if ok then oxLibUiConfig = cfg end
end)

---@param key string
---@return string[]
local function readList(key)
    local raw = GetResourceKvpString(key)
    local ok, list = pcall(json.decode, raw or '[]')
    return (ok and type(list) == 'table') and list or {}
end

---@param key string
---@param list string[]
local function writeList(key, list)
    SetResourceKvp(key, json.encode(list))
end

---@param value any
---@param max integer
---@return string[]
local function sanitizeNames(value, max)
    local out, seen = {}, {}
    if type(value) ~= 'table' then return out end

    for _, name in ipairs(value) do
        if type(name) == 'string' and CatalogCategory[name] and not seen[name] then
            seen[name] = true
            out[#out + 1] = name
            if #out >= max then break end
        end
    end

    return out
end

---@param name string
local function pushRecent(name)
    local recent = readList(KVP_RECENT)
    local out = { name }

    for _, other in ipairs(recent) do
        if other ~= name then out[#out + 1] = other end
        if #out >= MAX_RECENT then break end
    end

    writeList(KVP_RECENT, out)
    return out
end

local function buildPayload()
    local payload = {
        locale = GetConvar('ox:locale', 'pt-br'),
        favorites = readList(KVP_FAVORITES),
        recent = readList(KVP_RECENT),
        walk = exports[ENGINE]:getWalkstyle(),
        mood = currentMood,
        current = exports[ENGINE]:IsPlayerInAnim(),
        accentColor = accentColor,
        backgroundColor = backgroundColor,
        uiConfig = oxLibUiConfig,
    }

    if not catalogSent then
        payload.catalog = CatalogIndex
        catalogSent = true
    end

    return payload
end

local BLOCKED_CONTROLS = {
    1, 2, 14, 15, 16, 17, 24, 25, 37, 44, 0, 140, 141, 142, 143, 172, 173, 174, 175,
    18, 176, 191, 199, 200, 201, 241, 242, 245, 257, 263, 322,
    10, 11, 23, 177, 194, 202, 212, 213,
}

local isTyping = false

local function blockControlsWhileOpen()
    CreateThread(function()
        while isOpen do
            if isTyping then
                DisableAllControlActions(0)
            else
                for i = 1, #BLOCKED_CONTROLS do
                    DisableControlAction(0, BLOCKED_CONTROLS[i], true)
                end
                DisablePlayerFiring(PlayerId(), true)
            end
            Wait(0)
        end
    end)
end

---@param typing boolean
local function setTyping(typing)
    isTyping = typing
    SetNuiFocusKeepInput(not typing)
end

local CLOSE_GUARD_CONTROLS = { 177, 194, 199, 200, 202, 322 }
local CLOSE_GUARD_MS = 500

local function guardCloseKeys()
    CreateThread(function()
        local deadline = GetGameTimer() + CLOSE_GUARD_MS
        while GetGameTimer() < deadline or IsDisabledControlPressed(0, 200) or IsDisabledControlPressed(0, 177) do
            for i = 1, #CLOSE_GUARD_CONTROLS do
                DisableControlAction(0, CLOSE_GUARD_CONTROLS[i], true)
            end
            Wait(0)
        end
    end)
end

local function closeMenu()
    if not isOpen then return end
    guardCloseKeys()
    isOpen = false
    isTyping = false
    SetNuiFocusKeepInput(false)
    SetNuiFocus(false, false)
    HidePreview()
    SendNUIMessage({ action = 'setVisible', visible = false })
end

local function openMenu()
    if isOpen then return end

    if not AwaitCatalog() then
        lib.notify({ description = locale('catalog_loading'), type = 'error' })
        return
    end

    isOpen = true
    SetNuiFocus(true, true)
    setTyping(false)
    blockControlsWhileOpen()
    SendNUIMessage({ action = 'setVisible', visible = true, data = buildPayload() })
end

local function toggleMenu()
    if isOpen then closeMenu() else openMenu() end
end

RegisterCommand('mriemotes', toggleMenu, false)
RegisterCommand('em', toggleMenu, false)
RegisterKeyMapping('mriemotes', locale('keybind_menu'), 'keyboard', 'F4')

RegisterNUICallback('close', function(_, cb)
    closeMenu()
    cb(true)
end)

RegisterNUICallback('play', function(data, cb)
    if type(data) ~= 'table' or type(data.name) ~= 'string' then return cb(false) end

    local category = CatalogCategory[data.name]
    if not category then return cb(false) end

    local variation = tonumber(data.variation)
    local ok = exports[ENGINE]:Execute(data.name, category, variation)

    if ok and category == 'Expressions' then
        currentMood = data.name
    end

    cb({ ok = ok and true or false, recent = ok and pushRecent(data.name) or nil })
end)

RegisterNUICallback('cancel', function(_, cb)
    exports[ENGINE]:EmoteCancel()
    cb(true)
end)

RegisterNUICallback('resetWalk', function(_, cb)
    ExecuteCommand('walk reset')
    cb(true)
end)

RegisterNUICallback('resetMood', function(_, cb)
    ExecuteCommand('mood reset')
    currentMood = nil
    cb(true)
end)

RegisterNUICallback('setFavorites', function(data, cb)
    local list = sanitizeNames(type(data) == 'table' and data.favorites, MAX_FAVORITES)
    writeList(KVP_FAVORITES, list)
    cb(list)
end)

RegisterNUICallback('typing', function(data, cb)
    if isOpen then setTyping(type(data) == 'table' and data.typing == true) end
    cb(true)
end)

RegisterNUICallback('camera', function(data, cb)
    if isOpen and type(data) == 'table' then
        RotateGameplayCamera(tonumber(data.dx) or 0, tonumber(data.dy) or 0)
    end
    cb(true)
end)

RegisterNUICallback('preview', function(data, cb)
    if isOpen then ShowPreview(type(data) == 'table' and data.name or nil) end
    cb(true)
end)

RegisterNUICallback('getState', function(_, cb)
    cb({
        walk = exports[ENGINE]:getWalkstyle(),
        mood = currentMood,
        current = exports[ENGINE]:IsPlayerInAnim(),
    })
end)

RegisterNetEvent('mri_Qemotes:client:accentColorChanged', function(color)
    if type(color) ~= 'string' then return end
    accentColor = color
    SendNUIMessage({ action = 'updateAccentColor', accentColor = color })
end)

RegisterNetEvent('mri_Qemotes:client:backgroundColorChanged', function(color)
    backgroundColor = type(color) == 'string' and color or ''
    SendNUIMessage({ action = 'updateBackgroundColor', backgroundColor = backgroundColor })
end)

RegisterNetEvent('ox_lib:uiConfigChanged', function(cfg)
    oxLibUiConfig = cfg
    SendNUIMessage({ action = 'updateUiConfig', uiConfig = cfg })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and isOpen then
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
    end
    if resource == GetCurrentResourceName() then HidePreview() end
end)

exports('openMenu', openMenu)
exports('closeMenu', closeMenu)
exports('toggleMenu', toggleMenu)
