local SCREEN_X = 0.6
local SCREEN_Y = 0.77
local DEPTH = 3.5
local FACE_SCREEN_Y = 1.9
local FACE_DEPTH = 2.0
local SMOOTHING = 5
local MOTION_NONE = joaat('MotionState_None')

local NOT_PREVIEWABLE = { Emojis = true, Exits = true }

local ped
local shown
local closeUp = false
local token = 0

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

---Mostra o clone do personagem ao lado do menu fazendo o emote.
---@param name? string
function ShowPreview(name)
    local entry = name and CatalogEntries[name]
    if not entry or NOT_PREVIEWABLE[entry.emoteType] or not IsEmoteCompatible(name) then return HidePreview() end
    if name == shown and ped and DoesEntityExist(ped) then return end

    shown = name
    token = token + 1
    local my = token
    local function current() return my == token and ped ~= nil and DoesEntityExist(ped) end

    CreateThread(function()
        if not ped or not DoesEntityExist(ped) then spawn() end
        if not current() then return end
        closeUp = entry.emoteType == 'Expressions'
        AnimateOnPed(ped, entry, nil, current)
    end)
end

---Remove o clone de preview e os objetos dele.
function HidePreview()
    token = token + 1
    shown = nil
    if ped then
        ClearPedProps(ped)
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    ped = nil
end
