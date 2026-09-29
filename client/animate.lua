local LOAD_TIMEOUT = 3000
local DEFAULT_BONE = 60309

---@type table<integer, integer[]>
local pedProps = {}

---Remove os objetos presos a um ped por AnimateOnPed.
---@param ped integer
function ClearPedProps(ped)
    local list = pedProps[ped]
    if not list then return end
    for i = 1, #list do
        if DoesEntityExist(list[i]) then DeleteEntity(list[i]) end
    end
    pedProps[ped] = nil
end

---Remove os objetos de todos os peds animados por AnimateOnPed.
function ClearAllPedProps()
    for ped in pairs(pedProps) do ClearPedProps(ped) end
end

---@param ped integer
---@param model string|integer
---@param bone? integer
---@param placement? number[]
---@param variation? integer
---@param guard? fun(): boolean
local function attachProp(ped, model, bone, placement, variation, guard)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelValid(hash) then return end
    if not pcall(lib.requestModel, hash, LOAD_TIMEOUT) then return end
    if (guard and not guard()) or not DoesEntityExist(ped) then return end

    local coords = GetEntityCoords(ped)
    local object = CreateObject(hash, coords.x, coords.y, coords.z + 0.2, false, false, false)
    local p = placement or {}

    if variation then SetObjectTextureVariation(object, variation) end
    SetEntityCollision(object, false, false)
    SetEntityAlpha(object, GetEntityAlpha(ped), false)
    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, bone or DEFAULT_BONE),
        p[1] or 0.0, p[2] or 0.0, p[3] or 0.0, p[4] or 0.0, p[5] or 0.0, p[6] or 0.0,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(hash)

    pedProps[ped] = pedProps[ped] or {}
    table.insert(pedProps[ped], object)
end

---Para o que um ped animado por AnimateOnPed estiver fazendo.
---@param ped integer
function StopAnimationOnPed(ped)
    ClearPedProps(ped)
    if not DoesEntityExist(ped) then return end
    ClearPedTasks(ped)
    ClearFacialIdleAnimOverride(ped)
end

---Toca uma entrada do catalogo do rpemotes num ped que nao e o jogador.
---@param ped integer
---@param entry table
---@param variation? integer
---@param guard? fun(): boolean
---@return boolean
function AnimateOnPed(ped, entry, variation, guard)
    if not DoesEntityExist(ped) then return false end

    ClearPedProps(ped)
    ClearPedTasksImmediately(ped)
    ClearFacialIdleAnimOverride(ped)

    if entry.emoteType == 'Expressions' then
        if entry.anim then SetFacialIdleAnimOverride(ped, entry.anim, 0) end
        return true
    end

    if entry.scenario then
        TaskStartScenarioInPlace(ped, entry.scenario, 0, false)
        return true
    end

    local dict, anim = entry.dict, entry.anim
    if entry.emoteType == 'Walks' then dict, anim = entry.anim, 'walk' end
    if not dict or not anim then return false end
    if not pcall(lib.requestAnimDict, dict, LOAD_TIMEOUT) then return false end
    if (guard and not guard()) or not DoesEntityExist(ped) then return false end

    local opts = entry.AnimationOptions or {}
    local flag = (math.tointeger(opts.Flag or opts.onFootFlag) or 0) | 1

    TaskPlayAnim(ped, dict, anim, 5.0, 5.0, -1, flag, 0, false, false, false)
    RemoveAnimDict(dict)

    if opts.Prop then
        attachProp(ped, opts.Prop, opts.PropBone, opts.PropPlacement, variation, guard)
        if opts.SecondProp then
            attachProp(ped, opts.SecondProp, opts.SecondPropBone, opts.SecondPropPlacement, variation, guard)
        end
    end

    return true
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then ClearAllPedProps() end
end)
