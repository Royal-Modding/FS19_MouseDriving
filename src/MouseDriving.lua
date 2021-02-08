--- ${title}

---@author ${author}
---@version r_version_r
---@date 04/02/2021

MouseDriving = {}
MouseDriving.MOD_NAME = g_currentModName
MouseDriving.THROTTLE_BASE_DEADZONE = 0.06
MouseDriving.THROTTLE_BASE_SENSITIVITY = 0.02
MouseDriving.THROTTLE_DEADZONE = 0
MouseDriving.THROTTLE_SENSITIVITY = 0
MouseDriving.STEER_BASE_DEADZONE = 0.05
MouseDriving.STEER_BASE_SENSITIVITY = 0.013
MouseDriving.STEER_DEADZONE = 0
MouseDriving.STEER_SENSITIVITY = 0
MouseDriving.SHOW_HUD = true

function MouseDriving.initSpecialization()
    MouseDriving.hud = AxisHud:new()
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
    SpecializationUtil.registerEventListener(vehicleType, "onDraw", MouseDriving)
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
end

function MouseDriving:onDelete()
end

function MouseDriving:onUpdate(dt, _, _, _)
    if self:getIsEntered() then
        local spec = self.spec_mouseDriving

        if spec.enabled and not g_inputBinding:getShowMouseCursor() then
            -- compute "real" axes
            spec.realSteerAxis = Utility.clamp(-1 - MouseDriving.STEER_DEADZONE, spec.realSteerAxis + (MouseDrivingMain.axes.x * MouseDriving.STEER_SENSITIVITY), 1 + MouseDriving.STEER_DEADZONE)
            spec.realThrottleAxis = Utility.clamp(-1 - MouseDriving.THROTTLE_DEADZONE, spec.realThrottleAxis + (MouseDrivingMain.axes.y * MouseDriving.THROTTLE_SENSITIVITY), 1 + MouseDriving.THROTTLE_DEADZONE)

            -- compute "computed" axes (apply deadzone)
            if spec.realSteerAxis <= -MouseDriving.STEER_DEADZONE then
                spec.computedSteerAxis = spec.realSteerAxis + MouseDriving.STEER_DEADZONE
            elseif spec.realSteerAxis >= MouseDriving.STEER_DEADZONE then
                spec.computedSteerAxis = spec.realSteerAxis - MouseDriving.STEER_DEADZONE
            else
                spec.computedSteerAxis = 0
            end

            if spec.realThrottleAxis <= -MouseDriving.THROTTLE_DEADZONE then
                spec.computedThrottleAxis = spec.realThrottleAxis + MouseDriving.THROTTLE_DEADZONE
            elseif spec.realThrottleAxis >= MouseDriving.THROTTLE_DEADZONE then
                spec.computedThrottleAxis = spec.realThrottleAxis - MouseDriving.THROTTLE_DEADZONE
            else
                spec.computedThrottleAxis = 0
            end

            -- call input events
            if spec.computedThrottleAxis > 0 then
                Drivable.actionEventAccelerate(self, nil, spec.computedThrottleAxis, nil, nil)
            end

            if spec.computedThrottleAxis < 0 then
                Drivable.actionEventBrake(self, nil, math.abs(spec.computedThrottleAxis), nil, nil)
            end

            Drivable.actionEventSteer(self, nil, spec.computedSteerAxis, nil, true, nil, InputDevice.CATEGORY.GAMEPAD)

            -- update hud
            if MouseDriving.SHOW_HUD then
                MouseDriving.hud:setAxisData(spec.computedSteerAxis, spec.computedThrottleAxis)
                MouseDriving.hud:update(dt)
            end
        end
    end
end

function MouseDriving:onDraw()
    local spec = self.spec_mouseDriving
    if self:getIsEntered() and spec.enabled and MouseDriving.SHOW_HUD then
        MouseDriving.hud:render()
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
