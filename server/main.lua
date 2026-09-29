local ENGINE = 'rpemotes-reborn'
local extraEmotes = lib.load('data.emotes')

local function registerEmotes()
    exports[ENGINE]:AddEmotes(extraEmotes)
end

if GetResourceState(ENGINE) == 'started' then registerEmotes() end

AddEventHandler('onResourceStart', function(resource)
    if resource == ENGINE then registerEmotes() end
end)

AddConvarChangeListener('mri:color', function(name)
    if name ~= 'mri:color' then return end
    local color = GetConvar('mri:color', '#00E699')
    if not color:match('^#%x%x%x%x%x%x$') then return end
    TriggerClientEvent('mri_Qemotes:client:accentColorChanged', -1, color)
end)

AddConvarChangeListener('mri:backgroundColor', function(name)
    if name ~= 'mri:backgroundColor' then return end
    local color = GetConvar('mri:backgroundColor', '')
    if color ~= '' and not color:match('^#%x%x%x%x%x%x$') then return end
    TriggerClientEvent('mri_Qemotes:client:backgroundColorChanged', -1, color)
end)
