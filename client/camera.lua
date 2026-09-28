local ROTATE_SPEED = 0.35
local PITCH_SPEED = 0.2

---Gira a camera do jogo a partir do arraste do mouse na NUI.
---@param dx number
---@param dy number
function RotateGameplayCamera(dx, dy)
    SetGameplayCamRelativeHeading(GetGameplayCamRelativeHeading() - dx * ROTATE_SPEED)
    SetGameplayCamRelativePitch(GetGameplayCamRelativePitch() - dy * PITCH_SPEED, 1.0)
end
