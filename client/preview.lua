local SCREEN_X = 0.6
local SCREEN_Y = 0.77
local DEPTH = 3.5
local FACE_SCREEN_Y = 1.9
local FACE_DEPTH = 2.0
local SMOOTHING = 5
local LOAD_TIMEOUT = 3000
local DEFAULT_BONE = 60309
local MOTION_NONE = joaat('MotionState_None')

local NOT_PREVIEWABLE = { Emojis = true, Exits = true }

local ped
local props = {}
local shown
local closeUp = false
local token = 0

local function clearProps()
    for i = 1, #props do
        if DoesEntityExist(props[i]) then DeleteEntity(props[i]) end
    end
    props = {}
end

---@param clone integer
local function follow(clone)
    local buffer = {}

    while ped == clone and DoesEntityExist(clone) do
        local world, normal = GetWorldCoordFromScreenCoord(SCREEN_X, closeUp and FACE_SCREEN_Y or SCREEN_Y)
        buffer[#buffer + 1] = world + normal * (closeUp and FACE_DEPTH or DEPTH)
        if #buffer > SMOOTHING then table.remove(buffer, 1) end

        local sum = vector3(0.0, 0.0, 0.0)
        for i = 1, #buffer do sum = sum + buffer[i] end
        local pos = sum / #buffer
        local zOffset = IsPedHuman(clone) and 0.0 or (closeUp and 0.85 or 0.5)
        local rot = GetGameplayCamRot(2)

        SetEntityCoords(clone, pos.x, pos.y, pos.z + zOffset, false, false, false, false)
        SetEntityRotation(clone, -rot.x, 0.0, rot.z + 170.0, 2, false)
        ForcePedMotionState(clone, MOTION_NONE, false, 1, true)
        Wait(0)
    end
end

local function spawn()
    local player = PlayerPedId()
    local coords = GetEntityCoords(player)
    local clone = CreatePed(26, GetEntityModel(player), coords.x, coords.y, coords.z - 10.0, 0.0, false, false)

    ClonePedToTarget(player, clone)
    SetEntityInvincible(clone, true)
    SetEntityLocallyVisible(clone)
    NetworkSetEntityInvisibleToNetwork(clone, true)
    SetEntityCanBeDamaged(clone, false)
    SetBlockingOfNonTemporaryEvents(clone, true)
    SetEntityAlpha(clone, 254, false)
    SetEntityCollision(clone, false, false)
    SetPedCanBeTargetted(clone, false)

    ped = clone
    CreateThread(function() follow(clone) end)
end

---@param my integer
---@return boolean
local function isCurrent(my)
    return my == token and ped ~= nil and DoesEntityExist(ped)
end

---@param model string|integer
---@param bone? integer
---@param placement? number[]
---@param my integer
local function attachProp(model, bone, placement, my)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelValid(hash) then return end
    if not pcall(lib.requestModel, hash, LOAD_TIMEOUT) or not isCurrent(my) then return end

    local coords = GetEntityCoords(ped)
    local object = CreateObject(hash, coords.x, coords.y, coords.z + 0.2, false, false, false)
    local p = placement or {}

    SetEntityCollision(object, false, false)
    SetEntityAlpha(object, 254, false)
    AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, bone or DEFAULT_BONE),
        p[1] or 0.0, p[2] or 0.0, p[3] or 0.0, p[4] or 0.0, p[5] or 0.0, p[6] or 0.0,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(hash)
    props[#props + 1] = object
end

---@param entry table
---@param my integer
local function play(entry, my)
    closeUp = entry.emoteType == 'Expressions'
    clearProps()
    ClearPedTasksImmediately(ped)
    ClearFacialIdleAnimOverride(ped)

    if entry.emoteType == 'Expressions' then
        if entry.anim then SetFacialIdleAnimOverride(ped, entry.anim, 0) end
        return
    end

    if entry.scenario then
        TaskStartScenarioInPlace(ped, entry.scenario, 0, false)
        return
    end

    local dict, anim = entry.dict, entry.anim
    if entry.emoteType == 'Walks' then dict, anim = entry.anim, 'walk' end
    if not dict or not anim then return end
    if not pcall(lib.requestAnimDict, dict, LOAD_TIMEOUT) or not isCurrent(my) then return end

    local opts = entry.AnimationOptions or {}
    local flag = (math.tointeger(opts.Flag or opts.onFootFlag) or 0) | 1

    TaskPlayAnim(ped, dict, anim, 5.0, 5.0, -1, flag, 0, false, false, false)
    RemoveAnimDict(dict)

    if opts.Prop then
        attachProp(opts.Prop, opts.PropBone, opts.PropPlacement, my)
        if opts.SecondProp then
            attachProp(opts.SecondProp, opts.SecondPropBone, opts.SecondPropPlacement, my)
        end
    end
end

---Mostra o clone do personagem ao lado do menu fazendo o emote.
---@param name? string
function ShowPreview(name)
    local entry = name and CatalogEntries[name]
    if not entry or NOT_PREVIEWABLE[entry.emoteType] then return HidePreview() end
    if name == shown and ped and DoesEntityExist(ped) then return end

    shown = name
    token = token + 1
    local my = token

    CreateThread(function()
        if not ped or not DoesEntityExist(ped) then spawn() end
        if isCurrent(my) then play(entry, my) end
    end)
end

---Remove o clone de preview e os objetos dele.
function HidePreview()
    token = token + 1
    shown = nil
    clearProps()
    if ped and DoesEntityExist(ped) then DeleteEntity(ped) end
    ped = nil
end
