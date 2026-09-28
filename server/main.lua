AddConvarChangeListener('mri:color', function(name)
    if name ~= 'mri:color' then return end
    TriggerClientEvent('mri_Qemotes:client:accentColorChanged', -1, GetConvar('mri:color', '#00E699'))
end)

AddConvarChangeListener('mri:backgroundColor', function(name)
    if name ~= 'mri:backgroundColor' then return end
    TriggerClientEvent('mri_Qemotes:client:backgroundColorChanged', -1, GetConvar('mri:backgroundColor', ''))
end)
