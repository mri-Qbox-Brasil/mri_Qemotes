---@diagnostic disable: lowercase-global

local ENGINE = 'rpemotes-reborn'

---@type table[]?
CatalogIndex = nil

---@type table<string, string>
CatalogCategory = {}

---@type table<string, table>
CatalogEntries = {}

---@type table<string, string>
local byLower = {}

---@type table<string, string>
local byAlias = {}

---@return table<string, { label: string, alias?: string, aliases?: string[] }>
local function loadTranslations()
    local locale = GetConvar('ox:locale', 'pt-br')
    local raw = LoadResourceFile(GetCurrentResourceName(), ('locales/emotes.%s.json'):format(locale))
    if not raw then return {} end
    local ok, data = pcall(json.decode, raw)
    return (ok and type(data) == 'table') and data or {}
end

---@param entry table
---@param translation? { label: string, alias?: string, aliases?: string[] }
---@return table
local function toIndexEntry(entry, translation)
    local opts = entry.AnimationOptions
    local variations

    if opts and opts.PropTextureVariations then
        variations = {}
        for i, variation in ipairs(opts.PropTextureVariations) do
            variations[i] = variation.Name or tostring(i)
        end
    end

    local label = translation and translation.label or entry.label or entry.name
    local original = entry.label or entry.name

    return {
        name = entry.name,
        label = label,
        original = original ~= label and original or nil,
        alias = translation and translation.alias or nil,
        aliases = translation and translation.aliases or nil,
        category = entry.emoteType,
        prop = (opts and opts.Prop) and true or nil,
        variations = variations,
        shared = (entry.emoteType == 'Shared') or nil,
        adult = entry.AdultAnimation and true or nil,
        emoji = entry.emoji,
    }
end

local extraEmotes = lib.load('data.emotes')

local function registerEmotes()
    exports[ENGINE]:AddEmotes(extraEmotes)
end

if GetResourceState(ENGINE) == 'started' then registerEmotes() end

AddEventHandler('onClientResourceStart', function(resource)
    if resource == ENGINE then registerEmotes() end
end)

CreateThread(function()
    while GetResourceState(ENGINE) ~= 'started' do
        Wait(500)
    end

    local entries
    for _ = 1, 600 do
        entries = exports[ENGINE]:GetEmoteCatalog()
        if entries then break end
        Wait(100)
    end

    if not entries then
        lib.print.error(('catalogo do %s nao ficou pronto em 60s'):format(ENGINE))
        return
    end

    local translations = loadTranslations()
    local aliases = {}
    for name, translation in pairs(translations) do
        for _, alias in ipairs(translation.aliases or { translation.alias }) do
            aliases[alias:lower()] = name
        end
    end

    local index = {}
    for i = 1, #entries do
        local entry = entries[i]
        local lower = entry.name:lower()
        if not aliases[lower] then
            local item = toIndexEntry(entry, translations[entry.name])
            index[#index + 1] = item
            CatalogEntries[item.name] = entry
            CatalogCategory[item.name] = item.category
            byLower[lower] = item.name
            for _, alias in ipairs(item.aliases or { item.alias }) do
                byAlias[alias:lower()] = item.name
            end
        end
    end

    local sortKey = {}
    for i = 1, #index do
        local item = index[i]
        sortKey[item.name] = tostring(item.label):lower():gsub('%d+', function(n) return ('%012d'):format(tonumber(n)) end)
    end

    table.sort(index, function(a, b)
        return sortKey[a.name] < sortKey[b.name]
    end)

    CatalogIndex = index
end)

---Espera o catalogo do rpemotes ficar pronto.
---@param timeout? number
---@return boolean
function AwaitCatalog(timeout)
    local deadline = GetGameTimer() + (timeout or 5000)
    while not CatalogIndex and GetGameTimer() < deadline do
        Wait(50)
    end
    return CatalogIndex ~= nil
end

---Nome do emote no rpemotes a partir do nome, do apelido traduzido ou de qualquer caixa.
---@param command any
---@return string?
function ResolveEmoteName(command)
    if type(command) ~= 'string' or command == '' then return nil end
    if CatalogCategory[command] then return command end
    local lower = command:lower()
    return byLower[lower] or byAlias[lower]
end
