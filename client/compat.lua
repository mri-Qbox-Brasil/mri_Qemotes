local ENGINE = 'rpemotes-reborn'
local SELF = GetCurrentResourceName()
local REPLACES = { 'scully_emotemenu', 'dpemotes' }

local limited = false
local registered = {}

---Registra a funcao como export deste resource e como export do scully_emotemenu.
---@param name string
---@param fn function
local function expose(name, fn)
    exports(name, fn)
    AddEventHandler('__cfx_export_scully_emotemenu_' .. name, function(setCb) setCb(fn) end)
end

---@param name string
---@param fn function
local function scullyOnly(name, fn)
    AddEventHandler('__cfx_export_scully_emotemenu_' .. name, function(setCb) setCb(fn) end)
end

---@param command any
---@return string?
local function resolve(command)
    if not AwaitCatalog(5000) then return nil end
    local name = ResolveEmoteName(command)
    if not name then
        lib.notify({ description = ("'%s' %s"):format(tostring(command), locale('unknown_emote')), type = 'error' })
    end
    return name
end

---@param variation any
---@return integer?
local function toVariation(variation)
    local n = tonumber(variation)
    return (n and n >= 1) and math.floor(n) or nil
end

---@param command any
---@param variation? any
---@param ped? integer
---@return boolean
local function playEmoteByCommand(command, variation, ped)
    local name = resolve(command)
    if not name then return false end

    if ped and ped > 0 and ped ~= PlayerPedId() then
        local entry = CatalogEntries[name]
        CreateThread(function() AnimateOnPed(ped, entry, toVariation(variation)) end)
        return true
    end

    if limited then return false end

    local category = CatalogCategory[name]
    local ok = exports[ENGINE]:Execute(name, category, toVariation(variation)) and true or false
    if ok and category == 'Expressions' then SetCurrentMood(name) end
    return ok
end

---@param data any
---@return any
local function commandOf(data)
    if type(data) == 'table' then return data.Command or data.command or data.name end
    return data
end

---@param clipset string
local function setWalk(clipset)
    local name = ResolveEmoteName(clipset)
    if not name or CatalogCategory[name] ~= 'Walks' then
        name = nil
        for candidate, entry in pairs(CatalogEntries) do
            if entry.emoteType == 'Walks' and entry.anim == clipset then
                name = candidate
                break
            end
        end
    end

    if name then
        exports[ENGINE]:setWalkstyle(name)
        return
    end

    if type(clipset) == 'string' and pcall(lib.requestAnimSet, clipset, 3000) then
        SetPedMovementClipset(PlayerPedId(), clipset, 0.2)
        RemoveAnimSet(clipset)
    end
end

local function getCurrentWalk()
    local name = exports[ENGINE]:getWalkstyle()
    local entry = name and CatalogEntries[name]
    return entry and entry.anim or name or 'default'
end

---@param name any
local function setExpression(name)
    if not AwaitCatalog(5000) then return end
    local resolved = ResolveEmoteName(name)
    if not resolved then
        for candidate, entry in pairs(CatalogEntries) do
            if entry.emoteType == 'Expressions' and entry.anim == name then
                resolved = candidate
                break
            end
        end
    end
    if resolved and CatalogCategory[resolved] == 'Expressions' then
        if exports[ENGINE]:Execute(resolved, 'Expressions') then SetCurrentMood(resolved) end
    end
end

local function resetExpression()
    ExecuteCommand('mood reset')
    SetCurrentMood(nil)
end

local function getCurrentExpression()
    local name = GetCurrentMood()
    local entry = name and CatalogEntries[name]
    return entry and entry.anim or name or 'default'
end

---@param value any
local function setLimitation(value)
    limited = value and true or false
    LocalPlayer.state:set('canEmote', not limited, true)
end

---@param emote any
local function registerEmote(emote)
    if type(emote) ~= 'table' or type(emote.Name) ~= 'string' then return end
    registered[emote.Name] = emote
end

---@param name any
local function playRegisteredEmote(name)
    local emote = registered[name]
    if not emote then return playEmoteByCommand(name) end
    if emote.Type == 'Walks' and emote.Walk then return setWalk(emote.Walk) end
    return playEmoteByCommand(emote.Command or emote.Name, emote.Variant)
end

---Diz se outro recurso bloqueou os emotes via setLimitation.
---@return boolean
function IsEmoteLimited()
    return limited
end

expose('playEmoteByCommand', playEmoteByCommand)
expose('playEmote', function(data, variation, ped) return playEmoteByCommand(commandOf(data), variation, ped) end)
expose('cancelEmote', function() exports[ENGINE]:EmoteCancel() end)
expose('isInEmote', function() return exports[ENGINE]:IsPlayerInAnim() ~= nil end)
expose('getLastEmote', function() return exports[ENGINE]:IsPlayerInAnim() end)
expose('setLimitation', setLimitation)
expose('isLimited', function() return limited end)
expose('setWalk', setWalk)
expose('resetWalk', function() ExecuteCommand('walk reset') end)
expose('getCurrentWalk', getCurrentWalk)
expose('setExpression', setExpression)
expose('resetExpression', resetExpression)
expose('getCurrentExpression', getCurrentExpression)
expose('clearpedsObjects', ClearAllPedProps)
expose('registerEmote', registerEmote)
expose('playRegisteredEmote', playRegisteredEmote)
scullyOnly('toggleMenu', function() exports[SELF]:toggleMenu() end)
scullyOnly('closeMenu', function() exports[SELF]:closeMenu() end)
scullyOnly('openMenu', function() exports[SELF]:openMenu() end)

RegisterNetEvent('scully_emotemenu:playByCommand', function(command, variation, ped) playEmoteByCommand(command, variation, ped) end)
RegisterNetEvent('scully_emotemenu:play', function(data, variation, ped) playEmoteByCommand(commandOf(data), variation, ped) end)
RegisterNetEvent('scully_emotemenu:cancelEmote', function() exports[ENGINE]:EmoteCancel() end)
RegisterNetEvent('scully_emotemenu:cancelAnimation', function() exports[ENGINE]:EmoteCancel() end)
RegisterNetEvent('scully_emotemenu:closeMenu', function() exports[SELF]:closeMenu() end)
RegisterNetEvent('scully_emotemenu:toggleMenu', function() exports[SELF]:toggleMenu() end)
RegisterNetEvent('scully_emotemenu:setWalk', setWalk)
RegisterNetEvent('scully_emotemenu:resetWalk', function() ExecuteCommand('walk reset') end)
RegisterNetEvent('scully_emotemenu:setExpression', setExpression)
RegisterNetEvent('scully_emotemenu:resetExpression', resetExpression)
RegisterNetEvent('scully_emotemenu:toggleLimitation', setLimitation)
RegisterNetEvent('scully_emotemenu:registerEmote', registerEmote)
RegisterNetEvent('scully_emotemenu:playRegisteredEmote', playRegisteredEmote)

CreateThread(function()
    Wait(5000)
    for _, resource in ipairs(REPLACES) do
        if GetResourceState(resource) == 'started' then
            lib.print.warn(('%s esta rodando junto com o %s, que ja atende os exports dele. Pare o %s no server.cfg.')
                :format(resource, SELF, resource))
        end
    end
end)
