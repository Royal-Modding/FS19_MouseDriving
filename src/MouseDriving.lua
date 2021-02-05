--- ${title}

---@author ${author}
---@version r_version_r
---@date 04/02/2021

MouseDriving = {}
MouseDriving.MOD_NAME = g_currentModName

function MouseDriving.initSpecialization()
end

function MouseDriving.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(Drivable, specializations)
end

function MouseDriving.registerFunctions(vehicleType)
    SpecializationUtil.registerFunction(vehicleType, "toggleMouseDriving", MouseDriving.toggleMouseDriving)
end

function MouseDriving.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onPreLoad", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onUpdate", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onRegisterActionEvents", MouseDriving)
    SpecializationUtil.registerEventListener(vehicleType, "onDelete", MouseDriving)
end

function MouseDriving:onPreLoad(savegame)
    ---@type table
    self.spec_mouseDriving = self[string.format("spec_%s.mouseDriving", MouseDriving.MOD_NAME)]
    local spec = self.spec_mouseDriving
    spec.enabled = false

    spec.realSteerAxis = 0
    spec.computedSteerAxis = 0

    spec.realThrottleAxis = 0
    spec.computedThrottleAxis = 0

    spec.mouseSensitivity = 20
    spec.mouseDeadZone = 0.05
end

function MouseDriving:onDelete()
end

function MouseDriving:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
    if self:getIsEntered() then
        local spec = self.spec_mouseDriving

        local dbg = {}
        dbg.computedSteerAxis = spec.computedSteerAxis
        dbg.computedThrottleAxis = spec.computedThrottleAxis
        Utility.renderTable(0.4, 0.3, 0.02, dbg)

        if g_inputBinding.pressedMouseComboMask == 0 and spec.enabled and not g_inputBinding:getShowMouseCursor() then
            if math.abs(g_inputBinding.mouseMovementX) > 0.0005 then
                spec.realSteerAxis = Utility.clamp(-1 - spec.mouseDeadZone, spec.realSteerAxis + (g_inputBinding.mouseMovementX * spec.mouseSensitivity), 1 + spec.mouseDeadZone)
            end
            if math.abs(g_inputBinding.mouseMovementY) > 0.0005 then
                spec.realThrottleAxis = Utility.clamp(-1 - spec.mouseDeadZone, spec.realThrottleAxis + (g_inputBinding.mouseMovementY * spec.mouseSensitivity), 1 + spec.mouseDeadZone)
            end
        end

        if spec.realSteerAxis <= -spec.mouseDeadZone then
            spec.computedSteerAxis = spec.realSteerAxis + spec.mouseDeadZone
        elseif spec.realSteerAxis >= spec.mouseDeadZone then
            spec.computedSteerAxis = spec.realSteerAxis - spec.mouseDeadZone
        else
            spec.computedSteerAxis = 0
        end

        if spec.realThrottleAxis <= -spec.mouseDeadZone then
            spec.computedThrottleAxis = spec.realThrottleAxis + spec.mouseDeadZone
        elseif spec.realThrottleAxis >= spec.mouseDeadZone then
            spec.computedThrottleAxis = spec.realThrottleAxis - spec.mouseDeadZone
        else
            spec.computedThrottleAxis = 0
        end

        if not g_inputBinding:getShowMouseCursor() then
            if spec.computedThrottleAxis > 0 then
                Drivable.actionEventAccelerate(self, nil, spec.computedThrottleAxis, nil, nil)
            end

            if spec.computedThrottleAxis < 0 then
                Drivable.actionEventBrake(self, nil, math.abs(spec.computedThrottleAxis), nil, nil)
            end

            Drivable.actionEventSteer(self, nil, spec.computedSteerAxis, nil, true, nil, InputDevice.CATEGORY.GAMEPAD)
        end
    end
end

function MouseDriving:onRegisterActionEvents(isActiveForInput, isActiveForInputIgnoreSelection)
    local spec = self.spec_mouseDriving
    if self:getIsEntered() then
        self:clearActionEventsTable(spec.actionEvents)
        if self:getIsActiveForInput(true, true) then
            local _, actionEventId = self:addActionEvent(spec.actionEvents, InputAction.MD_TOGGLE, self, MouseDriving.onToggleMouseDriving, false, true, false, true, nil, nil, true)
            g_inputBinding:setActionEventTextVisibility(actionEventId, false)
        end
    end
end

function MouseDriving:toggleMouseDriving(enabled)
    local spec = self.spec_mouseDriving
    spec.enabled = enabled
    spec.realSteerAxis = 0
    spec.computedSteerAxis = 0
    spec.realThrottleAxis = 0
    spec.computedThrottleAxis = 0
end

function MouseDriving.onToggleMouseDriving(self, actionName, inputValue, callbackState, isAnalog, isMouse)
    local spec = self.spec_mouseDriving
    self:toggleMouseDriving(not spec.enabled)
end
