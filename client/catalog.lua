---@diagnostic disable: lowercase-global

local ENGINE = 'rpemotes-reborn'

---@type table[]?
CatalogIndex = nil

---@type table<string, string>
CatalogCategory = {}

---@type table<string, table>
CatalogEntries = {}

---@param entry table
---@return table
local function toIndexEntry(entry)
    local opts = entry.AnimationOptions
    local variations

    if opts and opts.PropTextureVariations then
        variations = {}
        for i, variation in ipairs(opts.PropTextureVariations) do
            variations[i] = variation.Name or tostring(i)
        end
    end

    return {
        name = entry.name,
        label = entry.label or entry.name,
        category = entry.emoteType,
        prop = (opts and opts.Prop) and true or nil,
        variations = variations,
        shared = (entry.emoteType == 'Shared') or nil,
        adult = entry.AdultAnimation and true or nil,
        emoji = entry.emoji,
    }
end

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

    local index = {}
    for i = 1, #entries do
        CatalogEntries[entries[i].name] = entries[i]
        local item = toIndexEntry(entries[i])
        index[#index + 1] = item
        CatalogCategory[item.name] = item.category
    end

    table.sort(index, function(a, b)
        return tostring(a.label):lower() < tostring(b.label):lower()
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
